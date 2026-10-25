import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/roadmap_model.dart';

class RoadmapRepository {
  final ApiClient apiClient;

  RoadmapRepository({required this.apiClient});

  Future<List<RoadmapModel>> getRoadmaps() async {
    final response = await apiClient.get(ApiConstants.roadmaps);
    return (response['data'] as List<dynamic>)
        .map((e) => RoadmapModel.fromJson(e))
        .toList();
  }

  Future<UserRoadmapResponse> getUserRoadmap({String? roadmapId}) async {
    final response = await apiClient.get(
      ApiConstants.userRoadmap,
      queryParameters: roadmapId != null ? {'roadmapId': roadmapId} : null,
    );
    return UserRoadmapResponse.fromJson(response['data']);
  }

  Future<void> updateTopicStatus({
    required String roadmapId,
    required String topicId,
    required String status, // 'completed', 'in_progress', 'not_started'
  }) async {
    await apiClient.put(
      ApiConstants.updateRoadmapProgress,
      data: {
        'roadmapId': roadmapId,
        'topicId': topicId,
        'status': status,
      },
    );
  }

  Future<void> toggleResourceBookmark({
    required String roadmapId,
    required String topicId,
    required String title,
    required String url,
    required String type,
  }) async {
    await apiClient.put(
      ApiConstants.updateRoadmapProgress,
      data: {
        'roadmapId': roadmapId,
        'resourceBookmark': {
          'topicId': topicId,
          'title': title,
          'url': url,
          'type': type,
        },
      },
    );
  }
}
