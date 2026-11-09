// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Nepali (`ne`).
class AppLocalizationsNe extends AppLocalizations {
  AppLocalizationsNe([String locale = 'ne']) : super(locale);

  @override
  String get appName => 'LOG Fitness';

  @override
  String get cancel => 'रद्द गर्नुहोस्';

  @override
  String get comingSoon => 'छिट्टै आउँदैछ';

  @override
  String get emptyDefault => 'यहाँ अहिलेसम्म केही छैन।';

  @override
  String get failureDuplicate => 'पहिले नै छ';

  @override
  String get failureInvalid => 'यो मान्य हुँदैन';

  @override
  String get failureNotFound => 'फेला परेन';

  @override
  String get failureOffline => 'इन्टरनेट छैन';

  @override
  String get failureRefused => 'अस्वीकृत';

  @override
  String get failureSignedOut => 'साइन आउट भयो';

  @override
  String get failureUnknown => 'यो काम गरेन';

  @override
  String get loading => 'लोड हुँदैछ';

  @override
  String get offline => 'तपाईं अफलाइन हुनुहुन्छ';

  @override
  String get ok => 'ठीक छ';

  @override
  String get paymentsAllSettled => 'सबै चुक्ता भएको छ - कुनै बाँकी छैन';

  @override
  String get paymentsAmountDue => 'तिर्न बाँकी रकम';

  @override
  String get paymentsDiscount => 'छुट';

  @override
  String get paymentsDue => 'बाँकी';

  @override
  String get paymentsEmptyInvoices =>
      'अहिलेसम्म कुनै बिल छैन। सदस्यता लिँदा वा नवीकरण गर्दा यहाँ देखिन्छ।';

  @override
  String get paymentsEmptyPayments =>
      'अहिलेसम्म कुनै भुक्तानी छैन। फ्रन्ट डेस्कमा गरेको भुक्तानी यहाँ देखिन्छ।';

  @override
  String paymentsIssuedOn(String date) {
    return 'जारी मिति $date';
  }

  @override
  String get paymentsKindPayment => 'भुक्तानी';

  @override
  String get paymentsKindRefund => 'फिर्ता';

  @override
  String get paymentsKindReversal => 'उल्टाइएको';

  @override
  String get paymentsMethodBank => 'बैंक ट्रान्सफर';

  @override
  String get paymentsMethodCard => 'कार्ड';

  @override
  String get paymentsMethodCash => 'नगद';

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
      'm1': 'जनवरी',
      'm2': 'फेब्रुअरी',
      'm3': 'मार्च',
      'm4': 'अप्रिल',
      'm5': 'मे',
      'm6': 'जुन',
      'm7': 'जुलाई',
      'm8': 'अगस्ट',
      'm9': 'सेप्टेम्बर',
      'm10': 'अक्टोबर',
      'm11': 'नोभेम्बर',
      'm12': 'डिसेम्बर',
      'other': '',
    });
    return '$_temp0 $year';
  }

  @override
  String get paymentsOnThisInvoice => 'यो बिलमा गरिएको भुक्तानी';

  @override
  String get paymentsPaid => 'तिरेको';

  @override
  String paymentsPaidAndDue(String paid, String due) {
    return 'तिरेको $paid - बाँकी $due';
  }

  @override
  String paymentsPaidOnly(String amount) {
    return 'तिरेको $amount';
  }

  @override
  String get paymentsPayAtDesk => 'कृपया फ्रन्ट डेस्कमा भुक्तानी गर्नुहोस्।';

  @override
  String paymentsReason(String reason) {
    return 'कारण: $reason';
  }

  @override
  String get paymentsStatusPaid => 'भुक्तानी भयो';

  @override
  String get paymentsStatusPartial => 'आंशिक भुक्तानी';

  @override
  String get paymentsStatusUnpaid => 'तिर्न बाँकी';

  @override
  String get paymentsStatusVoid => 'रद्द';

  @override
  String get paymentsSubtotal => 'उप-जम्मा';

  @override
  String get paymentsTabInvoices => 'बिलहरू';

  @override
  String get paymentsTabPayments => 'भुक्तानीहरू';

  @override
  String get paymentsTotal => 'जम्मा';

  @override
  String get paymentsTotalPaid => 'कुल भुक्तानी';

  @override
  String get retry => 'फेरि प्रयास गर्नुहोस्';

  @override
  String get snackRetry => 'फेरि गर्नुहोस्';

  @override
  String get tabCheckin => 'चेक-इन';

  @override
  String get tabClasses => 'कक्षा';

  @override
  String get tabHome => 'गृह';

  @override
  String get tabPayments => 'भुक्तानी';

  @override
  String get tabProfile => 'प्रोफाइल';
}
