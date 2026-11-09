import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_membership_flutter/app/theme.dart';
import 'package:logfitness_membership_flutter/data/payments/invoice.dart';
import 'package:logfitness_membership_flutter/data/payments/payment.dart';
import 'package:logfitness_membership_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_membership_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_membership_flutter/features/common/async_value_view.dart';
import 'package:logfitness_membership_flutter/features/common/failure_view.dart';
import 'package:logfitness_membership_flutter/features/payments/payments_logic.dart';
import 'package:logfitness_membership_flutter/features/payments/payments_providers.dart';
import 'package:logfitness_membership_flutter/features/payments/payments_screen.dart';
import 'package:logfitness_membership_flutter/l10n/app_localizations.dart';

final Invoice _partial = Invoice(
  id: 'inv-1',
  invoiceNo: 'INV-0007',
  subtotalPaisa: 350000,
  discountPaisa: 50000,
  totalPaisa: 300000,
  paidPaisa: 100000,
  duePaisa: 200000,
  status: InvoiceStatus.partial,
  issuedOn: DateTime.utc(2026, 11, 5),
  createdAt: DateTime.utc(2026, 11, 5, 4),
);

final Invoice _paidOld = Invoice(
  id: 'inv-0',
  invoiceNo: 'INV-0003',
  subtotalPaisa: 300000,
  discountPaisa: 0,
  totalPaisa: 300000,
  paidPaisa: 300000,
  duePaisa: 0,
  status: InvoiceStatus.paid,
  issuedOn: DateTime.utc(2026, 10, 3),
  createdAt: DateTime.utc(2026, 10, 3, 4),
);

final Payment _paid = Payment(
  id: 'pay-1',
  invoiceId: 'inv-1',
  kind: PaymentKind.payment,
  amountPaisa: 100000,
  method: PaymentMethod.esewa,
  paidAt: DateTime.utc(2026, 11, 5, 9),
  createdAt: DateTime.utc(2026, 11, 5, 9),
);

final Payment _refund = Payment(
  id: 'pay-2',
  invoiceId: 'inv-1',
  kind: PaymentKind.refund,
  amountPaisa: -25000,
  method: PaymentMethod.cash,
  reason: 'Double charged',
  paidAt: DateTime.utc(2026, 11, 6, 9),
  createdAt: DateTime.utc(2026, 11, 6, 9),
);

PaymentsOverview _data({
  List<Invoice> invoices = const <Invoice>[],
  List<Payment> payments = const <Payment>[],
}) => PaymentsOverview(
  invoices: invoices,
  payments: payments,
  currency: 'NPR',
  timezone: 'Asia/Kathmandu',
);

Widget _app(Widget home, {Locale locale = const Locale('en')}) => MaterialApp(
  theme: appLightTheme,
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: SingleChildScrollView(child: home)),
);

