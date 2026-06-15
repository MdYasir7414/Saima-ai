const express = require('express');
const { authenticate, requireParent } = require('../middleware/auth');
const { query } = require('../config/database');

const router = express.Router();
router.use(authenticate, requireParent);

router.get('/children', async (req, res, next) => {
  try {
    const result = await query(
      `SELECT u.id, u.username, u.display_name, u.avatar_url, u.age, u.age_group,
              t.overall as tci_overall,
              s.total_xp, s.level, s.current_streak, s.challenges_completed,
              s.total_playtime_minutes, s.last_activity_date
       FROM users u
       LEFT JOIN tci_ratings t ON t.user_id = u.id
       LEFT JOIN user_stats s ON s.user_id = u.id
       WHERE u.parent_id = $1 AND u.is_active = true`,
      [req.user.id]
    );

    res.json(result.rows);
  } catch (err) {
    next(err);
  }
});

router.get('/children/:childId/report', async (req, res, next) => {
  try {
    const { childId } = req.params;
    const { period = '7' } = req.query;

    // Verify parent-child relationship
    const childCheck = await query(
      'SELECT id FROM users WHERE id = $1 AND parent_id = $2',
      [childId, req.user.id]
    );

    if (childCheck.rows.length === 0) {
      return res.status(403).json({ error: 'Access denied' });
    }

    const [tci, stats, weeklyActivity] = await Promise.all([
      query('SELECT * FROM tci_ratings WHERE user_id = $1', [childId]),
      query('SELECT * FROM user_stats WHERE user_id = $1', [childId]),
      query(
        `SELECT DATE(created_at) as date, COUNT(*) as challenges, SUM(xp_earned) as xp, AVG(CASE WHEN is_correct THEN 1.0 ELSE 0.0 END) as accuracy
         FROM challenge_attempts
         WHERE user_id = $1 AND created_at >= NOW() - INTERVAL '${parseInt(period)} days'
         GROUP BY DATE(created_at)
         ORDER BY date ASC`,
        [childId]
      ),
    ]);

    res.json({
      child_id: childId,
      tci: tci.rows[0],
      stats: stats.rows[0],
      weekly_activity: weeklyActivity.rows,
      period_days: parseInt(period),
      generated_at: new Date().toISOString(),
    });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
