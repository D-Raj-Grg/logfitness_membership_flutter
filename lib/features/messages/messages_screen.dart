import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_membership_flutter/app/brand.dart';
import 'package:logfitness_membership_flutter/data/member/member_repository.dart';
import 'package:logfitness_membership_flutter/data/notifications/notification_message.dart';
import 'package:logfitness_membership_flutter/domain/format/dates.dart';
import 'package:logfitness_membership_flutter/features/common/async_value_view.dart';
import 'package:logfitness_membership_flutter/features/common/log_card.dart';
import 'package:logfitness_membership_flutter/features/common/skeleton_box.dart';
import 'package:logfitness_membership_flutter/features/messages/messages_controller.dart';
import 'package:logfitness_membership_flutter/l10n/app_localizations.dart';

/// Read-only history of what the gym sent this member, newest first.
class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<List<NotificationMessage>> async = ref.watch(
      messagesProvider,
    );
    final Set<String> read = ref.watch(readMessagesProvider);
    final String tz =
        ref.watch(memberSelfProvider).value?.timezone ?? kDefaultTimezone;
    final List<NotificationMessage> rows =
        async.value ?? const <NotificationMessage>[];
    final bool anyUnread = rows.any((m) => !read.contains(m.id));

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.messagesTitle),
        actions: <Widget>[
          if (anyUnread)
            IconButton(
              tooltip: l10n.messagesMarkAllRead,
              icon: const Icon(Icons.done_all),
              onPressed: () => ref
                  .read(readMessagesProvider.notifier)
                  .markAllRead(rows.map((m) => m.id)),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(messagesProvider);
          await ref.read(messagesProvider.future).catchError(
            (Object _) => const <NotificationMessage>[],
          );
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            Brand.gutter,
            Brand.spaceSm,
            Brand.gutter,
            Brand.spaceXl,
          ),
          children: <Widget>[
            if (async.isLoading && async.value == null)
              const _Skeleton()
            else
              AsyncValueView<List<NotificationMessage>>(
                value: async,
                onRetry: () => ref.invalidate(messagesProvider),
                isEmpty: (List<NotificationMessage> l) => l.isEmpty,
                emptyMessage:
                    '${l10n.messagesEmpty}\n${l10n.messagesEmptyHint}',
                data: (List<NotificationMessage> list) => Column(
                  children: <Widget>[
                    for (final NotificationMessage m in list)
                      Padding(
                        padding: const EdgeInsets.only(bottom: Brand.spaceMd),
                        child: _MessageCard(
                          message: m,
                          unread: !read.contains(m.id),
                          timeZone: tz,
                          onOpen: () => ref
                              .read(readMessagesProvider.notifier)
                              .markRead(m.id),
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MessageCard extends StatefulWidget {
  const _MessageCard({
    required this.message,
    required this.unread,
    required this.timeZone,
    required this.onOpen,
  });

  final NotificationMessage message;
  final bool unread;
  final String timeZone;
  final VoidCallback onOpen;

  @override
  State<_MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<_MessageCard> {
  bool _expanded = false;

  String _title(AppLocalizations l10n) {
    final String? subject = widget.message.subject;
    if (subject != null && subject.trim().isNotEmpty) {
      return subject;
    }
    return switch (widget.message.event) {
      MessageEvent.renewalReminder => l10n.messagesEventRenewalReminder,
      MessageEvent.duesReminder => l10n.messagesEventDuesReminder,
      MessageEvent.birthdayGreeting => l10n.messagesEventBirthdayGreeting,
      MessageEvent.customMessage => l10n.messagesEventCustomMessage,
      MessageEvent.announcement => l10n.messagesEventAnnouncement,
      MessageEvent.memberWelcome => l10n.messagesEventMemberWelcome,
      MessageEvent.paymentReceived => l10n.messagesEventPaymentReceived,
      MessageEvent.duesCleared => l10n.messagesEventDuesCleared,
      MessageEvent.membershipRenewed => l10n.messagesEventMembershipRenewed,
      MessageEvent.other => l10n.messagesEventOther,
    };
  }

  String _when(AppLocalizations l10n) {
    final MessageAge age = messageAge(
      DateTime.now().toUtc().difference(widget.message.createdAt),
    );
    return switch (age.kind) {
      MessageAgeKind.justNow => l10n.messagesJustNow,
      MessageAgeKind.minutes => l10n.messagesMinutesAgo(age.value),
      MessageAgeKind.hours => l10n.messagesHoursAgo(age.value),
      MessageAgeKind.absolute => formatDateTime(
        widget.message.createdAt,
        timeZone: widget.timeZone,
      ),
    };
  }

  (IconData, String?) _channel(AppLocalizations l10n) =>
      switch (widget.message.channel) {
        MessageChannel.sms => (Icons.sms_outlined, l10n.messagesChannelSms),
        MessageChannel.viber => (
          Icons.chat_bubble_outline,
          l10n.messagesChannelViber,
        ),
        MessageChannel.email => (
          Icons.mail_outline,
          l10n.messagesChannelEmail,
        ),
        null => (Icons.notifications_none, null),
      };

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final (IconData icon, String? channelLabel) = _channel(l10n);
    final String title = _title(l10n);
    final String when = _when(l10n);
    final bool unread = widget.unread;

    return Semantics(
      container: true,
      label: unread ? '${l10n.messagesUnread}. $title' : title,
      child: LogCard(
        tone: unread ? LogCardTone.surface : LogCardTone.tonal,
        onTap: () {
          widget.onOpen();
          setState(() => _expanded = !_expanded);
        },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Icon(icon, color: scheme.onSurfaceVariant),
            const SizedBox(width: Brand.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      if (unread)
                        Padding(
                          padding: const EdgeInsets.only(right: Brand.spaceSm),
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: scheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: unread
                                ? FontWeight.w800
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Brand.spaceXs),
                  Text(
                    widget.message.body,
                    maxLines: _expanded ? null : 3,
                    overflow: _expanded ? null : TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: unread ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: Brand.spaceSm),
                  Text(
                    channelLabel == null ? when : '$channelLabel · $when',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Skeleton extends StatelessWidget {
  const _Skeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        for (int i = 0; i < 4; i++) ...<Widget>[
          const SkeletonBox(height: 96, radius: Brand.radiusCard),
          const SizedBox(height: Brand.spaceMd),
        ],
      ],
    );
  }
}
