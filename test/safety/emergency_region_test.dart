import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/config/emergency_contacts.dart';

/// The emergency card dials whatever this returns, so the boxes are pinned to
/// real ports. Build 55 sent the whole Istrian coast and the Slovenian strip
/// to Italy (a single `lon <= 14.0` short-circuit) and the Balearics to Italy
/// as well, because the Italian box was tested before the Spanish one.
void main() {
  void expectPort(String port, double lat, double lon, String code) {
    expect(EmergencyContacts.detectCountry(lat, lon), code, reason: port);
  }

  group('Adriatic', () {
    test('Croatian coast', () {
      expectPort('Umag', 45.43, 13.52, 'HR');
      expectPort('Poreč', 45.22, 13.59, 'HR');
      expectPort('Rovinj', 45.08, 13.63, 'HR');
      expectPort('Pula', 44.87, 13.85, 'HR');
      expectPort('Rijeka', 45.33, 14.44, 'HR');
      expectPort('Zadar', 44.12, 15.23, 'HR');
      expectPort('Šibenik', 43.73, 15.89, 'HR');
      expectPort('Split', 43.50, 16.44, 'HR');
      expectPort('Vis', 43.06, 16.18, 'HR');
      expectPort('Dubrovnik', 42.65, 18.09, 'HR');
    });

    test('Slovenian strip', () {
      expectPort('Koper', 45.55, 13.73, 'SI');
      expectPort('Izola', 45.54, 13.66, 'SI');
      expectPort('Piran', 45.52, 13.57, 'SI');
    });

    test('Italian coast, including the Gulf of Trieste', () {
      expectPort('Trieste', 45.65, 13.78, 'IT');
      expectPort('Monfalcone', 45.79, 13.54, 'IT');
      expectPort('Grado', 45.68, 13.39, 'IT');
      expectPort('Venezia', 45.43, 12.33, 'IT');
      expectPort('Chioggia', 45.22, 12.28, 'IT');
      expectPort('Ravenna', 44.49, 12.28, 'IT');
      expectPort('Ancona', 43.62, 13.51, 'IT');
      expectPort('Pescara', 42.47, 14.22, 'IT');
      expectPort('Vieste', 41.88, 16.18, 'IT');
      expectPort('Bari', 41.13, 16.87, 'IT');
    });

    test('Montenegro and Albania', () {
      expectPort('Herceg Novi', 42.45, 18.53, 'ME');
      expectPort('Kotor', 42.42, 18.77, 'ME');
      expectPort('Bar', 42.09, 19.09, 'ME');
      expectPort('Ulcinj', 41.92, 19.20, 'ME');
      expectPort('Durrës', 41.31, 19.45, 'AL');
      expectPort('Vlorë', 40.45, 19.49, 'AL');
    });

    test('Cavtat is Croatian, not Montenegrin', () {
      expectPort('Cavtat', 42.58, 18.22, 'HR');
    });
  });

  group('Mediterranean', () {
    test('Balearics are Spanish, not Italian', () {
      expectPort('Palma de Mallorca', 39.57, 2.65, 'ES');
      expectPort('Ibiza', 38.91, 1.44, 'ES');
      expectPort('Mahón', 39.89, 4.27, 'ES');
    });

    test('Corsica is French, Sardinia Italian', () {
      expectPort('Bonifacio', 41.39, 9.16, 'FR');
      expectPort('Ajaccio', 41.92, 8.74, 'FR');
      expectPort('Olbia', 40.92, 9.50, 'IT');
      expectPort('Cagliari', 39.21, 9.11, 'IT');
    });

    test('the rest of the basin', () {
      expectPort('Barcelona', 41.37, 2.18, 'ES');
      expectPort('Marseille', 43.30, 5.37, 'FR');
      expectPort('Napoli', 40.84, 14.25, 'IT');
      expectPort('Palermo', 38.12, 13.37, 'IT');
      expectPort('Valletta', 35.90, 14.51, 'MT');
      expectPort('Corfu', 39.62, 19.92, 'GR');
      expectPort('Athína (Piraeus)', 37.94, 23.64, 'GR');
      expectPort('Falmouth', 50.15, -5.07, 'GB');
      expectPort('Bergen', 60.39, 5.32, 'NO');
    });

    test('the Atlantic coast splits between Portugal, Spain and France', () {
      expectPort('Lisboa', 38.70, -9.14, 'PT');
      expectPort('Porto', 41.15, -8.63, 'PT');
      expectPort('Faro', 37.01, -7.93, 'PT');
      expectPort('Cádiz', 36.53, -6.29, 'ES');
      expectPort('A Coruña', 43.37, -8.40, 'ES');
      expectPort('Bilbao', 43.26, -2.93, 'ES');
      expectPort('Biarritz', 43.48, -1.56, 'FR');
      expectPort('La Rochelle', 46.16, -1.15, 'FR');
      expectPort('Brest', 48.39, -4.49, 'FR');
    });
  });

  group('Aegean, where the two coasts interleave', () {
    test('Greek islands stay Greek', () {
      expectPort('Rodos', 36.44, 28.22, 'GR');
      expectPort('Symi', 36.61, 27.84, 'GR');
      expectPort('Kos', 36.89, 27.29, 'GR');
      expectPort('Samos', 37.75, 26.98, 'GR');
      expectPort('Chios', 38.37, 26.14, 'GR');
      expectPort('Lesbos', 39.15, 26.35, 'GR');
      expectPort('Kréta (Heraklion)', 35.34, 25.14, 'GR');
    });

    test('the Turkish charter coast is Turkish', () {
      expectPort('Bodrum', 37.03, 27.43, 'TR');
      expectPort('Marmaris', 36.85, 28.27, 'TR');
      expectPort('Göcek', 36.75, 28.94, 'TR');
      expectPort('Fethiye', 36.62, 29.10, 'TR');
      expectPort('Antalya', 36.88, 30.70, 'TR');
      expectPort('Izmir', 38.42, 27.14, 'TR');
    });
  });

  test('inland Slovakia and the open ocean still resolve', () {
    expectPort('Bratislava', 48.14, 17.11, 'SK');
    expectPort('mid-Atlantic', 35.00, -40.00, 'OFFSHORE');
    expectPort('Indian Ocean', -20.00, 60.00, 'OFFSHORE');
  });

  test('every code the detector can return has contacts behind it', () {
    // A code with no region would render an empty emergency card.
    for (final sample in const [
      (45.50, 13.60), // SI
      (43.50, 16.44), // HR
      (45.43, 12.33), // IT
      (42.42, 18.77), // ME
      (41.31, 19.45), // AL
      (39.57, 2.65), // ES
      (43.30, 5.37), // FR
      (35.90, 14.51), // MT
      (39.62, 19.92), // GR
      (37.03, 27.43), // TR
      (38.70, -9.14), // PT
      (50.15, -5.07), // GB
      (60.39, 5.32), // NO
      (48.14, 17.11), // SK
      (35.00, -40.00), // OFFSHORE
    ]) {
      final code = EmergencyContacts.detectCountry(sample.$1, sample.$2);
      final region = EmergencyContacts.getRegion(code, 'en');
      expect(region, isNotNull, reason: '$code has no contacts');
      expect(region!.contacts, isNotEmpty, reason: '$code has no contacts');
    }
  });
}
