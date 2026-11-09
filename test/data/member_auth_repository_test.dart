import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_membership_flutter/data/auth/member_auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  group('PIN shape', () {
    test('exactly six ASCII digits', () {
      expect(isValidMemberPin('123456'), isTrue);
      expect(isValidMemberPin('000000'), isTrue);
      for (final String bad in <String>['', '1234', '12345', '1234567', '12345a', '12 456', '١٢٣٤٥٦']) {
        expect(isValidMemberPin(bad), isFalse, reason: 'length ${bad.length}');
      }
    });

    test('login refuses a malformed PIN before touching the network', () async {
      // The client is never reached, so a null-ish stand-in would throw if it were.
      final SupabaseMemberAuthRepository repo =
          SupabaseMemberAuthRepository(_NoClient());
      expect(await repo.login(identifier: '0004', pin: '1234'), isA<LoginInvalid>());
      expect(await repo.login(identifier: '0004', pin: '1234567'), isA<LoginInvalid>());
    });
  });
}

class _NoClient implements SupabaseClient {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('network must not be reached');
}
