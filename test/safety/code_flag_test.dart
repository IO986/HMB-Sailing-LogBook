import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/features/safety/presentation/widgets/code_flag.dart';

const _size = Size(120, 80);

/// Rasterises a flag so the assertions look at what a user actually sees,
/// not at the spec that produced it.
Future<ui.Image> _render(String letter) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  CodeFlagPainter(codeFlags[letter]!).paint(canvas, _size);
  return recorder
      .endRecording()
      .toImage(_size.width.toInt(), _size.height.toInt());
}

Future<ByteData> _pixels(String letter) async {
  final image = await _render(letter);
  final data = await image.toByteData();
  return data!;
}

/// Colour at a fractional position, x/y in 0..1 from the upper hoist.
Color _at(ByteData pixels, double x, double y) {
  final px = (x * _size.width).clamp(0, _size.width - 1).toInt();
  final py = (y * _size.height).clamp(0, _size.height - 1).toInt();
  final offset = (py * _size.width.toInt() + px) * 4;
  return Color.fromARGB(
    pixels.getUint8(offset + 3),
    pixels.getUint8(offset),
    pixels.getUint8(offset + 1),
    pixels.getUint8(offset + 2),
  );
}

const _white = Color(0xFFFFFFFF);
const _black = Color(0xFF111111);
const _blue = Color(0xFF0A3EA0);
const _red = Color(0xFFD00A17);
const _yellow = Color(0xFFFFD200);

const _letters = [
  'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', //
  'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every letter has a flag', () {
    expect(codeFlags.keys.toSet(), _letters.toSet());
  });

  test('no two letters render the same flag', () async {
    final seen = <String, String>{};
    for (final letter in _letters) {
      final key = (await _pixels(letter)).buffer.asUint8List().join(',');
      final clash = seen[key];
      expect(clash, isNull,
          reason: '$letter renders identically to $clash '
              '- the pattern, not just the colours, has to differ');
      seen[key] = letter;
    }
  });

  group('orientation matches the ICS blazon', () {
    test('E is blue over red, not side by side', () async {
      final p = await _pixels('E');
      expect(_at(p, 0.5, 0.25), _blue);
      expect(_at(p, 0.5, 0.75), _red);
    });

    test('H is white at the hoist, red at the fly', () async {
      final p = await _pixels('H');
      expect(_at(p, 0.25, 0.5), _white);
      expect(_at(p, 0.75, 0.5), _red);
    });

    test('K is yellow at the hoist, blue at the fly', () async {
      final p = await _pixels('K');
      expect(_at(p, 0.25, 0.5), _yellow);
      expect(_at(p, 0.75, 0.5), _blue);
    });

    test('C is blue-white-red-white-blue top to bottom', () async {
      final p = await _pixels('C');
      expect(_at(p, 0.5, 0.1), _blue);
      expect(_at(p, 0.5, 0.3), _white);
      expect(_at(p, 0.5, 0.5), _red);
      expect(_at(p, 0.5, 0.7), _white);
      expect(_at(p, 0.5, 0.9), _blue);
    });

    test('D is a blue band across a yellow field', () async {
      final p = await _pixels('D');
      expect(_at(p, 0.5, 0.1), _yellow);
      expect(_at(p, 0.5, 0.5), _blue);
      expect(_at(p, 0.5, 0.9), _yellow);
    });

    test('L is quartered with yellow at the upper hoist', () async {
      final p = await _pixels('L');
      expect(_at(p, 0.25, 0.25), _yellow);
      expect(_at(p, 0.75, 0.25), _black);
      expect(_at(p, 0.25, 0.75), _black);
      expect(_at(p, 0.75, 0.75), _yellow);
    });

    test('U is quartered with red at the upper hoist', () async {
      final p = await _pixels('U');
      expect(_at(p, 0.25, 0.25), _red);
      expect(_at(p, 0.75, 0.25), _white);
      expect(_at(p, 0.25, 0.75), _white);
      expect(_at(p, 0.75, 0.75), _red);
    });

    test('O is red above the hoist-to-fly diagonal, yellow below', () async {
      final p = await _pixels('O');
      expect(_at(p, 0.8, 0.2), _red);
      expect(_at(p, 0.2, 0.8), _yellow);
    });

    test('Z is yellow top, black hoist, red bottom, blue fly', () async {
      final p = await _pixels('Z');
      expect(_at(p, 0.5, 0.1), _yellow);
      expect(_at(p, 0.08, 0.5), _black);
      expect(_at(p, 0.5, 0.9), _red);
      expect(_at(p, 0.92, 0.5), _blue);
    });

    test('N is a chequy with blue at the upper hoist', () async {
      final p = await _pixels('N');
      expect(_at(p, 0.1, 0.1), _blue);
      expect(_at(p, 0.35, 0.1), _white);
      expect(_at(p, 0.1, 0.35), _white);
      expect(_at(p, 0.35, 0.35), _blue);
    });

    test('G has six vertical stripes starting yellow at the hoist', () async {
      final p = await _pixels('G');
      for (var i = 0; i < 6; i++) {
        expect(_at(p, (i + 0.5) / 6, 0.5), i.isEven ? _yellow : _blue,
            reason: 'stripe $i');
      }
    });

    test('I is a black disc on yellow, not a two-colour split', () async {
      final p = await _pixels('I');
      expect(_at(p, 0.5, 0.5), _black);
      expect(_at(p, 0.05, 0.05), _yellow);
      expect(_at(p, 0.95, 0.95), _yellow);
    });

    test('P and S are inverse inescutcheons', () async {
      final papa = await _pixels('P');
      final sierra = await _pixels('S');
      expect(_at(papa, 0.5, 0.5), _white);
      expect(_at(papa, 0.05, 0.5), _blue);
      expect(_at(sierra, 0.5, 0.5), _blue);
      expect(_at(sierra, 0.05, 0.5), _white);
    });

    test('X is an upright cross, M a saltire - same colours, not the same flag',
        () async {
      final xray = await _pixels('X');
      expect(_at(xray, 0.5, 0.5), _blue);
      expect(_at(xray, 0.5, 0.05), _blue, reason: 'vertical arm reaches the top');
      expect(_at(xray, 0.05, 0.05), _white, reason: 'corner stays white');

      final mike = await _pixels('M');
      expect(_at(mike, 0.5, 0.5), _white);
      expect(_at(mike, 0.5, 0.05), _blue, reason: 'no arm at the top edge');
      expect(_at(mike, 0.02, 0.02), _white, reason: 'saltire reaches the corner');
    });

    test('W is red inside white inside blue', () async {
      final p = await _pixels('W');
      expect(_at(p, 0.5, 0.5), _red);
      expect(_at(p, 0.24, 0.5), _white);
      expect(_at(p, 0.02, 0.5), _blue);
    });

    test('B is solid red with a swallowtail bite out of the fly', () async {
      final p = await _pixels('B');
      expect(_at(p, 0.5, 0.5), _red);
      expect(_at(p, 0.99, 0.5).a, 0, reason: 'notch is cut away');
      expect(_at(p, 0.95, 0.02), _red, reason: 'fly corners stay');
    });

    test('A is white at the hoist, blue at the fly, swallowtailed', () async {
      final p = await _pixels('A');
      expect(_at(p, 0.25, 0.5), _white);
      expect(_at(p, 0.65, 0.5), _blue);
      expect(_at(p, 0.99, 0.5).a, 0);
    });

    test('Q is solid yellow', () async {
      final p = await _pixels('Q');
      expect(_at(p, 0.05, 0.05), _yellow);
      expect(_at(p, 0.95, 0.95), _yellow);
    });
  });
}
