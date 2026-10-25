class MilestoneModel {
  final String milestoneId;
  final String title;
  final String description;
  final String testingCriteria;

  MilestoneModel({
    required this.milestoneId,
    required this.title,
    required this.description,
    required this.testingCriteria,
  });

  factory MilestoneModel.fromJson(Map<String, dynamic> json) {
    return MilestoneModel(
      milestoneId: json['milestoneId'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      testingCriteria: json['testingCriteria'] ?? '',
    );
  }
}

class StepModel {
  final int stepNumber;
  final String title;
  final String description;

  StepModel({
    required this.stepNumber,
    required this.title,
    required this.description,
  });

  factory StepModel.fromJson(Map<String, dynamic> json) {
    return StepModel(
      stepNumber: json['stepNumber'] ?? 1,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
    );
  }
}

class ProjectModel {
  final String id;
  final String title;
  final String slug;
  final String domain;
  final String difficulty;
  final List<String> requiredTech;
  final int estimatedHours;
  final List<String> prerequisites;
  final String description;
  final List<String> learningObjectives;
  final List<StepModel> stepByStepPlan;
  final List<MilestoneModel> milestones;
  final List<String> suggestedResumeBullets;

  ProjectModel({
    required this.id,
    required this.title,
    required this.slug,
    required this.domain,
    required this.difficulty,
    required this.requiredTech,
    required this.estimatedHours,
    required this.prerequisites,
    required this.description,
    required this.learningObjectives,
    required this.stepByStepPlan,
    required this.milestones,
    required this.suggestedResumeBullets,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      domain: json['domain'] ?? 'Flutter development',
      difficulty: json['difficulty'] ?? 'Beginner',
      requiredTech: (json['requiredTech'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      estimatedHours: json['estimatedHours'] ?? 20,
      prerequisites: (json['prerequisites'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      description: json['description'] ?? '',
      learningObjectives: (json['learningObjectives'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      stepByStepPlan: (json['stepByStepPlan'] as List<dynamic>?)?.map((e) => StepModel.fromJson(e)).toList() ?? [],
      milestones: (json['milestones'] as List<dynamic>?)?.map((e) => MilestoneModel.fromJson(e)).toList() ?? [],
      suggestedResumeBullets: (json['suggestedResumeBullets'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class UserProjectModel {
  final String id;
  final ProjectModel project;
  final String status; // 'saved', 'in_progress', 'completed'
  final List<String> completedMilestones;
  final String githubUrl;
  final String liveDemoUrl;
  final String notes;
  final List<String> userResumeBullets;
  final int totalMilestones;
  final int completedMilestonesCount;
  final int progressPercentage;

  UserProjectModel({
    required this.id,
    required this.project,
    required this.status,
    required this.completedMilestones,
    required this.githubUrl,
    required this.liveDemoUrl,
    required this.notes,
    required this.userResumeBullets,
    required this.totalMilestones,
    required this.completedMilestonesCount,
    required this.progressPercentage,
  });

  factory UserProjectModel.fromJson(Map<String, dynamic> json) {
    return UserProjectModel(
      id: json['_id'] ?? json['id'] ?? '',
      project: ProjectModel.fromJson(json['projectId'] is Map ? json['projectId'] : json),
      status: json['status'] ?? 'saved',
      completedMilestones: (json['completedMilestones'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      githubUrl: json['githubUrl'] ?? '',
      liveDemoUrl: json['liveDemoUrl'] ?? '',
      notes: json['notes'] ?? '',
      userResumeBullets: (json['userResumeBullets'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      totalMilestones: json['totalMilestones'] ?? (json['projectId']?['milestones']?.length ?? 0),
      completedMilestonesCount: json['completedMilestonesCount'] ?? (json['completedMilestones']?.length ?? 0),
      progressPercentage: json['progressPercentage'] ?? 0,
    );
  }
}
