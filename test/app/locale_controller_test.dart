import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logfitness_membership_flutter/app/locale_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues(<String, Object>{}));

  test('unknown or absent codes mean follow the device', () {
    expect(localeFromCode(null), isNull);
    expect(localeFromCode('fr'), isNull);
    expect(localeFromCode('ne'), const Locale('ne'));
  });

  test('set persists and null clears', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container.read(localeProvider.notifier).set(const Locale('ne'));
    expect(container.read(localeProvider), const Locale('ne'));
    expect(await loadLocaleOverride(), const Locale('ne'));

    await container.read(localeProvider.notifier).set(null);
    expect(container.read(localeProvider), isNull);
    expect(await loadLocaleOverride(), isNull);
  });
}
