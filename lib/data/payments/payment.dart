// Mirrors `public.payments` (member-visible columns only). `collected_by`
// (which staff member took the money) and the desk's `notes` are deliberately
// not modelled -- members see what they paid, not who was at the counter.
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:logfitness_membership_flutter/domain/enums/postgres_enums.dart';

part 'payment.freezed.dart';
part 'payment.g.dart';

@freezed
abstract class Payment with _$Payment {
  @JsonSerializable(fieldRename: FieldRename.snake)
  const factory Payment({
    required String id,
    String? membershipId,
    String? invoiceId,
    required PaymentKind kind,
    // Integer paisa. Negative for refunds and reversals, so summing this
    // column gives net cash.
    required int amountPaisa,
    required PaymentMethod method,
    String? referenceNo,
    // Required by the database on a refund / reversal.
    String? reason,
    required DateTime paidAt,
    required DateTime createdAt,
  }) = _Payment;

  factory Payment.fromJson(Map<String, dynamic> json) =>
      _$PaymentFromJson(json);
}
