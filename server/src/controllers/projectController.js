const Project = require('../models/Project');
const UserProject = require('../models/UserProject');
const ActivityLog = require('../models/ActivityLog');
const { generateProjectResumeBullets } = require('../services/resumeService');

// @desc    Get all catalog projects
// @route   GET /api/projects
// @access  Public
const getAllProjects = async (req, res, next) => {
  try {
    const { domain, difficulty, search } = req.query;
    const query = {};

    if (domain && domain !== 'All') query.domain = domain;
    if (difficulty && difficulty !== 'All') query.difficulty = difficulty;
    if (search) query.title = { $regex: search, $options: 'i' };

    const projects = await Project.find(query).sort({ difficulty: 1, createdAt: -1 });

    res.status(200).json({
      success: true,
      count: projects.length,
      data: projects
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Get single project details
// @route   GET /api/projects/:id
// @access  Public
const getProjectById = async (req, res, next) => {
  try {
    const { id } = req.params;
    let project;
    if (id.match(/^[0-9a-fA-F]{24}$/)) {
      project = await Project.findById(id);
    } else {
      project = await Project.findOne({ slug: id.toLowerCase() });
    }

    if (!project) {
      return res.status(404).json({ success: false, message: 'Project not found' });
    }

    res.status(200).json({ success: true, data: project });
  } catch (error) {
    next(error);
  }
};

// @desc    Get current user's tracked projects
// @route   GET /api/users/me/projects
// @access  Private
const getUserProjects = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const { status } = req.query;

    const query = { userId };
    if (status && status !== 'All') query.status = status;

    const userProjects = await UserProject.find(query)
      .populate('projectId')
      .sort({ updatedAt: -1 });

    const enriched = userProjects
      .filter((up) => up.projectId != null)
      .map((up) => {
        const totalMilestones = (up.projectId.milestones || []).length;
        const completedCount = (up.completedMilestones || []).length;
        const progressPercentage =
          totalMilestones > 0 ? Math.round((completedCount / totalMilestones) * 100) : 0;

        return {
          ...up.toObject(),
          totalMilestones,
          completedMilestonesCount: completedCount,
          progressPercentage
        };
      });

    res.status(200).json({
      success: true,
      count: enriched.length,
      data: enriched
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Start or save a project
// @route   POST /api/users/me/projects
// @access  Private
const startOrSaveProject = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const { projectId, status } = req.body;

    if (!projectId) {
      return res.status(400).json({ success: false, message: 'Project ID is required' });
    }

    const project = await Project.findById(projectId);
    if (!project) {
      return res.status(404).json({ success: false, message: 'Project not found' });
    }

    let userProject = await UserProject.findOne({ userId, projectId });
    if (userProject) {
      if (status && userProject.status !== status) {
        userProject.status = status;
        if (status === 'in_progress' && !userProject.startedAt) {
          userProject.startedAt = new Date();
        }
        await userProject.save();
      }
    } else {
      userProject = await UserProject.create({
        userId,
        projectId,
        status: status || 'saved',
        completedMilestones: [],
        startedAt: status === 'in_progress' ? new Date() : null
      });
    }

    await userProject.populate('projectId');

    res.status(201).json({
      success: true,
      message: `Project ${userProject.status === 'in_progress' ? 'started' : 'saved'} successfully`,
      data: userProject
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Update project progress (milestone completion, repo links, notes)
// @route   PUT /api/users/me/projects/:id
// @access  Private
const updateProjectProgress = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const { id } = req.params;
    const { milestoneId, completed, githubUrl, liveDemoUrl, notes, status, userResumeBullets } = req.body;

    let userProject = await UserProject.findOne({ _id: id, userId }).populate('projectId');
    if (!userProject) {
      // Check if ID is projectId instead
      userProject = await UserProject.findOne({ projectId: id, userId }).populate('projectId');
    }

    if (!userProject) {
      return res.status(404).json({ success: false, message: 'Tracked project not found' });
    }

    if (githubUrl !== undefined) userProject.githubUrl = githubUrl;
    if (liveDemoUrl !== undefined) userProject.liveDemoUrl = liveDemoUrl;
    if (notes !== undefined) userProject.notes = notes;
    if (status) userProject.status = status;
    if (userResumeBullets) userProject.userResumeBullets = userResumeBullets;

    // Toggle milestone
    if (milestoneId) {
      const currentCompleted = new Set(userProject.completedMilestones || []);
      if (completed === false) {
        currentCompleted.delete(milestoneId);
      } else {
        currentCompleted.add(milestoneId);
        // Log milestone completion
        await ActivityLog.create({
          userId,
          activityType: 'project_milestone',
          details: {
            projectId: userProject.projectId._id,
            projectTitle: userProject.projectId.title,
            milestoneId
          }
        });
      }
      userProject.completedMilestones = Array.from(currentCompleted);

      // Auto update status to in_progress or completed
      const totalMilestones = (userProject.projectId.milestones || []).length;
      if (userProject.completedMilestones.length === totalMilestones && totalMilestones > 0) {
        userProject.status = 'completed';
        userProject.completedAt = new Date();
      } else if (userProject.completedMilestones.length > 0 && userProject.status === 'saved') {
        userProject.status = 'in_progress';
        if (!userProject.startedAt) userProject.startedAt = new Date();
      }
    }

    await userProject.save();

    const totalMilestones = (userProject.projectId.milestones || []).length;
    const completedCount = userProject.completedMilestones.length;
    const progressPercentage =
      totalMilestones > 0 ? Math.round((completedCount / totalMilestones) * 100) : 0;

    res.status(200).json({
      success: true,
      message: 'Project progress updated',
      data: {
        ...userProject.toObject(),
        totalMilestones,
        completedMilestonesCount: completedCount,
        progressPercentage
      }
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Generate resume bullets for a project
// @route   POST /api/users/me/projects/:id/resume-bullets
// @access  Private
const generateResumeBullets = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const { id } = req.params;

    let userProject = await UserProject.findOne({ _id: id, userId }).populate('projectId');
    if (!userProject) {
      userProject = await UserProject.findOne({ projectId: id, userId }).populate('projectId');
    }

    if (!userProject) {
      return res.status(404).json({ success: false, message: 'Tracked project not found' });
    }

    const bullets = generateProjectResumeBullets(
      userProject.projectId,
      userProject.completedMilestones
    );

    // Save as current user resume bullets if not manually customized yet
    if (!userProject.userResumeBullets || userProject.userResumeBullets.length === 0) {
      userProject.userResumeBullets = bullets;
      await userProject.save();
    }

    res.status(200).json({
      success: true,
      data: {
        suggestedBullets: bullets,
        userResumeBullets: userProject.userResumeBullets
      }
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Delete tracked project
// @route   DELETE /api/users/me/projects/:id
// @access  Private
const deleteUserProject = async (req, res, next) => {
  try {
    const userId = req.user._id;
    const { id } = req.params;

    const userProject = await UserProject.findOneAndDelete({ _id: id, userId });
    if (!userProject) {
      return res.status(404).json({ success: false, message: 'Tracked project not found' });
    }

    res.status(200).json({
      success: true,
      message: 'Project removed from your learning list'
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getAllProjects,
  getProjectById,
  getUserProjects,
  startOrSaveProject,
  updateProjectProgress,
  generateResumeBullets,
  deleteUserProject
};
