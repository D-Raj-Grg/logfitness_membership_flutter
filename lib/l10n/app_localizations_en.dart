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
  String get homeExpired => 'Expired';

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
  String get homeExpiredPrefix => 'Expired';

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
  String get offline => 'You\'re offline';

  @override
  String get ok => 'OK';

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
