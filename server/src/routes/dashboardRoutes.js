const express = require('express');
const router = express.Router();
const {
  getDashboardData,
  getUserAnalytics,
  getUserActivityLogs
} = require('../controllers/dashboardController');
const { protect } = require('../middleware/auth');

router.get('/users/me/dashboard', protect, getDashboardData);
router.get('/users/me/analytics', protect, getUserAnalytics);
router.get('/users/me/activity', protect, getUserActivityLogs);

module.exports = router;
