import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:logfitness_membership_flutter/app/brand.dart';
import 'package:logfitness_membership_flutter/app/features.dart';
import 'package:logfitness_membership_flutter/app/router.dart';
import 'package:logfitness_membership_flutter/data/attendance/membership_snapshot.dart';
import 'package:logfitness_membership_flutter/data/member/member_repository.dart';
import 'package:logfitness_membership_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_membership_flutter/domain/format/org_formatters.dart';
import 'package:logfitness_membership_flutter/domain/format/dates.dart';
import 'package:logfitness_membership_flutter/features/common/animated_count.dart';
import 'package:logfitness_membership_flutter/features/common/failure_snackbar.dart';
import 'package:logfitness_membership_flutter/features/common/failure_view.dart';
import 'package:logfitness_membership_flutter/features/common/log_card.dart';
import 'package:logfitness_membership_flutter/features/common/skeleton_box.dart';
import 'package:logfitness_membership_flutter/features/common/status_pill.dart';
import 'package:logfitness_membership_flutter/features/home/home_headline.dart';
import 'package:logfitness_membership_flutter/features/home/home_providers.dart';
import 'package:logfitness_membership_flutter/l10n/app_localizations.dart';

const Key homeHeroKey = Key('home-hero');
const Key homeDaysNumeralKey = Key('home-days-numeral');
const Key homeRenewButtonKey = Key('home-renew-button');
const Key homeAmountDueKey = Key('home-amount-due');
const Key homeCardChipKey = Key('home-card-chip');
const Key homeStaleBannerKey = Key('home-stale-banner');
const Key homeRenewPendingKey = Key('home-renew-pending');

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(memberSelfProvider);
    // Re-ask the server whether a renewal is still pending (this also
    // rebuilds homeDataProvider, which waits on it).
    ref.invalidate(pendingRenewalProvider);
    try {
      await ref.read(homeDataProvider.future);
    } catch (_) {
      // The error is rendered from provider state; the indicator just stops.
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<HomeData> async = ref.watch(homeDataProvider);
    // `value` is the last-known data even while refreshing or after a failed
    // refresh, so offline keeps the previous snapshot on screen.
    final HomeData? data = async.value;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => _refresh(ref),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              Brand.gutter,
              Brand.spaceMd,
              Brand.gutter,
              Brand.spaceXl,
            ),
            children: <Widget>[
              if (data != null)
                _HomeBody(data: data, stale: async.hasError)
              else if (async.hasError)
                FailureView(
                  failure: mapError(async.error!, async.stackTrace),
                  onRetry: () => _refresh(ref),
                )
              else
                const _HomeSkeleton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SkeletonBox(width: 180, height: 28),
        SizedBox(height: Brand.spaceSm),
        SkeletonBox(width: 120, height: 16),
        SizedBox(height: Brand.spaceLg),
        SkeletonBox(height: 280, radius: Brand.radiusCard),
        SizedBox(height: Brand.spaceMd),
        SkeletonBox(height: Brand.buttonHeight, radius: Brand.radiusLarge),
        SizedBox(height: Brand.spaceMd),
        SkeletonBox(height: 64, radius: Brand.radiusLarge),
        SizedBox(height: Brand.spaceSm),
        SkeletonBox(height: 64, radius: Brand.radiusLarge),
      ],
    );
  }
}

class _HomeBody extends ConsumerWidget {
  const _HomeBody({required this.data, required this.stale});

