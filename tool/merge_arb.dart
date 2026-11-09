// Merges per-feature l10n fragments into the two base ARB files.
//
//   dart run tool/merge_arb.dart && flutter gen-l10n
//
// Why: several feature agents add strings at once. Each owns
// `lib/l10n/fragments/<feature>_en.json` and `<feature>_ne.json` (flat
// key -> string maps, plus optional "@key" metadata entries), so nobody edits
// the shared `app_en.arb` / `app_ne.arb`, and parallel work cannot conflict.
//
// The base arbs hold the shared keys. Running this tool re-derives
// everything else: it keeps every key already in the base file that is NOT
// owned by a fragment, replaces fragment-owned keys with the fragment's
// values, and writes the result sorted by key (`@@locale` first, each `@key`
// metadata entry directly after its key).
//
// Rules, all errors (exit 1):
//  * a key defined in two fragments;
//  * a fragment key that already exists in the base arb as a shared key
//    (fragment keys must be unique across the whole app);
//  * a fragment that is not a flat JSON object, or a non-string, non-@ value.
import 'dart:convert';
import 'dart:io';

const String _dir = 'lib/l10n';

void main(List<String> args) {
  final bool ok = _mergeLocale('en') & _mergeLocale('ne');
  if (!ok) {
    exit(1);
  }
}

bool _mergeLocale(String locale) {
  final File base = File('$_dir/app_$locale.arb');
  if (!base.existsSync()) {
    stderr.writeln('Missing ${base.path}');
    return false;
  }

  final Map<String, dynamic> baseMap =
      jsonDecode(base.readAsStringSync()) as Map<String, dynamic>;

  final List<File> fragments = Directory('$_dir/fragments')
      .listSync()
      .whereType<File>()
      .where((File f) => f.path.endsWith('_$locale.json'))
      .toList()
    ..sort((File a, File b) => a.path.compareTo(b.path));

  // Keys owned by a previous merge are recorded in a manifest so removing a
  // key from a fragment removes it from the arb too.
  final File manifest = File('$_dir/fragments/.merged_$locale.manifest');
  final Set<String> previouslyMerged = manifest.existsSync()
      ? (jsonDecode(manifest.readAsStringSync()) as List<dynamic>)
          .cast<String>()
          .toSet()
      : <String>{};
  for (final String key in previouslyMerged) {
    baseMap.remove(key);
    baseMap.remove('@$key');
  }

  final Map<String, String> owner = <String, String>{};
  final Map<String, dynamic> merged = <String, dynamic>{};
  bool ok = true;

  for (final File file in fragments) {
    final String name = file.uri.pathSegments.last;
    final Object? decoded = jsonDecode(file.readAsStringSync());
    if (decoded is! Map<String, dynamic>) {
      stderr.writeln('$name: must be a flat JSON object.');
      ok = false;
      continue;
    }
    for (final MapEntry<String, dynamic> e in decoded.entries) {
      final String key = e.key;
      if (key.startsWith('@@')) {
        continue;
      }
      final bool isMeta = key.startsWith('@');
      if (isMeta ? e.value is! Map : e.value is! String) {
        stderr.writeln('$name: "$key" has an unsupported value type.');
        ok = false;
        continue;
      }
      if (isMeta) {
        merged[key] = e.value;
        continue;
      }
      if (owner.containsKey(key)) {
        stderr.writeln(
          'Duplicate key "$key" ($locale): ${owner[key]} and $name.',
        );
        ok = false;
        continue;
      }
      if (baseMap.containsKey(key)) {
        stderr.writeln(
          '$name: "$key" ($locale) already exists as a shared key in '
          'app_$locale.arb.',
        );
        ok = false;
        continue;
      }
      owner[key] = name;
      merged[key] = e.value;
    }
  }

  if (!ok) {
    return false;
  }

  final Map<String, dynamic> all = <String, dynamic>{...baseMap, ...merged};
  final List<String> keys = all.keys
      .where((String k) => !k.startsWith('@'))
      .toList()
    ..sort();

  final Map<String, dynamic> out = <String, dynamic>{};
  if (all.containsKey('@@locale')) {
    out['@@locale'] = all['@@locale'];
  }
  for (final String k in keys) {
    if (k == '@@locale') {
      continue;
    }
    out[k] = all[k];
    if (all.containsKey('@$k')) {
      out['@$k'] = all['@$k'];
    }
  }

  base.writeAsStringSync(
    '${const JsonEncoder.withIndent('  ').convert(out)}\n',
  );
  manifest.writeAsStringSync(
    '${jsonEncode(owner.keys.toList()..sort())}\n',
  );
  stdout.writeln(
    'app_$locale.arb: ${keys.length} keys '
    '(${owner.length} from ${fragments.length} fragments).',
  );
  return true;
}
