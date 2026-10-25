const express = require('express');
const router = express.Router();
const {
  getAllRoadmaps,
  getRoadmapById,
  getUserRoadmap,
  updateRoadmapProgress
} = require('../controllers/roadmapController');
const { protect } = require('../middleware/auth');

router.get('/roadmaps', getAllRoadmaps);
router.get('/roadmaps/:id', getRoadmapById);
router.get('/users/me/roadmap', protect, getUserRoadmap);
router.put('/users/me/roadmap/progress', protect, updateRoadmapProgress);

module.exports = router;
