// Pure logic for the Payments tab: month grouping and the summary totals.
// No Flutter, no Supabase -- so every rule here is unit-tested directly.
import 'package:intl/intl.dart';

import 'package:logfitness_membership_flutter/data/payments/invoice.dart';
import 'package:logfitness_membership_flutter/data/payments/payment.dart';
import 'package:logfitness_membership_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_membership_flutter/domain/format/dates.dart';

/// Everything the tab shows, loaded together so the summary card and both
/// lists always agree.
class PaymentsOverview {
  const PaymentsOverview({
    required this.invoices,
    required this.payments,
    required this.currency,
    required this.timezone,
  });

  final List<Invoice> invoices;
  final List<Payment> payments;
  final String currency;
  final String timezone;
}

/// One calendar month of rows, in the order the input came (newest first).
class MonthGroup<T> {
  const MonthGroup({
    required this.year,
    required this.month,
    required this.items,
  });

  final int year;
  final int month;
  final List<T> items;
}

/// The org-wall-clock calendar day of an instant, as UTC midnight. Goes
/// through [formatDate] so the timezone table stays in one place
/// (`dates.dart`).
DateTime orgCalendarDay(DateTime instant, String timezone) {
  final DateTime parsed = DateFormat(
    'dd MMM yyyy',
    'en_US',
  ).parseUtc(formatDate(instant, timeZone: timezone));
  return DateTime.utc(parsed.year, parsed.month, parsed.day);
}

/// Groups [items] by calendar month of [dayOf], keeping input order. Input is
/// expected newest first, so groups come out newest first too; a month with
/// no rows does not appear.
List<MonthGroup<T>> groupByMonth<T>(
  Iterable<T> items,
  DateTime Function(T item) dayOf,
) {
  final List<MonthGroup<T>> groups = <MonthGroup<T>>[];
  for (final T item in items) {
    final DateTime day = dayOf(item);
    if (groups.isEmpty ||
        groups.last.year != day.year ||
        groups.last.month != day.month) {
      // Same month appearing again later (unsorted input) joins its group.
      final int existing = groups.indexWhere(
        (MonthGroup<T> g) => g.year == day.year && g.month == day.month,
      );
      if (existing >= 0) {
        groups[existing].items.add(item);
        continue;
      }
      groups.add(
        MonthGroup<T>(year: day.year, month: day.month, items: <T>[item]),
      );
    } else {
      groups.last.items.add(item);
    }
  }
  return groups;
}

/// Invoices grouped by the (date-only) day they were issued -- no timezone
/// shift, a `date` column is already a calendar day.
List<MonthGroup<Invoice>> groupInvoices(List<Invoice> invoices) =>
    groupByMonth<Invoice>(invoices, (Invoice i) => i.issuedOn);

/// Payments grouped by the month they were paid in the org's timezone.
List<MonthGroup<Payment>> groupPayments(
  List<Payment> payments,
  String timezone,
) => groupByMonth<Payment>(
  payments,
  (Payment p) => orgCalendarDay(p.paidAt, timezone),
);

/// The two numbers in the summary card.
class PaymentsSummary {
  const PaymentsSummary({required this.netPaidPaisa, required this.duePaisa});

  /// Net cash received: payments minus refunds and reversals.
  final int netPaidPaisa;

  /// What is still owed across invoices that have not been voided.
  final int duePaisa;

  bool get hasDue => duePaisa > 0;
}

PaymentsSummary summarize(List<Invoice> invoices, List<Payment> payments) {
  int net = 0;
  for (final Payment p in payments) {
    // Refunds and reversals are stored negative, so a plain sum is net cash.
    net += p.amountPaisa;
  }
  int due = 0;
  for (final Invoice i in invoices) {
    if (i.status != InvoiceStatus.voided && i.duePaisa > 0) {
      due += i.duePaisa;
    }
  }
  return PaymentsSummary(netPaidPaisa: net, duePaisa: due);
}

/// Payments recorded against one invoice, in input order.
List<Payment> paymentsForInvoice(List<Payment> payments, String invoiceId) =>
    payments.where((Payment p) => p.invoiceId == invoiceId).toList();

/// ARB `select` key for a month number: `m1`..`m12`.
String monthKey(int month) => 'm$month';
