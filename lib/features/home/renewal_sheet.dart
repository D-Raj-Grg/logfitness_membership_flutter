import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:logfitness_membership_flutter/app/brand.dart';
import 'package:logfitness_membership_flutter/l10n/app_localizations.dart';

const Key renewalPhoneFieldKey = Key('renewal-phone');
const Key renewalNoteFieldKey = Key('renewal-note');
const Key renewalSendKey = Key('renewal-send');

class RenewalRequestInput {
  const RenewalRequestInput({this.phone, this.note});

  final String? phone;
  final String? note;
}

/// Bottom sheet collecting the optional phone + note. Returns null when
/// dismissed; the caller sends the request (so the sheet holds no state about
/// the network).
Future<RenewalRequestInput?> showRenewalSheet(BuildContext context) {
  return showModalBottomSheet<RenewalRequestInput>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (BuildContext context) => const _RenewalSheet(),
  );
}

class _RenewalSheet extends StatefulWidget {
  const _RenewalSheet();

  @override
  State<_RenewalSheet> createState() => _RenewalSheetState();
}

class _RenewalSheetState extends State<_RenewalSheet> {
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _note = TextEditingController();

  @override
  void dispose() {
    _phone.dispose();
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: Brand.gutter,
        right: Brand.gutter,
        top: Brand.spaceSm,
        bottom: MediaQuery.viewInsetsOf(context).bottom + Brand.spaceLg,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(l10n.homeRenewSheetTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: Brand.spaceSm),
            Text(
              l10n.homeRenewSheetBody,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: Brand.spaceMd),
            TextField(
              key: renewalPhoneFieldKey,
              controller: _phone,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              maxLength: 15,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+ ]')),
              ],
              decoration: InputDecoration(
                labelText: l10n.homeRenewPhoneLabel,
                counterText: '',
                prefixIcon: const Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: Brand.spaceMd),
            TextField(
              key: renewalNoteFieldKey,
              controller: _note,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.newline,
              minLines: 2,
              maxLines: 4,
              maxLength: 200,
              decoration: InputDecoration(labelText: l10n.homeRenewNoteLabel),
            ),
            const SizedBox(height: Brand.spaceSm),
            SizedBox(
              height: Brand.buttonHeight,
              child: FilledButton(
                key: renewalSendKey,
                onPressed: () => Navigator.of(context).pop(
                  RenewalRequestInput(phone: _phone.text, note: _note.text),
                ),
                child: Text(l10n.homeRenewSend),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
