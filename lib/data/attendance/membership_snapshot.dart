// What the door and the public balance page would say about this member right
// now. Mirrors the return shape of the SQL function `attendance_snapshot`
// (20261012100200_member_card_rpcs_and_rfid_check_in.sql):
//
//   membership_id uuid, membership_status membership_status, plan_name text,
//   days_to_expiry int, sessions_remaining int, due_paisa bigint, banner text
//
// The function returns no dates, so `startDate` / `endDate` are filled by the
// repository from the member's own `memberships` row (RLS-scoped).
//
// `banner` is one of: active, expiring, expired, frozen, upcoming, none, left.
// Hand-written (no codegen): it is a read model, never sent back.

enum SnapshotBanner {
  active,
  expiring,
  expired,
  frozen,
  upcoming,
  none;

  /// Unknown or `left` banners fall to [none]: a member who has left never
  /// reaches Home (the router sends them to /not-member), and a banner added
  /// upstream later must not crash a shipped build.
  static SnapshotBanner parse(Object? raw) => switch (raw) {
    'active' => SnapshotBanner.active,
    'expiring' => SnapshotBanner.expiring,
    'expired' => SnapshotBanner.expired,
    'frozen' => SnapshotBanner.frozen,
    'upcoming' => SnapshotBanner.upcoming,
    _ => SnapshotBanner.none,
  };
}

class MembershipSnapshot {
  const MembershipSnapshot({
    required this.banner,
    this.membershipId,
    this.planName,
    this.daysToExpiry,
    this.sessionsRemaining,
    this.duePaisa = 0,
    this.startDate,
    this.endDate,
  });

  /// No membership row at all (a member with nothing yet).
  const MembershipSnapshot.empty() : this(banner: SnapshotBanner.none);

  factory MembershipSnapshot.fromRow(Map<String, dynamic> row) {
    int? asInt(Object? v) => v is num ? v.toInt() : null;
    return MembershipSnapshot(
      banner: SnapshotBanner.parse(row['banner']),
      membershipId: row['membership_id'] as String?,
      planName: row['plan_name'] as String?,
      daysToExpiry: asInt(row['days_to_expiry']),
      sessionsRemaining: asInt(row['sessions_remaining']),
      // bigint arrives as an int over JSON; never a double.
      duePaisa: asInt(row['due_paisa']) ?? 0,
    );
  }

  final SnapshotBanner banner;
  final String? membershipId;
  final String? planName;

  /// Calendar days from the org's today to the end date; negative once past.
  final int? daysToExpiry;
  final int? sessionsRemaining;

  /// Integer paisa across unpaid / partial invoices.
  final int duePaisa;

  /// Plain dates (UTC midnight), see `plain_date.dart`.
  final DateTime? startDate;
  final DateTime? endDate;

  MembershipSnapshot withDates({DateTime? startDate, DateTime? endDate}) =>
      MembershipSnapshot(
        banner: banner,
        membershipId: membershipId,
        planName: planName,
        daysToExpiry: daysToExpiry,
        sessionsRemaining: sessionsRemaining,
        duePaisa: duePaisa,
        startDate: startDate,
        endDate: endDate,
      );
}
