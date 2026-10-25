const mongoose = require('mongoose');

const dsaCategories = [
  'Arrays',
  'Strings',
  'Hashing',
  'Two pointers',
  'Sliding window',
  'Linked lists',
  'Stacks and queues',
  'Binary search',
  'Trees',
  'Graphs',
  'Recursion and backtracking',
  'Greedy algorithms',
  'Dynamic programming',
  'Heaps',
  'Tries'
];

const dsaProblemSchema = new mongoose.Schema(
  {
    title: { type: String, required: true, trim: true },
    url: { type: String, required: true, trim: true },
    platform: {
      type: String,
      enum: ['LeetCode', 'Codeforces', 'GeeksforGeeks', 'HackerRank', 'Other'],
      default: 'LeetCode'
    },
    topic: {
      type: String,
      required: true,
      enum: dsaCategories
    },
    difficulty: {
      type: String,
      required: true,
      enum: ['Easy', 'Medium', 'Hard']
    },
    isPreset: {
      type: Boolean,
      default: true
    },
    suggestedTimeMinutes: {
      type: Number,
      default: 30
    }
  },
  { timestamps: true }
);

dsaProblemSchema.index({ topic: 1, difficulty: 1 });
dsaProblemSchema.index({ platform: 1 });

module.exports = {
  DSAProblem: mongoose.model('DSAProblem', dsaProblemSchema),
  dsaCategories
};
