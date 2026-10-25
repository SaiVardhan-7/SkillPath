const express = require('express');
const router = express.Router();
const {
  getInterviewQuestions,
  getUserInterviewProgress,
  updateQuestionProgress
} = require('../controllers/interviewController');
const { protect } = require('../middleware/auth');

router.get('/interview-questions', getInterviewQuestions);
router.get('/users/me/interview-progress', protect, getUserInterviewProgress);
router.put('/users/me/interview-progress/:id', protect, updateQuestionProgress);

module.exports = router;
