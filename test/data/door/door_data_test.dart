import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_membership_flutter/data/door/door_check_in_result.dart';
import 'package:logfitness_membership_flutter/data/door/door_qr_payload.dart';

void main() {
  group('DoorQrPayload.tryParse', () {
    test('accepts a valid payload', () {
      expect(DoorQrPayload.tryParse('LG1.7.56789012')?.text, 'LG1.7.56789012');
      expect(
        DoorQrPayload.tryParse('LG1.123456.00000000')?.text,
        'LG1.123456.00000000',
      );
    });

    test('trims surrounding whitespace', () {
      expect(
        DoorQrPayload.tryParse('  LG1.7.56789012\n')?.text,
        'LG1.7.56789012',
      );
    });

    test('rejects a wrong prefix', () {
      expect(DoorQrPayload.tryParse('LG2.7.56789012'), isNull);
      expect(DoorQrPayload.tryParse('XX1.7.56789012'), isNull);
      expect(DoorQrPayload.tryParse('7.56789012'), isNull);
    });

    test('rejects lowercase prefix', () {
      expect(DoorQrPayload.tryParse('lg1.7.56789012'), isNull);
    });

    test('rejects wrong lengths', () {
      expect(DoorQrPayload.tryParse('LG1.7.5678901'), isNull); // 7 digits
      expect(DoorQrPayload.tryParse('LG1.7.567890123'), isNull); // 9 digits
      expect(DoorQrPayload.tryParse('LG1..56789012'), isNull); // empty id
      expect(
        DoorQrPayload.tryParse('LG1.1234567.56789012'),
        isNull,
      ); // 7-digit id
    });

    test('rejects non-digits, extra segments, embedded whitespace', () {
      expect(DoorQrPayload.tryParse('LG1.7.5678901a'), isNull);
      expect(DoorQrPayload.tryParse('LG1.7.56789012.x'), isNull);
      expect(DoorQrPayload.tryParse('LG1.7. 56789012'), isNull);
      expect(DoorQrPayload.tryParse('LG1.7.56789012 LG1.7.56789012'), isNull);
    });

    test('rejects null, empty and foreign QR content', () {
      expect(DoorQrPayload.tryParse(null), isNull);
      expect(DoorQrPayload.tryParse(''), isNull);
      expect(DoorQrPayload.tryParse('https://example.com'), isNull);
    });
  });

  group('DoorCheckInResult.fromJson', () {
    test('ok with all fields', () {
      final DoorCheckInResult r = DoorCheckInResult.fromJson(<String, dynamic>{
        'result': 'ok',
        'member_name': 'Sita Rai',
        'days_to_expiry': 12,
        'already_checked_in_today': true,
      });
      expect(r, isA<DoorOk>());
      final DoorOk ok = r as DoorOk;
      expect(ok.memberName, 'Sita Rai');
      expect(ok.firstName, 'Sita');
      expect(ok.daysToExpiry, 12);
      expect(ok.alreadyCheckedInToday, isTrue);
    });

    test('ok with only the result key', () {
      final DoorOk ok =
          DoorCheckInResult.fromJson(<String, dynamic>{'result': 'ok'})
              as DoorOk;
      expect(ok.firstName, isNull);
      expect(ok.daysToExpiry, isNull);
      expect(ok.alreadyCheckedInToday, isFalse);
    });

    test('denied maps reasons leniently', () {
      DoorDenied denied(String? reason, {Object? due}) =>
          DoorCheckInResult.fromJson(<String, dynamic>{
                'result': 'denied',
                'reason': reason,
                'due_paisa': due,
              })
              as DoorDenied;
      expect(denied('expired').reason, DoorDeniedReason.expired);
      expect(denied('membership_expired').reason, DoorDeniedReason.expired);
      expect(denied('frozen').reason, DoorDeniedReason.frozen);
      expect(denied('dues_unpaid', due: 150000).reason, DoorDeniedReason.dues);
      expect(denied('dues_unpaid', due: 150000).duePaisa, 150000);
      expect(denied('something_new').reason, DoorDeniedReason.other);
      expect(denied(null).reason, DoorDeniedReason.other);
    });

    test('the plain statuses', () {
      expect(
        DoorCheckInResult.fromJson(<String, dynamic>{'result': 'invalid_code'}),
        isA<DoorInvalidCode>(),
      );
      expect(
        DoorCheckInResult.fromJson(<String, dynamic>{'result': 'closed'}),
        isA<DoorClosed>(),
      );
      expect(
        DoorCheckInResult.fromJson(<String, dynamic>{'result': 'rate_limited'}),
        isA<DoorRateLimited>(),
      );
    });

    test('unknown result codes and junk never become a success', () {
      final DoorCheckInResult r = DoorCheckInResult.fromJson(<String, dynamic>{
        'result': 'teleported',
      });
      expect(r, isA<DoorUnknown>());
      expect((r as DoorUnknown).code, 'teleported');
      expect(DoorCheckInResult.fromJson(null), isA<DoorUnknown>());
      expect(DoorCheckInResult.fromJson('ok'), isA<DoorUnknown>());
      expect(
        DoorCheckInResult.fromJson(<String, dynamic>{'result': 7}),
        isA<DoorUnknown>(),
      );
    });
  });
}
