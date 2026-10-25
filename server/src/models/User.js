const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

const userSchema = new mongoose.Schema(
  {
    name: {
      type: String,
      required: [true, 'Please provide a name'],
      trim: true,
      maxlength: [60, 'Name cannot exceed 60 characters']
    },
    email: {
      type: String,
      required: [true, 'Please provide an email'],
      unique: true,
      lowercase: true,
      trim: true,
      match: [
        /^\w+([.-]?\w+)*@\w+([.-]?\w+)*(\.\w{2,3})+$/,
        'Please provide a valid email address'
      ]
    },
    password: {
      type: String,
      required: [true, 'Please provide a password'],
      minlength: [6, 'Password must be at least 6 characters'],
      select: false
    },
    targetRole: {
      type: String,
      enum: [
        'Software Development Engineer',
        'Flutter Developer',
        'Frontend Developer',
        'Backend Developer',
        'Full-Stack Developer'
      ],
      default: 'Software Development Engineer'
    },
    currentSkillLevel: {
      type: String,
      enum: ['Beginner', 'Intermediate', 'Advanced'],
      default: 'Beginner'
    },
    dailyStudyTimeMinutes: {
      type: Number,
      default: 60,
      min: 15,
      max: 480
    },
    learningGoals: {
      type: [String],
      default: []
    },
    isOnboarded: {
      type: Boolean,
      default: false
    },
    refreshToken: {
      type: String,
      default: null,
      select: false
    }
  },
  {
    timestamps: true
  }
);

userSchema.pre('save', async function (next) {
  if (!this.isModified('password')) {
    return next();
  }
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
  next();
});

userSchema.methods.matchPassword = async function (enteredPassword) {
  return await bcrypt.compare(enteredPassword, this.password);
};

userSchema.methods.generateAccessToken = function () {
  return jwt.sign(
    { id: this._id, role: this.targetRole },
    process.env.JWT_ACCESS_SECRET || 'skillpath_jwt_access_secret_key_production_ready_2026',
    { expiresIn: process.env.JWT_ACCESS_EXPIRES_IN || '1h' }
  );
};

userSchema.methods.generateRefreshToken = function () {
  return jwt.sign(
    { id: this._id },
    process.env.JWT_REFRESH_SECRET || 'skillpath_jwt_refresh_secret_key_production_ready_2026',
    { expiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '30d' }
  );
};

module.exports = mongoose.model('User', userSchema);
