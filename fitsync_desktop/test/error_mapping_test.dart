import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitsync_desktop/core/error/dio_failure.dart';

/// These cover the two things the error path has to get right: the API's own
/// envelope must be unwrapped (never printed as a Dart map), and the stable
/// code must survive, because the whole translation layer keys off it.
DioException _withBody(Object? body) => DioException(
      requestOptions: RequestOptions(path: '/api/Trainers/1/availability'),
      response: Response(
        requestOptions: RequestOptions(path: '/api/Trainers/1/availability'),
        statusCode: 400,
        data: body,
      ),
      type: DioExceptionType.badResponse,
    );

void main() {
  test('business-rule envelope keeps both the message and the code', () {
    final f = _withBody({
      'error': 'AVAILABILITY_OVERLAP',
      'message': 'This window overlaps an availability slot the trainer already has.',
      'traceId': '00-f3c1-01',
    });
    final failure = failureFrom(f);

    expect(failure.code, 'AVAILABILITY_OVERLAP');
    expect(failure.message,
        'This window overlaps an availability slot the trainer already has.');
    // The bug this replaced: the whole map ended up on screen.
    expect(failure.message, isNot(contains('traceId')));
    expect(failure.message, isNot(contains('{')));
  });

  test('model-validation envelope uses the first field error', () {
    final failure = failureFrom(_withBody({
      'error': 'VALIDATION_FAILED',
      'errors': {
        'Price': ['Price must be greater than zero.'],
      },
    }));

    expect(failure.code, 'VALIDATION_FAILED');
    expect(failure.message, 'Price must be greater than zero.');
  });

  test('a connection failure with no body falls back to the Dio message', () {
    final failure = failureFrom(DioException(
      requestOptions: RequestOptions(path: '/api/Trainings'),
      type: DioExceptionType.connectionError,
      message: 'Connection refused',
    ));

    expect(failure.code, isNull);
    expect(failure.message, 'Connection refused');
  });

  test('a non-map body does not crash the parser', () {
    final failure = failureFrom(_withBody('<html>502 Bad Gateway</html>'));
    expect(failure.message, isNotEmpty);
  });
}
