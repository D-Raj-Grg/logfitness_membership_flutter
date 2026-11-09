// A member's own invoices and payments. Read-only: financial history is
// append-only and members have no write policy. RLS scopes every query to the
// signed-in member, so there is deliberately no `member_id` filter here.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:logfitness_membership_flutter/data/payments/invoice.dart';
import 'package:logfitness_membership_flutter/data/payments/payment.dart';
import 'package:logfitness_membership_flutter/data/repository_guard.dart';
import 'package:logfitness_membership_flutter/supabase/supabase_providers.dart';

/// Row -> model mapping, split out so tests can prove it with fake rows
/// without a Supabase client.
List<Invoice> invoicesFromRows(List<Map<String, dynamic>> rows) =>
    rows.map(Invoice.fromJson).toList();

List<Payment> paymentsFromRows(List<Map<String, dynamic>> rows) =>
    rows.map(Payment.fromJson).toList();

class PaymentsRepository {
  const PaymentsRepository(this._client);

  final SupabaseClient _client;

  /// The member's invoices, newest first.
  Future<List<Invoice>> listInvoices() => guardFailures(() async {
    final PostgrestList rows = await _client
        .from('invoices')
        .select(
          'id, membership_id, invoice_no, subtotal_paisa, discount_paisa, '
          'total_paisa, paid_paisa, due_paisa, status, issued_on, created_at',
        )
        .order('issued_on', ascending: false)
        .order('created_at', ascending: false);
    return invoicesFromRows(rows);
  });

  /// The member's payments, refunds and reversals, newest first.
  Future<List<Payment>> listPayments() => guardFailures(() async {
    final PostgrestList rows = await _client
        .from('payments')
        .select(
          'id, membership_id, invoice_id, kind, amount_paisa, method, '
          'reference_no, reason, paid_at, created_at',
        )
        .order('paid_at', ascending: false)
        .order('created_at', ascending: false);
    return paymentsFromRows(rows);
  });
}

final paymentsRepositoryProvider = Provider<PaymentsRepository>((ref) {
  return PaymentsRepository(ref.watch(supabaseClientProvider));
});
