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
  String get authErrorInvalid => 'Card number or PIN is wrong.';

  @override
  String authErrorLocked(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes minutes',
      one: '1 minute',
    );
    return 'Too many tries. Try again in $_temp0.';
  }

  @override
  String get authErrorOffline =>
      'No connection. Check your internet and try again.';

  @override
  String get authErrorRateLimited =>
      'Too many attempts from this phone. Please wait a few minutes and try again.';

  @override
  String get authErrorUnknown =>
      'Couldn\'t sign in right now. Please try again.';

  @override
  String get authForgotPin =>
      'Forgot your PIN? Ask the front desk. They can set a new one for you.';

  @override
  String get authHidePin => 'Hide PIN';

  @override
  String get authIdentifierHint => '0004 or 98XXXXXXXX';

  @override
  String get authIdentifierLabel => 'Card number or phone';

  @override
  String get authNotMemberBody =>
      'Your membership is no longer active. Please contact the front desk.';

  @override
  String get authNotMemberTitle => 'Membership not active';

  @override
  String get authPinLabel => 'PIN';

  @override
  String get authShowPin => 'Show PIN';

  @override
  String get authSignIn => 'Sign in';

  @override
  String get authSignOut => 'Sign out';

  @override
  String get authSigningIn => 'Signing in';

  @override
  String get authSubtitle =>
      'Sign in with the card number or phone number the front desk gave you.';

  @override
  String get authTagline => 'Your membership, in your pocket';

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
  String get homeActiveOpen => 'Active';

  @override
  String get homeAmountDue => 'Amount due';

  @override
  String get homeAmountDueHint => 'Pay at the front desk.';

  @override
  String get homeBookings => 'My bookings';

  @override
  String get homeBookingsSubtitle => 'Classes you\'ve booked';

  @override
  String homeCardNo(String number) {
    return 'NO. $number';
  }

  @override
  String homeDaysLeftLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'days left',
      one: 'day left',
    );
    return '$_temp0';
  }

  @override
  String get homeEndsLabel => 'Ends';

  @override
  String homeExpiredAgoLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'days ago',
      one: 'day ago',
    );
    return '$_temp0';
  }

  @override
  String get homeExpiredHint =>
      'Request a renewal and the front desk will get you back in.';

  @override
  String get homeExpiringHint =>
      'Your plan ends soon. Request a renewal so you don\'t miss a day.';

  @override
  String get homeFrozen => 'Frozen';

  @override
  String get homeFrozenHint =>
      'Your membership is paused. Ask the front desk to resume it.';

  @override
  String homeGreeting(String name) {
    return 'Hi, $name';
  }

  @override
  String get homeLastDay => 'Last day';

  @override
  String get homeLastDayHint => 'Your plan ends today.';

  @override
  String homeLastUpdated(String time) {
    return 'Updated $time';
  }

  @override
  String get homeMembershipEnded => 'Membership ended';

  @override
  String get homeMessages => 'Messages';

  @override
  String get homeMessagesSubtitle => 'Notes from the gym';

  @override
  String get homeNoPlan => 'No active plan';

  @override
  String get homeNoPlanHint => 'Ask the front desk about a plan.';

  @override
  String get homePlanLabel => 'Plan';

  @override
  String get homeRenewButton => 'Request renewal';

  @override
  String get homeRenewNoMember =>
      'We couldn\'t find an active membership on this account. Please contact the front desk.';

  @override
  String get homeRenewNoteLabel => 'Note (optional)';

  @override
  String get homeRenewPhoneLabel => 'Phone (optional)';

  @override
  String homeRenewRequestedAt(String time) {
    return 'Requested at $time. The front desk will call you.';
  }

  @override
  String get homeRenewRequestedButton => 'Request sent';

  @override
  String get homeRenewRequestedNow =>
      'Requested just now. The front desk will call you.';

  @override
  String homeRenewRequestedOn(String date, String time) {
    return 'Requested $date at $time. The front desk will call you.';
  }

  @override
  String get homeRenewSend => 'Send request';

  @override
  String get homeRenewSending => 'Sending';

  @override
  String get homeRenewSent => 'Request sent. The front desk will call you.';

  @override
  String get homeRenewSheetBody =>
      'The front desk will get your request and call you. You pay at the counter. Nothing is charged here.';

  @override
  String get homeRenewSheetTitle => 'Request renewal';

  @override
  String get homeRenewTooSoon =>
      'You asked a moment ago. The front desk already has your request.';

  @override
  String homeSessionsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sessions left',
      one: '1 session left',
    );
    return '$_temp0';
  }

  @override
  String homeStaleBanner(String time) {
    return 'Couldn\'t refresh. Showing what we had at $time.';
  }

  @override
  String get homeStatusActive => 'Active';

  @override
  String get homeStatusExpired => 'Expired';

  @override
  String get homeStatusExpiring => 'Expiring soon';

  @override
  String get homeStatusFrozen => 'Frozen';

  @override
  String get homeStatusNone => 'No plan';

  @override
  String get homeStatusUpcoming => 'Upcoming';

  @override
  String homeUpcomingOn(String date) {
    return 'Starts $date';
  }

  @override
  String get homeUpcomingSoon => 'Starts soon';

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
  String get profileBranch => 'Home branch';

  @override
  String get profileCardNo => 'Card number';

  @override
  String get profileLanguage => 'Language';

  @override
  String get profileLanguageEnglish => 'English';

  @override
  String get profileLanguageNepali => 'नेपाली';

  @override
  String get profileMemberCode => 'Member code';

  @override
  String get profileMessages => 'Messages';

  @override
  String get profileNoCard => 'No card yet';

  @override
  String get profilePhone => 'Phone';

  @override
  String get profileSectionAbout => 'About';

  @override
  String get profileSectionDetails => 'Your details';

  @override
  String get profileSectionPreferences => 'Preferences';

  @override
  String get profileSignOut => 'Sign out';

  @override
  String get profileSignOutConfirmBody =>
      'You\'ll need your card number or phone and your PIN to sign in again.';

  @override
  String get profileSignOutConfirmTitle => 'Sign out?';

  @override
  String get profileTheme => 'Appearance';

  @override
  String get profileThemeDark => 'Dark';

  @override
  String get profileThemeLight => 'Light';

  @override
  String get profileThemeSystem => 'System';

  @override
  String get profileTitle => 'Profile';

  @override
  String get profileVersion => 'App version';

  @override
  String get qrCheckAgain => 'Check again';

  @override
  String get qrExpired => 'Code expired';

  @override
  String get qrHeadline => 'Show this at the door';

  @override
  String get qrLoading => 'Getting your code…';

  @override
  String qrMemberCode(String code) {
    return 'Member $code';
  }

  @override
  String get qrNotEligibleBody =>
      'The door will turn this code away until the front desk has sorted this out. Please see the front desk and we\'ll get you in.';

  @override
  String get qrNotEligibleTitle => 'Check-in isn\'t available right now';

  @override
  String get qrReconnecting => 'Reconnecting…';

  @override
  String get qrReconnectingHint =>
      'No problem. We\'ll keep trying and show a fresh code as soon as we\'re back.';

  @override
  String qrSecondsLeft(int seconds) {
    return 'Refreshes in ${seconds}s';
  }

  @override
  String qrSemanticsLabel(String name) {
    return 'Check-in QR code for $name';
  }

  @override
  String get qrSemanticsLabelNoName => 'Check-in QR code';

  @override
  String get qrSubtitle => 'Your code refreshes by itself.';

  @override
  String get retry => 'Try again';

  @override
  String get snackRetry => 'Retry';

  @override
  String get tabAttendance => 'Attendance';

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
