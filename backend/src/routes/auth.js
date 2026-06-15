const express = require('express');
const { body, validationResult } = require('express-validator');
const { register, login, googleAuth, refreshToken } = require('../controllers/authController');

const router = express.Router();

const validate = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ error: 'Validation failed', details: errors.array() });
  }
  next();
};

router.post(
  '/register',
  [
    body('username').trim().isLength({ min: 3, max: 30 }).matches(/^[a-zA-Z0-9_]+$/),
    body('email').isEmail().normalizeEmail(),
    body('password').isLength({ min: 8 }),
    body('age').isInt({ min: 3, max: 120 }),
    body('ageGroup').isIn(['explorer', 'adventurer', 'scholar', 'challenger', 'pioneer']),
  ],
  validate,
  register
);

router.post(
  '/login',
  [
    body('email').isEmail().normalizeEmail(),
    body('password').notEmpty(),
  ],
  validate,
  login
);

router.post('/google', googleAuth);

router.post(
  '/refresh',
  [body('refreshToken').notEmpty()],
  validate,
  refreshToken
);

module.exports = router;
