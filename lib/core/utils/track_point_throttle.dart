import 'package:latlong2/latlong.dart' hide DistanceCalculator;

import 'distance_calculator.dart';

/// Rozhoduje, ktoré GPS fixy sa naozaj zapíšu do trasy.
///
/// Prijímač dodáva fix každé ~2 s. Pri 6 uzloch je to bod každých ~6 m — trase
/// to nepridá ani meter presnosti, ale za osemhodinovú plavbu je to vyše
/// 14 000 zápisov do SQLite: merateľný odber batérie a zbytočne nafúknutá
/// databáza aj GPX export.
///
/// Táto trieda rieši výhradne HUSTOTU zapísanej trasy. Súčet najazdených míľ
/// sa počíta zvlášť, z každého jedného fixu, takže vzdialenosť v denníku
/// ostáva rovnako presná ako pri zápise všetkého.
class TrackPointThrottle {
  TrackPointThrottle({
    this.minInterval = const Duration(seconds: 5),
    this.minDistanceM = 10,
  });

  /// Najkratší čas medzi dvoma zapísanými bodmi.
  final Duration minInterval;

  /// Najmenší posun od posledného ZAPÍSANÉHO bodu, nie od predošlého fixu:
  /// inak by loď plaziaca sa pomalšie než prah nezapísala už nikdy nič.
  final double minDistanceM;

  DateTime? _lastAt;
  LatLng? _lastPoint;

  /// Posledný zapísaný bod, alebo `null` kým sa nezapísalo nič.
  LatLng? get lastRecordedPoint => _lastPoint;

  /// Zabudne históriu — volá sa na začiatku plavby, aby prvý bod novej trasy
  /// prešiel vždy.
  void reset() {
    _lastAt = null;
    _lastPoint = null;
  }

  /// Vráti `true` a zapamätá si bod, ak sa má [candidate] zapísať.
  ///
  /// Obe podmienky musia platiť naraz a je to zámer: samotný čas by na kotve
  /// zapisoval státie, samotná vzdialenosť by pri GPS šume zapisovala skoky
  /// na mieste.
  bool accept(LatLng candidate, {DateTime? now}) {
    final at = now ?? DateTime.now();
    final lastAt = _lastAt;
    final lastPoint = _lastPoint;

    if (lastAt == null || lastPoint == null) {
      _lastAt = at;
      _lastPoint = candidate;
      return true;
    }
    if (at.difference(lastAt) < minInterval) return false;

    final movedM = DistanceCalculator.distanceM(
      lastPoint.latitude,
      lastPoint.longitude,
      candidate.latitude,
      candidate.longitude,
    );
    if (movedM < minDistanceM) return false;

    _lastAt = at;
    _lastPoint = candidate;
    return true;
  }
}
