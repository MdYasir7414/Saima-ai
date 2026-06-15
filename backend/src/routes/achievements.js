const express = require('express');
const { authenticate } = require('../middleware/auth');
const { query } = require('../config/database');

const router = express.Router();
router.use(authenticate);

router.get('/', async (req, res, next) => {
  try {
    const result = await query(
      `SELECT ua.achievement_id, ua.unlocked_at
       FROM user_achievements ua
       WHERE ua.user_id = $1
       ORDER BY ua.unlocked_at DESC`,
      [req.user.id]
    );

    res.json({
      unlocked: result.rows,
      total_unlocked: result.rows.length,
    });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
