import 'package:equatable/equatable.dart';

sealed class AppException extends Equatable implements Exception {
  const AppException(this.message);

  final String message;

  @override
  List<Object?> get props => [message];

  @override
  String toString() => message;
}

final class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection.']);
}

final class AuthException extends AppException {
  const AuthException([super.message = 'Authentication failed.']);
}

final class LocalDatabaseException extends AppException {
  const LocalDatabaseException([super.message = 'Local database error.']);
}

final class PermissionDeniedException extends AppException {
  const PermissionDeniedException([super.message = 'Permission denied.']);
}

final class ConsentRequiredException extends AppException {
  const ConsentRequiredException([
    super.message = 'Please accept consent to continue.',
  ]);
}

final class OperationCancelledException extends AppException {
  const OperationCancelledException([super.message = 'Operation cancelled.']);
}
