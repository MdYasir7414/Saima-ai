const express = require('express');
const { authenticate } = require('../middleware/auth');
const { query } = require('../config/database');
const { cacheGet, cacheSet } = require('../config/redis');

const router = express.Router();
router.use(authenticate);

router.get('/today', async (req, res, next) => {
  try {
    const today = new Date().toISOString().split('T')[0];
    const cacheKey = `daily_quest:${req.user.id}:${today}`;
    let quest = await cacheGet(cacheKey);

    if (!quest) {
      // Check if user already has today's quest assigned
      const existing = await query(
        `SELECT dq.*, uq.completed_count, uq.is_completed
         FROM daily_quests dq
         LEFT JOIN user_daily_quests uq ON uq.quest_id = dq.id AND uq.user_id = $1
         WHERE dq.date = $2 AND dq.age_group = $3`,
        [req.user.id, today, req.user.age_group]
      );

      if (existing.rows.length > 0) {
        quest = existing.rows[0];
      } else {
        // Generate quest for today
        quest = {
          id: `quest_${today}_${req.user.age_group}`,
          title: getTodayQuestTitle(),
          description: 'Complete all 5 challenges to earn bonus XP and extend your streak.',
          challenge_ids: generateChallengeIds(req.user.age_group),
          total_xp_reward: 50,
          completed_count: 0,
          is_completed: false,
          date: today,
        };
      }

      await cacheSet(cacheKey, quest, 3600);
    }

    res.json(quest);
  } catch (err) {
    next(err);
  }
});

function getTodayQuestTitle() {
  const titles = [
    'Morning Cognitive Sprint',
    'Logic & Memory Boost',
    'Cross-Domain Challenge',
    'Pattern Recognition Day',
    'Strategic Thinking Session',
    'Math & Creativity Mix',
    'Elite Thinking Workout',
  ];
  return titles[new Date().getDay()];
}

function generateChallengeIds(ageGroup) {
  const domains = ['logic', 'math', 'memory', 'strategy', 'creativity'];
  return domains.map((d) => `${d}_daily_${Date.now()}_${Math.random().toString(36).substr(2, 5)}`);
}

module.exports = router;
