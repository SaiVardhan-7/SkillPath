class UserModel {
  final String id;
  final String name;
  final String email;
  final String targetRole;
  final String currentSkillLevel;
  final int dailyStudyTimeMinutes;
  final List<String> learningGoals;
  final bool isOnboarded;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.targetRole,
    required this.currentSkillLevel,
    required this.dailyStudyTimeMinutes,
    required this.learningGoals,
    required this.isOnboarded,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      targetRole: json['targetRole'] ?? 'Software Development Engineer',
      currentSkillLevel: json['currentSkillLevel'] ?? 'Beginner',
      dailyStudyTimeMinutes: json['dailyStudyTimeMinutes'] ?? 60,
      learningGoals: (json['learningGoals'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      isOnboarded: json['isOnboarded'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'targetRole': targetRole,
      'currentSkillLevel': currentSkillLevel,
      'dailyStudyTimeMinutes': dailyStudyTimeMinutes,
      'learningGoals': learningGoals,
      'isOnboarded': isOnboarded,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? targetRole,
    String? currentSkillLevel,
    int? dailyStudyTimeMinutes,
    List<String>? learningGoals,
    bool? isOnboarded,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      targetRole: targetRole ?? this.targetRole,
      currentSkillLevel: currentSkillLevel ?? this.currentSkillLevel,
      dailyStudyTimeMinutes: dailyStudyTimeMinutes ?? this.dailyStudyTimeMinutes,
      learningGoals: learningGoals ?? this.learningGoals,
      isOnboarded: isOnboarded ?? this.isOnboarded,
    );
  }
}
