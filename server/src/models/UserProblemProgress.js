const mongoose = require('mongoose');

const userProblemProgressSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true
    },
    problemId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'DSAProblem',
      default: null,
      index: true
    },
    title: { type: String, required: true, trim: true },
    url: { type: String, required: true, trim: true },
    platform: {
      type: String,
      enum: ['LeetCode', 'Codeforces', 'GeeksforGeeks', 'HackerRank', 'Other'],
      default: 'LeetCode'
    },
    topic: { type: String, required: true },
    difficulty: {
      type: String,
      enum: ['Easy', 'Medium', 'Hard'],
      required: true
    },
    status: {
      type: String,
      enum: ['unsolved', 'attempted', 'solved'],
      default: 'attempted'
    },
    isBookmarked: {
      type: Boolean,
      default: false,
      index: true
    },
    notes: {
      type: String,
      default: ''
    },
    mistakes: {
      type: String,
      default: ''
    },
    observations: {
      type: String,
      default: ''
    },
    dateSolved: {
      type: Date,
      default: null
    },
    revisionScheduledDate: {
      type: Date,
      default: null,
      index: true
    },
    revisionIntervalDays: {
      type: Number,
      default: 3
    },
    revisionCount: {
      type: Number,
      default: 0
    }
  },
  { timestamps: true }
);

userProblemProgressSchema.index({ userId: 1, status: 1 });
userProblemProgressSchema.index({ userId: 1, problemId: 1 });
userProblemProgressSchema.index({ userId: 1, revisionScheduledDate: 1 });

module.exports = mongoose.model('UserProblemProgress', userProblemProgressSchema);
