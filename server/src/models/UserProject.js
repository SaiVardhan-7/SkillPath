const mongoose = require('mongoose');

const userProjectSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true
    },
    projectId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Project',
      required: true,
      index: true
    },
    status: {
      type: String,
      enum: ['saved', 'in_progress', 'completed'],
      default: 'saved'
    },
    completedMilestones: [{ type: String }],
    githubUrl: { type: String, default: '', trim: true },
    liveDemoUrl: { type: String, default: '', trim: true },
    notes: { type: String, default: '' },
    userResumeBullets: [{ type: String }],
    startedAt: { type: Date, default: null },
    completedAt: { type: Date, default: null }
  },
  { timestamps: true }
);

userProjectSchema.index({ userId: 1, projectId: 1 }, { unique: true });
userProjectSchema.index({ userId: 1, status: 1 });

module.exports = mongoose.model('UserProject', userProjectSchema);
