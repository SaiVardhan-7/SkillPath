import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/token_storage.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiClient apiClient;
  final TokenStorage tokenStorage;

  AuthRepository({required this.apiClient, required this.tokenStorage});

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    String? targetRole,
    String? currentSkillLevel,
    int? dailyStudyTimeMinutes,
    List<String>? learningGoals,
  }) async {
    final response = await apiClient.post(
      ApiConstants.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'targetRole': targetRole ?? 'Software Development Engineer',
        'currentSkillLevel': currentSkillLevel ?? 'Beginner',
        'dailyStudyTimeMinutes': dailyStudyTimeMinutes ?? 60,
        'learningGoals': learningGoals ?? [],
      },
    );

    final data = response['data'];
    await tokenStorage.saveTokens(
      accessToken: data['accessToken'],
      refreshToken: data['refreshToken'],
    );

    return UserModel.fromJson(data['user']);
  }

  Future<UserModel> login({required String email, required String password}) async {
    final response = await apiClient.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );

    final data = response['data'];
    await tokenStorage.saveTokens(
      accessToken: data['accessToken'],
      refreshToken: data['refreshToken'],
    );

    return UserModel.fromJson(data['user']);
  }

  Future<UserModel> getMe() async {
    final response = await apiClient.get(ApiConstants.me);
    return UserModel.fromJson(response['data']);
  }

  Future<UserModel> updateProfile({
    String? name,
    String? targetRole,
    String? currentSkillLevel,
    int? dailyStudyTimeMinutes,
    List<String>? learningGoals,
    bool? isOnboarded,
  }) async {
    final response = await apiClient.put(
      ApiConstants.profile,
      data: {
        ? 'name': name,
        ? 'targetRole': targetRole,
        ? 'currentSkillLevel': currentSkillLevel,
        ? 'dailyStudyTimeMinutes': dailyStudyTimeMinutes,
        ? 'learningGoals': learningGoals,
        ? 'isOnboarded': isOnboarded,
      },
    );

    return UserModel.fromJson(response['data']);
  }

  Future<void> logout() async {
    try {
      await apiClient.post(ApiConstants.logout);
    } catch (_) {}
    await tokenStorage.clearTokens();
  }
}
