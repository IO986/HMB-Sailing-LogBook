import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show FilteringTextInputFormatter;

import '../../core/services/units_service.dart';
import '../../core/utils/coordinate_parser.dart';
import '../../l10n/app_localizations.dart';

/// What the person has typed so far into a [CoordinateInput].
class CoordinateEdit {
  /// Decimal degrees, negative for S and W. `null` when the cells are empty
  /// (nothing recorded) or unreadable (see [invalid]).
  final double? value;

  /// Something is typed but it is not a coordinate, e.g. 75 minutes.
  final bool invalid;

  const CoordinateEdit(this.value, {this.invalid = false});
}

/// One latitude or longitude, typed without any of the symbols.
///
/// Follows the app's coordinate format: degrees and decimal minutes get a cell
/// each (`43` `30.738`), decimal degrees get a single cell (`43.5123`). The
/// hemisphere is a toggle, not a letter to type. The unit signs are drawn by
/// the cells themselves, so a person copying from paper never has to find `°`
/// or `'` on a phone keyboard.
///
/// Reports only edits. A cell that was filled from [initial] and never touched
/// reports nothing, so the caller keeps the exact stored value instead of the
/// rounded one the cells show.
class CoordinateInput extends StatefulWidget {
  final bool isLatitude;
  final double? initial;
  final CoordFormat format;
  final String label;

  /// An error that comes from outside (half a position, for example). Shown
  /// instead of the field's own error.
  final String? errorText;

  /// Prefix of the cell keys: `<prefix>-deg`, `<prefix>-min`, `<prefix>-hem`.
  final String keyPrefix;

  final ValueChanged<CoordinateEdit> onEdited;

  const CoordinateInput({
    super.key,
    required this.isLatitude,
    required this.initial,
    required this.format,
    required this.label,
    required this.onEdited,
    this.errorText,
    this.keyPrefix = 'coord',
  });

  @override
  State<CoordinateInput> createState() => _CoordinateInputState();
}

class _CoordinateInputState extends State<CoordinateInput> {
  final _deg = TextEditingController();
  final _min = TextEditingController();
  bool _negative = false;
  bool _edited = false;
  bool _invalid = false;

  bool get _dmm => widget.format == CoordFormat.dmm;

  @override
  void initState() {
    super.initState();
    _fillFrom(widget.initial);
  }

  @override
  void didUpdateWidget(CoordinateInput old) {
    super.didUpdateWidget(old);
    // The stored value arrives after the first build when an entry is opened
    // for editing. Never overwrite what the person has already typed.
    if (!_edited && old.initial != widget.initial) _fillFrom(widget.initial);
  }

  void _fillFrom(double? value) {
    if (value == null) {
      _deg.clear();
      _min.clear();
      _negative = false;
      return;
    }
    _negative = value < 0;
    final abs = value.abs();
    if (!_dmm) {
      _deg.text = abs.toStringAsFixed(5);
      _min.clear();
      return;
    }
    var d = abs.floor();
    var m = double.parse(((abs - d) * 60).toStringAsFixed(3));
    if (m >= 60) {
      d += 1;
      m = 0;
    }
    _deg.text = '$d';
    _min.text = m.toStringAsFixed(3);
  }

  CoordinateEdit _compute() {
    final deg = _deg.text.trim();
    final min = _min.text.trim();
    final letter = widget.isLatitude
        ? (_negative ? 'S' : 'N')
        : (_negative ? 'W' : 'E');

    final String text;
    if (_dmm) {
      if (deg.isEmpty && min.isEmpty) return const CoordinateEdit(null);
      if (deg.isEmpty) return const CoordinateEdit(null, invalid: true);
      text = '$deg ${min.isEmpty ? '0' : min} $letter';
    } else {
      if (deg.isEmpty) return const CoordinateEdit(null);
      text = '$deg $letter';
    }

    final value = widget.isLatitude
        ? CoordinateParser.parseLatitude(text)
        : CoordinateParser.parseLongitude(text);
    return CoordinateEdit(value, invalid: value == null);
  }

  void _changed() {
    final edit = _compute();
    setState(() {
      _edited = true;
      _invalid = edit.invalid;
    });
    widget.onEdited(edit);
  }

  @override
  void dispose() {
    _deg.dispose();
    _min.dispose();
    super.dispose();
  }

  /// The unit sign is drawn as an icon, not as `suffixText`: Flutter shows
  /// suffix text only while the field is focused or filled, so an empty cell
  /// would give no hint what goes into it.
  static Widget _unit(String sign) => Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Text(sign, style: const TextStyle(fontSize: 16)),
      );

  static const _unitConstraints = BoxConstraints(minWidth: 24, minHeight: 0);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final error = widget.errorText ?? (_invalid ? l.coordinateInvalid : null);
    final hemispheres =
        widget.isLatitude ? const ['N', 'S'] : const ['E', 'W'];
    final digitsOnly = FilteringTextInputFormatter.digitsOnly;
    final decimal = FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
            flex: _dmm ? 2 : 5,
            child: TextField(
              key: ValueKey('${widget.keyPrefix}-deg'),
              controller: _deg,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [_dmm ? digitsOnly : decimal],
              onChanged: (_) => _changed(),
              decoration: InputDecoration(
                labelText: widget.label,
                suffixIcon: _unit('°'),
                suffixIconConstraints: _unitConstraints,
              ),
            ),
          ),
          if (_dmm) ...[
            const SizedBox(width: 8),
            Expanded(
              flex: 3,
              child: TextField(
                key: ValueKey('${widget.keyPrefix}-min'),
                controller: _min,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [decimal],
                onChanged: (_) => _changed(),
                decoration: InputDecoration(
                  labelText: '′',
                  suffixIcon: _unit("'"),
                  suffixIconConstraints: _unitConstraints,
                ),
              ),
            ),
          ],
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: ToggleButtons(
              key: ValueKey('${widget.keyPrefix}-hem'),
              isSelected: [!_negative, _negative],
              constraints: const BoxConstraints(minWidth: 40, minHeight: 44),
              borderRadius: BorderRadius.circular(8),
              onPressed: (i) {
                setState(() => _negative = i == 1);
                _changed();
              },
              children: [for (final h in hemispheres) Text(h)],
            ),
          ),
        ]),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 12),
            child: Text(error,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.error, fontSize: 12)),
          ),
      ],
    );
  }
}
