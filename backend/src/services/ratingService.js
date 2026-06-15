/**
 * TCI Rating Engine — Elo-inspired adaptive rating system
 *
 * Base K-factor varies by difficulty and current rating tier.
 * Time bonus/penalty is applied for fast/slow completions.
 */

const DIFFICULTY_K = {
  beginner: 12,
  intermediate: 20,
  advanced: 32,
  expert: 45,
  master: 60,
};

const XP_BY_DIFFICULTY = {
  beginner: 15,
  intermediate: 30,
  advanced: 60,
  expert: 100,
  master: 150,
};

function getTierMultiplier(overallRating) {
  if (overallRating >= 2800) return 0.5;  // Grandmaster/Master — slower growth
  if (overallRating >= 2000) return 0.75; // Expert/Advanced
  if (overallRating >= 1200) return 1.0;  // Intermediate
  return 1.5;                              // Beginner — faster growth
}

function getTimeBonus(timeSpent, timeLimit, isCorrect) {
  if (!isCorrect) return 0;
  const ratio = timeSpent / timeLimit;
  if (ratio <= 0.3) return 3;   // Very fast: bonus
  if (ratio <= 0.5) return 2;
  if (ratio <= 0.7) return 1;
  return 0;
}

function calculateRatingChange({
  isCorrect,
  difficulty,
  timeSpentSeconds,
  timeLimitSeconds,
  challengeTciDelta,
  dimensionDeltas,
  currentTci,
}) {
  const k = DIFFICULTY_K[difficulty] || 20;
  const tierMult = getTierMultiplier(currentTci.overall || 500);
  const timeBonus = getTimeBonus(timeSpentSeconds, timeLimitSeconds, isCorrect);

  let tciChange;
  if (isCorrect) {
    tciChange = Math.round((challengeTciDelta + timeBonus) * tierMult);
  } else {
    // Smaller penalty — losing is educational, not punishing
    tciChange = -Math.round((challengeTciDelta * 0.4) * tierMult);
  }

  // Scale dimension changes
  const dimensionChanges = {};
  for (const [dim, delta] of Object.entries(dimensionDeltas || {})) {
    if (isCorrect) {
      dimensionChanges[dim] = Math.round(delta * tierMult);
    } else {
      dimensionChanges[dim] = -Math.round(delta * 0.25 * tierMult);
    }
  }

  // XP: even wrong answers earn a small amount
  const baseXp = XP_BY_DIFFICULTY[difficulty] || 30;
  const xpEarned = isCorrect
    ? Math.round(baseXp * tierMult + timeBonus * 5)
    : Math.round(baseXp * 0.15);

  return { tciChange, dimensionChanges, xpEarned };
}

function calculateBattleRatingChange(userTci, opponentTci, userWon) {
  // Expected score using Elo formula
  const expected = 1 / (1 + Math.pow(10, (opponentTci - userTci) / 400));
  const actual = userWon ? 1 : 0;
  const k = 32;

  const change = Math.round(k * (actual - expected));
  const xpEarned = userWon ? 75 : 10;

  return { tciChange: change, xpEarned };
}

module.exports = { calculateRatingChange, calculateBattleRatingChange };
