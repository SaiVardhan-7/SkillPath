class DSAProblemModel {
  final String id;
  final String? problemId;
  final String title;
  final String url;
  final String platform;
  final String topic;
  final String difficulty;
  final String status; // 'solved', 'attempted', 'unsolved'
  final bool isBookmarked;
  final String notes;
  final String mistakes;
  final String observations;
  final DateTime? dateSolved;
  final DateTime? revisionScheduledDate;
  final int revisionIntervalDays;
  final int revisionCount;

  DSAProblemModel({
    required this.id,
    this.problemId,
    required this.title,
    required this.url,
    required this.platform,
    required this.topic,
    required this.difficulty,
    required this.status,
    required this.isBookmarked,
    required this.notes,
    required this.mistakes,
    required this.observations,
    this.dateSolved,
    this.revisionScheduledDate,
    required this.revisionIntervalDays,
    required this.revisionCount,
  });

  factory DSAProblemModel.fromJson(Map<String, dynamic> json) {
    return DSAProblemModel(
      id: json['_id'] ?? json['id'] ?? '',
      problemId: json['problemId'] is Map ? json['problemId']['_id'] : json['problemId'],
      title: json['title'] ?? '',
      url: json['url'] ?? '',
      platform: json['platform'] ?? 'LeetCode',
      topic: json['topic'] ?? 'Arrays',
      difficulty: json['difficulty'] ?? 'Easy',
      status: json['status'] ?? 'attempted',
      isBookmarked: json['isBookmarked'] ?? false,
      notes: json['notes'] ?? '',
      mistakes: json['mistakes'] ?? '',
      observations: json['observations'] ?? '',
      dateSolved: json['dateSolved'] != null ? DateTime.tryParse(json['dateSolved']) : null,
      revisionScheduledDate: json['revisionScheduledDate'] != null ? DateTime.tryParse(json['revisionScheduledDate']) : null,
      revisionIntervalDays: json['revisionIntervalDays'] ?? 3,
      revisionCount: json['revisionCount'] ?? 0,
    );
  }

  bool get isRevisionDue {
    if (revisionScheduledDate == null || status != 'solved') return false;
    final now = DateTime.now();
    final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);
    return revisionScheduledDate!.isBefore(endOfToday);
  }
}

class DSAAnalyticsModel {
  final int totalSolved;
  final int totalAttempted;
  final int easySolved;
  final int mediumSolved;
  final int hardSolved;
  final List<String> weakTopics;
  final int dueRevisionsCount;

  DSAAnalyticsModel({
    required this.totalSolved,
    required this.totalAttempted,
    required this.easySolved,
    required this.mediumSolved,
    required this.hardSolved,
    required this.weakTopics,
    required this.dueRevisionsCount,
  });

  factory DSAAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return DSAAnalyticsModel(
      totalSolved: json['totalSolved'] ?? 0,
      totalAttempted: json['totalAttempted'] ?? 0,
      easySolved: json['easySolved'] ?? 0,
      mediumSolved: json['mediumSolved'] ?? 0,
      hardSolved: json['hardSolved'] ?? 0,
      weakTopics: (json['weakTopics'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      dueRevisionsCount: json['dueRevisionsCount'] ?? 0,
    );
  }
}

class UserProblemsResponse {
  final int count;
  final DSAAnalyticsModel analytics;
  final List<DSAProblemModel> problems;

  UserProblemsResponse({
    required this.count,
    required this.analytics,
    required this.problems,
  });

  factory UserProblemsResponse.fromJson(Map<String, dynamic> json) {
    return UserProblemsResponse(
      count: json['count'] ?? 0,
      analytics: DSAAnalyticsModel.fromJson(json['analytics'] ?? {}),
      problems: (json['data'] as List<dynamic>?)
              ?.map((e) => DSAProblemModel.fromJson(e))
              .toList() ??
          [],
    );
  }
}
