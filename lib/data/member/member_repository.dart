// The signed-in member's own record. A repository is the only thing that
// touches `supabase` (PLANNING.md §3); every method runs under
// `guardFailures`.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:logfitness_membership_flutter/data/member/current_member.dart';
import 'package:logfitness_membership_flutter/data/repository_guard.dart';
import 'package:logfitness_membership_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_membership_flutter/supabase/supabase_providers.dart';

class MemberRepository {
  const MemberRepository(this._client);

  final SupabaseClient _client;

  /// The member row for the signed-in account via the `current_member()` RPC
  /// (readable before claims exist). `null` when the account is not linked to
  /// a member.
  Future<CurrentMember?> currentMember() => guardFailures(() async {
    final List<dynamic> rows =
        await _client.rpc('current_member') as List<dynamic>;
    if (rows.isEmpty) {
      return null;
    }
    return CurrentMember.fromJson(rows.first as Map<String, dynamic>);
  });
}

final memberRepositoryProvider = Provider<MemberRepository>((ref) {
  return MemberRepository(ref.watch(supabaseClientProvider));
});

/// The signed-in member (identity, org name/currency/timezone, home branch,
/// member code, status). Every feature reads org currency/timezone from here
/// -- dates are shown in the org's timezone, never the phone's.
///
/// Re-fetches when a different user signs in. Throws a `notFound`
/// `AppFailure` if the account is not linked to a member.
final memberSelfProvider = FutureProvider<CurrentMember>((ref) async {
  // Rebuild on account change, but not on every token refresh.
  ref.watch(sessionProvider.select((Session? s) => s?.user.id));
  final CurrentMember? me = await ref
      .watch(memberRepositoryProvider)
      .currentMember();
  if (me == null) {
    throw const AppFailure(
      FailureKind.notFound,
      'This account is not linked to a member.',
    );
  }
  return me;
});
