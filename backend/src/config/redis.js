const { createClient } = require('redis');
const logger = require('./logger');

let redisClient;

async function connectRedis() {
  redisClient = createClient({
    url: process.env.REDIS_URL || 'redis://localhost:6379',
  });

  redisClient.on('error', (err) => logger.error('Redis error:', err));
  redisClient.on('connect', () => logger.info('✅ Redis connected'));

  await redisClient.connect();
  return redisClient;
}

function getRedis() {
  return redisClient;
}

async function cacheSet(key, value, ttlSeconds = 300) {
  await redisClient.setEx(key, ttlSeconds, JSON.stringify(value));
}

async function cacheGet(key) {
  const val = await redisClient.get(key);
  return val ? JSON.parse(val) : null;
}

async function cacheDel(key) {
  await redisClient.del(key);
}

async function cacheInvalidatePattern(pattern) {
  const keys = await redisClient.keys(pattern);
  if (keys.length > 0) {
    await redisClient.del(keys);
  }
}

module.exports = {
  connectRedis,
  getRedis,
  cacheSet,
  cacheGet,
  cacheDel,
  cacheInvalidatePattern,
};
