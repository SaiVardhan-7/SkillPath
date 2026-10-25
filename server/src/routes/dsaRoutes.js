const express = require('express');
const router = express.Router();
const {
  getCatalogProblems,
  getUserProblems,
  addUserProblem,
  updateUserProblem,
  deleteUserProblem,
  getRevisionQueue
} = require('../controllers/dsaController');
const { protect } = require('../middleware/auth');

router.get('/problems', getCatalogProblems);
router.get('/users/me/problems', protect, getUserProblems);
router.post('/users/me/problems', protect, addUserProblem);
router.put('/users/me/problems/:id', protect, updateUserProblem);
router.delete('/users/me/problems/:id', protect, deleteUserProblem);
router.get('/users/me/revisions', protect, getRevisionQueue);

module.exports = router;
