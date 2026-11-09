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
  String get bookingsCancel => 'Cancel booking';

  @override
  String bookingsCancelConfirmBody(String name, String when) {
    return '$name, $when';
  }

  @override
  String get bookingsCancelConfirmTitle => 'Cancel this booking?';

  @override
  String get bookingsEmpty => 'No bookings yet';

  @override
  String get bookingsEmptyHint => 'Book a class from the Classes tab.';

  @override
  String get bookingsKeep => 'Keep booking';

  @override
  String get bookingsNoUpcoming => 'Nothing coming up';

  @override
  String get bookingsPast => 'Past';

  @override
  String get bookingsSessionCancelled => 'Class cancelled by the gym';

  @override
  String get bookingsStatusAttended => 'Attended';

  @override
  String get bookingsStatusBooked => 'Booked';

  @override
  String get bookingsStatusCancelled => 'Cancelled';

  @override
  String get bookingsStatusNoShow => 'Missed';

  @override
  String get bookingsStatusWaitlisted => 'On waitlist';

  @override
  String get bookingsTitle => 'My bookings';

  @override
  String get bookingsUpcoming => 'Upcoming';

  @override
  String get bookingsWaitlistNote =>
      'You\'ll move into the class automatically if a spot opens.';

  @override
  String get cancel => 'Cancel';

  @override
  String get classesBook => 'Book';

  @override
  String get classesBooked => 'Booked';

  @override
  String classesBookedSnack(String name) {
    return 'You\'re booked in for $name.';
  }

  @override
  String get classesCancel => 'Cancel';

  @override
  String get classesCancelledSnack => 'Booking cancelled.';

  @override
  String classesCapacitySemantics(int booked, int capacity) {
    return '$booked of $capacity places taken';
  }

  @override
  String get classesClosed => 'Closed';

  @override
  String get classesDaySelectorLabel => 'Choose a day';

  @override
  String get classesFull => 'Full';

  @override
  String get classesJoinWaitlist => 'Join waitlist';

  @override
  String get classesMyBookings => 'My bookings';

  @override
  String get classesNoClasses => 'No classes this day';

  @override
  String get classesNoClassesHint => 'Pick another day, or check back later.';

  @override
  String get classesOnWaitlist => 'On waitlist';

  @override
  String classesRoom(String room) {
    return 'Room $room';
  }

  @override
  String classesSpotsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count spots left',
      one: '1 spot left',
    );
    return '$_temp0';
  }

  @override
  String get classesToday => 'Today';

  @override
  String get classesUpdating => 'Updating';

  @override
  String classesWaitlistedSnack(String name) {
    return 'You\'re on the waitlist for $name.';
  }

  @override
  String classesWeekdayShort(String day) {
    String _temp0 = intl.Intl.selectLogic(day, {
      'mon': 'Mon',
      'tue': 'Tue',
      'wed': 'Wed',
      'thu': 'Thu',
      'fri': 'Fri',
      'sat': 'Sat',
      'sun': 'Sun',
      'other': '',
    });
    return '$_temp0';
  }

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
  String get messagesChannelEmail => 'Email';

  @override
  String get messagesChannelSms => 'SMS';

  @override
  String get messagesChannelViber => 'Viber';

  @override
  String get messagesEmpty => 'No messages yet';

  @override
  String get messagesEmptyHint => 'Messages from the gym will appear here.';

  @override
  String get messagesEventAnnouncement => 'Announcement';

  @override
  String get messagesEventBirthdayGreeting => 'Birthday greeting';

  @override
  String get messagesEventCustomMessage => 'Message from the gym';

  @override
  String get messagesEventDuesCleared => 'Balance cleared';

  @override
  String get messagesEventDuesReminder => 'Dues reminder';

  @override
  String get messagesEventMemberWelcome => 'Welcome';

  @override
  String get messagesEventMembershipRenewed => 'Membership renewed';

  @override
  String get messagesEventOther => 'Message from the gym';

  @override
  String get messagesEventPaymentReceived => 'Payment receipt';

  @override
  String get messagesEventRenewalReminder => 'Renewal reminder';

  @override
  String messagesHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String get messagesJustNow => 'Just now';

  @override
  String get messagesMarkAllRead => 'Mark all read';

  @override
  String messagesMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes ago',
      one: '1 minute ago',
    );
    return '$_temp0';
  }

  @override
  String get messagesTitle => 'Messages';

  @override
  String get messagesUnread => 'Unread';

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
