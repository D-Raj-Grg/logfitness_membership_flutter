import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ne.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ne'),
  ];

  /// Store name of the app.
  ///
  /// In en, this message translates to:
  /// **'LOG Fitness'**
  String get appName;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// No description provided for @emptyDefault.
  ///
  /// In en, this message translates to:
  /// **'Nothing here yet.'**
  String get emptyDefault;

  /// No description provided for @failureDuplicate.
  ///
  /// In en, this message translates to:
  /// **'Already exists'**
  String get failureDuplicate;

  /// No description provided for @failureInvalid.
  ///
  /// In en, this message translates to:
  /// **'That would not be valid'**
  String get failureInvalid;

  /// No description provided for @failureNotFound.
  ///
  /// In en, this message translates to:
  /// **'Not found'**
  String get failureNotFound;

  /// No description provided for @failureOffline.
  ///
  /// In en, this message translates to:
  /// **'No connection'**
  String get failureOffline;

  /// No description provided for @failureRefused.
  ///
  /// In en, this message translates to:
  /// **'Refused'**
  String get failureRefused;

  /// No description provided for @failureSignedOut.
  ///
  /// In en, this message translates to:
  /// **'Signed out'**
  String get failureSignedOut;

  /// No description provided for @failureUnknown.
  ///
  /// In en, this message translates to:
  /// **'That did not work'**
  String get failureUnknown;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline'**
  String get offline;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @paymentsAllSettled.
  ///
  /// In en, this message translates to:
  /// **'All settled - nothing is due'**
  String get paymentsAllSettled;

  /// No description provided for @paymentsAmountDue.
  ///
  /// In en, this message translates to:
  /// **'Amount due'**
  String get paymentsAmountDue;

  /// No description provided for @paymentsDiscount.
  ///
  /// In en, this message translates to:
  /// **'Discount'**
  String get paymentsDiscount;

  /// No description provided for @paymentsDue.
  ///
  /// In en, this message translates to:
  /// **'Due'**
  String get paymentsDue;

  /// No description provided for @paymentsEmptyInvoices.
  ///
  /// In en, this message translates to:
  /// **'No invoices yet. They appear here when you join or renew.'**
  String get paymentsEmptyInvoices;

  /// No description provided for @paymentsEmptyPayments.
  ///
  /// In en, this message translates to:
  /// **'No payments yet. Payments you make at the front desk appear here.'**
  String get paymentsEmptyPayments;

  /// No description provided for @paymentsIssuedOn.
  ///
  /// In en, this message translates to:
  /// **'Issued {date}'**
  String paymentsIssuedOn(String date);

  /// No description provided for @paymentsKindPayment.
  ///
  /// In en, this message translates to:
  /// **'Payment'**
  String get paymentsKindPayment;

  /// No description provided for @paymentsKindRefund.
  ///
  /// In en, this message translates to:
  /// **'Refund'**
  String get paymentsKindRefund;

  /// No description provided for @paymentsKindReversal.
  ///
  /// In en, this message translates to:
  /// **'Reversed'**
  String get paymentsKindReversal;

  /// No description provided for @paymentsMethodBank.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer'**
  String get paymentsMethodBank;

  /// No description provided for @paymentsMethodCard.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get paymentsMethodCard;

  /// No description provided for @paymentsMethodCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get paymentsMethodCash;

  /// No description provided for @paymentsMethodEsewa.
  ///
  /// In en, this message translates to:
  /// **'eSewa'**
  String get paymentsMethodEsewa;

  /// No description provided for @paymentsMethodFonepay.
  ///
  /// In en, this message translates to:
  /// **'Fonepay'**
  String get paymentsMethodFonepay;

  /// No description provided for @paymentsMethodKhalti.
  ///
  /// In en, this message translates to:
  /// **'Khalti'**
  String get paymentsMethodKhalti;

  /// No description provided for @paymentsMethodOnDate.
  ///
  /// In en, this message translates to:
  /// **'{method} - {date}'**
  String paymentsMethodOnDate(String method, String date);

  /// No description provided for @paymentsMonthYear.
  ///
  /// In en, this message translates to:
  /// **'{month, select, m1{January} m2{February} m3{March} m4{April} m5{May} m6{June} m7{July} m8{August} m9{September} m10{October} m11{November} m12{December} other{}} {year}'**
  String paymentsMonthYear(String month, String year);

  /// No description provided for @paymentsOnThisInvoice.
  ///
  /// In en, this message translates to:
  /// **'Payments on this invoice'**
  String get paymentsOnThisInvoice;

  /// No description provided for @paymentsPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paymentsPaid;

  /// No description provided for @paymentsPaidAndDue.
  ///
  /// In en, this message translates to:
  /// **'Paid {paid} - Due {due}'**
  String paymentsPaidAndDue(String paid, String due);

  /// No description provided for @paymentsPaidOnly.
  ///
  /// In en, this message translates to:
  /// **'Paid {amount}'**
  String paymentsPaidOnly(String amount);

  /// No description provided for @paymentsPayAtDesk.
  ///
  /// In en, this message translates to:
  /// **'Please pay at the front desk.'**
  String get paymentsPayAtDesk;

  /// No description provided for @paymentsReason.
  ///
  /// In en, this message translates to:
  /// **'Reason: {reason}'**
  String paymentsReason(String reason);

  /// No description provided for @paymentsStatusPaid.
  ///
  /// In en, this message translates to:
  /// **'Paid'**
  String get paymentsStatusPaid;

  /// No description provided for @paymentsStatusPartial.
  ///
  /// In en, this message translates to:
  /// **'Partly paid'**
  String get paymentsStatusPartial;

  /// No description provided for @paymentsStatusUnpaid.
  ///
  /// In en, this message translates to:
  /// **'Unpaid'**
  String get paymentsStatusUnpaid;

  /// No description provided for @paymentsStatusVoid.
  ///
  /// In en, this message translates to:
  /// **'Void'**
  String get paymentsStatusVoid;

  /// No description provided for @paymentsSubtotal.
  ///
  /// In en, this message translates to:
  /// **'Subtotal'**
  String get paymentsSubtotal;

  /// No description provided for @paymentsTabInvoices.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get paymentsTabInvoices;

  /// No description provided for @paymentsTabPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get paymentsTabPayments;

  /// No description provided for @paymentsTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get paymentsTotal;

  /// No description provided for @paymentsTotalPaid.
  ///
  /// In en, this message translates to:
  /// **'Total paid'**
  String get paymentsTotalPaid;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @snackRetry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get snackRetry;

  /// No description provided for @tabCheckin.
  ///
  /// In en, this message translates to:
  /// **'Check-in'**
  String get tabCheckin;

  /// No description provided for @tabClasses.
  ///
  /// In en, this message translates to:
  /// **'Classes'**
  String get tabClasses;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get tabPayments;

  /// No description provided for @tabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get tabProfile;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ne'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ne':
      return AppLocalizationsNe();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
