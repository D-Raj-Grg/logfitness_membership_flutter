// Mirrors `public.invoices` (member-visible columns only). The desk's free-text
// `notes` are deliberately not modelled: members see totals, not staff remarks.
// Unknown JSON keys are ignored, so an additive backend change never breaks a
// shipped build.
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logfitness_membership_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_membership_flutter/domain/format/plain_date.dart';

part 'invoice.freezed.dart';
part 'invoice.g.dart';

@freezed
abstract class Invoice with _$Invoice {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Invoice({
    required String id,
    String? membershipId,
    required String invoiceNo,
    // Money is integer paisa end to end. Never a double, never converted here.
    required int subtotalPaisa,
    required int discountPaisa,
    required int totalPaisa,
    // Maintained by trigger from the payments rows.
    required int paidPaisa,
    // Generated column (`total_paisa - paid_paisa`).
    required int duePaisa,
    required InvoiceStatus status,
    // `date`, not `timestamptz`: a calendar day, never shifted by an offset.
    @PlainDateConverter() required DateTime issuedOn,
    required DateTime createdAt,
  }) = _Invoice;

  factory Invoice.fromJson(Map<String, dynamic> json) =>
      _$InvoiceFromJson(json);
}
