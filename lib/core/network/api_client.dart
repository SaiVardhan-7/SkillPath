import 'package:dio/dio.dart';
import '../constants/api_constants.dart';
import '../errors/failures.dart';
import '../storage/token_storage.dart';

class ApiClient {
  late final Dio dio;
  final TokenStorage tokenStorage;

  ApiClient({required this.tokenStorage}) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await tokenStorage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          // Check if token expired and refresh
          if (error.response?.statusCode == 401) {
            final isTokenExpired = error.response?.data is Map &&
                error.response?.data['code'] == 'TOKEN_EXPIRED';

            if (isTokenExpired) {
              final refreshToken = await tokenStorage.getRefreshToken();
              if (refreshToken != null) {
                try {
                  final refreshDio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
                  final refreshRes = await refreshDio.post(
                    ApiConstants.refresh,
                    data: {'refreshToken': refreshToken},
                  );

                  if (refreshRes.statusCode == 200 && refreshRes.data['data'] != null) {
                    final newAccess = refreshRes.data['data']['accessToken'];
                    final newRefresh = refreshRes.data['data']['refreshToken'];
                    await tokenStorage.saveTokens(
                      accessToken: newAccess,
                      refreshToken: newRefresh,
                    );

                    // Retry original request with new token
                    final opts = error.requestOptions;
                    opts.headers['Authorization'] = 'Bearer $newAccess';
                    final retryResponse = await dio.fetch(opts);
                    return handler.resolve(retryResponse);
                  }
                } catch (_) {
                  await tokenStorage.clearTokens();
                }
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await dio.get(path, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<dynamic> post(String path, {dynamic data}) async {
    try {
      final response = await dio.post(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<dynamic> put(String path, {dynamic data}) async {
    try {
      final response = await dio.put(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<dynamic> delete(String path, {dynamic data}) async {
    try {
      final response = await dio.delete(path, data: data);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  AppFailure _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError) {
      return const NetworkFailure('Unable to reach SkillPath server. Please check your connection.');
    }

    if (e.response != null) {
      final data = e.response?.data;
      String message = 'An unexpected error occurred.';
      if (data is Map && data['message'] != null) {
        message = data['message'].toString();
      }
      final statusCode = e.response?.statusCode;
      if (statusCode == 401) {
        return AuthFailure(message, statusCode);
      }
      return ServerFailure(message, statusCode);
    }

    return AppFailure(e.message ?? 'An unknown network error occurred.');
  }
}
