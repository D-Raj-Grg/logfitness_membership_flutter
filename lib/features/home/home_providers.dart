import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:logfitness_membership_flutter/data/attendance/attendance_repository.dart';
import 'package:logfitness_membership_flutter/data/attendance/membership_snapshot.dart';
import 'package:logfitness_membership_flutter/data/member/current_member.dart';
import 'package:logfitness_membership_flutter/data/member/member_repository.dart';
import 'package:logfitness_membership_flutter/data/member/my_card.dart';
import 'package:logfitness_membership_flutter/data/renewal/renewal_repository.dart';
import 'package:logfitness_membership_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_membership_flutter/supabase/supabase_providers.dart';

/// Everything Home shows, with the moment it was fetched ("last updated").
class HomeData {
  const HomeData({
    required this.member,
    required this.snapshot,
    required this.card,
    required this.fetchedAt,
  });

  final CurrentMember member;
  final MembershipSnapshot snapshot;
  final MyCard card;
  final DateTime fetchedAt;
}

/// Not auto-disposed: the previous value stays in memory, so a failed refresh
/// (offline) keeps showing the last-known snapshot (`AsyncValue.value`).
/// Scoped to the signed-in account via [memberSelfProvider].
final homeDataProvider = FutureProvider<HomeData>((ref) async {
  final CurrentMember me = await ref.watch(memberSelfProvider.future);
  final AttendanceRepository attendance = ref.watch(
    attendanceRepositoryProvider,
  );
  // Seeds the renewal button (see [RenewalController]); loaded with Home so
  // the button never flashes "Request renewal" before "Requested".
  await ref.watch(pendingRenewalProvider.future);
  final (MembershipSnapshot snap, MyCard card) = await (
    attendance.fetchSnapshot(me.memberId),
    // A card lookup failing must not take Home down.
    ref
        .watch(memberRepositoryProvider)
        .myCard()
        .catchError((Object _) => const MyCard.none()),
  ).wait;
  return HomeData(
    member: me,
    snapshot: snap,
    card: card,
    fetchedAt: DateTime.now(),
  );
});

/// The server's pending renewal request for this member, or null.
///
/// Never throws: a failure here must not break Home, so it falls back to
/// "nothing pending" (the button stays usable; the server's `too_soon` guard
/// still protects against double-sends).
final pendingRenewalProvider = FutureProvider<PendingRenewal?>((ref) async {
  ref.watch(sessionProvider.select((Session? s) => s?.user.id));
  try {
    return await ref.watch(renewalRepositoryProvider).pendingRequest();
  } catch (_) {
    return null;
  }
});

/// Renewal request state. Seeded from [pendingRenewalProvider] so a pending
/// request survives an app restart; the server remains the authority (one
/// pending row; `too_soon`), this only drives the button.
sealed class RenewalState {
  const RenewalState();
}

final class RenewalIdle extends RenewalState {
  const RenewalIdle();
}

final class RenewalSubmitting extends RenewalState {
  const RenewalSubmitting();
}

final class RenewalRequested extends RenewalState {
  const RenewalRequested(this.at);

  final DateTime at;
}

/// Outcome the UI turns into copy.
enum RenewalOutcome { requested, tooSoon, noMember }

class RenewalController extends Notifier<RenewalState> {
  @override
  RenewalState build() {
    // A different account must never inherit "already requested".
    ref.watch(sessionProvider.select((Session? s) => s?.user.id));
    // Re-seeds whenever the server copy is refreshed (pull-to-refresh), so a
    // request the front desk has handled frees the button again.
    final PendingRenewal? pending = ref.watch(pendingRenewalProvider).value;
    return pending == null
        ? const RenewalIdle()
        : RenewalRequested(pending.lastRequestedAt);
  }

  /// Throws [AppFailure] on offline/other failure (state returns to idle).
  Future<RenewalOutcome> submit({String? phone, String? note}) async {
    if (state is RenewalSubmitting) {
      return RenewalOutcome.requested;
    }
    final RenewalState before = state;
    state = const RenewalSubmitting();
    try {
      final RenewalResult result = await ref
          .read(renewalRepositoryProvider)
          .requestRenewal(phone: phone, note: note);
      switch (result) {
        case RenewalResult.ok:
          state = RenewalRequested(DateTime.now());
          return RenewalOutcome.requested;
        case RenewalResult.tooSoon:
          // The first request stands; show it as pending.
          state = before is RenewalRequested
              ? before
              : RenewalRequested(DateTime.now());
          return RenewalOutcome.tooSoon;
        case RenewalResult.noMember:
          state = before;
          return RenewalOutcome.noMember;
      }
    } catch (e, st) {
      state = before is RenewalSubmitting ? const RenewalIdle() : before;
      Error.throwWithStackTrace(mapError(e, st), st);
    }
  }
}

final renewalControllerProvider =
    NotifierProvider<RenewalController, RenewalState>(RenewalController.new);
