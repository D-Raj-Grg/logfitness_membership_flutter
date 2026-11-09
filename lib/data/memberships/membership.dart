// Mirrors `public.memberships` (member-visible columns only): plan history.
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logfitness_membership_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_membership_flutter/domain/format/plain_date.dart';

part 'membership.freezed.dart';
part 'membership.g.dart';

@freezed
abstract class Membership with _$Membership {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Membership({
    required String id,
    required String planId,
    // Snapshot of the plan name as sold.
    required String planName,
    // Raw `plan_type` wire value. Kept as a string: this app only displays the
    // plan name, and a new plan type must not stop the history loading.
    required String planType,
    // `date` columns: calendar days, never shifted by an offset.
    @PlainDateConverter() required DateTime startDate,
    @NullablePlainDateConverter() DateTime? endDate,
    int? sessionsTotal,
    int? sessionsRemaining,
    // Integer paisa.
    required int pricePaisa,
    required int discountPaisa,
    required MembershipStatus status,
    required DateTime createdAt,
  }) = _Membership;

  factory Membership.fromJson(Map<String, dynamic> json) =>
      _$MembershipFromJson(json);
}
