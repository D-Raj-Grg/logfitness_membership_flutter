import 'package:flutter/material.dart';

import 'package:logfitness_membership_flutter/app/brand.dart';
import 'package:logfitness_membership_flutter/domain/classes/class_session.dart';
import 'package:logfitness_membership_flutter/domain/classes/session_card_state.dart';
import 'package:logfitness_membership_flutter/domain/format/dates.dart';
import 'package:logfitness_membership_flutter/features/common/log_card.dart';
import 'package:logfitness_membership_flutter/features/common/status_pill.dart';
import 'package:logfitness_membership_flutter/l10n/app_localizations.dart';

class SessionCard extends StatelessWidget {
  const SessionCard({
    required this.session,
    required this.state,
    required this.timeZone,
    required this.onBook,
    required this.onCancel,
    super.key,
  });

  final ClassSession session;
  final SessionCardState state;
  final String timeZone;
  final VoidCallback onBook;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final String start = formatTime(session.startsAt, timeZone: timeZone);
    final String end = formatTime(session.endsAt, timeZone: timeZone);
    final String spots = session.isFull
        ? l10n.classesFull
        : l10n.classesSpotsLeft(session.spotsLeft);

    return LogCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 64,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      start,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      end,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      session.className,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (session.room != null && session.room!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          l10n.classesRoom(session.room!),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Brand.spaceMd),
          Semantics(
            label: l10n.classesCapacitySemantics(
              session.bookedCount,
              session.capacity,
            ),
            child: ExcludeSemantics(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(Brand.radiusPill),
                      child: LinearProgressIndicator(
                        value: session.fill,
                        minHeight: 8,
                        backgroundColor: scheme.surfaceContainerHighest,
                        color: session.isFull
                            ? scheme.onSurface
                            : scheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: Brand.spaceMd),
                  Text(
                    session.capacityText,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Brand.spaceXs),
          Text(
            spots,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: session.isFull ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          const SizedBox(height: Brand.spaceMd),
          Align(
            alignment: Alignment.centerRight,
            child: _Action(state: state, onBook: onBook, onCancel: onCancel),
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    required this.state,
    required this.onBook,
    required this.onCancel,
  });

  final SessionCardState state;
  final VoidCallback onBook;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    const Size minSize = Size(120, 44);
    return switch (state) {
      SessionCardState.book => FilledButton(
        style: FilledButton.styleFrom(minimumSize: minSize),
        onPressed: onBook,
        child: Text(l10n.classesBook),
      ),
      SessionCardState.joinWaitlist => OutlinedButton(
        style: OutlinedButton.styleFrom(minimumSize: minSize),
        onPressed: onBook,
        child: Text(l10n.classesJoinWaitlist),
      ),
      SessionCardState.booked || SessionCardState.waitlisted => Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          StatusPill(
            label: state == SessionCardState.booked
                ? l10n.classesBooked
                : l10n.classesOnWaitlist,
            icon: state == SessionCardState.booked
                ? Icons.check_circle
                : Icons.hourglass_top,
            emphasis: state == SessionCardState.booked
                ? PillEmphasis.strong
                : PillEmphasis.standard,
          ),
          const SizedBox(width: Brand.spaceSm),
          TextButton(
            style: TextButton.styleFrom(minimumSize: const Size(72, 44)),
            onPressed: onCancel,
            child: Text(l10n.classesCancel),
          ),
        ],
      ),
      SessionCardState.closed => FilledButton(
        style: FilledButton.styleFrom(minimumSize: minSize),
        onPressed: null,
        child: Text(l10n.classesClosed),
      ),
      SessionCardState.busy => FilledButton(
        style: FilledButton.styleFrom(minimumSize: minSize),
        onPressed: null,
        child: Semantics(
          label: l10n.classesUpdating,
          child: const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    };
  }
}
