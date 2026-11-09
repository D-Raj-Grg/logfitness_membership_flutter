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
  String get qrCheckAgain => 'फेरि जाँच गर्नुहोस्';

  @override
  String get qrExpired => 'कोडको समय सकियो';

  @override
  String get qrHeadline => 'ढोकामा यो देखाउनुहोस्';

  @override
  String get qrLoading => 'तपाईंको कोड ल्याउँदै…';

  @override
  String qrMemberCode(String code) {
    return 'सदस्य $code';
  }

  @override
  String get qrNotEligibleBody =>
      'फ्रन्ट डेस्कले यो समस्या समाधान नगरेसम्म ढोकाले यो कोड स्वीकार गर्दैन। कृपया फ्रन्ट डेस्कमा भेट्नुहोस्, हामी तपाईंलाई भित्र पठाउँछौं।';

  @override
  String get qrNotEligibleTitle => 'अहिले चेक-इन गर्न मिल्दैन';

  @override
  String get qrReconnecting => 'फेरि जडान हुँदैछ…';

  @override
  String get qrReconnectingHint =>
      'चिन्ता नलिनुहोस्। हामी प्रयास गरिरहन्छौं, जडान फर्किनेबित्तिकै नयाँ कोड देखिनेछ।';

  @override
  String qrSecondsLeft(int seconds) {
    return '$seconds सेकेन्डमा नवीकरण हुन्छ';
  }

  @override
  String qrSemanticsLabel(String name) {
    return '$name को चेक-इन QR कोड';
  }

  @override
  String get qrSemanticsLabelNoName => 'चेक-इन QR कोड';

  @override
  String get qrSubtitle => 'तपाईंको कोड आफैँ नवीकरण हुन्छ।';

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
