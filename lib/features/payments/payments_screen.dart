// The Payments tab: what I have paid, what I owe, my invoices. Read-only --
// there is no payment in the app; the front desk takes money and renews.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:logfitness_membership_flutter/app/brand.dart';
import 'package:logfitness_membership_flutter/data/payments/invoice.dart';
import 'package:logfitness_membership_flutter/data/payments/payment.dart';
import 'package:logfitness_membership_flutter/domain/enums/postgres_enums.dart';
import 'package:logfitness_membership_flutter/domain/errors/app_failure.dart';
import 'package:logfitness_membership_flutter/domain/format/dates.dart';
import 'package:logfitness_membership_flutter/domain/format/money.dart';
import 'package:logfitness_membership_flutter/features/common/async_value_view.dart';
import 'package:logfitness_membership_flutter/features/common/failure_view.dart';
import 'package:logfitness_membership_flutter/features/common/log_card.dart';
import 'package:logfitness_membership_flutter/features/common/section_header.dart';
import 'package:logfitness_membership_flutter/features/common/skeleton_box.dart';
import 'package:logfitness_membership_flutter/features/common/status_pill.dart';
import 'package:logfitness_membership_flutter/features/payments/payment_formatting.dart';
import 'package:logfitness_membership_flutter/features/payments/payments_logic.dart';
import 'package:logfitness_membership_flutter/features/payments/payments_providers.dart';
import 'package:logfitness_membership_flutter/l10n/app_localizations.dart';

/// Widget keys for tests.
const Key paymentsSummaryKey = Key('payments-summary');
const Key paymentsDueKey = Key('payments-due');
const Key paymentsSettledKey = Key('payments-settled');
const Key paymentsSkeletonKey = Key('payments-skeleton');
const Key paymentsEmptyInvoicesKey = Key('payments-empty-invoices');
const Key paymentsEmptyPaymentsKey = Key('payments-empty-payments');

enum PaymentsTab { invoices, payments }

class PaymentsScreen extends ConsumerWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<PaymentsOverview> async = ref.watch(
      paymentsOverviewProvider,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.tabPayments)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(paymentsOverviewProvider);
          try {
            await ref.read(paymentsOverviewProvider.future);
          } catch (_) {
            // The error state renders itself; the spinner just has to stop.
          }
        },
        child: async.when(
          skipLoadingOnRefresh: true,
          loading: () => const _Scrollable(child: PaymentsSkeleton()),
          error: (Object error, StackTrace st) => _Scrollable(
            child: FailureView(
              failure: mapError(error, st),
              onRetry: () => ref.invalidate(paymentsOverviewProvider),
            ),
          ),
          data: (PaymentsOverview data) =>
              _Scrollable(child: PaymentsBody(data: data)),
        ),
      ),
    );
  }
}

/// Always-scrollable page frame so pull-to-refresh works in every state.
class _Scrollable extends StatelessWidget {
  const _Scrollable({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        Brand.gutter,
        Brand.spaceSm,
        Brand.gutter,
        Brand.spaceXl,
      ),
      children: <Widget>[child],
    );
  }
}

/// Loaded content. Stateless of providers so tests can pump it directly.
class PaymentsBody extends StatefulWidget {
  const PaymentsBody({
    required this.data,
    this.initialTab = PaymentsTab.invoices,
    super.key,
  });

  final PaymentsOverview data;
  final PaymentsTab initialTab;

  @override
  State<PaymentsBody> createState() => _PaymentsBodyState();
}

