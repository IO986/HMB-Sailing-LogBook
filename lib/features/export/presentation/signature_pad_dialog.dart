import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/signature_pad.dart';

Future<Uint8List?> showSignaturePadDialog(
    BuildContext context, {String? signerName}) {
  return showModalBottomSheet<Uint8List>(
    context: context,
    isScrollControlled: true,
    // The sheet must not move under the finger. Drag-to-dismiss competes
    // with the pen stroke: a signature is a long vertical drag, so the
    // sheet slid down (and sometimes closed) instead of taking the
    // signature — reported from the field. The sheet still closes by
    // tapping outside it or with the back gesture, just not by dragging.
    enableDrag: false,
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
  final _padKey = GlobalKey<SignaturePadState>();
  List<List<Offset>> _strokes = [];

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
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SignaturePad(
                key: _padKey,
                strokes: _strokes,
                onStrokeAdded: (s) =>
                    setState(() => _strokes = [..._strokes, s]),
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
              onPressed: () => setState(() => _strokes = []),
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
    if (_strokes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).pleaseSign)));
      return;
    }
    final img = await _padKey.currentState?.toBytes();
    if (img != null && mounted) Navigator.of(context).pop(img);
  }
}
