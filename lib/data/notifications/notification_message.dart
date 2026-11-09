// The member's view of a `notification_messages` row: only what a screen can
// show. Hand-written and deliberately forgiving -- a channel or event added
// to the Postgres enums after this build shipped must not blank the whole
// inbox, so both stay as raw strings with a typed accessor that falls back
// to null / `other`.

/// Mirrors `public.notification_channel`; unknown wire values map to null.
enum MessageChannel {
  sms,
  viber,
  email;

  static MessageChannel? tryParse(String? value) {
    for (final MessageChannel c in values) {
      if (c.name == value) {
        return c;
      }
    }
    return null;
  }
}

/// The reasons a member can be told something. Unknown values map to
/// [other] (shown as a generic "Message from the gym").
enum MessageEvent {
  renewalReminder('renewal_reminder'),
  duesReminder('dues_reminder'),
  birthdayGreeting('birthday_greeting'),
  customMessage('custom_message'),
  announcement('announcement'),
  memberWelcome('member_welcome'),
  paymentReceived('payment_received'),
  duesCleared('dues_cleared'),
  membershipRenewed('membership_renewed'),
  other('');

  const MessageEvent(this.wire);
  final String wire;

  static MessageEvent parse(String? value) {
    for (final MessageEvent e in values) {
      if (e.wire.isNotEmpty && e.wire == value) {
        return e;
      }
    }
    return other;
  }
}

class NotificationMessage {
  const NotificationMessage({
    required this.id,
    required this.channel,
    required this.event,
    required this.body,
    required this.createdAt,
    this.subject,
  });

  final String id;
  final MessageChannel? channel;
  final MessageEvent event;
  final String? subject;
  final String body;
  final DateTime createdAt;

  factory NotificationMessage.fromJson(Map<String, dynamic> json) =>
      NotificationMessage(
        id: json['id'] as String,
        channel: MessageChannel.tryParse(json['channel'] as String?),
        event: MessageEvent.parse(json['event'] as String?),
        subject: json['subject'] as String?,
        body: (json['body'] as String?) ?? '',
        createdAt: DateTime.parse(json['created_at'] as String).toUtc(),
      );
}

/// Newest first; ties broken by id descending so the order is stable and
/// matches the query's `order(created_at desc, id desc)`.
List<NotificationMessage> sortNewestFirst(Iterable<NotificationMessage> rows) {
  final List<NotificationMessage> out = rows.toList();
  out.sort((a, b) {
    final int byTime = b.createdAt.compareTo(a.createdAt);
    return byTime != 0 ? byTime : b.id.compareTo(a.id);
  });
  return out;
}