class _PaymentsBodyState extends State<PaymentsBody> {
  late PaymentsTab _tab = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final PaymentsOverview data = widget.data;
    final PaymentsSummary summary = summarize(data.invoices, data.payments);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _SummaryCard(summary: summary, currency: data.currency),
        const SizedBox(height: Brand.spaceMd),
        SegmentedButton<PaymentsTab>(
          showSelectedIcon: false,
          segments: <ButtonSegment<PaymentsTab>>[
            ButtonSegment<PaymentsTab>(
              value: PaymentsTab.invoices,
              icon: const Icon(Icons.receipt_long_outlined),
              label: Text(l10n.paymentsTabInvoices),
            ),
            ButtonSegment<PaymentsTab>(
              value: PaymentsTab.payments,
              icon: const Icon(Icons.payments_outlined),
              label: Text(l10n.paymentsTabPayments),
            ),
          ],
          selected: <PaymentsTab>{_tab},
          onSelectionChanged: (Set<PaymentsTab> s) =>
              setState(() => _tab = s.first),
        ),
        if (_tab == PaymentsTab.invoices)
          _InvoiceList(data: data)
        else
          _PaymentList(data: data),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Summary
// ---------------------------------------------------------------------------

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary, required this.currency});

  final PaymentsSummary summary;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);

    return LogCard(
      key: paymentsSummaryKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            l10n.paymentsTotalPaid,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: Brand.spaceXs),
          Text(
            signedMoney(summary.netPaidPaisa, currency),
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: Brand.spaceMd),
          if (summary.hasDue)
            _DueBlock(duePaisa: summary.duePaisa, currency: currency)
          else
            Row(
              key: paymentsSettledKey,
              children: <Widget>[
                Icon(
                  Icons.check_circle_outline,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: Brand.spaceSm),
                Expanded(
                  child: Text(
                    l10n.paymentsAllSettled,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

/// Amount owed: a heavy outline, an icon and words -- not colour alone.
class _DueBlock extends StatelessWidget {
  const _DueBlock({required this.duePaisa, required this.currency});

  final int duePaisa;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ColorScheme scheme = theme.colorScheme;

    return Semantics(
      container: true,
      child: DecoratedBox(
        key: paymentsDueKey,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(Brand.radiusMedium),
          border: Border.all(color: scheme.onSurface, width: 2.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(Brand.spaceMd - 2),
          child: Row(
            children: <Widget>[
              Icon(Icons.error_outline, color: scheme.onSurface),
              const SizedBox(width: Brand.spaceSm + 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      l10n.paymentsAmountDue,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      formatMoney(duePaisa, currency: currency),
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: Brand.spaceXs),
                    Text(
                      l10n.paymentsPayAtDesk,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Lists
// ---------------------------------------------------------------------------

/// A month heading followed by one card whose rows are divided by hairlines.
Widget _monthSection<T>({
  required BuildContext context,
  required MonthGroup<T> group,
  required Widget Function(T item) rowBuilder,
}) {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final List<Widget> rows = <Widget>[];
  for (int i = 0; i < group.items.length; i++) {
    if (i > 0) {
      rows.add(const Divider(height: 1));
    }
    rows.add(rowBuilder(group.items[i]));
  }
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: <Widget>[
      SectionHeader(title: monthHeading(l10n, group.year, group.month)),
      LogCard(
        padding: EdgeInsets.zero,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(Brand.radiusCard),
          child: Column(children: rows),
        ),
      ),
    ],
  );
}

class _InvoiceList extends StatelessWidget {
  const _InvoiceList({required this.data});

  final PaymentsOverview data;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (data.invoices.isEmpty) {
      return EmptyView(
        key: paymentsEmptyInvoicesKey,
        icon: Icons.receipt_long_outlined,
        message: l10n.paymentsEmptyInvoices,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final MonthGroup<Invoice> g in groupInvoices(data.invoices))
          _monthSection<Invoice>(
            context: context,
            group: g,
            rowBuilder: (Invoice i) => _InvoiceRow(
              invoice: i,
              currency: data.currency,
              onTap: () => showInvoiceDetail(context, data: data, invoice: i),
            ),
          ),
      ],
    );
  }
}

class _InvoiceRow extends StatelessWidget {
  const _InvoiceRow({
    required this.invoice,
    required this.currency,
    required this.onTap,
  });

  final Invoice invoice;
  final String currency;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool voided = invoice.status == InvoiceStatus.voided;
    final bool owes = !voided && invoice.duePaisa > 0;
    final TextStyle? muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 64),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: Brand.spaceMd,
            vertical: Brand.spaceMd - 2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Text(
                      invoice.invoiceNo,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: Brand.spaceSm),
                  Text(
                    formatMoney(invoice.totalPaisa, currency: currency),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      decoration: voided ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(width: Brand.spaceXs),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: Brand.spaceSm - 2),
              Wrap(
                spacing: Brand.spaceSm,
                runSpacing: Brand.spaceXs,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: <Widget>[
                  StatusPill(
                    label: invoiceStatusLabel(l10n, invoice.status),
                    icon: invoiceStatusIcon(invoice.status),
                    emphasis: invoiceStatusEmphasis(invoice.status),
                  ),
                  Text(
                    l10n.paymentsIssuedOn(formatPlainDate(invoice.issuedOn)),
                    style: muted,
                  ),
                ],
              ),
              if (!voided) ...<Widget>[
                const SizedBox(height: Brand.spaceSm - 2),
                Text(
                  owes
                      ? l10n.paymentsPaidAndDue(
                          formatMoney(invoice.paidPaisa, currency: currency),
                          formatMoney(invoice.duePaisa, currency: currency),
                        )
                      : l10n.paymentsPaidOnly(
                          formatMoney(invoice.paidPaisa, currency: currency),
                        ),
                  style: owes
                      ? theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        )
                      : muted,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentList extends StatelessWidget {
  const _PaymentList({required this.data});

  final PaymentsOverview data;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    if (data.payments.isEmpty) {
      return EmptyView(
        key: paymentsEmptyPaymentsKey,
        icon: Icons.payments_outlined,
        message: l10n.paymentsEmptyPayments,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final MonthGroup<Payment> g in groupPayments(
          data.payments,
          data.timezone,
        ))
          _monthSection<Payment>(
            context: context,
            group: g,
            rowBuilder: (Payment p) => PaymentRow(
              payment: p,
              currency: data.currency,
              timezone: data.timezone,
            ),
          ),
      ],
    );
  }
}

/// One payment, refund or reversal. Money-out rows carry a minus sign, a kind
/// pill with an icon, and the reason -- never colour alone.
class PaymentRow extends StatelessWidget {
  const PaymentRow({
    required this.payment,
    required this.currency,
    required this.timezone,
    super.key,
  });

  final Payment payment;
  final String currency;
  final String timezone;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool moneyOut = payment.kind != PaymentKind.payment;
    final TextStyle? muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final String? reason = payment.reason?.trim();

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Brand.spaceMd,
        vertical: Brand.spaceMd - 2,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            paymentMethodIcon(payment.method),
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: Brand.spaceMd - 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  signedMoney(payment.amountPaisa, currency),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  l10n.paymentsMethodOnDate(
                    paymentMethodLabel(l10n, payment.method),
                    formatDate(payment.paidAt, timeZone: timezone),
                  ),
                  style: muted,
                ),
                if (moneyOut) ...<Widget>[
                  const SizedBox(height: Brand.spaceXs + 2),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: StatusPill(
                      label: paymentKindLabel(l10n, payment.kind),
                      icon: payment.kind == PaymentKind.refund
                          ? Icons.undo
                          : Icons.block,
                      emphasis: PillEmphasis.standard,
                    ),
                  ),
                ],
                if (reason != null && reason.isNotEmpty) ...<Widget>[
                  const SizedBox(height: Brand.spaceXs + 2),
                  Text(l10n.paymentsReason(reason), style: muted),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Invoice detail
// ---------------------------------------------------------------------------

/// Bottom sheet with an invoice's totals and the payments recorded against
/// it. (The invoice has no line items; the plan sold is on the membership.)
Future<void> showInvoiceDetail(
  BuildContext context, {
  required PaymentsOverview data,
  required Invoice invoice,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (BuildContext ctx) =>
        InvoiceDetailSheet(data: data, invoice: invoice),
  );
}

class InvoiceDetailSheet extends StatelessWidget {
  const InvoiceDetailSheet({
    required this.data,
    required this.invoice,
    super.key,
  });

  final PaymentsOverview data;
  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context);
    String money(int p) => formatMoney(p, currency: data.currency);
    final List<Payment> related = paymentsForInvoice(data.payments, invoice.id);
    final bool voided = invoice.status == InvoiceStatus.voided;

    Widget line(String label, String value, {bool strong = false}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: Brand.spaceXs + 1),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: strong ? FontWeight.w800 : null,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: strong ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        Brand.gutter,
        0,
        Brand.gutter,
        Brand.spaceLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(
            invoice.invoiceNo,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: Brand.spaceSm),
          Wrap(
            spacing: Brand.spaceSm,
            runSpacing: Brand.spaceXs,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: <Widget>[
              StatusPill(
                label: invoiceStatusLabel(l10n, invoice.status),
                icon: invoiceStatusIcon(invoice.status),
                emphasis: invoiceStatusEmphasis(invoice.status),
              ),
              Text(
                l10n.paymentsIssuedOn(formatPlainDate(invoice.issuedOn)),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: Brand.spaceMd),
          line(l10n.paymentsSubtotal, money(invoice.subtotalPaisa)),
          if (invoice.discountPaisa > 0)
            line(l10n.paymentsDiscount, '−${money(invoice.discountPaisa)}'),
          const Divider(height: Brand.spaceMd),
          line(l10n.paymentsTotal, money(invoice.totalPaisa), strong: true),
          if (!voided) ...<Widget>[
            line(l10n.paymentsPaid, money(invoice.paidPaisa)),
            line(
              l10n.paymentsDue,
              money(invoice.duePaisa),
              strong: invoice.duePaisa > 0,
            ),
          ],
          if (related.isNotEmpty) ...<Widget>[
            SectionHeader(title: l10n.paymentsOnThisInvoice),
            LogCard(
              tone: LogCardTone.tonal,
              padding: EdgeInsets.zero,
              child: Column(
                children: <Widget>[
                  for (int i = 0; i < related.length; i++) ...<Widget>[
                    if (i > 0) const Divider(height: 1),
                    PaymentRow(
                      payment: related[i],
                      currency: data.currency,
                      timezone: data.timezone,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Loading
// ---------------------------------------------------------------------------

/// Skeleton shaped like the loaded tab: summary card, segmented control, rows.
class PaymentsSkeleton extends StatelessWidget {
  const PaymentsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Semantics(
      label: l10n.loading,
      container: true,
      child: Column(
        key: paymentsSkeletonKey,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const LogCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SkeletonBox(width: 90, height: 14),
                SizedBox(height: Brand.spaceSm),
                SkeletonBox(width: 180, height: 32),
                SizedBox(height: Brand.spaceMd),
                SkeletonBox(height: 56),
              ],
            ),
          ),
          const SizedBox(height: Brand.spaceMd),
          const SkeletonBox(height: 40, radius: Brand.radiusPill),
          const SizedBox(height: Brand.spaceLg),
          for (int i = 0; i < 3; i++) ...<Widget>[
            const SkeletonBox(height: 84, radius: Brand.radiusLarge),
            const SizedBox(height: Brand.spaceSm),
          ],
        ],
      ),
    );
  }
}
