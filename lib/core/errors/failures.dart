class AppFailure {
  final String message;
  final int? statusCode;

  const AppFailure(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class NetworkFailure extends AppFailure {
  const NetworkFailure([String message = 'Unable to connect to server. Please check your connection.'])
      : super(message);
}

class ServerFailure extends AppFailure {
  const ServerFailure([
    String message = 'A server error occurred. Please try again later.',
    int? statusCode,
  ]) : super(message, statusCode: statusCode);
}

class AuthFailure extends AppFailure {
  const AuthFailure([
    String message = 'Authentication failed. Please log in again.',
    int? statusCode,
  ]) : super(message, statusCode: statusCode);
}
