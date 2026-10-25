class InterviewQuestionModel {
  final String id;
  final String topic;
  final String category; // 'Technical', 'Behavioral', 'System Design'
  final String question;
  final List<String> answerKeyPoints;
  final String difficulty;
  final List<String> companyTags;
  final bool isPracticed;
  final bool isBookmarked;
  final String userNotes;

  InterviewQuestionModel({
    required this.id,
    required this.topic,
    required this.category,
    required this.question,
    required this.answerKeyPoints,
    required this.difficulty,
    required this.companyTags,
    this.isPracticed = false,
    this.isBookmarked = false,
    this.userNotes = '',
  });

  factory InterviewQuestionModel.fromJson(Map<String, dynamic> json) {
    return InterviewQuestionModel(
      id: json['_id'] ?? json['id'] ?? '',
      topic: json['topic'] ?? '',
      category: json['category'] ?? 'Technical',
      question: json['question'] ?? '',
      answerKeyPoints: (json['answerKeyPoints'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      difficulty: json['difficulty'] ?? 'Medium',
      companyTags: (json['companyTags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      isPracticed: json['isPracticed'] ?? false,
      isBookmarked: json['isBookmarked'] ?? false,
      userNotes: json['userNotes'] ?? '',
    );
  }
}
