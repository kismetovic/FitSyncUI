import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  /// Stable machine-readable code from the API, e.g. TIME_CONFLICT, CAPACITY_FULL,
  /// ALREADY_PAID. The UI branches on this instead of matching message text.
  final String? code;

  const Failure({this.message = 'An unexpected error occurred', this.code});

  @override
  List<Object?> get props => [message, code];
}

class ServerFailure extends Failure {
  const ServerFailure([String message = 'An unexpected error occurred', String? code])
      : super(message: message, code: code);
}

class CacheFailure extends Failure {
  const CacheFailure([String message = 'A caching error occurred', String? code])
      : super(message: message, code: code);
}
