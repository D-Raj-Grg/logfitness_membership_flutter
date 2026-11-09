/// Compile-time Supabase + tenant configuration.
///
/// Values are supplied via `--dart-define-from-file=env/local.json` (see
/// README) so the project URL, key and org slug never live in the tree.
abstract final class SupabaseConfig {
  /// The Supabase project URL, e.g. `https://xxxx.supabase.co`.
  static const String url = String.fromEnvironment('SUPABASE_URL');

  /// The Supabase publishable (anon) key. Never the secret/service key.
  static const String publishableKey = String.fromEnvironment(
    'SUPABASE_PUBLISHABLE_KEY',
  );

  /// The gym this build belongs to (`orgs.slug`). Fixed at build time: the
  /// member never picks a gym, and the login function takes the org from here,
  /// never from user input (PLANNING.md §4.2).
  static const String orgSlug = String.fromEnvironment('ORG_SLUG');

  /// Whether every required value was supplied at build time.
  static bool get isConfigured =>
      url.isNotEmpty && publishableKey.isNotEmpty && orgSlug.isNotEmpty;

  /// Throws a [StateError] naming the missing `--dart-define` values.
  ///
  /// Call early in start-up so a misconfigured build shows the startup
  /// failure screen instead of a frozen logo or a confusing network error.
  static void assertConfigured() {
    if (isConfigured) {
      return;
    }

    final List<String> missing = <String>[
      if (url.isEmpty) 'SUPABASE_URL',
      if (publishableKey.isEmpty) 'SUPABASE_PUBLISHABLE_KEY',
      if (orgSlug.isEmpty) 'ORG_SLUG',
    ];

    throw StateError(
      'This build is not configured. Missing: ${missing.join(', ')}. Run '
      'with --dart-define-from-file=env/local.json (see README).',
    );
  }
}
