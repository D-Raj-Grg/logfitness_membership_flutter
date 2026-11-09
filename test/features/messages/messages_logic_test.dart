// Message ordering, parsing tolerance, local read state, relative age.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_membership_flutter/data/notifications/notification_message.dart';
import 'package:logfitness_membership_flutter/features/messages/messages_controller.dart';

NotificationMessage _m(String id, DateTime at) => NotificationMessage(
  id: id,
  channel: MessageChannel.sms,
  event: MessageEvent.customMessage,
  body: 'x',
  createdAt: at,
);

void main() {
  test('sortNewestFirst orders by time desc, ties by id desc', () {
    final DateTime t = DateTime.utc(2026, 11, 9, 10);
    final List<NotificationMessage> out = sortNewestFirst(<NotificationMessage>[
      _m('a', t.subtract(const Duration(days: 1))),
      _m('b', t),
      _m('c', t),
      _m('d', t.add(const Duration(minutes: 1))),
    ]);
    expect(out.map((m) => m.id), <String>['d', 'c', 'b', 'a']);
  });

  test('fromJson tolerates unknown channel and event values', () {
    final NotificationMessage m = NotificationMessage.fromJson(<String, dynamic>{
      'id': '1',
      'channel': 'telepathy',
      'event': 'brand_new_event',
      'subject': null,
      'body': 'Hello',
      'created_at': '2026-11-09T10:00:00+00:00',
    });
    expect(m.channel, isNull);
    expect(m.event, MessageEvent.other);
    expect(m.createdAt.isUtc, isTrue);
  });

  test('known event wire values parse', () {
    expect(MessageEvent.parse('dues_reminder'), MessageEvent.duesReminder);
    expect(MessageEvent.parse(''), MessageEvent.other);
    expect(MessageEvent.parse(null), MessageEvent.other);
  });

  test('read state is local, idempotent, and supports mark-all', () {
    final ProviderContainer c = ProviderContainer();
    addTearDown(c.dispose);
    final ReadMessagesNotifier n = c.read(readMessagesProvider.notifier);
    expect(c.read(readMessagesProvider), isEmpty);
    n.markRead('a');
    n.markRead('a');
    expect(c.read(readMessagesProvider), <String>{'a'});
    n.markAllRead(<String>['b', 'c']);
    expect(c.read(readMessagesProvider), <String>{'a', 'b', 'c'});
  });

  test('messageAge buckets', () {
    expect(
      messageAge(const Duration(seconds: 20)),
      const MessageAge(MessageAgeKind.justNow),
    );
    expect(
      messageAge(const Duration(seconds: -30)),
      const MessageAge(MessageAgeKind.justNow),
    );
    expect(
      messageAge(const Duration(minutes: 5)),
      const MessageAge(MessageAgeKind.minutes, 5),
    );
    expect(
      messageAge(const Duration(hours: 3, minutes: 10)),
      const MessageAge(MessageAgeKind.hours, 3),
    );
    expect(
      messageAge(const Duration(hours: 24)),
      const MessageAge(MessageAgeKind.absolute),
    );
  });
}
