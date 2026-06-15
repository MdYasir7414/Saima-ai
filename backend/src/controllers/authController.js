const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const { query } = require('../config/database');
const logger = require('../config/logger');

function generateTokens(userId) {
  const accessToken = jwt.sign(
    { userId },
    process.env.JWT_SECRET,
    { expiresIn: '7d' }
  );
  const refreshToken = jwt.sign(
    { userId, type: 'refresh' },
    process.env.JWT_REFRESH_SECRET,
    { expiresIn: '30d' }
  );
  return { accessToken, refreshToken };
}

async function register(req, res, next) {
  try {
    const { username, email, password, age, ageGroup, country } = req.body;

    // Check if email already exists
    const existing = await query(
      'SELECT id FROM users WHERE email = $1 OR username = $2',
      [email.toLowerCase(), username.toLowerCase()]
    );

    if (existing.rows.length > 0) {
      return res.status(409).json({
        error: 'Email or username already taken',
      });
    }

    const passwordHash = await bcrypt.hash(password, 12);
    const userId = uuidv4();

    // Create user
    await query(
      `INSERT INTO users (id, username, email, password_hash, display_name, age, age_group, country, created_at, last_active_at)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, NOW(), NOW())`,
      [userId, username.toLowerCase(), email.toLowerCase(), passwordHash, username, age, ageGroup, country || 'Unknown']
    );

    // Initialize TCI rating
    await query(
      `INSERT INTO tci_ratings (user_id, overall, logic, memory, focus, strategy, mathematics, creativity, problem_solving, learning_speed)
       VALUES ($1, 500, 500, 500, 500, 500, 500, 500, 500, 500)`,
      [userId]
    );

    // Initialize user stats
    await query(
      `INSERT INTO user_stats (user_id, total_xp, level, current_streak, longest_streak)
       VALUES ($1, 0, 1, 0, 0)`,
      [userId]
    );

    const { accessToken, refreshToken } = generateTokens(userId);

    // Get full user
    const userResult = await query(
      `SELECT u.*, t.overall as tci_overall, s.total_xp, s.level, s.current_streak
       FROM users u
       LEFT JOIN tci_ratings t ON t.user_id = u.id
       LEFT JOIN user_stats s ON s.user_id = u.id
       WHERE u.id = $1`,
      [userId]
    );

    logger.info(`New user registered: ${username} (${userId})`);

    res.status(201).json({
      user: formatUser(userResult.rows[0]),
      accessToken,
      refreshToken,
    });
  } catch (err) {
    next(err);
  }
}

async function login(req, res, next) {
  try {
    const { email, password } = req.body;

    const result = await query(
      `SELECT u.*, t.overall as tci_overall, s.total_xp, s.level, s.current_streak
       FROM users u
       LEFT JOIN tci_ratings t ON t.user_id = u.id
       LEFT JOIN user_stats s ON s.user_id = u.id
       WHERE u.email = $1 AND u.is_active = true`,
      [email.toLowerCase()]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    const user = result.rows[0];
    const passwordValid = await bcrypt.compare(password, user.password_hash);

    if (!passwordValid) {
      return res.status(401).json({ error: 'Invalid credentials' });
    }

    // Update last active
    await query('UPDATE users SET last_active_at = NOW() WHERE id = $1', [user.id]);

    // Update streak
    await updateStreak(user.id);

    const { accessToken, refreshToken } = generateTokens(user.id);

    res.json({
      user: formatUser(user),
      accessToken,
      refreshToken,
    });
  } catch (err) {
    next(err);
  }
}

async function googleAuth(req, res, next) {
  try {
    const { googleToken, email, displayName, photoUrl, age, ageGroup } = req.body;

    // In production: verify googleToken with Google
    let user = await query(
      'SELECT * FROM users WHERE email = $1 AND is_active = true',
      [email.toLowerCase()]
    );

    let userId;
    if (user.rows.length === 0) {
      // Create new user
      userId = uuidv4();
      const username = email.split('@')[0].replace(/[^a-zA-Z0-9]/g, '') + Math.floor(Math.random() * 9999);
      await query(
        `INSERT INTO users (id, username, email, display_name, avatar_url, age, age_group, google_id, created_at, last_active_at)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, NOW(), NOW())`,
        [userId, username, email.toLowerCase(), displayName, photoUrl, age || 18, ageGroup || 'pioneer', email]
      );
      await query(
        `INSERT INTO tci_ratings (user_id, overall, logic, memory, focus, strategy, mathematics, creativity, problem_solving, learning_speed)
         VALUES ($1, 500, 500, 500, 500, 500, 500, 500, 500, 500)`,
        [userId]
      );
      await query(
        `INSERT INTO user_stats (user_id) VALUES ($1)`,
        [userId]
      );
    } else {
      userId = user.rows[0].id;
    }

    const { accessToken, refreshToken } = generateTokens(userId);
    res.json({ accessToken, refreshToken });
  } catch (err) {
    next(err);
  }
}

async function refreshToken(req, res, next) {
  try {
    const { refreshToken: token } = req.body;
    const decoded = jwt.verify(token, process.env.JWT_REFRESH_SECRET);

    if (decoded.type !== 'refresh') {
      return res.status(401).json({ error: 'Invalid refresh token' });
    }

    const { accessToken, refreshToken: newRefreshToken } = generateTokens(decoded.userId);
    res.json({ accessToken, refreshToken: newRefreshToken });
  } catch (err) {
    if (err.name === 'JsonWebTokenError' || err.name === 'TokenExpiredError') {
      return res.status(401).json({ error: 'Invalid or expired refresh token' });
    }
    next(err);
  }
}

async function updateStreak(userId) {
  const statsResult = await query(
    'SELECT current_streak, longest_streak, last_activity_date FROM user_stats WHERE user_id = $1',
    [userId]
  );

  if (statsResult.rows.length === 0) return;

  const stats = statsResult.rows[0];
  const today = new Date().toDateString();
  const lastActivity = stats.last_activity_date
    ? new Date(stats.last_activity_date).toDateString()
    : null;
  const yesterday = new Date(Date.now() - 86400000).toDateString();

  let newStreak = stats.current_streak;

  if (lastActivity === today) {
    return; // Already updated today
  } else if (lastActivity === yesterday) {
    newStreak += 1;
  } else {
    newStreak = 1;
  }

  const newLongest = Math.max(newStreak, stats.longest_streak || 0);

  await query(
    `UPDATE user_stats SET current_streak = $1, longest_streak = $2, last_activity_date = NOW()
     WHERE user_id = $3`,
    [newStreak, newLongest, userId]
  );
}

function formatUser(row) {
  return {
    id: row.id,
    username: row.username,
    email: row.email,
    display_name: row.display_name,
    avatar_url: row.avatar_url,
    age: row.age,
    age_group: row.age_group,
    country: row.country,
    tci_overall: row.tci_overall || 500,
    total_xp: row.total_xp || 0,
    level: row.level || 1,
    current_streak: row.current_streak || 0,
  };
}

module.exports = { register, login, googleAuth, refreshToken };
