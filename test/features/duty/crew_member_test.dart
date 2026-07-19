import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/features/duty/domain/crew_member.dart';

void main() {
  group('CrewMember.decode', () {
    test('reads crewJson and keeps the skipper role', () {
      final json = jsonEncode([
        {'name': 'Ján Novák', 'role': 'skipper', 'boatLicence': 'C'},
        {'name': 'Peter Kováč', 'role': 'crew'},
      ]);

      final crew = CrewMember.decode(crewJson: json);

      expect(crew.map((c) => c.name), ['Ján Novák', 'Peter Kováč']);
      expect(crew.first.isSkipper, isTrue);
      expect(crew.last.isSkipper, isFalse);
    });

    test('falls back to skipperName + pipe-separated crewNames', () {
      final crew = CrewMember.decode(
        skipperName: 'Ján Novák',
        crewNames: 'Peter Kováč|Eva Malá',
      );

      expect(crew.map((c) => c.name), ['Ján Novák', 'Peter Kováč', 'Eva Malá']);
      expect(crew.first.isSkipper, isTrue);
    });

    test('crewJson wins over the legacy fields when both are present', () {
      final json = jsonEncode([
        {'name': 'Z crewJson', 'role': 'skipper'},
      ]);

      final crew = CrewMember.decode(
        crewJson: json,
        skipperName: 'Zo starého poľa',
        crewNames: 'Ignorovaný',
      );

      expect(crew.map((c) => c.name), ['Z crewJson']);
    });

    test('adds the skipper when crewJson lists only crew', () {
      // The skipper must always be selectable — on a short-handed boat they may
      // be the only person ever on duty.
      final json = jsonEncode([
        {'name': 'Peter Kováč', 'role': 'crew'},
      ]);

      final crew = CrewMember.decode(crewJson: json, skipperName: 'Ján Novák');

      expect(crew.map((c) => c.name), ['Ján Novák', 'Peter Kováč']);
      expect(crew.first.isSkipper, isTrue);
    });

    test('does not duplicate the skipper if crewJson already names them', () {
      final json = jsonEncode([
        {'name': 'Ján Novák', 'role': 'crew'},
      ]);

      final crew = CrewMember.decode(crewJson: json, skipperName: 'Ján Novák');

      expect(crew, hasLength(1));
    });

    test('malformed crewJson degrades to the legacy fields, never throws', () {
      final crew = CrewMember.decode(
        crewJson: '{ this is not valid json',
        skipperName: 'Ján Novák',
      );

      expect(crew.map((c) => c.name), ['Ján Novák']);
    });

    test('an empty charter yields an empty list rather than crashing', () {
      expect(CrewMember.decode(), isEmpty);
      expect(CrewMember.decode(crewJson: '', skipperName: ''), isEmpty);
      expect(CrewMember.decode(crewJson: '[]'), isEmpty);
    });

    test('blank names are dropped and surrounding whitespace trimmed', () {
      final json = jsonEncode([
        {'name': '  Ján Novák  ', 'role': 'skipper'},
        {'name': '   ', 'role': 'crew'},
      ]);

      final crew = CrewMember.decode(crewJson: json);

      expect(crew.map((c) => c.name), ['Ján Novák']);
    });
  });
}
