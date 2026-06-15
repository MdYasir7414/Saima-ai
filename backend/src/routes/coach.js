const express = require('express');
const { authenticate } = require('../middleware/auth');
const { query } = require('../config/database');
const { generateCoachResponse } = require('../services/aiService');

const router = express.Router();
router.use(authenticate);

router.post('/chat', async (req, res, next) => {
  try {
    const { message } = req.body;
    if (!message?.trim()) {
      return res.status(400).json({ error: 'Message is required' });
    }

    const [tciResult, statsResult] = await Promise.all([
      query('SELECT * FROM tci_ratings WHERE user_id = $1', [req.user.id]),
      query('SELECT *, (challenges_completed::float / NULLIF(challenges_attempted, 0)) as accuracy FROM user_stats WHERE user_id = $1', [req.user.id]),
    ]);

    const response = await generateCoachResponse({
      message,
      userId: req.user.id,
      userTci: tciResult.rows[0],
      userStats: statsResult.rows[0],
    });

    res.json({ response, timestamp: new Date().toISOString() });
  } catch (err) {
    next(err);
  }
});

router.get('/analysis', async (req, res, next) => {
  try {
    const [tci, stats, recentAttempts] = await Promise.all([
      query('SELECT * FROM tci_ratings WHERE user_id = $1', [req.user.id]),
      query('SELECT * FROM user_stats WHERE user_id = $1', [req.user.id]),
      query(
        `SELECT c.type, c.difficulty, ca.is_correct, ca.time_spent_seconds, ca.created_at
         FROM challenge_attempts ca
         JOIN challenges c ON c.id = ca.challenge_id
         WHERE ca.user_id = $1
         ORDER BY ca.created_at DESC
         LIMIT 50`,
        [req.user.id]
      ),
    ]);

    // Find weakest dimensions
    const tciData = tci.rows[0] || {};
    const dimensions = [
      { name: 'logic', value: tciData.logic || 500 },
      { name: 'memory', value: tciData.memory || 500 },
      { name: 'focus', value: tciData.focus || 500 },
      { name: 'strategy', value: tciData.strategy || 500 },
      { name: 'mathematics', value: tciData.mathematics || 500 },
      { name: 'creativity', value: tciData.creativity || 500 },
      { name: 'problem_solving', value: tciData.problem_solving || 500 },
    ];

    dimensions.sort((a, b) => a.value - b.value);

    res.json({
      tci: tciData,
      stats: stats.rows[0],
      weakest_dimensions: dimensions.slice(0, 3),
      strongest_dimensions: dimensions.slice(-3).reverse(),
      recent_performance: {
        total: recentAttempts.rows.length,
        correct: recentAttempts.rows.filter((r) => r.is_correct).length,
        avg_time: recentAttempts.rows.reduce((sum, r) => sum + r.time_spent_seconds, 0) / (recentAttempts.rows.length || 1),
      },
      recommendations: generateRecommendations(dimensions, stats.rows[0]),
    });
  } catch (err) {
    next(err);
  }
});

function generateRecommendations(dimensions, stats) {
  const recs = [];
  const weakest = dimensions[0];

  if (weakest.value < 600) {
    recs.push({
      type: 'train',
      priority: 'high',
      dimension: weakest.name,
      message: `Your ${weakest.name} score of ${weakest.value} needs attention. Focus 3 sessions per day on ${weakest.name} challenges.`,
    });
  }

  if (stats?.current_streak < 3) {
    recs.push({
      type: 'habit',
      priority: 'medium',
      message: 'Build a daily habit — just 10 minutes per day creates lasting cognitive improvement.',
    });
  }

  if ((stats?.challenges_completed / Math.max(stats?.challenges_attempted, 1)) < 0.7) {
    recs.push({
      type: 'difficulty',
      priority: 'medium',
      message: 'Your accuracy is below 70%. Consider dropping one difficulty level to build confidence and understanding.',
    });
  }

  return recs;
}

module.exports = router;
