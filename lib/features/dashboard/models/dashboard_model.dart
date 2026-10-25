class RoadmapSummary {
  final String roadmapId;
  final String roadmapTitle;
  final int totalTopics;
  final int completedTopics;
  final int percentage;
  final int currentStageNumber;
  final String currentStageTitle;

  RoadmapSummary({
    required this.roadmapId,
    required this.roadmapTitle,
    required this.totalTopics,
    required this.completedTopics,
    required this.percentage,
    required this.currentStageNumber,
    required this.currentStageTitle,
  });

  factory RoadmapSummary.fromJson(Map<String, dynamic> json) {
    return RoadmapSummary(
      roadmapId: json['roadmapId'] ?? '',
      roadmapTitle: json['roadmapTitle'] ?? 'Career Roadmap',
      totalTopics: json['totalTopics'] ?? 0,
      completedTopics: json['completedTopics'] ?? 0,
      percentage: json['percentage'] ?? 0,
      currentStageNumber: json['currentStageNumber'] ?? 1,
      currentStageTitle: json['currentStageTitle'] ?? 'Stage 1',
    );
  }
}

class DSASummary {
  final int totalSolved;
  final int easySolved;
  final int mediumSolved;
  final int hardSolved;
  final int totalAttempted;
  final int dueRevisionsCount;

  DSASummary({
    required this.totalSolved,
    required this.easySolved,
    required this.mediumSolved,
    required this.hardSolved,
    required this.totalAttempted,
    required this.dueRevisionsCount,
  });

  factory DSASummary.fromJson(Map<String, dynamic> json) {
    return DSASummary(
      totalSolved: json['totalSolved'] ?? 0,
      easySolved: json['easySolved'] ?? 0,
      mediumSolved: json['mediumSolved'] ?? 0,
      hardSolved: json['hardSolved'] ?? 0,
      totalAttempted: json['totalAttempted'] ?? 0,
      dueRevisionsCount: json['dueRevisionsCount'] ?? 0,
    );
  }
}

class StreakSummary {
  final int currentStreak;
  final int longestStreak;
  final int activeDaysCount;

  StreakSummary({
    required this.currentStreak,
    required this.longestStreak,
    required this.activeDaysCount,
  });

  factory StreakSummary.fromJson(Map<String, dynamic> json) {
    return StreakSummary(
      currentStreak: json['currentStreak'] ?? 0,
      longestStreak: json['longestStreak'] ?? 0,
      activeDaysCount: json['activeDaysCount'] ?? 0,
    );
  }
}

class ActiveProjectSummary {
  final String id;
  final String projectId;
  final String title;
  final String domain;
  final String difficulty;
  final int totalMilestones;
  final int completedMilestones;
  final int progressPercentage;
  final String status;

  ActiveProjectSummary({
    required this.id,
    required this.projectId,
    required this.title,
    required this.domain,
    required this.difficulty,
    required this.totalMilestones,
    required this.completedMilestones,
    required this.progressPercentage,
    required this.status,
  });

  factory ActiveProjectSummary.fromJson(Map<String, dynamic> json) {
    return ActiveProjectSummary(
      id: json['_id'] ?? '',
      projectId: json['projectId'] ?? '',
      title: json['title'] ?? '',
      domain: json['domain'] ?? '',
      difficulty: json['difficulty'] ?? 'Beginner',
      totalMilestones: json['totalMilestones'] ?? 0,
      completedMilestones: json['completedMilestones'] ?? 0,
      progressPercentage: json['progressPercentage'] ?? 0,
      status: json['status'] ?? 'in_progress',
    );
  }
}

class RecommendationItem {
  final String id;
  final String type;
  final String priority;
  final String title;
  final String description;
  final String actionRoute;
  final String actionLabel;

  RecommendationItem({
    required this.id,
    required this.type,
    required this.priority,
    required this.title,
    required this.description,
    required this.actionRoute,
    required this.actionLabel,
  });

  factory RecommendationItem.fromJson(Map<String, dynamic> json) {
    return RecommendationItem(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      priority: json['priority'] ?? 'medium',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      actionRoute: json['actionRoute'] ?? '/dashboard',
      actionLabel: json['actionLabel'] ?? 'View',
    );
  }
}

class DayActivity {
  final String day;
  final String date;
  final int count;

  DayActivity({required this.day, required this.date, required this.count});

  factory DayActivity.fromJson(Map<String, dynamic> json) {
    return DayActivity(
      day: json['day'] ?? '',
      date: json['date'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class DashboardData {
  final RoadmapSummary roadmap;
  final DSASummary dsa;
  final StreakSummary streak;
  final ActiveProjectSummary? activeProject;
  final List<RecommendationItem> recommendations;
  final List<DayActivity> weeklyActivity;

  DashboardData({
    required this.roadmap,
    required this.dsa,
    required this.streak,
    this.activeProject,
    required this.recommendations,
    required this.weeklyActivity,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      roadmap: RoadmapSummary.fromJson(json['roadmap'] ?? {}),
      dsa: DSASummary.fromJson(json['dsa'] ?? {}),
      streak: StreakSummary.fromJson(json['streak'] ?? {}),
      activeProject: json['activeProject'] != null
          ? ActiveProjectSummary.fromJson(json['activeProject'])
          : null,
      recommendations: (json['recommendations'] as List<dynamic>?)
              ?.map((e) => RecommendationItem.fromJson(e))
              .toList() ??
          [],
      weeklyActivity: (json['weeklyActivity'] as List<dynamic>?)
              ?.map((e) => DayActivity.fromJson(e))
              .toList() ??
          [],
    );
  }
}
