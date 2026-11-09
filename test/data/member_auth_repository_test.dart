import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_membership_flutter/data/auth/member_auth_repository.dart';

void main() {
  group('mapLoginResponse', () {
    test('invalid is one generic answer', () {
      expect(
        mapLoginResponse(401, {'result': 'invalid'}),
        isA<LoginInvalid>(),
      );
    });

    test('locked carries the wait', () {
      final r = mapLoginResponse(423, {
        'result': 'locked',
        'retry_after_seconds': 840,
      });
      expect(r, isA<LoginLocked>());
      expect((r as LoginLocked).retryAfterSeconds, 840);
    });

    test('rate_limited, by body or by 429', () {
      expect(
        mapLoginResponse(200, {'result': 'rate_limited'}),
        isA<LoginRateLimited>(),
      );
      expect(mapLoginResponse(429, null), isA<LoginRateLimited>());
    });

    test('a JSON-string body (some non-2xx paths) is decoded', () {
      expect(
        mapLoginResponse(423, '{"result":"locked","retry_after_seconds":60}'),
        isA<LoginLocked>(),
      );
      expect(mapLoginResponse(500, 'not json'), isA<LoginFailed>());
    });

    test('anything unrecognised is a failure, not "wrong PIN"', () {
      expect(mapLoginResponse(500, null), isA<LoginFailed>());
      expect(mapLoginResponse(200, {'result': 'banana'}), isA<LoginFailed>());
    });
  });
}
