import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_membership_flutter/data/payments/invoice.dart';
import 'package:logfitness_membership_flutter/data/payments/payment.dart';
import 'package:logfitness_membership_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_membership_flutter/features/payments/payments_logic.dart';

Invoice inv(
  String id, {
  required DateTime issuedOn,
  int total = 1000,
  int paid = 0,
  InvoiceStatus status = InvoiceStatus.unpaid,
}) => Invoice(
  id: id,
  invoiceNo: 'INV-$id',
  subtotalPaisa: total,
  discountPaisa: 0,
  totalPaisa: total,
  paidPaisa: paid,
  duePaisa: total - paid,
  status: status,
  issuedOn: issuedOn,
  createdAt: issuedOn,
);

Payment pay(
  String id, {
  required DateTime paidAt,
  int amount = 1000,
  PaymentKind kind = PaymentKind.payment,
  String? invoiceId,
}) => Payment(
  id: id,
  invoiceId: invoiceId,
  kind: kind,
  amountPaisa: amount,
  method: PaymentMethod.cash,
  paidAt: paidAt,
  createdAt: paidAt,
);

void main() {
  group('groupByMonth', () {
    test('groups newest-first input into month buckets, keeping order', () {
      final List<MonthGroup<int>> g = groupByMonth<int>(
        <int>[1, 2, 3, 4, 5],
        (int n) => switch (n) {
          1 || 2 => DateTime.utc(2026, 11, 20),
          3 => DateTime.utc(2026, 11, 2),
          4 => DateTime.utc(2026, 10, 30),
          _ => DateTime.utc(2025, 11, 1),
        },
      );
      expect(g.map((MonthGroup<int> m) => (m.year, m.month)), <(int, int)>[
        (2026, 11),
        (2026, 10),
        (2025, 11),
      ]);
      expect(g[0].items, <int>[1, 2, 3]);
      expect(g[1].items, <int>[4]);
    });

    test('empty input gives no groups', () {
      expect(
        groupByMonth<int>(<int>[], (int _) => DateTime.utc(2026)),
        isEmpty,
      );
    });

    test('same month in different years stays separate', () {
      final List<MonthGroup<int>> g = groupByMonth<int>(<int>[
        1,
        2,
      ], (int n) => DateTime.utc(n == 1 ? 2026 : 2025, 3, 1));
      expect(g, hasLength(2));
    });

    test('unsorted input still joins an earlier month group', () {
      final List<MonthGroup<int>> g = groupByMonth<int>(<int>[
        1,
        2,
        3,
      ], (int n) => DateTime.utc(2026, n == 2 ? 10 : 11, 1));
      expect(g, hasLength(2));
      expect(g[0].items, <int>[1, 3]);
    });
  });

  group('payments are grouped in the org timezone', () {
    test('23:30 UTC on 31 Oct is already 1 Nov in Kathmandu', () {
      final DateTime t = DateTime.utc(2026, 10, 31, 23, 30);
      final List<MonthGroup<Payment>> kathmandu = groupPayments(<Payment>[
        pay('a', paidAt: t),
      ], 'Asia/Kathmandu');
      expect((kathmandu.single.year, kathmandu.single.month), (2026, 11));
      final List<MonthGroup<Payment>> utc = groupPayments(<Payment>[
        pay('a', paidAt: t),
      ], 'UTC');
      expect((utc.single.year, utc.single.month), (2026, 10));
    });

    test('invoices group by their plain issue date, with no shift', () {
      final List<MonthGroup<Invoice>> g = groupInvoices(<Invoice>[
        inv('1', issuedOn: DateTime.utc(2026, 11, 1)),
        inv('2', issuedOn: DateTime.utc(2026, 10, 31)),
      ]);
      expect(g.map((MonthGroup<Invoice> m) => m.month), <int>[11, 10]);
    });
  });

  group('summarize', () {
    test('net paid subtracts refunds and reversals', () {
      final PaymentsSummary s = summarize(<Invoice>[], <Payment>[
        pay('1', paidAt: DateTime.utc(2026, 11, 1), amount: 300000),
        pay(
          '2',
          paidAt: DateTime.utc(2026, 11, 2),
          amount: -50000,
          kind: PaymentKind.refund,
        ),
        pay(
          '3',
          paidAt: DateTime.utc(2026, 11, 3),
          amount: -10000,
          kind: PaymentKind.reversal,
        ),
      ]);
      expect(s.netPaidPaisa, 240000);
      expect(s.hasDue, isFalse);
    });

    test('due ignores void invoices and fully paid ones', () {
      final PaymentsSummary s = summarize(<Invoice>[
        inv('1', issuedOn: DateTime.utc(2026, 11, 1), total: 5000, paid: 1000),
        inv(
          '2',
          issuedOn: DateTime.utc(2026, 11, 1),
          total: 7000,
          status: InvoiceStatus.voided,
        ),
        inv(
          '3',
          issuedOn: DateTime.utc(2026, 11, 1),
          total: 2000,
          paid: 2000,
          status: InvoiceStatus.paid,
        ),
      ], <Payment>[]);
      expect(s.duePaisa, 4000);
      expect(s.hasDue, isTrue);
    });
  });

  test('paymentsForInvoice filters by invoice id', () {
    final List<Payment> list = <Payment>[
      pay('a', paidAt: DateTime.utc(2026), invoiceId: 'x'),
      pay('b', paidAt: DateTime.utc(2026), invoiceId: 'y'),
      pay('c', paidAt: DateTime.utc(2026)),
    ];
    expect(paymentsForInvoice(list, 'x').map((Payment p) => p.id), <String>[
      'a',
    ]);
  });
}
