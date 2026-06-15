const express = require('express');
const { authenticate } = require('../middleware/auth');
const { query } = require('../config/database');

const router = express.Router();
router.use(authenticate);

router.get('/history', async (req, res, next) => {
  try {
    const { limit = 20, page = 1 } = req.query;
    const offset = (page - 1) * limit;

    const result = await query(
      `SELECT * FROM battle_sessions
       WHERE player1_id = $1 OR player2_id = $1
       ORDER BY started_at DESC
       LIMIT $2 OFFSET $3`,
      [req.user.id, parseInt(limit), offset]
    );

    res.json(result.rows);
  } catch (err) {
    next(err);
  }
});

router.get('/stats', async (req, res, next) => {
  try {
    const result = await query(
      'SELECT battles_won, battles_lost FROM user_stats WHERE user_id = $1',
      [req.user.id]
    );

    const stats = result.rows[0] || { battles_won: 0, battles_lost: 0 };
    const total = stats.battles_won + stats.battles_lost;
    stats.win_rate = total === 0 ? 0 : stats.battles_won / total;

    res.json(stats);
  } catch (err) {
    next(err);
  }
});

module.exports = router;
