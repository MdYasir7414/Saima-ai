const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const logger = require('../config/logger');
const { cacheGet, cacheSet, cacheDel } = require('../config/redis');
const { calculateBattleRatingChange } = require('./ratingService');
const { query } = require('../config/database');

const matchmakingQueue = new Map(); // userId -> { socket, tci, joinedAt }
const activeBattles = new Map();    // battleId -> { players, challenge, scores }

function registerSocketHandlers(io) {
  io.use(async (socket, next) => {
    try {
      const token = socket.handshake.auth?.token;
      if (!token) return next(new Error('Authentication required'));
      const decoded = jwt.verify(token, process.env.JWT_SECRET);
      socket.userId = decoded.userId;
      next();
    } catch {
      next(new Error('Invalid token'));
    }
  });

  io.on('connection', (socket) => {
    logger.info(`Socket connected: ${socket.userId}`);

    socket.on('battle:join_queue', async ({ tci }) => {
      matchmakingQueue.set(socket.userId, {
        socket,
        tci: tci || 500,
        joinedAt: Date.now(),
      });

      socket.emit('battle:searching', { message: 'Searching for opponent...' });
      tryMatchmaking(io, socket.userId);
    });

    socket.on('battle:submit_answer', async ({ battleId, answerId, timeSpent }) => {
      const battle = activeBattles.get(battleId);
      if (!battle) return;

      const playerIndex = battle.players.findIndex((p) => p.userId === socket.userId);
      if (playerIndex === -1 || battle.answers[playerIndex] !== undefined) return;

      const isCorrect = battle.challenge?.content?.correct_answer === answerId;
      const score = calculateBattleScore(isCorrect, timeSpent, battle.challenge?.time_limit_seconds);

      battle.answers[playerIndex] = { answerId, isCorrect, score, timeSpent };

      // Broadcast partial result to both players
      io.to(battleId).emit('battle:answer_received', {
        playerIndex,
        score,
      });

      // If both players answered, resolve battle
      if (battle.answers.every((a) => a !== undefined)) {
        await resolveBattle(io, battleId, battle);
      }
    });

    socket.on('battle:leave_queue', () => {
      matchmakingQueue.delete(socket.userId);
      socket.emit('battle:queue_left');
    });

    socket.on('disconnect', () => {
      matchmakingQueue.delete(socket.userId);
      logger.info(`Socket disconnected: ${socket.userId}`);
    });
  });
}

function tryMatchmaking(io, newUserId) {
  const newPlayer = matchmakingQueue.get(newUserId);
  if (!newPlayer) return;

  const TCI_RANGE = 200;
  const MAX_WAIT_EXPANSION = 5000; // After 5s, expand range
  const waitTime = Date.now() - newPlayer.joinedAt;
  const range = waitTime > MAX_WAIT_EXPANSION ? TCI_RANGE * 3 : TCI_RANGE;

  for (const [userId, player] of matchmakingQueue.entries()) {
    if (userId === newUserId) continue;
    if (Math.abs(player.tci - newPlayer.tci) <= range) {
      // Match found
      matchmakingQueue.delete(userId);
      matchmakingQueue.delete(newUserId);

      const battleId = uuidv4();
      const challenge = getQuickBattleChallenge();

      const battle = {
        id: battleId,
        players: [
          { userId, socket: player.socket, tci: player.tci },
          { userId: newUserId, socket: newPlayer.socket, tci: newPlayer.tci },
        ],
        challenge,
        answers: [undefined, undefined],
        startedAt: Date.now(),
      };

      activeBattles.set(battleId, battle);

      player.socket.join(battleId);
      newPlayer.socket.join(battleId);

      io.to(battleId).emit('battle:match_found', {
        battleId,
        challenge: sanitizeChallenge(challenge),
        players: [
          { userId, tci: player.tci },
          { userId: newUserId, tci: newPlayer.tci },
        ],
      });

      // Auto-resolve after time limit
      setTimeout(() => {
        const b = activeBattles.get(battleId);
        if (b && b.answers.some((a) => a === undefined)) {
          b.answers = b.answers.map((a) => a || { score: 0, isCorrect: false });
          resolveBattle(io, battleId, b);
        }
      }, (challenge.time_limit_seconds + 5) * 1000);

      return;
    }
  }
}

