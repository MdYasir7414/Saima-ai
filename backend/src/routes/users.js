const express = require('express');
const { authenticate } = require('../middleware/auth');
const { query } = require('../config/database');
const { cacheGet, cacheSet } = require('../config/redis');

const router = express.Router();
router.use(authenticate);

// Get current user profile
router.get('/me', async (req, res, next) => {
  try {
    const cacheKey = `user:full:${req.user.id}`;
    let userData = await cacheGet(cacheKey);

    if (!userData) {
      const result = await query(
        `SELECT u.*,
                t.overall, t.logic, t.memory, t.focus, t.strategy, t.mathematics, t.creativity, t.problem_solving, t.learning_speed,
                s.total_xp, s.level, s.current_streak, s.longest_streak, s.challenges_completed, s.challenges_attempted,
                s.battles_won, s.battles_lost, s.total_playtime_minutes, s.last_activity_date
         FROM users u
         LEFT JOIN tci_ratings t ON t.user_id = u.id
         LEFT JOIN user_stats s ON s.user_id = u.id
         WHERE u.id = $1`,
        [req.user.id]
      );

      if (result.rows.length === 0) {
        return res.status(404).json({ error: 'User not found' });
      }

      userData = result.rows[0];
      delete userData.password_hash;
      await cacheSet(cacheKey, userData, 120);
    }

    res.json(userData);
  } catch (err) {
    next(err);
  }
});

// Update profile
router.patch('/me', async (req, res, next) => {
  try {
    const { displayName, country, avatarUrl } = req.body;
    await query(
      'UPDATE users SET display_name = COALESCE($1, display_name), country = COALESCE($2, country), avatar_url = COALESCE($3, avatar_url) WHERE id = $4',
      [displayName, country, avatarUrl, req.user.id]
    );
    res.json({ message: 'Profile updated' });
  } catch (err) {
    next(err);
  }
});

// Get user by id (public profile)
router.get('/:id', async (req, res, next) => {
  try {
    const result = await query(
      `SELECT u.id, u.username, u.display_name, u.avatar_url, u.country, u.created_at,
              t.overall, t.logic, t.memory, t.mathematics, t.creativity,
              s.total_xp, s.level, s.current_streak, s.challenges_completed, s.battles_won
       FROM users u
       LEFT JOIN tci_ratings t ON t.user_id = u.id
       LEFT JOIN user_stats s ON s.user_id = u.id
       WHERE u.id = $1 AND u.is_active = true`,
      [req.params.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json(result.rows[0]);
  } catch (err) {
    next(err);
  }
});

module.exports = router;
