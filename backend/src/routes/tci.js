const express = require('express');
const { authenticate } = require('../middleware/auth');
const { query } = require('../config/database');
const { cacheGet, cacheSet } = require('../config/redis');

const router = express.Router();
router.use(authenticate);

router.get('/', async (req, res, next) => {
  try {
    const cacheKey = `tci:${req.user.id}`;
    let tci = await cacheGet(cacheKey);

    if (!tci) {
      const result = await query(
        'SELECT * FROM tci_ratings WHERE user_id = $1',
        [req.user.id]
      );

      if (result.rows.length === 0) {
        return res.status(404).json({ error: 'TCI data not found' });
      }

      tci = result.rows[0];
      await cacheSet(cacheKey, tci, 60);
    }

    res.json(tci);
  } catch (err) {
    next(err);
  }
});

// TCI history (for progress charts)
router.get('/history', async (req, res, next) => {
  try {
    const { days = 30 } = req.query;
    const result = await query(
      `SELECT DATE(created_at) as date, AVG(tci_change) as avg_change, SUM(tci_change) as total_change
       FROM challenge_attempts
       WHERE user_id = $1 AND created_at >= NOW() - INTERVAL '${parseInt(days)} days'
       GROUP BY DATE(created_at)
       ORDER BY date ASC`,
      [req.user.id]
    );

    // Build running TCI from history
    const tciResult = await query(
      'SELECT overall FROM tci_ratings WHERE user_id = $1',
      [req.user.id]
    );

    const currentTci = tciResult.rows[0]?.overall || 500;
    const totalChange = result.rows.reduce((sum, r) => sum + parseFloat(r.total_change), 0);
    let runningTci = currentTci - totalChange;

    const history = result.rows.map((row) => {
      runningTci += parseFloat(row.total_change);
      return {
        date: row.date,
        tci: Math.round(runningTci),
        change: parseFloat(row.total_change),
      };
    });

    res.json({ history, current: currentTci });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
