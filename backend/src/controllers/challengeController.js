const { v4: uuidv4 } = require('uuid');
const { query } = require('../config/database');
const { cacheGet, cacheSet, cacheDel } = require('../config/redis');
const aiService = require('../services/aiService');
const ratingService = require('../services/ratingService');
const logger = require('../config/logger');

async function generateChallenge(req, res, next) {
  try {
    const { realmId, difficulty, type, ageGroup } = req.query;
    const userId = req.user.id;

    const cacheKey = `challenge:gen:${realmId}:${difficulty}:${type}:${ageGroup}:${Math.floor(Date.now() / 60000)}`;
    let challenge = await cacheGet(cacheKey);

    if (!challenge) {
      // Get user's TCI for difficulty calibration
      const tciResult = await query(
        'SELECT * FROM tci_ratings WHERE user_id = $1',
        [userId]
      );
      const tci = tciResult.rows[0];

      challenge = await aiService.generateChallenge({
        realmId,
        difficulty,
        type,
        ageGroup: ageGroup || req.user.age_group,
        userTci: tci,
      });

      challenge.id = uuidv4();

      // Save to DB
      await query(
        `INSERT INTO challenges (id, realm_id, type, difficulty, title, description, content, time_limit_seconds, xp_reward, tci_delta, dimension_deltas, age_group, is_ai_generated)
         VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, true)
         ON CONFLICT DO NOTHING`,
        [
          challenge.id,
          challenge.realm_id,
          challenge.type,
          challenge.difficulty,
          challenge.title,
          challenge.description,
          JSON.stringify(challenge.content),
          challenge.time_limit_seconds,
          challenge.xp_reward,
          challenge.tci_delta,
          JSON.stringify(challenge.dimension_deltas),
          challenge.age_group,
        ]
      );

      await cacheSet(cacheKey, challenge, 3600);
    }

    res.json(challenge);
  } catch (err) {
    next(err);
  }
}

async function getChallenge(req, res, next) {
  try {
    const { id } = req.params;

    const cacheKey = `challenge:${id}`;
    let challenge = await cacheGet(cacheKey);

    if (!challenge) {
      const result = await query(
        'SELECT * FROM challenges WHERE id = $1',
        [id]
      );

      if (result.rows.length === 0) {
        return res.status(404).json({ error: 'Challenge not found' });
      }

      challenge = {
        ...result.rows[0],
        content: result.rows[0].content,
        dimension_deltas: result.rows[0].dimension_deltas,
      };

      await cacheSet(cacheKey, challenge, 3600);
    }

    // Strip correct answer before sending
    const safeChallenge = { ...challenge };
    if (safeChallenge.content?.options) {
      safeChallenge.content = {
        ...safeChallenge.content,
        options: safeChallenge.content.options.map((o) => ({
          id: o.id,
          text: o.text,
        })),
        correct_answer: undefined,
      };
    }

    res.json(safeChallenge);
  } catch (err) {
    next(err);
  }
}

