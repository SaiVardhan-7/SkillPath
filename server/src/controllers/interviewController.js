const InterviewQuestion = require('../models/InterviewQuestion');
const UserInterviewProgress = require('../models/UserInterviewProgress');
const ActivityLog = require('../models/ActivityLog');

// @desc    Get all interview questions
// @route   GET /api/interview-questions
// @access  Public
const getInterviewQuestions = async (req, res, next) => {
  try {
    const { category, topic, difficulty, search } = req.query;
    const query = {};

    if (category && category !== 'All') query.category = category;
    if (topic && topic !== 'All') query.topic = topic;
    if (difficulty && difficulty !== 'All') query.difficulty = difficulty;
    if (search) query.question = { $regex: search, $options: 'i' };

    const questions = await InterviewQuestion.find(query).sort({ category: 1, difficulty: 1 });

    res.status(200).json({
      success: true,
      count: questions.length,
      data: questions
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get user's interview preparation progress
// @route   GET /api/users/me/interview-progress
// @access  Private
const getUserInterviewProgress = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const userProgress = await UserInterviewProgress.find({ userId }).populate('questionId');

    const totalPracticed = userProgress.filter((p) => p.isPracticed).length;
    const totalBookmarked = userProgress.filter((p) => p.isBookmarked).length;

    res.status(200).json({
      success: true,
      stats: {
        totalPracticed,
        totalBookmarked
      },
      data: userProgress
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Update progress for specific interview question
// @route   PUT /api/users/me/interview-progress/:id
// @access  Private
const updateQuestionProgress = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const { id } = req.params; // Question ID or Progress ID
    const { isPracticed, isBookmarked, userNotes } = req.body;

    let questionId = id;
    const isObjectId = id.match(/^[0-9a-fA-F]{24}$/);
    if (!isObjectId) {
      return res.status(400).json({ success: false, message: 'Invalid question ID' });
    }

    let progress = await UserInterviewProgress.findOne({
      userId,
      $or: [{ _id: id }, { questionId: id }]
    });

    if (!progress) {
      const question = await InterviewQuestion.findById(id);
      if (!question) {
        return res.status(404).json({ success: false, message: 'Question not found' });
      }
      progress = await UserInterviewProgress.create({
        userId,
        questionId: question._id,
        isPracticed: Boolean(isPracticed),
        isBookmarked: Boolean(isBookmarked),
        userNotes: userNotes || '',
        practicedAt: isPracticed ? new Date() : null
      });
    } else {
      if (isPracticed !== undefined) {
        progress.isPracticed = isPracticed;
        if (isPracticed && !progress.practicedAt) {
          progress.practicedAt = new Date();
          await ActivityLog.create({
            userId,
            activityType: 'interview_practiced',
            details: { questionId: progress.questionId }
          });
        }
      }
      if (isBookmarked !== undefined) progress.isBookmarked = isBookmarked;
      if (userNotes !== undefined) progress.userNotes = userNotes;
      await progress.save();
    }

    await progress.populate('questionId');

    res.status(200).json({
      success: true,
      message: 'Interview progress updated',
      data: progress
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getInterviewQuestions,
  getUserInterviewProgress,
  updateQuestionProgress
};
