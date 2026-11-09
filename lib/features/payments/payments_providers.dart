import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_membership_flutter/data/member/current_member.dart';
import 'package:logfitness_membership_flutter/data/member/member_repository.dart';
import 'package:logfitness_membership_flutter/data/payments/invoice.dart';
import 'package:logfitness_membership_flutter/data/payments/payment.dart';
import 'package:logfitness_membership_flutter/data/payments/payments_repository.dart';
import 'package:logfitness_membership_flutter/features/payments/payments_logic.dart';

/// Invoices + payments + the member's currency/timezone, fetched in parallel.
/// Invalidate to refresh (pull-to-refresh and the retry button do).
///
/// No automatic retry: a failed read should show [FailureView] with a "Try
/// again" button straight away, not sit on a skeleton while Riverpod retries.
final paymentsOverviewProvider = FutureProvider<PaymentsOverview>(
  retry: (int count, Object error) => null,
  (ref) async {
    final CurrentMember me = await ref.watch(memberSelfProvider.future);
    final PaymentsRepository repo = ref.watch(paymentsRepositoryProvider);
    final (List<Invoice> invoices, List<Payment> payments) = await (
      repo.listInvoices(),
      repo.listPayments(),
    ).wait;
    return PaymentsOverview(
      invoices: invoices,
      payments: payments,
      currency: me.currency,
      timezone: me.timezone,
    );
  },
);