  final HomeData data;
  final bool stale;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final OrgFormatters fmt = orgFormatters(
      currency: data.member.currency,
      timezone: data.member.timezone,
    );
    final String firstName = data.member.fullName.trim().split(RegExp(r'\s+')).first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(l10n.homeGreeting(firstName), style: theme.textTheme.headlineSmall),
        const SizedBox(height: Brand.spaceXs),
        Text(
          data.member.orgName,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        if (stale) ...<Widget>[
          const SizedBox(height: Brand.spaceMd),
          _StaleBanner(time: fmt.time(data.fetchedAt)),
        ],
        const SizedBox(height: Brand.spaceLg),
        _Hero(data: data, fmt: fmt),
        const SizedBox(height: Brand.spaceMd),
        _RenewalSection(
          snapshot: data.snapshot,
          timezone: data.member.timezone,
          phone: data.member.phone,
        ),
        const SizedBox(height: Brand.spaceLg),
        LogCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.mail_outline),
                title: Text(l10n.homeMessages),
                subtitle: Text(l10n.homeMessagesSubtitle),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(AppRoutes.messages),
              ),
              if (kClassesEnabled) ...<Widget>[
                Divider(height: 1, color: theme.colorScheme.outlineVariant),
                ListTile(
                  leading: const Icon(Icons.event_available_outlined),
                  title: Text(l10n.homeBookings),
                  subtitle: Text(l10n.homeBookingsSubtitle),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.push(AppRoutes.bookings),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: Brand.spaceMd),
        Center(
          child: Text(
            l10n.homeLastUpdated(fmt.time(data.fetchedAt)),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _StaleBanner extends StatelessWidget {
  const _StaleBanner({required this.time});

  final String time;

  @override
  Widget build(BuildContext context) {
    final ColorScheme s = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      child: Container(
        key: homeStaleBannerKey,
        padding: const EdgeInsets.all(Brand.spaceMd - 4),
        decoration: BoxDecoration(
          color: s.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(Brand.radiusMedium),
          border: Border.all(color: s.outline),
        ),
        child: Row(
          children: <Widget>[
            const Icon(Icons.cloud_off, size: 18),
            const SizedBox(width: Brand.spaceSm),
            Expanded(
              child: Text(
                AppLocalizations.of(context).homeStaleBanner(time),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

(String, IconData, PillEmphasis) _pillFor(
  AppLocalizations l10n,
  SnapshotBanner banner,
) => switch (banner) {
  SnapshotBanner.active => (
    l10n.homeStatusActive,
    Icons.check_circle_outline,
    PillEmphasis.standard,
  ),
  SnapshotBanner.expiring => (
    l10n.homeStatusExpiring,
    Icons.hourglass_bottom,
    PillEmphasis.strong,
  ),
  SnapshotBanner.expired => (
    l10n.homeStatusExpired,
    Icons.error_outline,
    PillEmphasis.alert,
  ),
  SnapshotBanner.frozen => (
    l10n.homeStatusFrozen,
    Icons.ac_unit,
    PillEmphasis.subtle,
  ),
  SnapshotBanner.upcoming => (
    l10n.homeStatusUpcoming,
    Icons.event_outlined,
    PillEmphasis.subtle,
  ),
  SnapshotBanner.none => (
    l10n.homeStatusNone,
    Icons.remove_circle_outline,
    PillEmphasis.subtle,
  ),
};

class _Hero extends StatelessWidget {
  const _Hero({required this.data, required this.fmt});

  final HomeData data;
  final OrgFormatters fmt;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final ColorScheme scheme = theme.colorScheme;
    final MembershipSnapshot snap = data.snapshot;
    final Headline headline = headlineFor(snap);
    final (String pillLabel, IconData pillIcon, PillEmphasis emphasis) =
        _pillFor(
          l10n,
          // A live banner with a negative day count is headlined as expired;
          // the pill must agree with the headline, not the raw banner.
          headline.kind == HeadlineKind.expiredAgo
              ? SnapshotBanner.expired
              : snap.banner,
        );
    final bool expiring = snap.banner == SnapshotBanner.expiring;

    final Color fg = scheme.onInverseSurface;
    final Color muted = fg.withValues(alpha: 0.72);

    final TextStyle numeral = theme.textTheme.displayLarge!.copyWith(
      fontSize: 112,
      fontWeight: FontWeight.w900,
      height: 1,
      color: fg,
    );
    final TextStyle word = theme.textTheme.displaySmall!.copyWith(
      fontWeight: expiring ? FontWeight.w900 : FontWeight.w800,
      height: 1.1,
      color: fg,
    );
    final TextStyle label = theme.textTheme.titleMedium!.copyWith(
      color: muted,
      fontWeight: FontWeight.w600,
    );

    final (String? prefix, Widget big, String? caption, String? hint) =
        switch (headline.kind) {
          HeadlineKind.daysLeft => (
            null,
            AnimatedCount(
              key: homeDaysNumeralKey,
              value: headline.number!,
              style: numeral,
            ),
            l10n.homeDaysLeftLabel(headline.number!),
            expiring ? l10n.homeExpiringHint : null,
          ),
          HeadlineKind.lastDay => (
            null,
            Text(l10n.homeLastDay, key: homeDaysNumeralKey, style: word),
            null,
            l10n.homeLastDayHint,
          ),
          // The pill already says "Expired"; the hero reads
          // "<pill> 9 days ago" and must not repeat the word.
          HeadlineKind.expiredAgo => (
            null,
            AnimatedCount(
              key: homeDaysNumeralKey,
              value: headline.number!,
              style: numeral,
            ),
            l10n.homeExpiredAgoLabel(headline.number!),
            l10n.homeExpiredHint,
          ),
          HeadlineKind.expired => (
            null,
            Text(l10n.homeMembershipEnded, key: homeDaysNumeralKey, style: word),
            null,
            l10n.homeExpiredHint,
          ),
          HeadlineKind.activeOpen => (
            null,
            Text(l10n.homeActiveOpen, key: homeDaysNumeralKey, style: word),
            null,
            null,
          ),
          HeadlineKind.frozen => (
            null,
            Text(l10n.homeFrozen, key: homeDaysNumeralKey, style: word),
            null,
            l10n.homeFrozenHint,
          ),
          HeadlineKind.upcoming => (
            null,
            Text(l10n.homeUpcomingSoon, key: homeDaysNumeralKey, style: word),
            headline.startDate == null
                ? null
                : l10n.homeUpcomingOn(fmt.date(headline.startDate!)),
            null,
          ),
          HeadlineKind.none => (
            null,
            Text(l10n.homeNoPlan, key: homeDaysNumeralKey, style: word),
            null,
            l10n.homeNoPlanHint,
          ),
        };

    final String? cardNo = data.card.cardNoText;
    final DateTime? end = snap.endDate;

    Widget detailRow(String name, String value) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: <Widget>[
          Text(name, style: theme.textTheme.bodyMedium?.copyWith(color: muted)),
          const SizedBox(width: Brand.spaceMd),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: fg,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    // Expiring: heavier weight AND an outline -- never colour alone.
    return DecoratedBox(
      key: homeHeroKey,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(Brand.radiusCard + 3),
        border: expiring ? Border.all(color: scheme.primary, width: 3) : null,
      ),
      child: LogCard(
        tone: LogCardTone.inverse,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Flexible(
                  child: StatusPill(
                    label: pillLabel,
                    icon: pillIcon,
                    emphasis: emphasis,
                  ),
                ),
                const Spacer(),
                if (cardNo != null)
                  Container(
                    key: homeCardChipKey,
                    padding: const EdgeInsets.symmetric(
                      horizontal: Brand.spaceMd - 4,
                      vertical: Brand.spaceXs + 1,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Brand.radiusPill),
                      border: Border.all(color: fg.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      l10n.homeCardNo(cardNo),
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: fg,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: Brand.spaceLg),
            if (prefix != null) ...<Widget>[
              Text(prefix, style: label),
              const SizedBox(height: Brand.spaceXs),
            ],
            big,
            if (caption != null) ...<Widget>[
              const SizedBox(height: Brand.spaceXs),
              Text(caption, style: label),
            ],
            if (hint != null) ...<Widget>[
              const SizedBox(height: Brand.spaceSm),
              Text(
                hint,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: fg,
                  fontWeight: expiring ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
            const SizedBox(height: Brand.spaceLg),
            Divider(height: 1, color: fg.withValues(alpha: 0.18)),
            const SizedBox(height: Brand.spaceMd - 4),
            if (snap.planName != null)
              detailRow(l10n.homePlanLabel, snap.planName!),
            if (end != null) detailRow(l10n.homeEndsLabel, formatPlainDate(end)),
            if (snap.sessionsRemaining != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(
                  l10n.homeSessionsLeft(snap.sessionsRemaining!),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            if (snap.duePaisa > 0) ...<Widget>[
              const SizedBox(height: Brand.spaceSm),
              Container(
                key: homeAmountDueKey,
                width: double.infinity,
                padding: const EdgeInsets.all(Brand.spaceMd - 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Brand.radiusMedium),
                  border: Border.all(color: fg.withValues(alpha: 0.5), width: 1.5),
                ),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.payments_outlined, color: fg, size: 20),
                    const SizedBox(width: Brand.spaceSm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            l10n.homeAmountDue,
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: muted,
                            ),
                          ),
                          Text(
                            l10n.homeAmountDueHint,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      fmt.money(snap.duePaisa),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: fg,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RenewalSection extends ConsumerWidget {
  const _RenewalSection({
    required this.snapshot,
    required this.timezone,
    required this.phone,
  });

  final MembershipSnapshot snapshot;
  final String timezone;
  final String? phone;

  /// One tap sends the request at once: the member's phone is already on file,
  /// so there is no sheet and no note.
  Future<void> _send(BuildContext context, WidgetRef ref) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    try {
      final RenewalOutcome outcome = await ref
          .read(renewalControllerProvider.notifier)
          .submit(phone: phone);
      if (!context.mounted) {
        return;
      }
      final String text = switch (outcome) {
        RenewalOutcome.requested => l10n.homeRenewSent,
        RenewalOutcome.tooSoon => l10n.homeRenewTooSoon,
        RenewalOutcome.noMember => l10n.homeRenewNoMember,
      };
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(text)));
    } catch (e, st) {
      if (context.mounted) {
        showErrorSnackBar(
          context,
          e,
          stackTrace: st,
          onRetry: () => _send(context, ref),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final RenewalState state = ref.watch(renewalControllerProvider);

    final bool pending = state is RenewalRequested;
    final bool sending = state is RenewalSubmitting;

    String? pendingText;
    if (state is RenewalRequested) {
      final DateTime now = DateTime.now();
      final OrgFormatters fmt = orgFormatters(
        currency: 'NPR',
        timezone: timezone,
      );
      pendingText = now.difference(state.at).inMinutes < 2
          ? l10n.homeRenewRequestedNow
          // Same org-local day: just the time. Otherwise name the date too,
          // since a request seeded from the server can be days old.
          : fmt.date(state.at) == fmt.date(now)
          ? l10n.homeRenewRequestedAt(fmt.time(state.at))
          : l10n.homeRenewRequestedOn(fmt.date(state.at), fmt.time(state.at));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SizedBox(
          height: Brand.buttonHeight,
          child: FilledButton.icon(
            key: homeRenewButtonKey,
            onPressed: pending || sending ? null : () => _send(context, ref),
            icon: sending
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : Icon(pending ? Icons.check : Icons.autorenew),
            label: Text(
              sending
                  ? l10n.homeRenewSending
                  : pending
                  ? l10n.homeRenewRequestedButton
                  : l10n.homeRenewButton,
            ),
          ),
        ),
        if (pendingText != null) ...<Widget>[
          const SizedBox(height: Brand.spaceSm),
          Semantics(
            liveRegion: true,
            child: Text(
              pendingText,
              key: homeRenewPendingKey,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
