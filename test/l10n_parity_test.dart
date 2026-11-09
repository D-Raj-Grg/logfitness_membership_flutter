import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Set<String> _keys(String path) =>
    (jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>).keys
        .where((String k) => !k.startsWith('@'))
        .toSet();

void main() {
  test('app_en.arb and app_ne.arb define exactly the same keys', () {
    final Set<String> en = _keys('lib/l10n/app_en.arb');
    final Set<String> ne = _keys('lib/l10n/app_ne.arb');

    expect(
      en.difference(ne),
      isEmpty,
      reason: 'In English but missing from Nepali',
    );
    expect(
      ne.difference(en),
      isEmpty,
      reason: 'In Nepali but missing from English',
    );
  });

  test('every fragment has a counterpart in the other language', () {
    final Directory dir = Directory('lib/l10n/fragments');
    final Set<String> names = dir
        .listSync()
        .whereType<File>()
        .map((File f) => f.uri.pathSegments.last)
        .where((String n) => n.endsWith('_en.json') || n.endsWith('_ne.json'))
        .toSet();
    for (final String n in names) {
      final String other = n.endsWith('_en.json')
          ? n.replaceAll('_en.json', '_ne.json')
          : n.replaceAll('_ne.json', '_en.json');
      expect(names, contains(other), reason: '$n has no $other');
    }
  });
}
