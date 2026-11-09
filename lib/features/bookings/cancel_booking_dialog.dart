import 'package:flutter/material.dart';

import 'package:logfitness_membership_flutter/l10n/app_localizations.dart';

/// Asks "cancel this booking?" and resolves to true only on an explicit yes.
/// The server may still refuse (cancellation window); its sentence is shown
/// by the caller's snackbar.
Future<bool> confirmCancelBooking(
  BuildContext context, {
  required String className,
  required String when,
}) async {
  final AppLocalizations l10n = AppLocalizations.of(context);
  final bool? yes = await showDialog<bool>(
    context: context,
    builder: (BuildContext ctx) => AlertDialog(
      title: Text(l10n.bookingsCancelConfirmTitle),
      content: Text(l10n.bookingsCancelConfirmBody(className, when)),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(l10n.bookingsKeep),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(l10n.bookingsCancel),
        ),
      ],
    ),
  );
  return yes ?? false;
}
