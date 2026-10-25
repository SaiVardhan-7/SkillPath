const Roadmap = require('../models/Roadmap');
const RoadmapProgress = require('../models/RoadmapProgress');
const UserProblemProgress = require('../models/UserProblemProgress');
const UserProject = require('../models/UserProject');

const getPersonalizedRecommendations = async (userId, user) => {
  const recommendations = [];

  // 1. Check for overdue or due-today DSA revisions
  const now = new Date();
  const endOfToday = new Date();
  endOfToday.setHours(23, 59, 59, 999);

  const pendingRevisions = await UserProblemProgress.find({
    userId,
    status: 'solved',
    revisionScheduledDate: { $lte: endOfToday }
  })
    .sort({ revisionScheduledDate: 1 })
    .limit(3);

  if (pendingRevisions.length > 0) {
    recommendations.push({
      id: 'rec_revision',
      type: 'revision_due',
      priority: 'high',
      title: 'Spaced Repetition Revision Due',
      description: `You have ${pendingRevisions.length} problem${pendingRevisions.length > 1 ? 's' : ''} scheduled for revision (${pendingRevisions.map(p => p.title).join(', ')}). Revise them to reinforce your concepts!`,
      actionRoute: '/dsa',
      actionLabel: 'Revise Problems',
      metadata: { count: pendingRevisions.length }
    });
  }

  // 2. Check active projects with incomplete milestones
  const activeProject = await UserProject.findOne({
    userId,
    status: 'in_progress'
  }).populate('projectId');

  if (activeProject && activeProject.projectId) {
    const allMilestones = activeProject.projectId.milestones || [];
    const completedSet = new Set(activeProject.completedMilestones || []);
    const nextMilestone = allMilestones.find((m) => !completedSet.has(m.milestoneId));

    if (nextMilestone) {
      recommendations.push({
        id: 'rec_project_milestone',
        type: 'project_next_step',
        priority: 'high',
        title: `Continue "${activeProject.projectId.title}"`,
        description: `Next milestone: ${nextMilestone.title}. ${nextMilestone.description}`,
        actionRoute: `/projects/${activeProject.projectId._id}`,
        actionLabel: 'Resume Project',
        metadata: {
          projectId: activeProject.projectId._id,
          milestoneId: nextMilestone.milestoneId
        }
      });
    }
  }

  // 3. Roadmap progress: find next eligible topic or incomplete prerequisites
  let roadmapProgress = await RoadmapProgress.findOne({ userId }).populate('roadmapId');
  if (!roadmapProgress && user.targetRole) {
    const roadmap = await Roadmap.findOne({ targetRole: user.targetRole });
    if (roadmap) {
      roadmapProgress = await RoadmapProgress.create({
        userId,
        roadmapId: roadmap._id,
        currentStageNumber: 1
      });
      roadmapProgress.roadmapId = roadmap;
    }
  }

  if (roadmapProgress && roadmapProgress.roadmapId) {
    const roadmap = roadmapProgress.roadmapId;
    const completedTopics = new Set(roadmapProgress.completedTopics || []);
    const inProgressTopics = new Set(roadmapProgress.inProgressTopics || []);

    let foundNextTopic = null;
    let stageCompleted = true;

    for (const stage of roadmap.stages) {
      for (const topic of stage.topics) {
        if (!completedTopics.has(topic.topicId)) {
          stageCompleted = false;
          // Check prerequisites
          const prereqs = topic.prerequisites || [];
          const missingPrereqs = prereqs.filter((p) => !completedTopics.has(p));

          if (missingPrereqs.length === 0) {
            foundNextTopic = {
              topic,
              stage,
              status: inProgressTopics.has(topic.topicId) ? 'in_progress' : 'ready'
            };
            break;
          } else {
            // Suggest completing prerequisite
            recommendations.push({
              id: `rec_prereq_${topic.topicId}`,
              type: 'prerequisite_incomplete',
              priority: 'medium',
              title: `Prerequisites Needed for ${topic.title}`,
              description: `Before starting "${topic.title}", complete prerequisite: ${missingPrereqs.join(', ')}.`,
              actionRoute: '/roadmap',
              actionLabel: 'View Roadmap',
              metadata: { topicId: topic.topicId, missingPrereqs }
            });
            break;
          }
        }
      }
      if (foundNextTopic) break;
    }

    if (foundNextTopic) {
      recommendations.push({
        id: `rec_topic_${foundNextTopic.topic.topicId}`,
        type: 'roadmap_next_topic',
        priority: 'high',
        title: foundNextTopic.status === 'in_progress' ? `Continue: ${foundNextTopic.topic.title}` : `Next Topic: ${foundNextTopic.topic.title}`,
        description: `Stage ${foundNextTopic.stage.stageNumber}: ${foundNextTopic.topic.description}`,
        actionRoute: '/roadmap',
        actionLabel: foundNextTopic.status === 'in_progress' ? 'Continue Topic' : 'Start Topic',
        metadata: { topicId: foundNextTopic.topic.topicId, stageNumber: foundNextTopic.stage.stageNumber }
      });
    }
  }

  // 4. DSA topic weakness detection
  const dsaProgress = await UserProblemProgress.find({ userId });
  const topicCounts = {};
  for (const item of dsaProgress) {
    if (!topicCounts[item.topic]) {
      topicCounts[item.topic] = { solved: 0, attempted: 0 };
    }
    if (item.status === 'solved') topicCounts[item.topic].solved += 1;
    if (item.status === 'attempted') topicCounts[item.topic].attempted += 1;
  }

  // Find topics where user attempted but solved few, or key topics not started
  const essentialTopics = ['Arrays', 'Strings', 'Two pointers', 'Trees', 'Dynamic programming'];
  for (const topic of essentialTopics) {
    const data = topicCounts[topic];
    if (!data || data.solved === 0) {
      recommendations.push({
        id: `rec_dsa_${topic.toLowerCase().replace(/\s+/g, '_')}`,
        type: 'dsa_topic_practice',
        priority: 'medium',
        title: `Practice ${topic} Problems`,
        description: `Strengthen your coding fundamentals with ${topic} challenges to boost your technical interview confidence.`,
        actionRoute: '/dsa',
        actionLabel: `Solve ${topic}`,
        metadata: { topic }
      });
      break; // Add at most one DSA recommendation
    }
  }

  return recommendations;
};

module.exports = { getPersonalizedRecommendations };
