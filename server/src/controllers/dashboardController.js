const User = require('../models/User');
const Roadmap = require('../models/Roadmap');
const RoadmapProgress = require('../models/RoadmapProgress');
const UserProblemProgress = require('../models/UserProblemProgress');
const UserProject = require('../models/UserProject');
const ActivityLog = require('../models/ActivityLog');
const { calculateStreak, getWeeklyActivity, getDSAAnalytics } = require('../services/analyticsService');
const { getPersonalizedRecommendations } = require('../services/recommendationService');

// @desc    Get consolidated dashboard data
// @route   GET /api/users/me/dashboard
// @access  Private
const getDashboardData = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const user = await User.findById(userId);

    // 1. Roadmap progress
    let roadmapProgress = await RoadmapProgress.findOne({ userId }).populate('roadmapId');
    if (!roadmapProgress && user.targetRole) {
      const defaultRoadmap = await Roadmap.findOne({ targetRole: user.targetRole });
      if (defaultRoadmap) {
        roadmapProgress = await RoadmapProgress.create({
          userId,
          roadmapId: defaultRoadmap._id,
          completedTopics: [],
          inProgressTopics: [],
          bookmarkedResources: [],
          currentStageNumber: 1
        });
        roadmapProgress.roadmapId = defaultRoadmap;
      }
    }

    let roadmapStats = {
      roadmapTitle: user.targetRole || 'Software Development Engineer',
      totalTopics: 0,
      completedTopics: 0,
      percentage: 0,
      currentStageNumber: 1,
      currentStageTitle: 'Stage 1'
    };

    if (roadmapProgress && roadmapProgress.roadmapId) {
      const stages = roadmapProgress.roadmapId.stages || [];
      let totalTopics = 0;
      stages.forEach((s) => (totalTopics += (s.topics || []).length));
      const completedCount = (roadmapProgress.completedTopics || []).length;
      const currentStage = stages.find((s) => s.stageNumber === roadmapProgress.currentStageNumber) || stages[0];

      roadmapStats = {
        roadmapId: roadmapProgress.roadmapId._id,
        roadmapTitle: roadmapProgress.roadmapId.title,
        totalTopics,
        completedTopics: completedCount,
        percentage: totalTopics > 0 ? Math.round((completedCount / totalTopics) * 100) : 0,
        currentStageNumber: roadmapProgress.currentStageNumber,
        currentStageTitle: currentStage ? currentStage.title : 'Stage 1'
      };
    }

    // 2. DSA statistics & streak
    const dsaAnalytics = await getDSAAnalytics(userId);
    const streakData = await calculateStreak(userId);
    const weeklyActivity = await getWeeklyActivity(userId);

    // 3. Active project
    const activeProject = await UserProject.findOne({
      userId,
      status: { $in: ['in_progress', 'saved'] }
    })
      .populate('projectId')
      .sort({ updatedAt: -1 });

    let activeProjectData = null;
    if (activeProject && activeProject.projectId) {
      const totalMilestones = (activeProject.projectId.milestones || []).length;
      const completedCount = (activeProject.completedMilestones || []).length;
      activeProjectData = {
        _id: activeProject._id,
        projectId: activeProject.projectId._id,
        title: activeProject.projectId.title,
        domain: activeProject.projectId.domain,
        difficulty: activeProject.projectId.difficulty,
        totalMilestones,
        completedMilestones: completedCount,
        progressPercentage: totalMilestones > 0 ? Math.round((completedCount / totalMilestones) * 100) : 0,
        status: activeProject.status
      };
    }

    // 4. Overdue/due revisions
    const now = new Date();
    const endOfToday = new Date();
    endOfToday.setHours(23, 59, 59, 999);

    const dueRevisions = await UserProblemProgress.find({
      userId,
      status: 'solved',
      revisionScheduledDate: { $lte: endOfToday }
    })
      .sort({ revisionScheduledDate: 1 })
      .limit(5);

    // 5. Recent activity logs (last 5)
    const recentActivity = await ActivityLog.find({ userId })
      .sort({ timestamp: -1 })
      .limit(5);

    // 6. Smart Rule-Based Recommendations
    const recommendations = await getPersonalizedRecommendations(userId, user);

    res.status(200).json({
      success: true,
      data: {
        user: {
          id: user._id,
          name: user.name,
          email: user.email,
          targetRole: user.targetRole,
          currentSkillLevel: user.currentSkillLevel,
          dailyStudyTimeMinutes: user.dailyStudyTimeMinutes,
          learningGoals: user.learningGoals
        },
        roadmap: roadmapStats,
        dsa: {
          totalSolved: dsaAnalytics.totalSolved,
          easySolved: dsaAnalytics.easySolved,
          mediumSolved: dsaAnalytics.mediumSolved,
          hardSolved: dsaAnalytics.hardSolved,
          totalAttempted: dsaAnalytics.totalAttempted,
          dueRevisionsCount: dueRevisions.length
        },
        streak: {
          currentStreak: streakData.currentStreak,
          longestStreak: streakData.longestStreak,
          activeDaysCount: streakData.activeDaysCount
        },
        activeProject: activeProjectData,
        dueRevisions,
        weeklyActivity,
        recentActivity,
        recommendations
      }
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get detailed user analytics
// @route   GET /api/users/me/analytics
// @access  Private
const getUserAnalytics = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const dsaAnalytics = await getDSAAnalytics(userId);
    const streakData = await calculateStreak(userId);
    const weeklyActivity = await getWeeklyActivity(userId);

    const userProjects = await UserProject.find({ userId }).populate('projectId');
    const completedProjectsCount = userProjects.filter((p) => p.status === 'completed').length;
    const inProgressProjectsCount = userProjects.filter((p) => p.status === 'in_progress').length;

    res.status(200).json({
      success: true,
      data: {
        streak: streakData,
        dsa: dsaAnalytics,
        weeklyActivity,
        projects: {
          completedCount: completedProjectsCount,
          inProgressCount: inProgressProjectsCount,
          totalSaved: userProjects.length
        }
      }
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get full activity log history
// @route   GET /api/users/me/activity
// @access  Private
const getUserActivityLogs = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const logs = await ActivityLog.find({ userId }).sort({ timestamp: -1 }).limit(30);

    res.status(200).json({
      success: true,
      count: logs.length,
      data: logs
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getDashboardData,
  getUserAnalytics,
  getUserActivityLogs
};
