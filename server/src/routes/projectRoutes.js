const express = require('express');
const router = express.Router();
const {
  getAllProjects,
  getProjectById,
  getUserProjects,
  startOrSaveProject,
  updateProjectProgress,
  generateResumeBullets,
  deleteUserProject
} = require('../controllers/projectController');
const { protect } = require('../middleware/auth');

router.get('/projects', getAllProjects);
router.get('/projects/:id', getProjectById);
router.get('/users/me/projects', protect, getUserProjects);
router.post('/users/me/projects', protect, startOrSaveProject);
router.put('/users/me/projects/:id', protect, updateProjectProgress);
router.post('/users/me/projects/:id/resume-bullets', protect, generateResumeBullets);
router.delete('/users/me/projects/:id', protect, deleteUserProject);

module.exports = router;
