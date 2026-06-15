const express = require('express');
const { authenticate } = require('../middleware/auth');
const { query } = require('../config/database');

const router = express.Router();
router.use(authenticate);

router.get('/progress', async (req, res, next) => {
  try {
    const result = await query(
      `SELECT realm_id, current_level, stars_earned, boss_defeated, updated_at
       FROM realm_progress WHERE user_id = $1`,
      [req.user.id]
    );

    res.json(result.rows);
  } catch (err) {
    next(err);
  }
});

router.post('/:realmId/complete-level', async (req, res, next) => {
  try {
    const { realmId } = req.params;
    const { levelNumber, stars } = req.body;

    await query(
      `INSERT INTO realm_progress (user_id, realm_id, current_level, stars_earned)
       VALUES ($1, $2, $3, $4)
       ON CONFLICT (user_id, realm_id)
       DO UPDATE SET
         current_level = GREATEST(realm_progress.current_level, EXCLUDED.current_level + 1),
         stars_earned = realm_progress.stars_earned + EXCLUDED.stars_earned,
         updated_at = NOW()`,
      [req.user.id, realmId, levelNumber, stars || 1]
    );

    // Check if it's a boss level (every 5th)
    const isBoss = levelNumber % 5 === 0;
    if (isBoss) {
      await query(
        'UPDATE realm_progress SET boss_defeated = true WHERE user_id = $1 AND realm_id = $2',
        [req.user.id, realmId]
      );
    }

    res.json({ success: true, isBoss });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
