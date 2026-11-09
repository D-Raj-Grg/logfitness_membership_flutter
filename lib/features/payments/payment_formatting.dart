// Labels and glyphs for the Payments tab, localised. Ported from the staff app
// (`lib/features/payments/payment_formatting.dart`) with the staff-only input
// helpers dropped.
import 'package:flutter/material.dart';

import 'package:logfitness_membership_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_membership_flutter/domain/format/money.dart';
import 'package:logfitness_membership_flutter/features/common/status_pill.dart';
import 'package:logfitness_membership_flutter/features/payments/payments_logic.dart'
    show monthKey;
import 'package:logfitness_membership_flutter/l10n/app_localizations.dart';

String paymentMethodLabel(AppLocalizations l10n, PaymentMethod method) =>
    switch (method) {
      PaymentMethod.cash => l10n.paymentsMethodCash,
      PaymentMethod.esewa => l10n.paymentsMethodEsewa,
      PaymentMethod.khalti => l10n.paymentsMethodKhalti,
      PaymentMethod.fonepay => l10n.paymentsMethodFonepay,
      PaymentMethod.bank => l10n.paymentsMethodBank,
      PaymentMethod.card => l10n.paymentsMethodCard,
    };

/// A glyph per rail. The label always sits beside it; never the only signal.
IconData paymentMethodIcon(PaymentMethod method) => switch (method) {
  PaymentMethod.cash => Icons.payments_outlined,
  PaymentMethod.esewa ||
  PaymentMethod.khalti ||
  PaymentMethod.fonepay => Icons.smartphone_outlined,
  PaymentMethod.bank => Icons.account_balance_outlined,
  PaymentMethod.card => Icons.credit_card_outlined,
};

String paymentKindLabel(AppLocalizations l10n, PaymentKind kind) =>
    switch (kind) {
      PaymentKind.payment => l10n.paymentsKindPayment,
      PaymentKind.refund => l10n.paymentsKindRefund,
      PaymentKind.reversal => l10n.paymentsKindReversal,
    };

String invoiceStatusLabel(AppLocalizations l10n, InvoiceStatus status) =>
    switch (status) {
      InvoiceStatus.unpaid => l10n.paymentsStatusUnpaid,
      InvoiceStatus.partial => l10n.paymentsStatusPartial,
      InvoiceStatus.paid => l10n.paymentsStatusPaid,
      InvoiceStatus.voided => l10n.paymentsStatusVoid,
    };

IconData invoiceStatusIcon(InvoiceStatus status) => switch (status) {
  InvoiceStatus.unpaid => Icons.error_outline,
  InvoiceStatus.partial => Icons.timelapse,
  InvoiceStatus.paid => Icons.check_circle_outline,
  InvoiceStatus.voided => Icons.block,
};

/// Status is carried by fill, outline, weight and icon -- never hue alone.
PillEmphasis invoiceStatusEmphasis(InvoiceStatus status) => switch (status) {
  InvoiceStatus.unpaid => PillEmphasis.alert,
  InvoiceStatus.partial => PillEmphasis.standard,
  InvoiceStatus.paid => PillEmphasis.strong,
  InvoiceStatus.voided => PillEmphasis.subtle,
};

/// Money for a payment row: refunds and reversals are stored negative and
/// show a leading minus (formatMoney yields `NPR -1,500`; the sign is moved
/// in front of the currency so it cannot be missed).
String signedMoney(int paisa, String currency) {
  if (paisa < 0) {
    return '−${formatMoney(-paisa, currency: currency)}';
  }
  return formatMoney(paisa, currency: currency);
}

/// "November 2026" in the active language (month names live in the ARB).
String monthHeading(AppLocalizations l10n, int year, int month) =>
    l10n.paymentsMonthYear(monthKey(month), year.toString());
