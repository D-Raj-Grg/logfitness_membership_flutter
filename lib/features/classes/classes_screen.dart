import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:logfitness_membership_flutter/app/brand.dart';
import 'package:logfitness_membership_flutter/app/router.dart';
import 'package:logfitness_membership_flutter/data/classes/class_board_notifier.dart';
import 'package:logfitness_membership_flutter/data/member/member_repository.dart';
import 'package:logfitness_membership_flutter/domain/classes/class_booking.dart';
import 'package:logfitness_membership_flutter/domain/classes/class_booking_status.dart';
import 'package:logfitness_membership_flutter/domain/classes/class_days.dart';
import 'package:logfitness_membership_flutter/domain/classes/class_session.dart';
import 'package:logfitness_membership_flutter/domain/classes/session_card_state.dart';
import 'package:logfitness_membership_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_membership_flutter/domain/format/dates.dart';
import 'package:logfitness_membership_flutter/features/bookings/cancel_booking_dialog.dart';
import 'package:logfitness_membership_flutter/features/classes/day_selector.dart';
import 'package:logfitness_membership_flutter/features/classes/session_card.dart';
import 'package:logfitness_membership_flutter/features/common/async_value_view.dart';
import 'package:logfitness_membership_flutter/features/common/failure_snackbar.dart';
import 'package:logfitness_membership_flutter/features/common/failure_view.dart';
import 'package:logfitness_membership_flutter/features/common/skeleton_box.dart';
import 'package:logfitness_membership_flutter/l10n/app_localizations.dart';

/// How often the board is re-read while this tab is on screen. Polling, not
/// Realtime: capacity changes are infrequent and a 30 s lag is harmless
/// because the booking RPC re-checks capacity under a row lock anyway.
const Duration kClassesPollInterval = Duration(seconds: 30);

class ClassesScreen extends ConsumerStatefulWidget {
  const ClassesScreen({super.key});

  @override
  ConsumerState<ClassesScreen> createState() => _ClassesScreenState();
}

class _ClassesScreenState extends ConsumerState<ClassesScreen>
    with WidgetsBindingObserver {
  int _day = 0;
  Timer? _timer;
  bool _foreground = true;
  bool _tabVisible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _syncTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The shell keeps every tab mounted; a hidden tab has tickers disabled.
    final bool visible = TickerMode.of(context);
    if (visible != _tabVisible) {
      _tabVisible = visible;
      if (visible) {
        _tick();
      }
      _syncTimer();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final bool fg = state == AppLifecycleState.resumed;
    if (fg == _foreground) {
      return;
    }
    _foreground = fg;
    if (fg) {
      _tick();
    }
    _syncTimer();
  }

  void _syncTimer() {
    _timer?.cancel();
    _timer = null;
    if (_foreground && _tabVisible) {
      _timer = Timer.periodic(kClassesPollInterval, (_) => _tick());
    }
  }

  void _tick() {
    if (!mounted) {
      return;
    }
    unawaited(ref.read(classBoardProvider.notifier).quietReload());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _book(ClassSession session) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      final ClassBookingStatus status = await ref
          .read(classBoardProvider.notifier)
          .book(session);
      if (!mounted) {
        return;
      }
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              status == ClassBookingStatus.waitlisted
                  ? l10n.classesWaitlistedSnack(session.className)
                  : l10n.classesBookedSnack(session.className),
            ),
          ),
        );
    } catch (error, stack) {
      if (mounted) {
        showErrorSnackBar(context, error, stackTrace: stack);
      }
    }
  }

  Future<void> _cancel(ClassSession session, ClassBooking booking) async {
    final String tz = _timeZone();
    final bool yes = await confirmCancelBooking(
      context,
      className: session.className,
      when: formatDateTime(session.startsAt, timeZone: tz),
    );
    if (!yes || !mounted) {
      return;
    }
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(classBoardProvider.notifier).cancel(booking);
      if (mounted) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.classesCancelledSnack)));
      }
    } catch (error, stack) {
      if (mounted) {
        showErrorSnackBar(context, error, stackTrace: stack);
      }
    }
  }

  String _timeZone() =>
      ref.read(memberSelfProvider).value?.timezone ?? kDefaultTimezone;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<ClassBoard> board = ref.watch(classBoardProvider);
    final String tz =
        ref.watch(memberSelfProvider).value?.timezone ?? kDefaultTimezone;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.tabClasses),
        actions: <Widget>[
          IconButton(
            tooltip: l10n.classesMyBookings,
            icon: const Icon(Icons.event_available_outlined),
            onPressed: () => context.push(AppRoutes.bookings),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          DaySelector(
            timeZone: tz,
            selected: _day,
            onSelected: (int d) => setState(() => _day = d),
          ),
          Expanded(
            child: board.when(
              skipLoadingOnRefresh: true,
              skipError: false,
              loading: () => const _Skeleton(),
              error: (Object e, StackTrace s) => FailureView(
                failure: mapError(e, s),
                onRetry: () => ref.invalidate(classBoardProvider),
              ),
              data: (ClassBoard data) => _Day(
                board: data,
                day: _day,
                timeZone: tz,
                onBook: _book,
                onCancel: _cancel,
                onRefresh: () =>
                    ref.read(classBoardProvider.notifier).refresh(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Day extends StatelessWidget {
  const _Day({
    required this.board,
    required this.day,
    required this.timeZone,
    required this.onBook,
    required this.onCancel,
    required this.onRefresh,
  });

  final ClassBoard board;
  final int day;
  final String timeZone;
  final void Function(ClassSession) onBook;
  final void Function(ClassSession, ClassBooking) onCancel;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final DateTime now = DateTime.now().toUtc();
    final List<ClassSession> sessions =
        groupSessionsByDay(
          board.sessions,
          dayOf: (ClassSession s) =>
              orgDayOffset(s.startsAt, timeZone: timeZone),
        )[day] ??
        const <ClassSession>[];

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: sessions.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(Brand.gutter),
              children: <Widget>[
                const SizedBox(height: Brand.spaceXl),
                EmptyView(
                  icon: Icons.event_busy_outlined,
                  message:
                      '${l10n.classesNoClasses}\n${l10n.classesNoClassesHint}',
                ),
              ],
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                Brand.gutter,
                Brand.spaceSm,
                Brand.gutter,
                Brand.spaceXl,
              ),
              itemCount: sessions.length,
              separatorBuilder: (_, _) => const SizedBox(height: Brand.spaceMd),
              itemBuilder: (BuildContext context, int i) {
                final ClassSession s = sessions[i];
                final ClassBooking? live = board.liveBookingFor(s.id);
                return SessionCard(
                  session: s,
                  timeZone: timeZone,
                  state: sessionCardState(
                    session: s,
                    liveBooking: live,
                    busy: board.isBusy(s.id),
                    now: now,
                  ),
                  onBook: () => onBook(s),
                  onCancel: () {
                    if (live != null) {
                      onCancel(s, live);
                    }
                  },
                );
              },
            ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(Brand.gutter),
      children: <Widget>[
        for (int i = 0; i < 3; i++) ...<Widget>[
          const SkeletonBox(height: 168, radius: Brand.radiusCard),
          const SizedBox(height: Brand.spaceMd),
        ],
      ],
    );
  }
}
