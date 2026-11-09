// Member-side reads of `notification_messages`. RLS bounds the rows to the
// signed-in member's own, so no member filter is applied here (CLAUDE.md:
// never hand-filter as a security measure). Read-only: members have no write
// policy, which is why "read/unread" is client-local.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:logfitness_membership_flutter/data/notifications/notification_message.dart';
import 'package:logfitness_membership_flutter/data/repository_guard.dart';
import 'package:logfitness_membership_flutter/supabase/supabase_providers.dart';

class NotificationsRepository {
  const NotificationsRepository(this._client);

  final SupabaseClient _client;

  /// Everything the gym has actually sent this member, newest first.
  ///
  /// Only `sent` rows: a queued, skipped or failed row is the outbox's
  /// bookkeeping, not something the member was told.
  Future<List<NotificationMessage>> listNotificationsForMember({
    int limit = 50,
  }) {
    return guardFailures(() async {
      final List<dynamic> rows = await _client
          .from('notification_messages')
          .select('id, channel, event, subject, body, created_at')
          .eq('status', 'sent')
          .order('created_at', ascending: false)
          .order('id', ascending: false)
          .limit(limit);
      return rows
          .map((r) => NotificationMessage.fromJson(r as Map<String, dynamic>))
          .toList(growable: false);
    });
  }
}

final notificationsRepositoryProvider = Provider<NotificationsRepository>((
  ref,
) {
  return NotificationsRepository(ref.watch(supabaseClientProvider));
});
