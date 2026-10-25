const Roadmap = require('../models/Roadmap');
const RoadmapProgress = require('../models/RoadmapProgress');
const ActivityLog = require('../models/ActivityLog');
const User = require('../models/User');

// @desc    Get all roadmaps catalog
// @route   GET /api/roadmaps
// @access  Public
const getAllRoadmaps = async (req, res, next) => {
  try {
    const roadmaps = await Roadmap.find().select('title slug targetRole description estimatedWeeks stages.title stages.stageNumber');
    res.status(200).json({
      success: true,
      count: roadmaps.length,
      data: roadmaps
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get roadmap by ID or slug
// @route   GET /api/roadmaps/:id
// @access  Public
const getRoadmapById = async (req, res, next) => {
  try {
    const { id } = req.params;
    let roadmap;
    if (id.match(/^[0-9a-fA-F]{24}$/)) {
      roadmap = await Roadmap.findById(id);
    } else {
      roadmap = await Roadmap.findOne({ slug: id.toLowerCase() });
    }

    if (!roadmap) {
      return res.status(404).json({ success: false, message: 'Roadmap not found' });
    }

    res.status(200).json({ success: true, data: roadmap });
  } catch (error) {
    next(error);
  }
};

// @desc    Get current user's active roadmap with topic unlock state & progress
// @route   GET /api/users/me/roadmap
// @access  Private
const getUserRoadmap = async (req, res, next) => {
  try {
    const user = await User.findById(req.user._id);
    const { roadmapId } = req.query;

    let targetRoadmap;
    if (roadmapId) {
      targetRoadmap = await Roadmap.findById(roadmapId);
    } else {
      targetRoadmap = await Roadmap.findOne({ targetRole: user.targetRole });
      if (!targetRoadmap) {
        targetRoadmap = await Roadmap.findOne();
      }
    }

    if (!targetRoadmap) {
      return res.status(404).json({
        success: false,
        message: 'No roadmap found for user target role'
      });
    }

    let progress = await RoadmapProgress.findOne({
      userId: user._id,
      roadmapId: targetRoadmap._id
    });

    if (!progress) {
      progress = await RoadmapProgress.create({
        userId: user._id,
        roadmapId: targetRoadmap._id,
        completedTopics: [],
        inProgressTopics: [],
        bookmarkedResources: [],
        currentStageNumber: 1
      });
    }

    const completedSet = new Set(progress.completedTopics || []);
    const inProgressSet = new Set(progress.inProgressTopics || []);
    const bookmarkedUrls = new Set((progress.bookmarkedResources || []).map((r) => r.url));

    let totalTopics = 0;
    let totalCompleted = 0;

    // Build enriched stage structure with unlocked calculation
    const enrichedStages = targetRoadmap.stages.map((stage) => {
      let stageTotal = stage.topics.length;
      let stageCompleted = 0;

      const enrichedTopics = stage.topics.map((topic) => {
        totalTopics++;
        const isCompleted = completedSet.has(topic.topicId);
        const isInProgress = inProgressSet.has(topic.topicId);

        if (isCompleted) {
          totalCompleted++;
          stageCompleted++;
        }

        // Topic is unlocked if no prerequisites OR all prerequisites are completed
        const missingPrereqs = (topic.prerequisites || []).filter(
          (prereqId) => !completedSet.has(prereqId)
        );
        const isUnlocked = missingPrereqs.length === 0;

        let status = 'locked';
        if (isCompleted) {
          status = 'completed';
        } else if (isInProgress) {
          status = 'in_progress';
        } else if (isUnlocked) {
          status = 'ready';
        }

        const enrichedResources = (topic.resources || []).map((res) => ({
          ...res.toObject(),
          isBookmarked: bookmarkedUrls.has(res.url)
        }));

        return {
          ...topic.toObject(),
          isUnlocked,
          status,
          missingPrerequisites: missingPrereqs,
          resources: enrichedResources
        };
      });

      const stagePercent = stageTotal > 0 ? Math.round((stageCompleted / stageTotal) * 100) : 0;

      return {
        ...stage.toObject(),
        topics: enrichedTopics,
        totalTopics: stageTotal,
        completedTopics: stageCompleted,
        progressPercentage: stagePercent
      };
    });

    const overallPercentage = totalTopics > 0 ? Math.round((totalCompleted / totalTopics) * 100) : 0;

    res.status(200).json({
      success: true,
      data: {
        roadmap: {
          _id: targetRoadmap._id,
          title: targetRoadmap.title,
          slug: targetRoadmap.slug,
          targetRole: targetRoadmap.targetRole,
          description: targetRoadmap.description,
          estimatedWeeks: targetRoadmap.estimatedWeeks,
          stages: enrichedStages
        },
        progress: {
          totalTopics,
          completedTopicsCount: totalCompleted,
          overallPercentage,
          completedTopicIds: progress.completedTopics,
          inProgressTopicIds: progress.inProgressTopics,
          bookmarkedResources: progress.bookmarkedResources,
          currentStageNumber: progress.currentStageNumber
        }
      }
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Update topic status (start, complete, bookmark resource)
// @route   PUT /api/users/me/roadmap/progress
// @access  Private
const updateRoadmapProgress = async (req, res, next) => {
  try {
    const { roadmapId, topicId, status, resourceBookmark, currentStageNumber } = req.body;
    const userId = req.user._id;

    let targetRoadmapId = roadmapId;
    if (!targetRoadmapId) {
      const user = await User.findById(userId);
      const defaultRoadmap = await Roadmap.findOne({ targetRole: user.targetRole });
      if (defaultRoadmap) targetRoadmapId = defaultRoadmap._id;
    }

    let progress = await RoadmapProgress.findOne({
      userId,
      roadmapId: targetRoadmapId
    });

    if (!progress) {
      progress = await RoadmapProgress.create({
        userId,
        roadmapId: targetRoadmapId,
        completedTopics: [],
        inProgressTopics: [],
        bookmarkedResources: []
      });
    }

    if (currentStageNumber) {
      progress.currentStageNumber = currentStageNumber;
    }

    // Status can be: 'completed', 'in_progress', 'not_started'
    if (topicId && status) {
      progress.completedTopics = progress.completedTopics.filter((id) => id !== topicId);
      progress.inProgressTopics = progress.inProgressTopics.filter((id) => id !== topicId);

      if (status === 'completed') {
        progress.completedTopics.push(topicId);
        // Log activity
        await ActivityLog.create({
          userId,
          activityType: 'topic_completed',
          details: { topicId, roadmapId: targetRoadmapId }
        });
      } else if (status === 'in_progress') {
        progress.inProgressTopics.push(topicId);
      }
    }

    // Toggle resource bookmark
    if (resourceBookmark && resourceBookmark.url) {
      const existingIdx = progress.bookmarkedResources.findIndex(
        (r) => r.url === resourceBookmark.url
      );
      if (existingIdx > -1) {
        progress.bookmarkedResources.splice(existingIdx, 1);
      } else {
        progress.bookmarkedResources.push({
          topicId: resourceBookmark.topicId || 'general',
          title: resourceBookmark.title,
          url: resourceBookmark.url,
          type: resourceBookmark.type || 'article',
          addedAt: new Date()
        });
      }
    }

    progress.lastActiveDate = new Date();
    await progress.save();

    res.status(200).json({
      success: true,
      message: 'Roadmap progress updated',
      data: progress
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getAllRoadmaps,
  getRoadmapById,
  getUserRoadmap,
  updateRoadmapProgress
};
