import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_membership_flutter/domain/enums/postgres_enums.dart';

void main() {
  test('wire values round-trip and unknown values fail loudly', () {
    for (final v in MemberStatus.values) {
      expect(MemberStatus.fromDb(v.wire), v);
    }
    expect(
      () => MemberStatus.fromDb('banana'),
      throwsA(isA<UnknownEnumValue>()),
    );
  });
}
