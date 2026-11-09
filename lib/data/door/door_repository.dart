// `member_door_check_in(p_payload)`: marks today's attendance AND opens the
// door in one server call. The only write this feature makes, and it goes
// through the RPC.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:logfitness_membership_flutter/data/door/door_check_in_result.dart';
import 'package:logfitness_membership_flutter/data/door/door_qr_payload.dart';
import 'package:logfitness_membership_flutter/data/repository_guard.dart';
import 'package:logfitness_membership_flutter/supabase/supabase_providers.dart';

export 'package:logfitness_membership_flutter/data/door/door_check_in_result.dart';
export 'package:logfitness_membership_flutter/data/door/door_qr_payload.dart';

abstract interface class DoorRepository {
  /// Throws an `AppFailure` (offline, unauthenticated, ...) when the call
  /// itself fails; every answer the server gives is a [DoorCheckInResult].
  Future<DoorCheckInResult> checkIn(DoorQrPayload payload);
}

class SupabaseDoorRepository implements DoorRepository {
  const SupabaseDoorRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<DoorCheckInResult> checkIn(DoorQrPayload payload) =>
      guardFailures(() async {
        final Object? data = await _client.rpc(
          'member_door_check_in',
          params: <String, dynamic>{'p_payload': payload.text},
        );
        return DoorCheckInResult.fromJson(data);
      });
}

final doorRepositoryProvider = Provider<DoorRepository>((ref) {
  return SupabaseDoorRepository(ref.watch(supabaseClientProvider));
});