async function submitChallenge(req, res, next) {
  try {
    const { id } = req.params;
    const { selectedAnswer, timeSpentSeconds } = req.body;
    const userId = req.user.id;

    // Get challenge with answer
    const challengeResult = await query(
      'SELECT * FROM challenges WHERE id = $1',
      [id]
    );

    if (challengeResult.rows.length === 0) {
      return res.status(404).json({ error: 'Challenge not found' });
    }

    const challenge = challengeResult.rows[0];
    const content = challenge.content;
    const isCorrect = content.correct_answer === selectedAnswer;

    // Calculate TCI change using Elo-like algorithm
    const tciResult = await query(
      'SELECT * FROM tci_ratings WHERE user_id = $1',
      [userId]
    );
    const currentTci = tciResult.rows[0];

    const { tciChange, dimensionChanges, xpEarned } = ratingService.calculateRatingChange({
      isCorrect,
      difficulty: challenge.difficulty,
      timeSpentSeconds,
      timeLimitSeconds: challenge.time_limit_seconds,
      challengeTciDelta: challenge.tci_delta,
      dimensionDeltas: challenge.dimension_deltas,
      currentTci,
    });

    // Update TCI ratings
    const newOverall = Math.max(100, currentTci.overall + tciChange);
    const updates = Object.entries(dimensionChanges).map(([dim, delta]) => ({
      dim,
      newValue: Math.max(100, (currentTci[dim] || 500) + delta),
    }));

    await query(
      `UPDATE tci_ratings SET
        overall = $1,
        logic = GREATEST(100, logic + $2),
        memory = GREATEST(100, memory + $3),
        focus = GREATEST(100, focus + $4),
        strategy = GREATEST(100, strategy + $5),
        mathematics = GREATEST(100, mathematics + $6),
        creativity = GREATEST(100, creativity + $7),
        problem_solving = GREATEST(100, problem_solving + $8),
        learning_speed = GREATEST(100, learning_speed + $9),
        updated_at = NOW()
       WHERE user_id = $10`,
      [
        newOverall,
        dimensionChanges.logic || 0,
        dimensionChanges.memory || 0,
        dimensionChanges.focus || 0,
        dimensionChanges.strategy || 0,
        dimensionChanges.mathematics || 0,
        dimensionChanges.creativity || 0,
        dimensionChanges.problem_solving || 0,
        dimensionChanges.learning_speed || 0,
        userId,
      ]
    );

    // Update user stats
    await query(
      `UPDATE user_stats SET
        total_xp = total_xp + $1,
        challenges_attempted = challenges_attempted + 1,
        challenges_completed = challenges_completed + $2,
        total_playtime_minutes = total_playtime_minutes + $3,
        last_activity_date = NOW()
       WHERE user_id = $4`,
      [xpEarned, isCorrect ? 1 : 0, Math.ceil(timeSpentSeconds / 60), userId]
    );

    // Update level based on XP
    await query(
      `UPDATE user_stats SET level = GREATEST(1, FLOOR(SQRT(total_xp / 1000)) + 1) WHERE user_id = $1`,
      [userId]
    );

    // Save attempt record
    const attemptId = uuidv4();
    await query(
      `INSERT INTO challenge_attempts (id, user_id, challenge_id, is_correct, selected_answer, time_spent_seconds, xp_earned, tci_change, created_at)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, NOW())`,
      [attemptId, userId, id, isCorrect, selectedAnswer, timeSpentSeconds, xpEarned, tciChange]
    );

    // Invalidate user cache
    await cacheDel(`user:${userId}`);

    // Check achievements
    const newAchievements = await checkAchievements(userId);

    res.json({
      is_correct: isCorrect,
      correct_answer: content.correct_answer,
      explanation: content.explanation,
      xp_earned: xpEarned,
      tci_change: tciChange,
      new_tci: newOverall,
      dimension_changes: dimensionChanges,
      new_achievements: newAchievements,
    });
  } catch (err) {
    next(err);
  }
}

async function getChallengeHistory(req, res, next) {
  try {
    const userId = req.user.id;
    const { page = 1, limit = 20 } = req.query;
    const offset = (page - 1) * limit;

    const result = await query(
      `SELECT ca.*, c.title, c.type, c.difficulty, c.realm_id
       FROM challenge_attempts ca
       JOIN challenges c ON c.id = ca.challenge_id
       WHERE ca.user_id = $1
       ORDER BY ca.created_at DESC
       LIMIT $2 OFFSET $3`,
      [userId, parseInt(limit), offset]
    );

    const countResult = await query(
      'SELECT COUNT(*) FROM challenge_attempts WHERE user_id = $1',
      [userId]
    );

    res.json({
      attempts: result.rows,
      total: parseInt(countResult.rows[0].count),
      page: parseInt(page),
      limit: parseInt(limit),
    });
  } catch (err) {
    next(err);
  }
}

async function checkAchievements(userId) {
  const newAchievements = [];

  const stats = await query(
    `SELECT s.*, t.overall as tci_overall
     FROM user_stats s
     JOIN tci_ratings t ON t.user_id = s.user_id
     WHERE s.user_id = $1`,
    [userId]
  );

  if (stats.rows.length === 0) return [];
  const s = stats.rows[0];

  const unlockedResult = await query(
    'SELECT achievement_id FROM user_achievements WHERE user_id = $1',
    [userId]
  );
  const unlocked = new Set(unlockedResult.rows.map((r) => r.achievement_id));

  const checks = [
    { id: 'streak_3', condition: s.current_streak >= 3 },
    { id: 'streak_7', condition: s.current_streak >= 7 },
    { id: 'streak_30', condition: s.current_streak >= 30 },
    { id: 'challenges_10', condition: s.challenges_completed >= 10 },
    { id: 'challenges_100', condition: s.challenges_completed >= 100 },
    { id: 'tci_1200', condition: s.tci_overall >= 1200 },
    { id: 'tci_2000', condition: s.tci_overall >= 2000 },
    { id: 'battles_1', condition: s.battles_won >= 1 },
  ];

  for (const check of checks) {
    if (check.condition && !unlocked.has(check.id)) {
      await query(
        'INSERT INTO user_achievements (user_id, achievement_id, unlocked_at) VALUES ($1, $2, NOW())',
        [userId, check.id]
      );
      newAchievements.push(check.id);
    }
  }

  return newAchievements;
}

module.exports = {
  generateChallenge,
  getChallenge,
  submitChallenge,
  getChallengeHistory,
};
