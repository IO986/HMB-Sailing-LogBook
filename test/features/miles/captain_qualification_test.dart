import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/models/crew_member_ref.dart';
import 'package:hmb_sailing_log/core/models/skipper_profile.dart';
import 'package:hmb_sailing_log/features/miles/services/captain_qualification.dart';

void main() {
  const emptyProfile = SkipperProfile();

  group('CrewMemberRef.qualification', () {
    test('is read from crewJson, apart from the licence number', () {
      final crew = CrewMemberRef.parse(jsonEncode([
        {
          'name': 'Ján Novák',
          'role': 'skipper',
          'qualification': 'Yachtmaster Offshore',
          'boatLicence': 'SK-12345',
        },
        {'name': 'Eva', 'role': 'crew'},
      ]));
      expect(crew.first.qualification, 'Yachtmaster Offshore');
      expect(crew.first.boatLicence, 'SK-12345');
      expect(crew.last.qualification, isNull);
    });

    test('older voyages without the key simply have none', () {
      final crew = CrewMemberRef.parse(jsonEncode([
        {'name': 'Ján Novák', 'role': 'skipper', 'boatLicence': 'SK-12345'},
      ]));
      expect(crew.single.qualification, isNull);
    });
  });

  group('suggestedQualification', () {
    test("the voyage's own skipper card comes first", () {
      final crew = CrewMemberRef.parse(jsonEncode([
        {'name': 'Ján', 'role': 'skipper', 'qualification': 'Kapitán jachty'},
      ]));
      final profile = const SkipperProfile(licenseType: 'Námorník');
      expect(suggestedQualification(crew: crew, profile: profile),
          'Kapitán jachty');
    });

    test('falls back to what the phone remembers about its owner', () {
      final crew = CrewMemberRef.parse(jsonEncode([
        {'name': 'Ján', 'role': 'skipper'},
      ]));
      final profile = const SkipperProfile(licenseType: ' Kapitán jachty ');
      expect(suggestedQualification(crew: crew, profile: profile),
          'Kapitán jachty');
    });

    test('a crew member qualification is not the captain\'s', () {
      final crew = CrewMemberRef.parse(jsonEncode([
        {'name': 'Ján', 'role': 'skipper'},
        {'name': 'Eva', 'role': 'crew', 'qualification': 'Kapitán jachty'},
      ]));
      expect(suggestedQualification(crew: crew, profile: emptyProfile), isNull);
    });

    test('a licence number is never offered as a qualification', () {
      final crew = CrewMemberRef.parse(jsonEncode([
        {'name': 'Ján', 'role': 'skipper', 'boatLicence': 'SK-12345'},
      ]));
      final profile = const SkipperProfile(licenseNumber: 'SK-12345');
      expect(suggestedQualification(crew: crew, profile: profile), isNull);
    });

    test('nothing written down means nothing offered', () {
      expect(suggestedQualification(crew: const [], profile: emptyProfile),
          isNull);
    });
  });
}
