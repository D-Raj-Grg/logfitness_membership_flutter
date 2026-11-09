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
  String get authErrorInvalid => 'कार्ड नम्बर वा पिन मिलेन।';

  @override
  String authErrorLocked(int minutes) {
    String _temp0 = intl.Intl.pluralLogic(
      minutes,
      locale: localeName,
      other: '$minutes मिनेट',
      one: '१ मिनेट',
    );
    return 'धेरै पटक प्रयास भयो। $_temp0 पछि फेरि प्रयास गर्नुहोस्।';
  }

  @override
  String get authErrorOffline =>
      'इन्टरनेट छैन। इन्टरनेट जाँचेर फेरि प्रयास गर्नुहोस्।';

  @override
  String get authErrorRateLimited =>
      'यो फोनबाट धेरै प्रयास भयो। केही मिनेट कुरेर फेरि प्रयास गर्नुहोस्।';

  @override
  String get authErrorUnknown =>
      'अहिले साइन इन गर्न सकिएन। कृपया फेरि प्रयास गर्नुहोस्।';

  @override
  String get authForgotPin =>
      'पिन बिर्सनुभयो? फ्रन्ट डेस्कलाई सोध्नुहोस्। उहाँहरूले नयाँ पिन राखिदिनुहुन्छ।';

  @override
  String get authHidePin => 'पिन लुकाउनुहोस्';

  @override
  String get authIdentifierHint => '0004 वा 98XXXXXXXX';

  @override
  String get authIdentifierLabel => 'कार्ड नम्बर वा फोन';

  @override
  String get authNotMemberBody =>
      'तपाईंको सदस्यता अब सक्रिय छैन। कृपया फ्रन्ट डेस्कमा सम्पर्क गर्नुहोस्।';

  @override
  String get authNotMemberTitle => 'सदस्यता सक्रिय छैन';

  @override
  String get authPinLabel => 'पिन';

  @override
  String get authShowPin => 'पिन देखाउनुहोस्';

  @override
  String get authSignIn => 'साइन इन';

  @override
  String get authSignOut => 'साइन आउट';

  @override
  String get authSigningIn => 'साइन इन हुँदैछ';

  @override
  String get authSubtitle =>
      'फ्रन्ट डेस्कले दिएको कार्ड नम्बर वा फोन नम्बरबाट साइन इन गर्नुहोस्।';

  @override
  String get authTagline => 'तपाईंको सदस्यता, तपाईंकै खल्तीमा';

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
  String get homeActiveOpen => 'सक्रिय';

  @override
  String get homeAmountDue => 'तिर्नुपर्ने रकम';

  @override
  String get homeAmountDueHint => 'फ्रन्ट डेस्कमा तिर्नुहोस्।';

  @override
  String get homeBookings => 'मेरा बुकिङ';

  @override
  String get homeBookingsSubtitle => 'तपाईंले बुक गरेका कक्षा';

  @override
  String homeCardNo(String number) {
    return 'नं. $number';
  }

  @override
  String homeDaysLeftLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'दिन बाँकी',
      one: 'दिन बाँकी',
    );
    return '$_temp0';
  }

  @override
  String get homeEndsLabel => 'सकिने मिति';

  @override
  String get homeExpired => 'म्याद सकियो';

  @override
  String homeExpiredAgoLabel(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'दिन अघि',
      one: 'दिन अघि',
    );
    return '$_temp0';
  }

  @override
  String get homeExpiredHint =>
      'नवीकरणको अनुरोध गर्नुहोस्, फ्रन्ट डेस्कले तपाईंलाई फेरि सुचारु गरिदिनुहुन्छ।';

  @override
  String get homeExpiredPrefix => 'म्याद सकियो';

  @override
  String get homeExpiringHint =>
      'तपाईंको योजना छिट्टै सकिँदैछ। एक दिन पनि नछुटोस् भनेर नवीकरणको अनुरोध गर्नुहोस्।';

  @override
  String get homeFrozen => 'रोकिएको';

  @override
  String get homeFrozenHint =>
      'तपाईंको सदस्यता रोकिएको छ। फेरि चालु गर्न फ्रन्ट डेस्कलाई भन्नुहोस्।';

  @override
  String homeGreeting(String name) {
    return 'नमस्ते, $name';
  }

  @override
  String get homeLastDay => 'अन्तिम दिन';

  @override
  String get homeLastDayHint => 'तपाईंको योजना आज सकिँदैछ।';

  @override
  String homeLastUpdated(String time) {
    return '$time मा अद्यावधिक';
  }

  @override
  String get homeMessages => 'सन्देशहरू';

  @override
  String get homeMessagesSubtitle => 'जिमबाट आएका सूचना';

  @override
  String get homeNoPlan => 'सक्रिय योजना छैन';

  @override
  String get homeNoPlanHint => 'योजनाको बारेमा फ्रन्ट डेस्कलाई सोध्नुहोस्।';

  @override
  String get homePlanLabel => 'योजना';

  @override
  String get homeRenewButton => 'नवीकरणको अनुरोध';

  @override
  String get homeRenewNoMember =>
      'यो खातामा सक्रिय सदस्यता भेटिएन। कृपया फ्रन्ट डेस्कमा सम्पर्क गर्नुहोस्।';

  @override
  String get homeRenewNoteLabel => 'टिप्पणी (ऐच्छिक)';

  @override
  String get homeRenewPhoneLabel => 'फोन (ऐच्छिक)';

  @override
  String homeRenewRequestedAt(String time) {
    return '$time मा अनुरोध गरियो। फ्रन्ट डेस्कले तपाईंलाई फोन गर्नुहुन्छ।';
  }

  @override
  String get homeRenewRequestedButton => 'अनुरोध पठाइयो';

  @override
  String get homeRenewRequestedNow =>
      'अहिले नै अनुरोध गरियो। फ्रन्ट डेस्कले तपाईंलाई फोन गर्नुहुन्छ।';

  @override
  String get homeRenewSend => 'अनुरोध पठाउनुहोस्';

  @override
  String get homeRenewSending => 'पठाउँदैछ';

  @override
  String get homeRenewSent =>
      'अनुरोध पठाइयो। फ्रन्ट डेस्कले तपाईंलाई फोन गर्नुहुन्छ।';

  @override
  String get homeRenewSheetBody =>
      'फ्रन्ट डेस्कले तपाईंको अनुरोध पाउँछ र फोन गर्छ। रकम काउन्टरमै तिर्नुहुन्छ। यहाँ केही पनि काटिँदैन।';

  @override
  String get homeRenewSheetTitle => 'नवीकरणको अनुरोध';

  @override
  String get homeRenewTooSoon =>
      'तपाईंले भर्खरै अनुरोध गर्नुभएको छ। फ्रन्ट डेस्कसँग तपाईंको अनुरोध पुगिसकेको छ।';

  @override
  String homeSessionsLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count सत्र बाँकी',
      one: '१ सत्र बाँकी',
    );
    return '$_temp0';
  }

  @override
  String homeStaleBanner(String time) {
    return 'नयाँ जानकारी ल्याउन सकिएन। $time को जानकारी देखाइएको छ।';
  }

  @override
  String get homeStatusActive => 'सक्रिय';

  @override
  String get homeStatusExpired => 'म्याद सकियो';

  @override
  String get homeStatusExpiring => 'छिट्टै सकिँदैछ';

  @override
  String get homeStatusFrozen => 'रोकिएको';

  @override
  String get homeStatusNone => 'योजना छैन';

  @override
  String get homeStatusUpcoming => 'आउँदै';

  @override
  String homeUpcomingOn(String date) {
    return '$date देखि सुरु';
  }

  @override
  String get homeUpcomingSoon => 'छिट्टै सुरु हुन्छ';

  @override
  String get loading => 'लोड हुँदैछ';

  @override
  String get offline => 'तपाईं अफलाइन हुनुहुन्छ';

  @override
  String get ok => 'ठीक छ';

  @override
  String get profileBranch => 'मुख्य शाखा';

  @override
  String get profileCardNo => 'कार्ड नम्बर';

  @override
  String get profileLanguage => 'भाषा';

  @override
  String get profileLanguageEnglish => 'English';

  @override
  String get profileLanguageNepali => 'नेपाली';

  @override
  String get profileMemberCode => 'सदस्य कोड';

  @override
  String get profileMessages => 'सन्देशहरू';

  @override
  String get profileNoCard => 'कार्ड अझै छैन';

  @override
  String get profilePhone => 'फोन';

  @override
  String get profileSectionAbout => 'बारेमा';

  @override
  String get profileSectionDetails => 'तपाईंको विवरण';

  @override
  String get profileSectionPreferences => 'रोजाइ';

  @override
  String get profileSignOut => 'साइन आउट';

  @override
  String get profileSignOutConfirmBody =>
      'फेरि साइन इन गर्न कार्ड नम्बर वा फोन र पिन चाहिन्छ।';

  @override
  String get profileSignOutConfirmTitle => 'साइन आउट गर्ने?';

  @override
  String get profileTheme => 'रूपरङ';

  @override
  String get profileThemeDark => 'अँध्यारो';

  @override
  String get profileThemeLight => 'उज्यालो';

  @override
  String get profileThemeSystem => 'फोन अनुसार';

  @override
  String get profileTitle => 'प्रोफाइल';

  @override
  String get profileVersion => 'एपको संस्करण';

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
