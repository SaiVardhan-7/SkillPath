const UserProblemProgress = require('../models/UserProblemProgress');
const ActivityLog = require('../models/ActivityLog');
const RoadmapProgress = require('../models/RoadmapProgress');
const UserProject = require('../models/UserProject');

/**
 * Calculates current and longest streak from activity logs
 */
const calculateStreak = async (userId) => {
  const activities = await ActivityLog.find({ userId })
    .sort({ timestamp: -1 })
    .select('timestamp');

  if (activities.length === 0) {
    return { currentStreak: 0, longestStreak: 0, activeDaysCount: 0 };
  }

  // Normalize dates to YYYY-MM-DD
  const dateSet = new Set();
  activities.forEach((act) => {
    const d = new Date(act.timestamp);
    const dateStr = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
    dateSet.add(dateStr);
  });

  const sortedDates = Array.from(dateSet).sort().reverse();
  const activeDaysCount = sortedDates.length;

  const today = new Date();
  const todayStr = `${today.getFullYear()}-${String(today.getMonth() + 1).padStart(2, '0')}-${String(today.getDate()).padStart(2, '0')}`;

  const yesterday = new Date();
  yesterday.setDate(yesterday.getDate() - 1);
  const yesterdayStr = `${yesterday.getFullYear()}-${String(yesterday.getMonth() + 1).padStart(2, '0')}-${String(yesterday.getDate()).padStart(2, '0')}`;

  let currentStreak = 0;
  let checkDate = new Date();

  // If user has activity today, start from today. If not, but has activity yesterday, start from yesterday.
  if (dateSet.has(todayStr)) {
    checkDate = new Date();
  } else if (dateSet.has(yesterdayStr)) {
    checkDate = new Date(yesterday);
  } else {
    // Streak broken
    currentStreak = 0;
  }

  if (dateSet.has(todayStr) || dateSet.has(yesterdayStr)) {
    while (true) {
      const curStr = `${checkDate.getFullYear()}-${String(checkDate.getMonth() + 1).padStart(2, '0')}-${String(checkDate.getDate()).padStart(2, '0')}`;
      if (dateSet.has(curStr)) {
        currentStreak++;
        checkDate.setDate(checkDate.getDate() - 1);
      } else {
        break;
      }
    }
  }

  // Calculate longest streak
  let longestStreak = 0;
  if (sortedDates.length > 0) {
    let tempStreak = 1;
    longestStreak = 1;
    for (let i = 0; i < sortedDates.length - 1; i++) {
      const d1 = new Date(sortedDates[i]);
      const d2 = new Date(sortedDates[i + 1]);
      const diffTime = Math.abs(d1 - d2);
      const diffDays = Math.round(diffTime / (1000 * 60 * 60 * 24));

      if (diffDays === 1) {
        tempStreak++;
        if (tempStreak > longestStreak) longestStreak = tempStreak;
      } else {
        tempStreak = 1;
      }
    }
  }

  return { currentStreak, longestStreak, activeDaysCount };
};

/**
 * Calculates last 7 days activity counts
 */
const getWeeklyActivity = async (userId) => {
  const sevenDaysAgo = new Date();
  sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 6);
  sevenDaysAgo.setHours(0, 0, 0, 0);

  const logs = await ActivityLog.find({
    userId,
    timestamp: { $gte: sevenDaysAgo }
  });

  const daysMap = {};
  for (let i = 6; i >= 0; i--) {
    const d = new Date();
    d.setDate(d.getDate() - i);
    const dayLabel = d.toLocaleDateString('en-US', { weekday: 'short' });
    const dateKey = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
    daysMap[dateKey] = { day: dayLabel, date: dateKey, count: 0 };
  }

  logs.forEach((log) => {
    const d = new Date(log.timestamp);
    const dateKey = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
    if (daysMap[dateKey]) {
      daysMap[dateKey].count++;
    }
  });

  return Object.values(daysMap);
};

/**
 * Calculates DSA analytics: counts by difficulty, topic-wise, weak topics, revisions
 */
const getDSAAnalytics = async (userId) => {
  const problems = await UserProblemProgress.find({ userId });

  let totalSolved = 0;
  let easySolved = 0;
  let mediumSolved = 0;
  let hardSolved = 0;
  let totalAttempted = 0;

  const topicStats = {};

  const now = new Date();
  let dueRevisionsCount = 0;

  problems.forEach((p) => {
    if (!topicStats[p.topic]) {
      topicStats[p.topic] = { topic: p.topic, solved: 0, attempted: 0, total: 0 };
    }
    topicStats[p.topic].total++;

    if (p.status === 'solved') {
      totalSolved++;
      topicStats[p.topic].solved++;
      if (p.difficulty === 'Easy') easySolved++;
      else if (p.difficulty === 'Medium') mediumSolved++;
      else if (p.difficulty === 'Hard') hardSolved++;

      if (p.revisionScheduledDate && new Date(p.revisionScheduledDate) <= now) {
        dueRevisionsCount++;
      }
    } else if (p.status === 'attempted') {
      totalAttempted++;
      topicStats[p.topic].attempted++;
    }
  });

  // Calculate weak topics: topics where user attempted or has 0 solved vs attempted
  const weakTopics = Object.values(topicStats)
    .filter((t) => t.attempted > 0 && t.solved === 0)
    .map((t) => t.topic);

  return {
    totalSolved,
    totalAttempted,
    easySolved,
    mediumSolved,
    hardSolved,
    topicStats: Object.values(topicStats),
    weakTopics: weakTopics.length > 0 ? weakTopics : ['Dynamic programming', 'Graphs'],
    dueRevisionsCount
  };
};

module.exports = {
  calculateStreak,
  getWeeklyActivity,
  getDSAAnalytics
};
