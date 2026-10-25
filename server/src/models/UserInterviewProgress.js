const mongoose = require('mongoose');

const userInterviewProgressSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true
    },
    questionId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'InterviewQuestion',
      required: true,
      index: true
    },
    isPracticed: {
      type: Boolean,
      default: false
    },
    isBookmarked: {
      type: Boolean,
      default: false
    },
    userNotes: {
      type: String,
      default: ''
    },
    practicedAt: {
      type: Date,
      default: null
    }
  },
  { timestamps: true }
);

userInterviewProgressSchema.index({ userId: 1, questionId: 1 }, { unique: true });

module.exports = mongoose.model('UserInterviewProgress', userInterviewProgressSchema);
