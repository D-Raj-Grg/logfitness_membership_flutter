// The one place a failure becomes pixels.
//
// Why it exists: on 2026-09-07 the web console swallowed a `42501` RLS
// refusal in two Server Actions, so a manager acting outside their branches
// saw nothing happen — indistinguishable from success. This app is *more*
// exposed to that, because CLAUDE.md makes role gating in the UI explicitly
// cosmetic ("Role gates the shell, RLS gates the data") and leans on the
// database to refuse. A refusal that the database issues and the screen does
// not show is the same bug with a different stack trace.
//
// So: [FailureView] renders `AppFailure.message` verbatim — the mapper in
// `lib/domain/errors/app_failure.dart` already wrote a sentence for a person
// at a desk, and paraphrasing it here would undo that — and gives
// [FailureKind.refused] a treatment nobody can mistake for the generic
// "something went wrong" card.
import 'package:flutter/material.dart';

import 'package:logfitness_membership_flutter/app/brand.dart';
import 'package:logfitness_membership_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_membership_flutter/l10n/app_localizations.dart';

/// Widget keys the tests assert on, so a refactor of the layout cannot
/// quietly drop the treatment that distinguishes a refusal.
const Key failureViewKey = Key('failure-view');
const Key refusedFailureKey = Key('failure-view-refused');
const Key failureRetryKey = Key('failure-view-retry');

/// The heading above [AppFailure.message], per kind (localised).
///
/// A refusal and a lost connection each get a heading that names what
/// happened, because the action a person takes next differs completely: one
/// means "ask the front desk", the other means "do it again once you have
/// signal". The sentence under it (`AppFailure.message`) comes from the
/// database / mapper verbatim and is not localised.
String _headlineFor(AppLocalizations l10n, FailureKind kind) => switch (kind) {
  FailureKind.refused => l10n.failureRefused,
  FailureKind.offline => l10n.failureOffline,
  FailureKind.unauthenticated => l10n.failureSignedOut,
  FailureKind.duplicate => l10n.failureDuplicate,
  FailureKind.notFound => l10n.failureNotFound,
  FailureKind.invalid => l10n.failureInvalid,
  FailureKind.unknown => l10n.failureUnknown,
};

IconData _iconFor(FailureKind kind) => switch (kind) {
  FailureKind.refused => Icons.block,
  FailureKind.offline => Icons.cloud_off,
  FailureKind.unauthenticated => Icons.lock_outline,
  FailureKind.duplicate => Icons.copy_all_outlined,
  FailureKind.notFound => Icons.search_off,
  FailureKind.invalid => Icons.rule,
  FailureKind.unknown => Icons.error_outline,
};

/// Renders an [AppFailure] with its message shown as written, and a retry
/// affordance when [onRetry] is given.
class FailureView extends StatelessWidget {
  const FailureView({
    required this.failure,
    this.onRetry,
    this.retryLabel,
    super.key,
  });

  final AppFailure failure;

  /// Omit for a failure there is nothing useful to retry.
  final VoidCallback? onRetry;

  /// Defaults to the localised "Try again".
  final String? retryLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    // A refusal is the one kind that must never read as a transient glitch,
    // so it takes the error container — the loudest surface the theme
    // defines — while everything else sits on the ordinary raised surface.
    // Both come from `lib/app/theme.dart`'s scheme; no colour is invented
    // here (PLANNING.md §6).
    final refused = failure.isRefusal;
    final background = refused
        ? colorScheme.errorContainer
        : colorScheme.surfaceContainerHighest;
    final foreground = refused
        ? colorScheme.onErrorContainer
        : colorScheme.onSurface;
    final secondary = refused
        ? colorScheme.onErrorContainer
        : colorScheme.onSurfaceVariant;

    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        key: failureViewKey,
        width: double.infinity,
        padding: const EdgeInsets.all(Brand.spaceLg),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(Brand.radiusLarge),
          // Only the refusal is outlined. Two independent signals — fill and
          // border — so it survives a screenshot, a colour-blind reader, and
          // a theme change.
          border: refused
              ? Border.all(color: colorScheme.error, width: 2)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(_iconFor(failure.kind), color: foreground),
                const SizedBox(width: Brand.spaceSm),
                Expanded(
                  child: Text(
                    // Keyed so a test can prove the refusal treatment is
                    // present, and so it can never be silently collapsed
                    // into the generic branch.
                    key: refused ? refusedFailureKey : null,
                    _headlineFor(l10n, failure.kind),
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: foreground,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: Brand.spaceSm),
            // Verbatim. `mapError` passes the database's own words through
            // for every code that writes a usable sentence; rewording them
            // here would put the app back in the business of guessing.
            Text(
              failure.message,
              style: theme.textTheme.bodyMedium?.copyWith(color: secondary),
            ),
            if (onRetry != null) ...<Widget>[
              const SizedBox(height: Brand.spaceMd),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  key: failureRetryKey,
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text(retryLabel ?? l10n.retry),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: foreground,
                    side: BorderSide(color: foreground.withValues(alpha: 0.4)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
