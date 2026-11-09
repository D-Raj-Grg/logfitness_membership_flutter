// What `member_door_check_in` answered, as a closed set the UI can switch on.
// An unrecognised `result` becomes [DoorUnknown] -- never a fake success.

/// Why the door said no. Mapped leniently from the server's `reason` text so
/// a reworded reason degrades to [other] (a generic "see the front desk")
/// rather than to a wrong explanation.
enum DoorDeniedReason {
  expired,
  dues,
  frozen,
  other;

  static DoorDeniedReason parse(String? reason) {
    final String r = (reason ?? '').toLowerCase();
    if (r.contains('expire')) return DoorDeniedReason.expired;
    if (r.contains('froze') || r.contains('freez')) {
      return DoorDeniedReason.frozen;
    }
    if (r.contains('due') || r.contains('unpaid') || r.contains('balance')) {
      return DoorDeniedReason.dues;
    }
    return DoorDeniedReason.other;
  }
}

sealed class DoorCheckInResult {
  const DoorCheckInResult();

  factory DoorCheckInResult.fromJson(Object? raw) {
    if (raw is! Map) return const DoorUnknown(null);
    final Object? result = raw['result'];
    switch (result) {
      case 'ok':
        return DoorOk(
          memberName: _string(raw['member_name']),
          daysToExpiry: _int(raw['days_to_expiry']),
          alreadyCheckedInToday: raw['already_checked_in_today'] == true,
        );
      case 'denied':
        return DoorDenied(
          reason: DoorDeniedReason.parse(_string(raw['reason'])),
          memberName: _string(raw['member_name']),
          duePaisa: _int(raw['due_paisa']),
        );
      case 'invalid_code':
        return const DoorInvalidCode();
      case 'closed':
        return const DoorClosed();
      case 'rate_limited':
        return const DoorRateLimited();
      default:
        return DoorUnknown(result is String ? result : null);
    }
  }

  static String? _string(Object? v) {
    if (v is! String) return null;
    final String t = v.trim();
    return t.isEmpty ? null : t;
  }

  static int? _int(Object? v) => v is num ? v.toInt() : null;
}

/// Attendance marked and the door opened.
class DoorOk extends DoorCheckInResult {
  const DoorOk({
    this.memberName,
    this.daysToExpiry,
    this.alreadyCheckedInToday = false,
  });

  final String? memberName;
  final int? daysToExpiry;
  final bool alreadyCheckedInToday;

  /// First word of the name, for the greeting.
  String? get firstName {
    final String? n = memberName;
    if (n == null) return null;
    final String first = n.split(RegExp(r'\s+')).first;
    return first.isEmpty ? null : first;
  }
}

class DoorDenied extends DoorCheckInResult {
  const DoorDenied({required this.reason, this.memberName, this.duePaisa});

  final DoorDeniedReason reason;
  final String? memberName;

  /// Integer paisa owed, when the server says dues are the problem.
  final int? duePaisa;
}

/// The code was stale or not ours; scanning the screen again fixes it.
class DoorInvalidCode extends DoorCheckInResult {
  const DoorInvalidCode();
}

class DoorClosed extends DoorCheckInResult {
  const DoorClosed();
}

class DoorRateLimited extends DoorCheckInResult {
  const DoorRateLimited();
}

/// A `result` this build does not know.
class DoorUnknown extends DoorCheckInResult {
  const DoorUnknown(this.code);

  final String? code;
}
