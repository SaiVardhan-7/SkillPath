const mongoose = require('mongoose');

const interviewQuestionSchema = new mongoose.Schema(
  {
    topic: { type: String, required: true },
    category: {
      type: String,
      enum: ['Technical', 'Behavioral', 'System Design'],
      default: 'Technical'
    },
    question: { type: String, required: true },
    answerKeyPoints: [{ type: String }],
    difficulty: {
      type: String,
      enum: ['Easy', 'Medium', 'Hard'],
      default: 'Medium'
    },
    companyTags: [{ type: String }]
  },
  { timestamps: true }
);

interviewQuestionSchema.index({ topic: 1, difficulty: 1 });
interviewQuestionSchema.index({ category: 1 });

module.exports = mongoose.model('InterviewQuestion', interviewQuestionSchema);
