// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'membership.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Membership _$MembershipFromJson(Map<String, dynamic> json) => _Membership(
  id: json['id'] as String,
  planId: json['plan_id'] as String,
  planName: json['plan_name'] as String,
  planType: json['plan_type'] as String,
  startDate: const PlainDateConverter().fromJson(json['start_date'] as String),
  endDate: const NullablePlainDateConverter().fromJson(
    json['end_date'] as String?,
  ),
  sessionsTotal: (json['sessions_total'] as num?)?.toInt(),
  sessionsRemaining: (json['sessions_remaining'] as num?)?.toInt(),
  pricePaisa: (json['price_paisa'] as num).toInt(),
  discountPaisa: (json['discount_paisa'] as num).toInt(),
  status: $enumDecode(_$MembershipStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$MembershipToJson(_Membership instance) =>
    <String, dynamic>{
      'id': instance.id,
      'plan_id': instance.planId,
      'plan_name': instance.planName,
      'plan_type': instance.planType,
      'start_date': const PlainDateConverter().toJson(instance.startDate),
      'end_date': ?const NullablePlainDateConverter().toJson(instance.endDate),
      'sessions_total': ?instance.sessionsTotal,
      'sessions_remaining': ?instance.sessionsRemaining,
      'price_paisa': instance.pricePaisa,
      'discount_paisa': instance.discountPaisa,
      'status': _$MembershipStatusEnumMap[instance.status]!,
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$MembershipStatusEnumMap = {
  MembershipStatus.upcoming: 'upcoming',
  MembershipStatus.active: 'active',
  MembershipStatus.frozen: 'frozen',
  MembershipStatus.expired: 'expired',
  MembershipStatus.cancelled: 'cancelled',
};
