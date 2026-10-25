const mongoose = require('mongoose');

const resourceSchema = new mongoose.Schema({
  title: { type: String, required: true },
  type: {
    type: String,
    enum: ['article', 'video', 'doc', 'tutorial', 'practice'],
    default: 'article'
  },
  url: { type: String, required: true },
  durationMinutes: { type: Number, default: 30 }
});

const topicSchema = new mongoose.Schema({
  topicId: { type: String, required: true },
  title: { type: String, required: true },
  description: { type: String, required: true },
  estimatedHours: { type: Number, default: 10 },
  prerequisites: [{ type: String }],
  resources: [resourceSchema]
});

const stageSchema = new mongoose.Schema({
  stageNumber: { type: Number, required: true },
  title: { type: String, required: true },
  description: { type: String, required: true },
  estimatedHours: { type: Number, default: 40 },
  topics: [topicSchema]
});

const roadmapSchema = new mongoose.Schema(
  {
    title: { type: String, required: true, trim: true },
    slug: { type: String, required: true, unique: true, lowercase: true },
    targetRole: {
      type: String,
      required: true,
      enum: [
        'Software Development Engineer',
        'Flutter Developer',
        'Frontend Developer',
        'Backend Developer',
        'Full-Stack Developer'
      ]
    },
    description: { type: String, required: true },
    estimatedWeeks: { type: Number, default: 24 },
    stages: [stageSchema]
  },
  { timestamps: true }
);

roadmapSchema.index({ targetRole: 1 });

module.exports = mongoose.model('Roadmap', roadmapSchema);
