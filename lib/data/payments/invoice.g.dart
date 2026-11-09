// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Invoice _$InvoiceFromJson(Map<String, dynamic> json) => _Invoice(
  id: json['id'] as String,
  membershipId: json['membership_id'] as String?,
  invoiceNo: json['invoice_no'] as String,
  subtotalPaisa: (json['subtotal_paisa'] as num).toInt(),
  discountPaisa: (json['discount_paisa'] as num).toInt(),
  totalPaisa: (json['total_paisa'] as num).toInt(),
  paidPaisa: (json['paid_paisa'] as num).toInt(),
  duePaisa: (json['due_paisa'] as num).toInt(),
  status: $enumDecode(_$InvoiceStatusEnumMap, json['status']),
  issuedOn: const PlainDateConverter().fromJson(json['issued_on'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$InvoiceToJson(_Invoice instance) => <String, dynamic>{
  'id': instance.id,
  'membership_id': ?instance.membershipId,
  'invoice_no': instance.invoiceNo,
  'subtotal_paisa': instance.subtotalPaisa,
  'discount_paisa': instance.discountPaisa,
  'total_paisa': instance.totalPaisa,
  'paid_paisa': instance.paidPaisa,
  'due_paisa': instance.duePaisa,
  'status': _$InvoiceStatusEnumMap[instance.status]!,
  'issued_on': const PlainDateConverter().toJson(instance.issuedOn),
  'created_at': instance.createdAt.toIso8601String(),
};

const _$InvoiceStatusEnumMap = {
  InvoiceStatus.unpaid: 'unpaid',
  InvoiceStatus.partial: 'partial',
  InvoiceStatus.paid: 'paid',
  InvoiceStatus.voided: 'void',
};
