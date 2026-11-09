import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

/// The claims the Supabase access-token hook injects into a session's JWT.
///
/// Member-only view of the same claim set the staff app reads. The hook does
/// NOT overwrite the `role` claim -- that belongs to PostgREST and stays
/// `authenticated` for every request (PLANNING.md §3 says `role: 'member'`;
/// the deployed hook, migration `20260905150300`, does not do that). The
/// principal type is carried by which id claim is present: `member_id` for a
/// member, `staff_role` for staff. A member is therefore:
/// `member_id != null && staff_role == null`.
///
/// A staff-only token, or a freshly created session before the member row is
/// linked, is "signed in but not a member": [fromSession] returns `null` for
/// the latter, and [isMember] is false for the former. The router shows the
/// "ask the front desk" screen for both.
/// Thrown when the access-token hook produced a claim set this client cannot
/// make sense of. Distinct from "no claims yet", which is a normal state.
class MalformedClaims implements Exception {
  const MalformedClaims(this.field, this.value);

  final String field;
  final Object? value;

  @override
  String toString() => 'MalformedClaims: $field was $value';
}

class AppClaims {
  const AppClaims({
    required this.orgId,
    required this.branchIds,
    this.staffRole,
    this.memberId,
    this.role,
  });

  final String orgId;
  final List<String> branchIds;

  /// The raw `staff_role` claim. Present only for a staff token; this app
  /// never interprets it, only treats its presence as "not a member".
  final String? staffRole;

  /// The linked member id, or `null` for a staff principal.
  final String? memberId;

  /// The PostgREST `role` claim (`authenticated`). Informational only.
  final String? role;

  /// Whether this session belongs to a member principal. A member carries
  /// `member_id` and no `staff_role`; a staff token is never a member here.
  bool get isMember => memberId != null && staffRole == null;

  /// Decodes the claims carried by [session]'s access token.
  ///
  /// Returns `null` when the token carries no principal claims yet.
  static AppClaims? fromSession(Session session) =>
      fromJwtPayload(_decodeJwtPayload(session.accessToken));

  /// Decodes claims out of an already-parsed JWT payload map.
  ///
  /// Returns `null` only when neither `staff_role` nor `member_id` is
  /// present — the normal shape of a session created before the principal
  /// row is linked.
  ///
  /// Throws [MalformedClaims] when a principal marker IS present but the
  /// rest of the claim set is not the shape the access-token hook produces
  /// (a missing `org_id`, a `branch_ids` that is not a list of strings, or
  /// both principal markers at once). Those are backend regressions, and
  /// reading them as "not linked yet" would hide one behind a screen that
  /// tells the user everything is fine.
  ///
  static AppClaims? fromJwtPayload(Map<String, dynamic> payload) {
    final orgId = payload['org_id'];
    final branchIds = payload['branch_ids'];
    final staffRoleWire = payload['staff_role'];
    final memberId = payload['member_id'];
    final role = payload['role'];

    if (staffRoleWire is! String && memberId is! String) {
      // Neither principal claim is present: signed in, not yet linked. This
      // is the only shape that legitimately produces null.
      return null;
    }

    // A principal marker IS present, so the rest of the claim set must be
    // well formed. Returning null here instead would render a token the hook
    // built wrong as an ordinary "not linked yet" account, and hide the
    // regression behind a friendly screen.
    if (orgId is! String || orgId.isEmpty) {
      throw MalformedClaims('org_id', orgId);
    }
    if (branchIds is! List) {
      throw MalformedClaims('branch_ids', branchIds);
    }
    if (staffRoleWire is String && memberId is String) {
      throw MalformedClaims('staff_role + member_id', payload);
    }

    return AppClaims(
      orgId: orgId,
      branchIds: branchIds.map((dynamic id) {
        if (id is! String) {
          throw MalformedClaims('branch_ids entry', id);
        }
        return id;
      }).toList(),
      staffRole: staffRoleWire is String ? staffRoleWire : null,
      memberId: memberId is String ? memberId : null,
      role: role is String ? role : null,
    );
  }

  /// Decodes the payload segment of [jwt] into a JSON map.
  ///
  /// This never verifies the token's signature: the database — via the
  /// access-token hook and RLS policies — is the authority on whether a
  /// claim is valid, not this client. Signature verification here would be
  /// pure theatre; a compromised client can fabricate any payload it likes
  /// regardless, so the security boundary has to (and does) live in
  /// Postgres.
  static Map<String, dynamic> _decodeJwtPayload(String jwt) {
    final parts = jwt.split('.');
    if (parts.length != 3) {
      throw const FormatException('Not a JWT: expected three segments.');
    }

    final normalized = base64Url.normalize(parts[1]);
    final decoded = utf8.decode(base64Url.decode(normalized));
    final payload = jsonDecode(decoded);

    if (payload is! Map<String, dynamic>) {
      throw const FormatException('JWT payload is not a JSON object.');
    }

    return payload;
  }
}
