import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_membership_flutter/app/brand.dart';
import 'package:logfitness_membership_flutter/data/classes/class_board_notifier.dart';
import 'package:logfitness_membership_flutter/data/member/member_repository.dart';
import 'package:logfitness_membership_flutter/domain/classes/booking_partition.dart';
import 'package:logfitness_membership_flutter/domain/classes/class_booking.dart';
import 'package:logfitness_membership_flutter/domain/classes/class_booking_status.dart';
import 'package:logfitness_membership_flutter/domain/format/dates.dart';
import 'package:logfitness_membership_flutter/features/bookings/cancel_booking_dialog.dart';
import 'package:logfitness_membership_flutter/features/common/async_value_view.dart';
import 'package:logfitness_membership_flutter/features/common/failure_snackbar.dart';
import 'package:logfitness_membership_flutter/features/common/log_card.dart';
import 'package:logfitness_membership_flutter/features/common/section_header.dart';
import 'package:logfitness_membership_flutter/features/common/skeleton_box.dart';
import 'package:logfitness_membership_flutter/features/common/status_pill.dart';
import 'package:logfitness_membership_flutter/l10n/app_localizations.dart';

/// The member's own bookings: upcoming (cancellable) and past. Shares
/// `classBoardProvider` with the Classes tab so a change on one shows on the
/// other immediately.
class BookingsScreen extends ConsumerWidget {
  const BookingsScreen({super.key});

  Future<void> _cancel(
    BuildContext context,
    WidgetRef ref,
    ClassBooking booking,
    String tz,
  ) async {
    final bool yes = await confirmCancelBooking(
      context,
      className: booking.className,
      when: formatDateTime(booking.startsAt, timeZone: tz),
    );
    if (!yes || !context.mounted) {
      return;
    }
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(classBoardProvider.notifier).cancel(booking);
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.classesCancelledSnack)));
    } catch (error, stack) {
      if (context.mounted) {
        showErrorSnackBar(context, error, stackTrace: stack);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<ClassBoard> board = ref.watch(classBoardProvider);
    final String tz =
        ref.watch(memberSelfProvider).value?.timezone ?? kDefaultTimezone;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.bookingsTitle)),
      body: RefreshIndicator(
        onRefresh: () => ref.read(classBoardProvider.notifier).refresh(),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            Brand.gutter,
            Brand.spaceSm,
            Brand.gutter,
            Brand.spaceXl,
          ),
          children: <Widget>[
            if (board.isLoading && board.value == null)
              const _Skeleton()
            else
              AsyncValueView<ClassBoard>(
                value: board,
                onRetry: () => ref.invalidate(classBoardProvider),
                isEmpty: (ClassBoard b) => b.bookings.isEmpty,
                emptyMessage:
                    '${l10n.bookingsEmpty}\n${l10n.bookingsEmptyHint}',
                data: (ClassBoard b) {
                  final ({List<ClassBooking> upcoming, List<ClassBooking> past})
                  parts = partitionBookings(b.bookings, DateTime.now().toUtc());
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SectionHeader(title: l10n.bookingsUpcoming),
                      if (parts.upcoming.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: Brand.spaceMd,
                          ),
                          child: Text(l10n.bookingsNoUpcoming),
                        ),
                      for (final ClassBooking bk in parts.upcoming)
                        _BookingCard(
                          booking: bk,
                          timeZone: tz,
                          busy: b.busy.contains(bk.id),
                          onCancel: () => _cancel(context, ref, bk, tz),
                        ),
                      if (parts.past.isNotEmpty) ...<Widget>[
                        SectionHeader(title: l10n.bookingsPast),
                        for (final ClassBooking bk in parts.past)
                          _BookingCard(
                            booking: bk,
                            timeZone: tz,
                            busy: false,
                            onCancel: null,
                          ),
                      ],
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  const _BookingCard({
    required this.booking,
    required this.timeZone,
    required this.busy,
    required this.onCancel,
  });

  final ClassBooking booking;
  final String timeZone;
  final bool busy;
  final VoidCallback? onCancel;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final bool waitlisted = booking.status == ClassBookingStatus.waitlisted;
    final String when =
        '${formatDateTime(booking.startsAt, timeZone: timeZone)} – '
        '${formatTime(booking.endsAt, timeZone: timeZone)}';
    final bool cancellable =
        onCancel != null && booking.status.isLive && !busy;

    return Padding(
      padding: const EdgeInsets.only(bottom: Brand.spaceMd),
      child: LogCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Text(
                    booking.className,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: Brand.spaceSm),
                _statusPill(l10n),
              ],
            ),
            const SizedBox(height: Brand.spaceXs),
            Text(
              when,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (booking.room != null && booking.room!.isNotEmpty)
              Text(
                l10n.classesRoom(booking.room!),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            if (booking.sessionCancelled)
              Padding(
                padding: const EdgeInsets.only(top: Brand.spaceSm),
                child: Text(
                  l10n.bookingsSessionCancelled,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            if (waitlisted && onCancel != null)
              Padding(
                padding: const EdgeInsets.only(top: Brand.spaceSm),
                child: Text(
                  l10n.bookingsWaitlistNote,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            if (onCancel != null && booking.status.isLive)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  style: TextButton.styleFrom(minimumSize: const Size(88, 44)),
                  onPressed: cancellable ? onCancel : null,
                  child: Text(l10n.bookingsCancel),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _statusPill(AppLocalizations l10n) => switch (booking.status) {
    ClassBookingStatus.booked => StatusPill(
      label: l10n.bookingsStatusBooked,
      icon: Icons.check_circle,
      emphasis: PillEmphasis.strong,
    ),
    ClassBookingStatus.waitlisted => StatusPill(
      label: l10n.bookingsStatusWaitlisted,
      icon: Icons.hourglass_top,
    ),
    ClassBookingStatus.cancelled => StatusPill(
      label: l10n.bookingsStatusCancelled,
      icon: Icons.cancel_outlined,
      emphasis: PillEmphasis.subtle,
    ),
    ClassBookingStatus.attended => StatusPill(
      label: l10n.bookingsStatusAttended,
      icon: Icons.task_alt,
      emphasis: PillEmphasis.subtle,
    ),
    ClassBookingStatus.noShow => StatusPill(
      label: l10n.bookingsStatusNoShow,
      icon: Icons.event_busy_outlined,
      emphasis: PillEmphasis.subtle,
    ),
  };
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (int i = 0; i < 3; i++) ...<Widget>[
          const SkeletonBox(height: 110, radius: Brand.radiusCard),
          const SizedBox(height: Brand.spaceMd),
        ],
      ],
    );
  }
}
