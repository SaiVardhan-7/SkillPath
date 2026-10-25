const mongoose = require('mongoose');

const bookmarkedResourceSchema = new mongoose.Schema({
  topicId: { type: String, required: true },
  title: { type: String, required: true },
  url: { type: String, required: true },
  type: { type: String, default: 'article' },
  addedAt: { type: Date, default: Date.now }
});

const roadmapProgressSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      index: true
    },
    roadmapId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Roadmap',
      required: true,
      index: true
    },
    completedTopics: [{ type: String }],
    inProgressTopics: [{ type: String }],
    bookmarkedResources: [bookmarkedResourceSchema],
    currentStageNumber: { type: Number, default: 1 },
    lastActiveDate: { type: Date, default: Date.now }
  },
  { timestamps: true }
);

roadmapProgressSchema.index({ userId: 1, roadmapId: 1 }, { unique: true });

module.exports = mongoose.model('RoadmapProgress', roadmapProgressSchema);
