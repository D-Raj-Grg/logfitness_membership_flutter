import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_membership_flutter/data/payments/invoice.dart';
import 'package:logfitness_membership_flutter/data/payments/payment.dart';
import 'package:logfitness_membership_flutter/data/payments/payments_repository.dart';
import 'package:logfitness_membership_flutter/domain/enums/postgres_enums.dart';

Map<String, dynamic> _invoiceRow({
  String id = 'inv-1',
  String status = 'partial',
  int total = 300000,
  int paid = 100000,
}) => <String, dynamic>{
  'id': id,
  'org_id': 'org',
  'membership_id': 'ms-1',
  'invoice_no': 'INV-0007',
  'subtotal_paisa': 350000,
  'discount_paisa': 50000,
  'total_paisa': total,
  'paid_paisa': paid,
  'due_paisa': total - paid,
  'status': status,
  'issued_on': '2026-11-05',
  'created_at': '2026-11-05T04:15:00+00:00',
  'notes': 'staff-only remark', // not modelled; must be ignored
  'some_future_column': 1,
};

Map<String, dynamic> _paymentRow({
  String id = 'pay-1',
  String kind = 'payment',
  int amount = 100000,
  String method = 'esewa',
  String? reason,
}) => <String, dynamic>{
  'id': id,
  'invoice_id': 'inv-1',
  'membership_id': null,
  'kind': kind,
  'amount_paisa': amount,
  'method': method,
  'reference_no': 'TX123',
  'reason': reason,
  'collected_by': 'staff-9', // not modelled; must be ignored
  'paid_at': '2026-11-05T09:00:00+00:00',
  'created_at': '2026-11-05T09:00:01+00:00',
};

void main() {
  group('invoicesFromRows', () {
    test('maps money as integer paisa and issued_on as a plain date', () {
      final List<Invoice> invoices = invoicesFromRows(<Map<String, dynamic>>[
        _invoiceRow(),
      ]);
      final Invoice i = invoices.single;
      expect(i.invoiceNo, 'INV-0007');
      expect(i.totalPaisa, 300000);
      expect(i.duePaisa, 200000);
      expect(i.status, InvoiceStatus.partial);
      expect(i.issuedOn, DateTime.utc(2026, 11, 5));
      expect(i.issuedOn.isUtc, isTrue);
    });

    test('maps the "void" wire value to InvoiceStatus.voided', () {
      final Invoice i = invoicesFromRows(<Map<String, dynamic>>[
        _invoiceRow(status: 'void'),
      ]).single;
      expect(i.status, InvoiceStatus.voided);
    });

    test('preserves input order', () {
      final List<Invoice> invoices = invoicesFromRows(<Map<String, dynamic>>[
        _invoiceRow(id: 'b'),
        _invoiceRow(id: 'a'),
      ]);
      expect(invoices.map((Invoice i) => i.id), <String>['b', 'a']);
    });
  });

  group('paymentsFromRows', () {
    test('maps a refund as negative paisa with its reason', () {
      final Payment p = paymentsFromRows(<Map<String, dynamic>>[
        _paymentRow(kind: 'refund', amount: -25000, reason: 'Double charged'),
      ]).single;
      expect(p.kind, PaymentKind.refund);
      expect(p.amountPaisa, -25000);
      expect(p.reason, 'Double charged');
      expect(p.method, PaymentMethod.esewa);
      expect(p.paidAt, DateTime.utc(2026, 11, 5, 9));
    });

    test('maps reversals', () {
      final Payment p = paymentsFromRows(<Map<String, dynamic>>[
        _paymentRow(kind: 'reversal', amount: -1000),
      ]).single;
      expect(p.kind, PaymentKind.reversal);
    });

    test('an unknown method value is an error, not a silent default', () {
      expect(
        () => paymentsFromRows(<Map<String, dynamic>>[
          _paymentRow(method: 'bitcoin'),
        ]),
        throwsA(anything),
      );
    });
  });
}
