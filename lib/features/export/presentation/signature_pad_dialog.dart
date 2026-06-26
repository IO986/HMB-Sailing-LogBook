import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import '../../../l10n/app_localizations.dart';

Future<Uint8List?> showSignaturePadDialog(
    BuildContext context, {String? signerName}) {
  return showModalBottomSheet<Uint8List>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _SignaturePadSheet(signerName: signerName),
  );
}

class _SignaturePadSheet extends StatefulWidget {
  final String? signerName;
  const _SignaturePadSheet({this.signerName});

  @override
  State<_SignaturePadSheet> createState() => _SignaturePadSheetState();
}

class _SignaturePadSheetState extends State<_SignaturePadSheet> {
  late final SignatureController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = SignatureController(penStrokeWidth: 3, penColor: Colors.black);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          16, 16, 16, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          Text(AppLocalizations.of(context).skipperSignature,
              style: Theme.of(context).textTheme.titleLarge),
          if (widget.signerName != null) ...[
            const SizedBox(height: 4),
            Text(widget.signerName!,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: Colors.grey[600])),
          ],
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Signature(
                controller: _ctrl,
                height: 200,
                backgroundColor: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(AppLocalizations.of(context).signWithFinger,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: Colors.grey)),
          const SizedBox(height: 16),
          Row(children: [
            OutlinedButton.icon(
              icon: const Icon(Icons.clear),
              label: Text(AppLocalizations.of(context).clear),
              onPressed: () => _ctrl.clear(),
            ),
            const Spacer(),
            FilledButton.icon(
              icon: const Icon(Icons.draw),
              label: Text(AppLocalizations.of(context).signAndExport),
              onPressed: _confirm,
            ),
          ]),
        ],
      ),
    );
  }

  Future<void> _confirm() async {
    if (_ctrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).pleaseSign)));
      return;
    }
    final img = await _ctrl.toPngBytes();
    if (img != null && mounted) Navigator.of(context).pop(img);
  }
}
