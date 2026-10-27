import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/interview_model.dart';

class InterviewRepository {
  final ApiClient apiClient;

  InterviewRepository({required this.apiClient});

  Future<List<InterviewQuestionModel>> getQuestions({String? category, String? topic}) async {
    final queryParams = <String, dynamic>{};
    if (category != null && category != 'All') queryParams['category'] = category;
    if (topic != null && topic != 'All') queryParams['topic'] = topic;

    final response = await apiClient.get(
      ApiConstants.interviewQuestions,
      queryParameters: queryParams,
    );

    // Fetch user interview progress to merge states
    Map<String, dynamic> progressMap = {};
    try {
      final userProgressRes = await apiClient.get(ApiConstants.interviewProgress);
      final list = userProgressRes['data'] as List<dynamic>;
      for (var p in list) {
        final qId = p['questionId'] is Map ? p['questionId']['_id'] : p['questionId'];
        progressMap[qId] = p;
      }
    } catch (_) {}

    return (response['data'] as List<dynamic>).map((e) {
      final qId = e['_id'] ?? e['id'];
      final userProg = progressMap[qId];
      return InterviewQuestionModel(
        id: qId,
        topic: e['topic'] ?? '',
        category: e['category'] ?? 'Technical',
        question: e['question'] ?? '',
        answerKeyPoints: (e['answerKeyPoints'] as List<dynamic>?)?.map((k) => k.toString()).toList() ?? [],
        difficulty: e['difficulty'] ?? 'Medium',
        companyTags: (e['companyTags'] as List<dynamic>?)?.map((k) => k.toString()).toList() ?? [],
        isPracticed: userProg != null ? (userProg['isPracticed'] ?? false) : false,
        isBookmarked: userProg != null ? (userProg['isBookmarked'] ?? false) : false,
        userNotes: userProg != null ? (userProg['userNotes'] ?? '') : '',
      );
    }).toList();
  }

  Future<void> updateProgress({
    required String questionId,
    bool? isPracticed,
    bool? isBookmarked,
    String? userNotes,
  }) async {
    await apiClient.put(
      '${ApiConstants.interviewProgress}/$questionId',
      data: {
        ? 'isPracticed': isPracticed,
        ? 'isBookmarked': isBookmarked,
        ? 'userNotes': userNotes,
      },
    );
  }
}
