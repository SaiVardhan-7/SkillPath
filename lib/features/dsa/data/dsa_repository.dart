import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/dsa_problem_model.dart';

class DSARepository {
  final ApiClient apiClient;

  DSARepository({required this.apiClient});

  Future<UserProblemsResponse> getUserProblems({
    String? topic,
    String? difficulty,
    String? platform,
    String? status,
    bool? bookmarked,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{};
    if (topic != null && topic != 'All') queryParams['topic'] = topic;
    if (difficulty != null && difficulty != 'All') queryParams['difficulty'] = difficulty;
    if (platform != null && platform != 'All') queryParams['platform'] = platform;
    if (status != null && status != 'All') queryParams['status'] = status;
    if (bookmarked == true) queryParams['bookmarked'] = 'true';
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final response = await apiClient.get(
      ApiConstants.userProblems,
      queryParameters: queryParams,
    );
    return UserProblemsResponse.fromJson(response);
  }

  Future<List<DSAProblemModel>> getCatalogProblems({
    String? topic,
    String? difficulty,
  }) async {
    final queryParams = <String, dynamic>{};
    if (topic != null && topic != 'All') queryParams['topic'] = topic;
    if (difficulty != null && difficulty != 'All') queryParams['difficulty'] = difficulty;

    final response = await apiClient.get(
      ApiConstants.catalogProblems,
      queryParameters: queryParams,
    );
    return (response['data'] as List<dynamic>)
        .map((e) => DSAProblemModel.fromJson(e))
        .toList();
  }

  Future<DSAProblemModel> addProblem({
    String? problemId,
    required String title,
    required String url,
    required String platform,
    required String topic,
    required String difficulty,
    String status = 'attempted',
    bool isBookmarked = false,
    String notes = '',
    String mistakes = '',
    String observations = '',
    int revisionIntervalDays = 3,
  }) async {
    final response = await apiClient.post(
      ApiConstants.userProblems,
      data: {
        ? 'problemId': problemId,
        'title': title,
        'url': url,
        'platform': platform,
        'topic': topic,
        'difficulty': difficulty,
        'status': status,
        'isBookmarked': isBookmarked,
        'notes': notes,
        'mistakes': mistakes,
        'observations': observations,
        'revisionIntervalDays': revisionIntervalDays,
      },
    );
    return DSAProblemModel.fromJson(response['data']);
  }

  Future<DSAProblemModel> updateProblem({
    required String id,
    String? status,
    bool? isBookmarked,
    String? notes,
    String? mistakes,
    String? observations,
    int? rescheduleDays,
  }) async {
    final response = await apiClient.put(
      '${ApiConstants.userProblems}/$id',
      data: {
        ? 'status': status,
        ? 'isBookmarked': isBookmarked,
        ? 'notes': notes,
        ? 'mistakes': mistakes,
        ? 'observations': observations,
        ? 'rescheduleDays': rescheduleDays,
      },
    );
    return DSAProblemModel.fromJson(response['data']);
  }

  Future<void> deleteProblem(String id) async {
    await apiClient.delete('${ApiConstants.userProblems}/$id');
  }
}
