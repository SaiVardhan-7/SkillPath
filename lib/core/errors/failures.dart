class AppFailure {
  final String message;
  final int? statusCode;

  const AppFailure(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class NetworkFailure extends AppFailure {
  const NetworkFailure([super.message = 'Unable to connect to server. Please check your connection.']);
}

class ServerFailure extends AppFailure {
  const ServerFailure([
    super.message = 'A server error occurred. Please try again later.',
    int? statusCode,
  ]) : super(statusCode: statusCode);
}

class AuthFailure extends AppFailure {
  const AuthFailure([
    super.message = 'Authentication failed. Please log in again.',
    int? statusCode,
  ]) : super(statusCode: statusCode);
}
