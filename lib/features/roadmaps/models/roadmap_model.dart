class ResourceModel {
  final String title;
  final String type; // article, video, doc, tutorial, practice
  final String url;
  final int durationMinutes;
  final bool isBookmarked;

  ResourceModel({
    required this.title,
    required this.type,
    required this.url,
    required this.durationMinutes,
    this.isBookmarked = false,
  });

  factory ResourceModel.fromJson(Map<String, dynamic> json) {
    return ResourceModel(
      title: json['title'] ?? '',
      type: json['type'] ?? 'article',
      url: json['url'] ?? '',
      durationMinutes: json['durationMinutes'] ?? 30,
      isBookmarked: json['isBookmarked'] ?? false,
    );
  }
}

class TopicModel {
  final String topicId;
  final String title;
  final String description;
  final int estimatedHours;
  final List<String> prerequisites;
  final List<ResourceModel> resources;
  final bool isUnlocked;
  final String status; // 'completed', 'in_progress', 'locked', 'ready'
  final List<String> missingPrerequisites;

  TopicModel({
    required this.topicId,
    required this.title,
    required this.description,
    required this.estimatedHours,
    required this.prerequisites,
    required this.resources,
    required this.isUnlocked,
    required this.status,
    required this.missingPrerequisites,
  });

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      topicId: json['topicId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      estimatedHours: json['estimatedHours'] ?? 10,
      prerequisites: (json['prerequisites'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      resources: (json['resources'] as List<dynamic>?)?.map((e) => ResourceModel.fromJson(e)).toList() ?? [],
      isUnlocked: json['isUnlocked'] ?? true,
      status: json['status'] ?? 'ready',
      missingPrerequisites: (json['missingPrerequisites'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class StageModel {
  final int stageNumber;
  final String title;
  final String description;
  final int estimatedHours;
  final List<TopicModel> topics;
  final int totalTopics;
  final int completedTopics;
  final int progressPercentage;

  StageModel({
    required this.stageNumber,
    required this.title,
    required this.description,
    required this.estimatedHours,
    required this.topics,
    required this.totalTopics,
    required this.completedTopics,
    required this.progressPercentage,
  });

  factory StageModel.fromJson(Map<String, dynamic> json) {
    return StageModel(
      stageNumber: json['stageNumber'] ?? 1,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      estimatedHours: json['estimatedHours'] ?? 40,
      topics: (json['topics'] as List<dynamic>?)?.map((e) => TopicModel.fromJson(e)).toList() ?? [],
      totalTopics: json['totalTopics'] ?? 0,
      completedTopics: json['completedTopics'] ?? 0,
      progressPercentage: json['progressPercentage'] ?? 0,
    );
  }
}

class RoadmapModel {
  final String id;
  final String title;
  final String slug;
  final String targetRole;
  final String description;
  final int estimatedWeeks;
  final List<StageModel> stages;

  RoadmapModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.targetRole,
    required this.description,
    required this.estimatedWeeks,
    required this.stages,
  });

  factory RoadmapModel.fromJson(Map<String, dynamic> json) {
    return RoadmapModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      targetRole: json['targetRole'] ?? '',
      description: json['description'] ?? '',
      estimatedWeeks: json['estimatedWeeks'] ?? 24,
      stages: (json['stages'] as List<dynamic>?)?.map((e) => StageModel.fromJson(e)).toList() ?? [],
    );
  }
}

class RoadmapProgressModel {
  final int totalTopics;
  final int completedTopicsCount;
  final int overallPercentage;
  final List<String> completedTopicIds;
  final List<String> inProgressTopicIds;
  final int currentStageNumber;

  RoadmapProgressModel({
    required this.totalTopics,
    required this.completedTopicsCount,
    required this.overallPercentage,
    required this.completedTopicIds,
    required this.inProgressTopicIds,
    required this.currentStageNumber,
  });

  factory RoadmapProgressModel.fromJson(Map<String, dynamic> json) {
    return RoadmapProgressModel(
      totalTopics: json['totalTopics'] ?? 0,
      completedTopicsCount: json['completedTopicsCount'] ?? 0,
      overallPercentage: json['overallPercentage'] ?? 0,
      completedTopicIds: (json['completedTopicIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      inProgressTopicIds: (json['inProgressTopicIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      currentStageNumber: json['currentStageNumber'] ?? 1,
    );
  }
}

class UserRoadmapResponse {
  final RoadmapModel roadmap;
  final RoadmapProgressModel progress;

  UserRoadmapResponse({required this.roadmap, required this.progress});

  factory UserRoadmapResponse.fromJson(Map<String, dynamic> json) {
    return UserRoadmapResponse(
      roadmap: RoadmapModel.fromJson(json['roadmap']),
      progress: RoadmapProgressModel.fromJson(json['progress']),
    );
  }
}
