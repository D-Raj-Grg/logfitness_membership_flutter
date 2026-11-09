import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_membership_flutter/data/memberships/membership.dart';
import 'package:logfitness_membership_flutter/data/memberships/memberships_repository.dart';
import 'package:logfitness_membership_flutter/domain/enums/postgres_enums.dart';

void main() {
  test('maps plan history rows, with plain-date start/end', () {
    final List<Membership> list = membershipsFromRows(<Map<String, dynamic>>[
      <String, dynamic>{
        'id': 'm2',
        'plan_id': 'p1',
        'plan_name': 'Monthly',
        'plan_type': 'time',
        'start_date': '2026-11-01',
        'end_date': '2026-11-30',
        'sessions_total': null,
        'sessions_remaining': null,
        'price_paisa': 300000,
        'discount_paisa': 0,
        'status': 'active',
        'created_at': '2026-11-01T03:00:00+00:00',
        'future_column': true,
      },
      <String, dynamic>{
        'id': 'm1',
        'plan_id': 'p1',
        'plan_name': 'Monthly',
        'plan_type': 'a_plan_type_we_have_never_seen',
        'start_date': '2026-10-01',
        'end_date': null,
        'price_paisa': 300000,
        'discount_paisa': 50000,
        'status': 'expired',
        'created_at': '2026-10-01T03:00:00+00:00',
      },
    ]);
    expect(list.map((Membership m) => m.id), <String>['m2', 'm1']);
    expect(list.first.startDate, DateTime.utc(2026, 11, 1));
    expect(list.first.endDate, DateTime.utc(2026, 11, 30));
    expect(list.first.status, MembershipStatus.active);
    expect(list.last.endDate, isNull);
    expect(list.last.planType, 'a_plan_type_we_have_never_seen');
    expect(list.last.discountPaisa, 50000);
  });
}
