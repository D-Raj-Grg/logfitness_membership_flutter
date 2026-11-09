// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'LOG Fitness';

  @override
  String get cancel => 'Cancel';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get emptyDefault => 'Nothing here yet.';

  @override
  String get failureDuplicate => 'Already exists';

  @override
  String get failureInvalid => 'That would not be valid';

  @override
  String get failureNotFound => 'Not found';

  @override
  String get failureOffline => 'No connection';

  @override
  String get failureRefused => 'Refused';

  @override
  String get failureSignedOut => 'Signed out';

  @override
  String get failureUnknown => 'That did not work';

  @override
  String get loading => 'Loading';

  @override
  String get offline => 'You\'re offline';

  @override
  String get ok => 'OK';

  @override
  String get paymentsAllSettled => 'All settled - nothing is due';

  @override
  String get paymentsAmountDue => 'Amount due';

  @override
  String get paymentsDiscount => 'Discount';

  @override
  String get paymentsDue => 'Due';

  @override
  String get paymentsEmptyInvoices =>
      'No invoices yet. They appear here when you join or renew.';

  @override
  String get paymentsEmptyPayments =>
      'No payments yet. Payments you make at the front desk appear here.';

  @override
  String paymentsIssuedOn(String date) {
    return 'Issued $date';
  }

  @override
  String get paymentsKindPayment => 'Payment';

  @override
  String get paymentsKindRefund => 'Refund';

  @override
  String get paymentsKindReversal => 'Reversed';

  @override
  String get paymentsMethodBank => 'Bank transfer';

  @override
  String get paymentsMethodCard => 'Card';

  @override
  String get paymentsMethodCash => 'Cash';

  @override
  String get paymentsMethodEsewa => 'eSewa';

  @override
  String get paymentsMethodFonepay => 'Fonepay';

  @override
  String get paymentsMethodKhalti => 'Khalti';

  @override
  String paymentsMethodOnDate(String method, String date) {
    return '$method - $date';
  }

  @override
  String paymentsMonthYear(String month, String year) {
    String _temp0 = intl.Intl.selectLogic(month, {
      'm1': 'January',
      'm2': 'February',
      'm3': 'March',
      'm4': 'April',
      'm5': 'May',
      'm6': 'June',
      'm7': 'July',
      'm8': 'August',
      'm9': 'September',
      'm10': 'October',
      'm11': 'November',
      'm12': 'December',
      'other': '',
    });
    return '$_temp0 $year';
  }

  @override
  String get paymentsOnThisInvoice => 'Payments on this invoice';

  @override
  String get paymentsPaid => 'Paid';

  @override
  String paymentsPaidAndDue(String paid, String due) {
    return 'Paid $paid - Due $due';
  }

  @override
  String paymentsPaidOnly(String amount) {
    return 'Paid $amount';
  }

  @override
  String get paymentsPayAtDesk => 'Please pay at the front desk.';

  @override
  String paymentsReason(String reason) {
    return 'Reason: $reason';
  }

  @override
  String get paymentsStatusPaid => 'Paid';

  @override
  String get paymentsStatusPartial => 'Partly paid';

  @override
  String get paymentsStatusUnpaid => 'Unpaid';

  @override
  String get paymentsStatusVoid => 'Void';

  @override
  String get paymentsSubtotal => 'Subtotal';

  @override
  String get paymentsTabInvoices => 'Invoices';

  @override
  String get paymentsTabPayments => 'Payments';

  @override
  String get paymentsTotal => 'Total';

  @override
  String get paymentsTotalPaid => 'Total paid';

  @override
  String get retry => 'Try again';

  @override
  String get snackRetry => 'Retry';

  @override
  String get tabCheckin => 'Check-in';

  @override
  String get tabClasses => 'Classes';

  @override
  String get tabHome => 'Home';

  @override
  String get tabPayments => 'Payments';

  @override
  String get tabProfile => 'Profile';
}
