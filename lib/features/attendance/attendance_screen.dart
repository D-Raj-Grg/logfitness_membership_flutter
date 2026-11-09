// The Attendance tab: a month calendar of the member's own visits. Read-only;
// the database decides present / absent / off / holiday per day.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_membership_flutter/app/brand.dart';
import 'package:logfitness_membership_flutter/data/attendance_calendar/attendance_calendar.dart';
import 'package:logfitness_membership_flutter/data/attendance_calendar/year_month.dart';
import 'package:logfitness_membership_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_membership_flutter/features/attendance/attendance_providers.dart';
import 'package:logfitness_membership_flutter/features/attendance/calendar_logic.dart';
import 'package:logfitness_membership_flutter/features/attendance/calendar_widgets.dart';
import 'package:logfitness_membership_flutter/features/common/async_value_view.dart';
import 'package:logfitness_membership_flutter/features/common/failure_view.dart';
import 'package:logfitness_membership_flutter/features/common/log_card.dart';
import 'package:logfitness_membership_flutter/features/common/skeleton_box.dart';
import 'package:logfitness_membership_flutter/l10n/app_localizations.dart';

const Key attendancePrevKey = Key('attendance-prev');
const Key attendanceNextKey = Key('attendance-next');
const Key attendanceTitleKey = Key('attendance-title');

class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen> {
  /// Direction of the last navigation, for the slide transition.
  bool _forward = true;

  void _go(YearMonth target) {
    final YearMonth current = ref.read(selectedAttendanceMonthProvider);
    setState(() => _forward = target > current);
    ref.read(selectedAttendanceMonthProvider.notifier).set(target);
  }

  Future<void> _refresh(YearMonth month) async {
    ref.invalidate(attendanceCalendarProvider(month));
    try {
      await ref.read(attendanceCalendarProvider(month).future);
    } catch (_) {
      // The error state renders itself; the spinner just has to stop.
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final YearMonth selected = ref.watch(selectedAttendanceMonthProvider);
    final YearMonth initial = ref.watch(attendanceInitialMonthProvider);
    // The server's `today` is the authority once a response is in.
    final DateTime? serverToday = ref
        .watch(attendanceCalendarProvider(selected))
        .value
        ?.today;
    final YearMonth current = serverToday == null
        ? initial
        : YearMonth.of(serverToday);
    final bool still = MediaQuery.disableAnimationsOf(context);
    final Duration duration = still ? Duration.zero : Brand.motionBase;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabAttendance)),
      body: RefreshIndicator(
        onRefresh: () => _refresh(selected),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            Brand.gutter,
            Brand.spaceSm,
            Brand.gutter,
            Brand.spaceXl,
          ),
          children: <Widget>[
            _MonthHeader(
              month: selected,
              forward: _forward,
              duration: duration,
              onPrevious: canGoPrevious(selected, current)
                  ? () => _go(selected.addMonths(-1))
                  : null,
              onNext: canGoNext(selected, current)
                  ? () => _go(selected.addMonths(1))
                  : null,
            ),
            const SizedBox(height: Brand.spaceSm),
            AnimatedSwitcher(
              duration: duration,
              switchInCurve: Brand.motionCurve,
              switchOutCurve: Curves.easeIn,
              transitionBuilder: (Widget child, Animation<double> animation) =>
                  _monthTransition(child, animation, selected, _forward),
              child: _MonthBody(
                key: ValueKey<YearMonth>(selected),
                month: selected,
                onRetry: () =>
                    ref.invalidate(attendanceCalendarProvider(selected)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Slide + fade. The incoming child enters from the travel direction, the
/// outgoing one leaves the opposite way.
Widget _monthTransition(
  Widget child,
  Animation<double> animation,
  YearMonth selected,
  bool forward,
) {
  final bool incoming = child.key == ValueKey<YearMonth>(selected);
  final double dx = (forward ? 1 : -1) * 0.12 * (incoming ? 1 : -1);
  return FadeTransition(
    opacity: animation,
    child: SlideTransition(
      position: Tween<Offset>(
        begin: Offset(dx, 0),
        end: Offset.zero,
      ).animate(animation),
      child: child,
    ),
  );
}

class _MonthHeader extends StatelessWidget {
  const _MonthHeader({
    required this.month,
    required this.forward,
    required this.duration,
    required this.onPrevious,
    required this.onNext,
  });

  final YearMonth month;
  final bool forward;
  final Duration duration;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    return Row(
      children: <Widget>[
        IconButton(
          key: attendancePrevKey,
          tooltip: l10n.attendancePreviousMonth,
          onPressed: onPrevious,
          icon: const Icon(Icons.chevron_left),
        ),
        Expanded(
          child: Semantics(
            header: true,
            liveRegion: true,
            child: AnimatedSwitcher(
              duration: duration,
              transitionBuilder: (Widget child, Animation<double> animation) =>
                  _monthTransition(child, animation, month, forward),
              child: Text(
                monthTitle(context, month),
                key: ValueKey<YearMonth>(month),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge,
              ),
            ),
          ),
        ),
        IconButton(
          key: attendanceNextKey,
          tooltip: l10n.attendanceNextMonth,
          onPressed: onNext,
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class _MonthBody extends ConsumerWidget {
  const _MonthBody({required this.month, required this.onRetry, super.key});

  final YearMonth month;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AttendanceCalendar> async = ref.watch(
      attendanceCalendarProvider(month),
    );
    return async.when(
      skipLoadingOnRefresh: true,
      loading: () => const CalendarSkeleton(),
      error: (Object error, StackTrace st) =>
          FailureView(failure: mapError(error, st), onRetry: onRetry),
      data: (AttendanceCalendar calendar) =>
          _CalendarContent(month: month, calendar: calendar),
    );
  }
}

class _CalendarContent extends StatelessWidget {
  const _CalendarContent({required this.month, required this.calendar});

  final YearMonth month;
  final AttendanceCalendar calendar;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SummaryCard(summary: calendar.summary),
        const SizedBox(height: Brand.spaceMd),
        LogCard(
          padding: const EdgeInsets.fromLTRB(
            Brand.spaceSm,
            Brand.spaceMd,
            Brand.spaceSm,
            Brand.spaceSm,
          ),
          child: Column(
            children: <Widget>[
              const WeekdayRow(),
              const SizedBox(height: Brand.spaceXs),
              MonthGrid(month: month, calendar: calendar),
            ],
          ),
        ),
        const SizedBox(height: Brand.spaceMd),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: Brand.spaceXs),
          child: CalendarLegend(),
        ),
        if (isQuietMonth(calendar))
          EmptyView(
            message: l10n.attendanceEmptyMonth,
            icon: Icons.event_available_outlined,
          ),
      ],
    );
  }
}

/// Stand-in for the summary card + calendar card while a month loads.
class CalendarSkeleton extends StatelessWidget {
  const CalendarSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: attendanceSkeletonKey,
      children: <Widget>[
        const SkeletonBox(height: 112, radius: Brand.radiusCard),
        const SizedBox(height: Brand.spaceMd),
        const SkeletonBox(height: 340, radius: Brand.radiusCard),
        const SizedBox(height: Brand.spaceMd),
        Row(
          children: <Widget>[
            for (int i = 0; i < 4; i++) ...<Widget>[
              const SkeletonBox(width: 64, height: 16),
              const SizedBox(width: Brand.spaceMd),
            ],
          ],
        ),
      ],
    );
  }
}
