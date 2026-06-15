const jwt = require('jsonwebtoken');
const { query } = require('../config/database');
const { cacheGet, cacheSet } = require('../config/redis');

async function authenticate(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader?.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Missing or invalid authorization header' });
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // Check cache first
    const cacheKey = `user:${decoded.userId}`;
    let user = await cacheGet(cacheKey);

    if (!user) {
      const result = await query(
        'SELECT id, username, email, age_group, is_parent_account FROM users WHERE id = $1 AND is_active = true',
        [decoded.userId]
      );

      if (result.rows.length === 0) {
        return res.status(401).json({ error: 'User not found or deactivated' });
      }

      user = result.rows[0];
      await cacheSet(cacheKey, user, 300);
    }

    req.user = user;
    next();
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      return res.status(401).json({ error: 'Token expired' });
    }
    return res.status(401).json({ error: 'Invalid token' });
  }
}

async function optionalAuth(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader?.startsWith('Bearer ')) {
    req.user = null;
    return next();
  }

  try {
    const token = authHeader.split(' ')[1];
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = { id: decoded.userId };
  } catch {
    req.user = null;
  }
  next();
}

function requireParent(req, res, next) {
  if (!req.user?.is_parent_account) {
    return res.status(403).json({ error: 'Parent account required' });
  }
  next();
}

module.exports = { authenticate, optionalAuth, requireParent };