Future<void> _pumpBody(
  WidgetTester tester,
  PaymentsOverview data, {
  PaymentsTab tab = PaymentsTab.invoices,
  Locale locale = const Locale('en'),
}) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    _app(
      PaymentsBody(data: data, initialTab: tab),
      locale: locale,
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('summary card', () {
    testWidgets('shows net paid and an outlined amount due', (tester) async {
      await _pumpBody(
        tester,
        _data(
          invoices: <Invoice>[_partial],
          payments: <Payment>[_refund, _paid],
        ),
      );
      expect(find.text('Total paid'), findsOneWidget);
      // 100000 - 25000 paisa = NPR 750
      expect(
        find.descendant(
          of: find.byKey(paymentsSummaryKey),
          matching: find.text('NPR 750'),
        ),
        findsOneWidget,
      );
      expect(find.byKey(paymentsDueKey), findsOneWidget);
      expect(find.text('Amount due'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byKey(paymentsDueKey),
          matching: find.text('NPR 2,000'),
        ),
        findsOneWidget,
      );
      // Due is carried by a heavy outline, not colour alone.
      final DecoratedBox box = tester.widget<DecoratedBox>(
        find.byKey(paymentsDueKey),
      );
      final Border border = (box.decoration as BoxDecoration).border! as Border;
      expect(border.top.width, greaterThanOrEqualTo(2));
    });

    testWidgets('says all settled when nothing is due', (tester) async {
      await _pumpBody(tester, _data(invoices: <Invoice>[_paidOld]));
      expect(find.byKey(paymentsSettledKey), findsOneWidget);
      expect(find.byKey(paymentsDueKey), findsNothing);
    });
  });

  group('invoices tab', () {
    testWidgets('groups by month and shows number, status, totals', (
      tester,
    ) async {
      await _pumpBody(tester, _data(invoices: <Invoice>[_partial, _paidOld]));
      expect(find.text('NOVEMBER 2026'), findsOneWidget);
      expect(find.text('OCTOBER 2026'), findsOneWidget);
      expect(find.text('INV-0007'), findsOneWidget);
      expect(find.text('Partly paid'), findsOneWidget);
      expect(find.text('Paid'), findsOneWidget);
      expect(find.text('NPR 3,000'), findsNWidgets(2));
      expect(find.text('Paid NPR 1,000 - Due NPR 2,000'), findsOneWidget);
      expect(find.text('Issued 05 Nov 2026'), findsOneWidget);
    });

    testWidgets('tap opens the detail sheet with totals and its payments', (
      tester,
    ) async {
      await _pumpBody(
        tester,
        _data(invoices: <Invoice>[_partial], payments: <Payment>[_paid]),
      );
      await tester.tap(find.text('INV-0007'));
      await tester.pumpAndSettle();
      expect(find.text('Subtotal'), findsOneWidget);
      expect(find.text('NPR 3,500'), findsOneWidget);
      expect(find.text('Discount'), findsOneWidget);
      expect(find.text('−NPR 500'), findsOneWidget);
      expect(
        find.text('Payments on this invoice'.toUpperCase()),
        findsOneWidget,
      );
      expect(find.text('NPR 1,000'), findsWidgets);
    });

    testWidgets('empty state', (tester) async {
      await _pumpBody(tester, _data());
      expect(find.byKey(paymentsEmptyInvoicesKey), findsOneWidget);
      expect(find.byKey(paymentsEmptyPaymentsKey), findsNothing);
      expect(find.byKey(paymentsSettledKey), findsOneWidget);
    });
  });

  group('payments tab', () {
    testWidgets('refunds are negative, labelled and carry their reason', (
      tester,
    ) async {
      await _pumpBody(
        tester,
        _data(payments: <Payment>[_refund, _paid]),
        tab: PaymentsTab.payments,
      );
      expect(find.text('−NPR 250'), findsOneWidget);
      expect(find.text('Refund'), findsOneWidget);
      expect(find.text('Reason: Double charged'), findsOneWidget);
      expect(find.text('NPR 1,000'), findsOneWidget);
      expect(find.text('eSewa - 05 Nov 2026'), findsOneWidget);
      expect(find.text('Cash - 06 Nov 2026'), findsOneWidget);
    });

    testWidgets('empty state', (tester) async {
      await _pumpBody(tester, _data(), tab: PaymentsTab.payments);
      expect(find.byKey(paymentsEmptyPaymentsKey), findsOneWidget);
    });

    testWidgets('segmented control switches tabs', (tester) async {
      await _pumpBody(
        tester,
        _data(invoices: <Invoice>[_partial], payments: <Payment>[_paid]),
      );
      expect(find.text('INV-0007'), findsOneWidget);
      await tester.tap(find.text('Payments').first);
      await tester.pumpAndSettle();
      expect(find.text('INV-0007'), findsNothing);
      expect(find.text('eSewa - 05 Nov 2026'), findsOneWidget);
    });
  });

  testWidgets('renders in Nepali', (tester) async {
    await _pumpBody(
      tester,
      _data(invoices: <Invoice>[_partial], payments: <Payment>[_refund]),
      locale: const Locale('ne'),
    );
    expect(find.text('तिर्न बाँकी रकम'), findsOneWidget);
    expect(find.text('आंशिक भुक्तानी'), findsOneWidget);
  });

  group('screen states', () {
    testWidgets('loading shows the skeleton', (tester) async {
      final Completer<PaymentsOverview> never = Completer<PaymentsOverview>();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            paymentsOverviewProvider.overrideWith((ref) => never.future),
          ],
          child: MaterialApp(
            theme: appLightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const PaymentsScreen(),
          ),
        ),
      );
      await tester.pump();
      expect(find.byKey(paymentsSkeletonKey), findsOneWidget);
    });

    testWidgets('failure shows FailureView and retry reloads', (tester) async {
      int calls = 0;
      await tester.pumpWidget(
        ProviderScope(
          retry: (int c, Object e) => null,
          overrides: [
            paymentsOverviewProvider.overrideWith((ref) async {
              calls++;
              if (calls == 1) {
                throw const AppFailure(FailureKind.offline, 'No signal.');
              }
              return _data(invoices: <Invoice>[_partial]);
            }),
          ],
          child: MaterialApp(
            theme: appLightTheme,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const PaymentsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byKey(failureViewKey), findsOneWidget);
      expect(find.text('No signal.'), findsOneWidget);
      await tester.tap(find.byKey(failureRetryKey));
      await tester.pumpAndSettle();
      expect(find.byKey(failureViewKey), findsNothing);
      expect(find.text('INV-0007'), findsOneWidget);
      expect(calls, 2);
    });

    testWidgets('empty overview uses the shared EmptyView', (tester) async {
      await _pumpBody(tester, _data());
      expect(find.byType(EmptyView), findsOneWidget);
    });
  });
}
