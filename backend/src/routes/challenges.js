const express = require('express');
const { authenticate } = require('../middleware/auth');
const {
  generateChallenge,
  getChallenge,
  submitChallenge,
  getChallengeHistory,
} = require('../controllers/challengeController');

const router = express.Router();

router.use(authenticate);

router.get('/generate', generateChallenge);
router.get('/history', getChallengeHistory);
router.get('/:id', getChallenge);
router.post('/:id/submit', submitChallenge);

module.exports = router;
