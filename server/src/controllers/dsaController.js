const { DSAProblem, dsaCategories } = require('../models/DSAProblem');
const UserProblemProgress = require('../models/UserProblemProgress');
const ActivityLog = require('../models/ActivityLog');
const { getDSAAnalytics } = require('../services/analyticsService');

// @desc    Get preset catalog problems
// @route   GET /api/problems
// @access  Public
const getCatalogProblems = async (req, res, next) => {
  try {
    const { topic, difficulty, platform, search } = req.query;
    const query = {};

    if (topic && topic !== 'All') query.topic = topic;
    if (difficulty && difficulty !== 'All') query.difficulty = difficulty;
    if (platform && platform !== 'All') query.platform = platform;
    if (search) query.title = { $regex: search, $options: 'i' };

    const problems = await DSAProblem.find(query).sort({ topic: 1, difficulty: 1 });
    res.status(200).json({
      success: true,
      count: problems.length,
      categories: dsaCategories,
      data: problems
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get current user's tracked problems
// @route   GET /api/users/me/problems
// @access  Private
const getUserProblems = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const { topic, difficulty, platform, status, bookmarked, search } = req.query;

    const query = { userId };
    if (topic && topic !== 'All') query.topic = topic;
    if (difficulty && difficulty !== 'All') query.difficulty = difficulty;
    if (platform && platform !== 'All') query.platform = platform;
    if (status && status !== 'All') query.status = status;
    if (bookmarked === 'true') query.isBookmarked = true;
    if (search) query.title = { $regex: search, $options: 'i' };

    const problems = await UserProblemProgress.find(query).sort({ updatedAt: -1 });
    const analytics = await getDSAAnalytics(userId);

    res.status(200).json({
      success: true,
      count: problems.length,
      analytics,
      categories: dsaCategories,
      data: problems
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Add problem to user tracker
// @route   POST /api/users/me/problems
// @access  Private
const addUserProblem = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const {
      problemId,
      title,
      url,
      platform,
      topic,
      difficulty,
      status,
      isBookmarked,
      notes,
      mistakes,
      observations,
      revisionIntervalDays
    } = req.body;

    let targetTitle = title;
    let targetUrl = url;
    let targetPlatform = platform || 'LeetCode';
    let targetTopic = topic;
    let targetDifficulty = difficulty;

    // If linking from preset catalog
    if (problemId) {
      const preset = await DSAProblem.findById(problemId);
      if (preset) {
        targetTitle = targetTitle || preset.title;
        targetUrl = targetUrl || preset.url;
        targetPlatform = targetPlatform || preset.platform;
        targetTopic = targetTopic || preset.topic;
        targetDifficulty = targetDifficulty || preset.difficulty;
      }
    }

    if (!targetTitle || !targetUrl || !targetTopic || !targetDifficulty) {
      return res.status(400).json({
        success: false,
        message: 'Please provide title, url, topic, and difficulty'
      });
    }

    // Check if user already tracked this URL
    let existing = await UserProblemProgress.findOne({ userId, url: targetUrl });
    if (existing) {
      return res.status(400).json({
        success: false,
        message: 'You have already added this problem. You can update it instead.'
      });
    }

    const interval = Number(revisionIntervalDays) || 3;
    let revisionDate = null;
    let solvedDate = null;

    if (status === 'solved') {
      solvedDate = new Date();
      revisionDate = new Date();
      revisionDate.setDate(revisionDate.getDate() + interval);
    }

    const problemProgress = await UserProblemProgress.create({
      userId,
      problemId: problemId || null,
      title: targetTitle,
      url: targetUrl,
      platform: targetPlatform,
      topic: targetTopic,
      difficulty: targetDifficulty,
      status: status || 'attempted',
      isBookmarked: Boolean(isBookmarked),
      notes: notes || '',
      mistakes: mistakes || '',
      observations: observations || '',
      dateSolved: solvedDate,
      revisionScheduledDate: revisionDate,
      revisionIntervalDays: interval,
      revisionCount: 0
    });

    if (status === 'solved') {
      await ActivityLog.create({
        userId,
        activityType: 'dsa_solved',
        details: {
          problemId: problemProgress._id,
          title: targetTitle,
          topic: targetTopic,
          difficulty: targetDifficulty,
          platform: targetPlatform
        }
      });
    }

    res.status(201).json({
      success: true,
      message: 'Problem added to tracker successfully',
      data: problemProgress
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Update tracked problem
// @route   PUT /api/users/me/problems/:id
// @access  Private
const updateUserProblem = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const { id } = req.params;
    const {
      status,
      isBookmarked,
      notes,
      mistakes,
      observations,
      rescheduleDays,
      revisionIntervalDays
    } = req.body;

    const problem = await UserProblemProgress.findOne({ _id: id, userId });
    if (!problem) {
      return res.status(404).json({ success: false, message: 'Tracked problem not found' });
    }

    const previousStatus = problem.status;

    if (status) {
      problem.status = status;
      if (status === 'solved' && previousStatus !== 'solved') {
        problem.dateSolved = new Date();
        const interval = revisionIntervalDays || problem.revisionIntervalDays || 3;
        const revDate = new Date();
        revDate.setDate(revDate.getDate() + interval);
        problem.revisionScheduledDate = revDate;

        await ActivityLog.create({
          userId,
          activityType: 'dsa_solved',
          details: {
            problemId: problem._id,
            title: problem.title,
            topic: problem.topic,
            difficulty: problem.difficulty,
            platform: problem.platform
          }
        });
      }
    }

    if (isBookmarked !== undefined) problem.isBookmarked = isBookmarked;
    if (notes !== undefined) problem.notes = notes;
    if (mistakes !== undefined) problem.mistakes = mistakes;
    if (observations !== undefined) problem.observations = observations;

    if (rescheduleDays) {
      const days = Number(rescheduleDays);
      const nextDate = new Date();
      nextDate.setDate(nextDate.getDate() + days);
      problem.revisionScheduledDate = nextDate;
      problem.revisionIntervalDays = days;
      problem.revisionCount = (problem.revisionCount || 0) + 1;
    }

    await problem.save();

    res.status(200).json({
      success: true,
      message: 'Problem updated successfully',
      data: problem
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Delete tracked problem
// @route   DELETE /api/users/me/problems/:id
// @access  Private
const deleteUserProblem = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const { id } = req.params;

    const problem = await UserProblemProgress.findOneAndDelete({ _id: id, userId });
    if (!problem) {
      return res.status(404).json({ success: false, message: 'Problem not found' });
    }

    res.status(200).json({
      success: true,
      message: 'Problem removed from tracker'
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get spaced repetition revision queue
// @route   GET /api/users/me/revisions
// @access  Private
const getRevisionQueue = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const now = new Date();
    const endOfToday = new Date();
    endOfToday.setHours(23, 59, 59, 999);

    const dueRevisions = await UserProblemProgress.find({
      userId,
      status: 'solved',
      revisionScheduledDate: { $lte: endOfToday }
    }).sort({ revisionScheduledDate: 1 });

    const upcomingRevisions = await UserProblemProgress.find({
      userId,
      status: 'solved',
      revisionScheduledDate: { $gt: endOfToday }
    })
      .sort({ revisionScheduledDate: 1 })
      .limit(10);

    res.status(200).json({
      success: true,
      data: {
        dueCount: dueRevisions.length,
        due: dueRevisions,
        upcoming: upcomingRevisions
      }
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getCatalogProblems,
  getUserProblems,
  addUserProblem,
  updateUserProblem,
  deleteUserProblem,
  getRevisionQueue
};