function calculateBattleScore(isCorrect, timeSpent, timeLimit) {
  if (!isCorrect) return 0;
  const ratio = timeSpent / timeLimit;
  if (ratio <= 0.3) return 100;
  if (ratio <= 0.5) return 90;
  if (ratio <= 0.7) return 80;
  return 70;
}

async function resolveBattle(io, battleId, battle) {
  const [p1, p2] = battle.players;
  const [a1, a2] = battle.answers;

  const p1Score = a1?.score || 0;
  const p2Score = a2?.score || 0;
  const p1Won = p1Score > p2Score;
  const isDraw = p1Score === p2Score;

  const { tciChange: p1Change, xpEarned: p1Xp } = calculateBattleRatingChange(
    p1.tci, p2.tci, p1Won
  );
  const { tciChange: p2Change, xpEarned: p2Xp } = calculateBattleRatingChange(
    p2.tci, p1.tci, !p1Won
  );

  // Update DB
  try {
    await Promise.all([
      query(
        `UPDATE tci_ratings SET overall = GREATEST(100, overall + $1), updated_at = NOW() WHERE user_id = $2`,
        [p1Change, p1.userId]
      ),
      query(
        `UPDATE tci_ratings SET overall = GREATEST(100, overall + $1), updated_at = NOW() WHERE user_id = $2`,
        [p2Change, p2.userId]
      ),
      query(
        `UPDATE user_stats SET total_xp = total_xp + $1, battles_won = battles_won + $2, battles_lost = battles_lost + $3 WHERE user_id = $4`,
        [p1Xp, p1Won ? 1 : 0, p1Won ? 0 : 1, p1.userId]
      ),
      query(
        `UPDATE user_stats SET total_xp = total_xp + $1, battles_won = battles_won + $2, battles_lost = battles_lost + $3 WHERE user_id = $4`,
        [p2Xp, !p1Won ? 1 : 0, !p1Won ? 0 : 1, p2.userId]
      ),
    ]);
  } catch (err) {
    logger.error('Battle DB update failed:', err);
  }

  io.to(battleId).emit('battle:result', {
    winnerId: isDraw ? null : (p1Won ? p1.userId : p2.userId),
    scores: { [p1.userId]: p1Score, [p2.userId]: p2Score },
    tciChanges: { [p1.userId]: p1Change, [p2.userId]: p2Change },
    xpEarned: { [p1.userId]: p1Xp, [p2.userId]: p2Xp },
    explanation: battle.challenge?.content?.explanation,
    correctAnswer: battle.challenge?.content?.correct_answer,
  });

  activeBattles.delete(battleId);
}

function getQuickBattleChallenge() {
  return {
    id: uuidv4(),
    title: 'Battle Challenge',
    type: 'logic_puzzle',
    difficulty: 'intermediate',
    time_limit_seconds: 60,
    content: {
      prompt: 'If all Bloops are Razzles and all Razzles are Lazzles, then all Bloops are definitely Lazzles?\n\nA) True B) False C) Possibly D) Cannot determine',
      options: [
        { id: 'a', text: 'True', is_correct: true },
        { id: 'b', text: 'False', is_correct: false },
        { id: 'c', text: 'Possibly', is_correct: false },
        { id: 'd', text: 'Cannot determine', is_correct: false },
      ],
      correct_answer: 'a',
      explanation: 'This is a syllogism: Bloops ⊆ Razzles, Razzles ⊆ Lazzles, therefore Bloops ⊆ Lazzles. This is definitively TRUE by transitive property.',
    },
  };
}

function sanitizeChallenge(challenge) {
  const safe = { ...challenge };
  if (safe.content) {
    safe.content = {
      ...safe.content,
      options: safe.content.options?.map((o) => ({ id: o.id, text: o.text })),
      correct_answer: undefined,
      explanation: undefined,
    };
  }
  return safe;
}

module.exports = { registerSocketHandlers };
