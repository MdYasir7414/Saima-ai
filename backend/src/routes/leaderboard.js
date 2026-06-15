const express = require('express');
const { authenticate } = require('../middleware/auth');
const { query } = require('../config/database');
const { cacheGet, cacheSet } = require('../config/redis');

const router = express.Router();
router.use(authenticate);

router.get('/', async (req, res, next) => {
  try {
    const { scope = 'global', ageGroup, country, limit = 100 } = req.query;
    const cacheKey = `leaderboard:${scope}:${ageGroup || 'all'}:${country || 'all'}`;

    let data = await cacheGet(cacheKey);

    if (!data) {
      let sql = `
        SELECT
          ROW_NUMBER() OVER (ORDER BY t.overall DESC) as rank,
          u.id as user_id,
          u.username,
          u.display_name,
          u.avatar_url,
          u.country,
          t.overall as tci_overall,
          CASE
            WHEN t.overall >= 3000 THEN 'Grandmaster'
            WHEN t.overall >= 2800 THEN 'Master'
            WHEN t.overall >= 2500 THEN 'Expert'
            WHEN t.overall >= 2000 THEN 'Advanced'
            WHEN t.overall >= 1200 THEN 'Intermediate'
            ELSE 'Beginner'
          END as tci_tier,
          s.current_streak,
          s.challenges_completed,
          COALESCE(w.weekly_xp, 0) as weekly_xp
        FROM users u
        JOIN tci_ratings t ON t.user_id = u.id
        JOIN user_stats s ON s.user_id = u.id
        LEFT JOIN (
          SELECT user_id, SUM(xp_earned) as weekly_xp
          FROM challenge_attempts
          WHERE created_at >= NOW() - INTERVAL '7 days'
          GROUP BY user_id
        ) w ON w.user_id = u.id
        WHERE u.is_active = true
      `;

      const params = [];
      if (scope === 'country' && country) {
        params.push(country);
        sql += ` AND u.country = $${params.length}`;
      }
      if (ageGroup) {
        params.push(ageGroup);
        sql += ` AND u.age_group = $${params.length}`;
      }

      sql += ` ORDER BY t.overall DESC LIMIT $${params.length + 1}`;
      params.push(parseInt(limit));

      const result = await query(sql, params);

      // Find current user's rank
      const currentUserRank = await query(
        `SELECT COUNT(*) + 1 as rank FROM tci_ratings WHERE overall > (SELECT overall FROM tci_ratings WHERE user_id = $1)`,
        [req.user.id]
      );

      data = {
        scope,
        entries: result.rows.map((row) => ({
          ...row,
          is_current_user: row.user_id === req.user.id,
        })),
        current_user_rank: parseInt(currentUserRank.rows[0]?.rank || 0),
        last_updated: new Date().toISOString(),
      };

      await cacheSet(cacheKey, data, 300); // Cache 5 minutes
    }

    res.json(data);
  } catch (err) {
    next(err);
  }
});

module.exports = router;
