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
