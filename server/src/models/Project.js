const mongoose = require('mongoose');

const milestoneSchema = new mongoose.Schema({
  milestoneId: { type: String, required: true },
  title: { type: String, required: true },
  description: { type: String, required: true },
  testingCriteria: { type: String, default: '' }
});

const stepSchema = new mongoose.Schema({
  stepNumber: { type: Number, required: true },
  title: { type: String, required: true },
  description: { type: String, required: true }
});

const projectSchema = new mongoose.Schema(
  {
    title: { type: String, required: true, trim: true },
    slug: { type: String, required: true, unique: true, lowercase: true },
    domain: {
      type: String,
      required: true,
      enum: [
        'Flutter development',
        'Web development',
        'MERN stack',
        'Artificial intelligence',
        'Data science',
        'Developer productivity tools'
      ]
    },
    difficulty: {
      type: String,
      required: true,
      enum: ['Beginner', 'Intermediate', 'Advanced']
    },
    requiredTech: [{ type: String }],
    estimatedHours: { type: Number, default: 20 },
    prerequisites: [{ type: String }],
    description: { type: String, required: true },
    learningObjectives: [{ type: String }],
    stepByStepPlan: [stepSchema],
    milestones: [milestoneSchema],
    suggestedResumeBullets: [{ type: String }]
  },
  { timestamps: true }
);

projectSchema.index({ domain: 1, difficulty: 1 });

module.exports = mongoose.model('Project', projectSchema);
