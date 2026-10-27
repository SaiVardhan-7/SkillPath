import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/project_model.dart';

class ProjectRepository {
  final ApiClient apiClient;

  ProjectRepository({required this.apiClient});

  Future<List<ProjectModel>> getAllProjects({String? domain, String? difficulty}) async {
    final queryParams = <String, dynamic>{};
    if (domain != null && domain != 'All') queryParams['domain'] = domain;
    if (difficulty != null && difficulty != 'All') queryParams['difficulty'] = difficulty;

    final response = await apiClient.get(
      ApiConstants.projects,
      queryParameters: queryParams,
    );
    return (response['data'] as List<dynamic>)
        .map((e) => ProjectModel.fromJson(e))
        .toList();
  }

  Future<ProjectModel> getProjectById(String id) async {
    final response = await apiClient.get('${ApiConstants.projects}/$id');
    return ProjectModel.fromJson(response['data']);
  }

  Future<List<UserProjectModel>> getUserProjects({String? status}) async {
    final queryParams = <String, dynamic>{};
    if (status != null && status != 'All') queryParams['status'] = status;

    final response = await apiClient.get(
      ApiConstants.userProjects,
      queryParameters: queryParams,
    );
    return (response['data'] as List<dynamic>)
        .map((e) => UserProjectModel.fromJson(e))
        .toList();
  }

  Future<UserProjectModel> startOrSaveProject({
    required String projectId,
    required String status,
  }) async {
    final response = await apiClient.post(
      ApiConstants.userProjects,
      data: {'projectId': projectId, 'status': status},
    );
    return UserProjectModel.fromJson(response['data']);
  }

  Future<UserProjectModel> updateProjectProgress({
    required String userProjectIdOrProjectId,
    String? milestoneId,
    bool? completed,
    String? githubUrl,
    String? liveDemoUrl,
    String? notes,
    List<String>? userResumeBullets,
  }) async {
    final response = await apiClient.put(
      '${ApiConstants.userProjects}/$userProjectIdOrProjectId',
      data: {
        ? 'milestoneId': milestoneId,
        ? 'completed': completed,
        ? 'githubUrl': githubUrl,
        ? 'liveDemoUrl': liveDemoUrl,
        ? 'notes': notes,
        ? 'userResumeBullets': userResumeBullets,
      },
    );
    return UserProjectModel.fromJson(response['data']);
  }

  Future<List<String>> generateResumeBullets(String userProjectIdOrProjectId) async {
    final response = await apiClient.post(
      '${ApiConstants.userProjects}/$userProjectIdOrProjectId/resume-bullets',
    );
    return (response['data']['suggestedBullets'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
  }
}
