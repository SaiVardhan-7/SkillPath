import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/storage/local_storage.dart';
import '../../../core/storage/token_storage.dart';
import '../data/auth_repository.dart';
import '../models/user_model.dart';

final tokenStorageProvider = Provider<TokenStorage>((ref) => TokenStorage());
final localStorageProvider = Provider<LocalStorage>((ref) => LocalStorage());

final apiClientProvider = Provider<ApiClient>((ref) {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return ApiClient(tokenStorage: tokenStorage);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final tokenStorage = ref.watch(tokenStorageProvider);
  return AuthRepository(apiClient: apiClient, tokenStorage: tokenStorage);
});

enum AuthStatus { initial, authenticated, unauthenticated, loading, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;
  bool get isLoading => status == AuthStatus.loading;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.status == status &&
        other.user == user &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hash(status, user, errorMessage);
}

class AuthNotifier extends Notifier<AuthState> {
  AuthRepository get _repository => ref.read(authRepositoryProvider);
  TokenStorage get _tokenStorage => ref.read(tokenStorageProvider);

  @override
  AuthState build() {
    return const AuthState();
  }

  void setUnauthenticated() {
    state = state.copyWith(status: AuthStatus.unauthenticated);
  }

  Future<void> checkAuth() async {
    final token = await _tokenStorage.getAccessToken();
    if (token == null || token.isEmpty) {
      state = state.copyWith(status: AuthStatus.unauthenticated);
      return;
    }

    try {
      final user = await _repository.getMe().timeout(const Duration(seconds: 8));
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
    } catch (_) {
      await _tokenStorage.clearTokens();
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<bool> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final user = await _repository.login(email: email, password: password);
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String? targetRole,
    String? currentSkillLevel,
    int? dailyStudyTimeMinutes,
    List<String>? learningGoals,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final user = await _repository.register(
        name: name,
        email: email,
        password: password,
        targetRole: targetRole,
        currentSkillLevel: currentSkillLevel,
        dailyStudyTimeMinutes: dailyStudyTimeMinutes,
        learningGoals: learningGoals,
      );
      state = state.copyWith(status: AuthStatus.authenticated, user: user);
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      return false;
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? targetRole,
    String? currentSkillLevel,
    int? dailyStudyTimeMinutes,
    List<String>? learningGoals,
    bool? isOnboarded,
  }) async {
    try {
      final updatedUser = await _repository.updateProfile(
        name: name,
        targetRole: targetRole,
        currentSkillLevel: currentSkillLevel,
        dailyStudyTimeMinutes: dailyStudyTimeMinutes,
        learningGoals: learningGoals,
        isOnboarded: isOnboarded,
      );
      state = state.copyWith(user: updatedUser);
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
