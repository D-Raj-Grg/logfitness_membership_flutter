import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_membership_flutter/data/qr/qr_token.dart';

void main() {
  test('parses the mint_qr_token payload and ignores expires_at', () {
    final QrToken t = QrToken.fromJson(<String, dynamic>{
      'token': 'abc.def',
      'member_id': 'm-1',
      'ttl_seconds': 90,
      'expires_at': '2099-01-01T00:00:00Z',
    });
    expect(t.token, 'abc.def');
    expect(t.memberId, 'm-1');
    expect(t.ttl, const Duration(seconds: 90));
  });

  test('tolerates a numeric ttl and a missing member_id', () {
    final QrToken t = QrToken.fromJson(<String, dynamic>{
      'token': 't',
      'ttl_seconds': 60.0,
    });
    expect(t.ttl, const Duration(seconds: 60));
    expect(t.memberId, isNull);
  });
}
