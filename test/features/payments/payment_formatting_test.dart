import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_membership_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_membership_flutter/features/common/status_pill.dart';
import 'package:logfitness_membership_flutter/features/payments/payment_formatting.dart';
import 'package:logfitness_membership_flutter/l10n/app_localizations_en.dart';
import 'package:logfitness_membership_flutter/l10n/app_localizations_ne.dart';

void main() {
  final AppLocalizationsEn en = AppLocalizationsEn();
  final AppLocalizationsNe ne = AppLocalizationsNe();

  group('signedMoney', () {
    test('formats paisa once, as rupees with Indian grouping', () {
      expect(signedMoney(0, 'NPR'), 'NPR 0');
      expect(signedMoney(150000, 'NPR'), 'NPR 1,500');
      expect(signedMoney(12345678, 'NPR'), 'NPR 1,23,456.78');
      expect(signedMoney(50, 'NPR'), 'NPR 0.5');
    });

    test('refunds and reversals show a leading minus before the currency', () {
      expect(signedMoney(-25000, 'NPR'), '−NPR 250');
      expect(signedMoney(-1, 'NPR'), '−NPR 0.01');
    });

    test('uses the member currency, not a hardcoded one', () {
      expect(signedMoney(100, 'INR'), 'INR 1');
    });
  });

  group('invoice status pill', () {
    test('every status has a label in English and Nepali', () {
      final Map<InvoiceStatus, String> english = <InvoiceStatus, String>{
        InvoiceStatus.unpaid: 'Unpaid',
        InvoiceStatus.partial: 'Partly paid',
        InvoiceStatus.paid: 'Paid',
        InvoiceStatus.voided: 'Void',
      };
      for (final InvoiceStatus s in InvoiceStatus.values) {
        expect(invoiceStatusLabel(en, s), english[s]);
        expect(invoiceStatusLabel(ne, s), isNotEmpty);
        expect(invoiceStatusLabel(ne, s), isNot(english[s]));
      }
    });

    test(
      'status is never hue alone: distinct emphasis and icon per status',
      () {
        final Set<PillEmphasis> emphases = InvoiceStatus.values
            .map(invoiceStatusEmphasis)
            .toSet();
        expect(emphases, hasLength(InvoiceStatus.values.length));
        expect(
          InvoiceStatus.values.map(invoiceStatusIcon).toSet(),
          hasLength(InvoiceStatus.values.length),
        );
        expect(invoiceStatusEmphasis(InvoiceStatus.unpaid), PillEmphasis.alert);
      },
    );
  });

  group('method and kind labels', () {
    test('english', () {
      expect(paymentMethodLabel(en, PaymentMethod.esewa), 'eSewa');
      expect(paymentMethodLabel(en, PaymentMethod.bank), 'Bank transfer');
      expect(paymentKindLabel(en, PaymentKind.refund), 'Refund');
      expect(paymentKindLabel(en, PaymentKind.reversal), 'Reversed');
    });

    test('nepali labels exist for every value', () {
      for (final PaymentMethod m in PaymentMethod.values) {
        expect(paymentMethodLabel(ne, m), isNotEmpty);
        expect(paymentMethodIcon(m), isNotNull);
      }
      for (final PaymentKind k in PaymentKind.values) {
        expect(paymentKindLabel(ne, k), isNotEmpty);
      }
    });
  });

  test('month heading comes from the active language', () {
    expect(monthHeading(en, 2026, 11), 'November 2026');
    expect(monthHeading(ne, 2026, 11), 'नोभेम्बर 2026');
    for (int m = 1; m <= 12; m++) {
      expect(monthHeading(en, 2026, m).trim(), isNot('2026'));
    }
  });
}
