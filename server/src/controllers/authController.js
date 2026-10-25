const User = require('../models/User');
const Roadmap = require('../models/Roadmap');
const RoadmapProgress = require('../models/RoadmapProgress');
const jwt = require('jsonwebtoken');

// @desc    Register a new user
// @route   POST /api/auth/register
// @access  Public
const register = async (req, res, next) => {
  try {
    const { name, email, password, targetRole, currentSkillLevel, dailyStudyTimeMinutes, learningGoals } = req.body;

    if (!name || !email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Please provide name, email, and password'
      });
    }

    const userExists = await User.findOne({ email });
    if (userExists) {
      return res.status(400).json({
        success: false,
        message: 'User already exists with this email'
      });
    }

    const user = await User.create({
      name,
      email,
      password,
      targetRole: targetRole || 'Software Development Engineer',
      currentSkillLevel: currentSkillLevel || 'Beginner',
      dailyStudyTimeMinutes: dailyStudyTimeMinutes || 60,
      learningGoals: learningGoals || [],
      isOnboarded: Boolean(targetRole)
    });

    // Auto-assign matching starter roadmap
    const roadmap = await Roadmap.findOne({ targetRole: user.targetRole });
    if (roadmap) {
      await RoadmapProgress.create({
        userId: user._id,
        roadmapId: roadmap._id,
        currentStageNumber: 1
      });
    }

    const accessToken = user.generateAccessToken();
    const refreshToken = user.generateRefreshToken();

    user.refreshToken = refreshToken;
    await user.save();

    res.status(201).json({
      success: true,
      message: 'Account created successfully',
      data: {
        user: {
          id: user._id,
          name: user.name,
          email: user.email,
          targetRole: user.targetRole,
          currentSkillLevel: user.currentSkillLevel,
          dailyStudyTimeMinutes: user.dailyStudyTimeMinutes,
          learningGoals: user.learningGoals,
          isOnboarded: user.isOnboarded
        },
        accessToken,
        refreshToken
      }
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Login user
// @route   POST /api/auth/login
// @access  Public
const login = async (req, res, next) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({
        success: false,
        message: 'Please provide email and password'
      });
    }

    const user = await User.findOne({ email }).select('+password');
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password'
      });
    }

    const isMatch = await user.matchPassword(password);
    if (!isMatch) {
      return res.status(401).json({
        success: false,
        message: 'Invalid email or password'
      });
    }

    const accessToken = user.generateAccessToken();
    const refreshToken = user.generateRefreshToken();

    user.refreshToken = refreshToken;
    await user.save();

    res.status(200).json({
      success: true,
      message: 'Logged in successfully',
      data: {
        user: {
          id: user._id,
          name: user.name,
          email: user.email,
          targetRole: user.targetRole,
          currentSkillLevel: user.currentSkillLevel,
          dailyStudyTimeMinutes: user.dailyStudyTimeMinutes,
          learningGoals: user.learningGoals,
          isOnboarded: user.isOnboarded
        },
        accessToken,
        refreshToken
      }
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Refresh access token
// @route   POST /api/auth/refresh
// @access  Public
const refresh = async (req, res, next) => {
  try {
    const { refreshToken } = req.body;

    if (!refreshToken) {
      return res.status(401).json({
        success: false,
        message: 'Refresh token required'
      });
    }

    const decoded = jwt.verify(
      refreshToken,
      process.env.JWT_REFRESH_SECRET || 'skillpath_jwt_refresh_secret_key_production_ready_2026'
    );

    const user = await User.findById(decoded.id).select('+refreshToken');
    if (!user || user.refreshToken !== refreshToken) {
      return res.status(401).json({
        success: false,
        message: 'Invalid refresh token'
      });
    }

    const newAccessToken = user.generateAccessToken();
    const newRefreshToken = user.generateRefreshToken();

    user.refreshToken = newRefreshToken;
    await user.save();

    res.status(200).json({
      success: true,
      data: {
        accessToken: newAccessToken,
        refreshToken: newRefreshToken
      }
    });
  } catch (error) {
    return res.status(401).json({
      success: false,
      message: 'Invalid or expired refresh token'
    });
  }
};

// @desc    Get current user profile
// @route   GET /api/auth/me
// @access  Private
const getMe = async (req, res, next) => {
  try {
    const user = await User.findById(req.user._id);
    res.status(200).json({
      success: true,
      data: user
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Update user profile & onboarding
// @route   PUT /api/auth/profile
// @access  Private
const updateProfile = async (req, res, next) => {
  try {
    const { name, targetRole, currentSkillLevel, dailyStudyTimeMinutes, learningGoals, isOnboarded } = req.body;

    const user = await User.findById(req.user._id);
    if (!user) {
      return res.status(404).json({ success: false, message: 'User not found' });
    }

    if (name) user.name = name;
    if (targetRole) {
      user.targetRole = targetRole;
      // If targetRole changed, ensure a RoadmapProgress exists for it
      const roadmap = await Roadmap.findOne({ targetRole });
      if (roadmap) {
        let progress = await RoadmapProgress.findOne({ userId: user._id, roadmapId: roadmap._id });
        if (!progress) {
          await RoadmapProgress.create({
            userId: user._id,
            roadmapId: roadmap._id,
            currentStageNumber: 1
          });
        }
      }
    }
    if (currentSkillLevel) user.currentSkillLevel = currentSkillLevel;
    if (dailyStudyTimeMinutes) user.dailyStudyTimeMinutes = dailyStudyTimeMinutes;
    if (learningGoals) user.learningGoals = learningGoals;
    if (isOnboarded !== undefined) user.isOnboarded = isOnboarded;

    await user.save();

    res.status(200).json({
      success: true,
      message: 'Profile updated successfully',
      data: user
    });
  } catch (error) {
    next(error);
  }
};

// @desc    Logout user
// @route   POST /api/auth/logout
// @access  Private
const logout = async (req, res, next) => {
  try {
    const user = await User.findById(req.user._id);
    if (user) {
      user.refreshToken = null;
      await user.save();
    }
    res.status(200).json({
      success: true,
      message: 'Logged out successfully'
    });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  register,
  login,
  refresh,
  getMe,
  updateProfile,
  logout
};
