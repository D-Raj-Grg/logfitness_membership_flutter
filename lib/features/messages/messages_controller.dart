import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_membership_flutter/data/notifications/notification_message.dart';
import 'package:logfitness_membership_flutter/data/notifications/notifications_repository.dart';
import 'package:logfitness_membership_flutter/supabase/supabase_providers.dart';

/// The member's messages, newest first. Auto-disposed so opening the screen
/// always re-reads; pull-to-refresh invalidates it.
///
/// Realtime vs polling: neither. Messages are re-read on open and on pull
/// (TASKS.md Phase 6); push (Phase 7) is the live channel.
final messagesProvider = FutureProvider.autoDispose<List<NotificationMessage>>((
  ref,
) async {
  ref.watch(sessionProvider.select((s) => s?.user.id));
  final List<NotificationMessage> rows = await ref
      .watch(notificationsRepositoryProvider)
      .listNotificationsForMember();
  return sortNewestFirst(rows);
});

/// Which messages this install has opened. Client-local and in-memory only:
/// members have no write policy on `notification_messages`, so there is
/// nowhere server-side to put it.
class ReadMessagesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  void markRead(String id) {
    if (!state.contains(id)) {
      state = <String>{...state, id};
    }
  }

  void markAllRead(Iterable<String> ids) {
    state = <String>{...state, ...ids};
  }
}

final readMessagesProvider =
    NotifierProvider<ReadMessagesNotifier, Set<String>>(
      ReadMessagesNotifier.new,
    );

/// How old a message is, in the words a card uses.
enum MessageAgeKind { justNow, minutes, hours, absolute }

class MessageAge {
  const MessageAge(this.kind, [this.value = 0]);
  final MessageAgeKind kind;
  final int value;

  @override
  bool operator ==(Object other) =>
      other is MessageAge && other.kind == kind && other.value == value;

  @override
  int get hashCode => Object.hash(kind, value);
}

/// Relative for the first day, absolute after. A message from the future
/// (clock skew) reads as "just now".
MessageAge messageAge(Duration age) {
  if (age.inMinutes < 1) {
    return const MessageAge(MessageAgeKind.justNow);
  }
  if (age.inMinutes < 60) {
    return MessageAge(MessageAgeKind.minutes, age.inMinutes);
  }
  if (age.inHours < 24) {
    return MessageAge(MessageAgeKind.hours, age.inHours);
  }
  return const MessageAge(MessageAgeKind.absolute);
}
