/// Vrstvy mapy pre zamerania: kužele, osi, popisky a vypočítané polohy.
///
/// Oba režimy kreslia to isté — polpriamku s kužeľom neistoty — len z opačnej
/// strany, a to musí byť na mape vidno na prvý pohľad:
///
/// * resekcia: čiarkovaná priamka vychádza zo ZAMERANÉHO BODU (kosoštvorec)
///   a smeruje k lodi; priesečník takých priamok je moja poloha;
/// * hľadanie objektu: plná priamka vychádza z POLOHY POZOROVATEĽA (bodka)
///   nameraným kurzom; priesečník je hľadaný objekt.
///
/// Popisok na hrote vždy ukazuje NAMERANÝ kurz, nikdy nie ten opačný, ktorým
/// sa priamka resekcie kreslí. Inak by mapa tvrdila iné číslo než skiperov
/// zápisník aj PDF, a to je presne ten druh nesúladu, po ktorom sa prístroju
/// prestane veriť.
///
/// Oddelené od `map_screen.dart` len preto, aby tá obrazovka nerástla.
library;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/models/bearing_kind.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/bearing_provider.dart';
import '../../services/bearing_geometry.dart';

/// Jantárová — odlišuje zamerania od modrej trasy, červených waypointov,
/// fialového pravítka aj tyrkysových prúdov.
const Color kBearingColor = Color(0xFFFFA000);

/// Tmavšia jantárová pre vytriangulovaný neznámy bod — musí sa dať odlíšiť
/// od "kde som ja", inak je celá funkcia na omyl.
const Color kSightObjectColor = Color(0xFFE65100);

/// Koľko bodov tvorí oblúk na konci kužeľa. Tetiva by pri ±8° stačila, ale
/// pár bodov navyše nič nestojí a hrana nevyzerá zlomená.
const int _arcSegments = 6;

/// Vrstvy zameraní, v poradí od spodnej po vrchnú.
///
/// [onTapBearing] dostane zameranie, keď používateľ ťukne na jeho hrot;
/// [onTapSightGroup] pátranie po objekte, keď ťukne na jeho vypočítanú polohu.
/// [gpsPosition] slúži len na zobrazenie odchýlky resekcie od GPS — je to
/// kalibračná pomôcka, nie podmienka.
List<Widget> buildBearingLayers({
  required List<Bearing> bearings,
  required BearingFix? resectionFix,
  required List<SightGroup> sightGroups,
  required AppLocalizations l,
  required void Function(Bearing bearing) onTapBearing,
  required void Function(SightGroup group) onTapSightGroup,
  LatLng? gpsPosition,
  double lineLengthNm = kBearingLineLengthNm,
}) {
  final drawn = <_DrawnBearing>[];
  for (final b in bearings) {
    final kind = BearingKind.fromCode(b.kind);
    final line = bearingLineOf(b);
    if (kind == null || line == null) continue;
    drawn.add(_DrawnBearing(row: b, kind: kind, line: line));
  }

  if (drawn.isEmpty && resectionFix == null && sightGroups.isEmpty) {
    return const [];
  }

  return [
    // ── Kužele neistoty ─────────────────────────────────────────
    PolygonLayer(
      polygons: [
        for (final d in drawn)
          Polygon(
            points: _conePoints(d.line, lineLengthNm),
            color: kBearingColor.withValues(alpha: 0.10),
            borderColor: kBearingColor.withValues(alpha: 0.30),
            borderStrokeWidth: 1,
          ),
      ],
    ),

    // ── Osi zameraní ────────────────────────────────────────────
    PolylineLayer(
      polylines: [
        for (final d in drawn)
          Polyline(
            points: [d.line.origin, _tipOf(d.line, lineLengthNm)],
            color: kBearingColor,
            strokeWidth: 2.5,
            // Čiarkovane pri resekcii: priamka nevedie tam, kam sa mieril
            // dalekohľad, ale opačne, od bodu k lodi.
            pattern: d.kind == BearingKind.resection
                // Bez `const`: StrokePattern.dashed si v konstruktore
                // čita segments.length, čo v konštantnom výraze nejde.
                ? StrokePattern.dashed(segments: const [9, 6])
                : const StrokePattern.solid(),
          ),
      ],
    ),

    // ── Začiatok priamky ────────────────────────────────────────
    MarkerLayer(
      markers: [
        for (final d in drawn)
          Marker(
            point: d.line.origin,
            width: 18,
            height: 18,
            child: d.kind == BearingKind.resection
                // Kosoštvorec = zameraný bod na mape, nie loď.
                ? Transform.rotate(
                    angle: 0.7854,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: kBearingColor,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  )
                : const DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: kBearingColor,
                      border: Border.fromBorderSide(
                          BorderSide(color: Colors.white, width: 2)),
                    ),
                  ),
          ),
      ],
    ),

    // ── Hrot s popisom ──────────────────────────────────────────
    MarkerLayer(
      markers: [
        for (final d in drawn)
          Marker(
            point: _tipOf(d.line, lineLengthNm),
            width: 140,
            height: 44,
            alignment: Alignment.center,
            child: _BearingTip(
              bearing: d.row,
              kind: d.kind,
              onTap: () => onTapBearing(d.row),
            ),
          ),
      ],
    ),

    // ── Moja poloha z resekcie ──────────────────────────────────
    if (resectionFix != null) ...[
      CircleLayer(
        circles: [
          CircleMarker(
            point: resectionFix.position,
            radius: resectionFix.errorRadiusMeters,
            useRadiusInMeter: true,
            color: (resectionFix.isWeak ? Colors.orange : Colors.green)
                .withValues(alpha: 0.12),
            borderColor: resectionFix.isWeak
                ? Colors.orange.shade700
                : Colors.green.shade600,
            borderStrokeWidth: 1.5,
          ),
        ],
      ),
      // Trojuholník chyby — pri troch a viac zameraniach ukáže, ako veľmi si
      // odčítania protirečia. Pri dvoch je to jediný bod, takže sa nekreslí.
      if (resectionFix.intersections.length >= 3)
        PolygonLayer(
          polygons: [
            Polygon(
              points: resectionFix.intersections,
              color: Colors.transparent,
              borderColor: (resectionFix.isWeak ? Colors.orange : Colors.green)
                  .withValues(alpha: 0.7),
              borderStrokeWidth: 1.5,
              pattern: const StrokePattern.dotted(),
            ),
          ],
        ),
      // Spojnica na GPS: kým GPS beží, je to jediná príležitosť zistiť,
      // nakoľko sa dá telefónovému kompasu veriť, keď raz GPS vypadne.
      if (gpsPosition != null)
        PolylineLayer(
          polylines: [
            Polyline(
              points: [resectionFix.position, gpsPosition],
              color: Colors.blueGrey.withValues(alpha: 0.8),
              strokeWidth: 1.5,
              pattern: const StrokePattern.dotted(),
            ),
          ],
        ),
      MarkerLayer(
        markers: [
          Marker(
            point: resectionFix.position,
            width: 170,
            height: 56,
            alignment: Alignment.center,
            child: _FixMarker(
              icon: Icons.person_pin_circle,
              colour: resectionFix.isWeak
                  ? Colors.orange.shade800
                  : Colors.green.shade700,
              title: l.bearingMyPositionFix,
              detail: '±${resectionFix.errorRadiusMeters.round()} m',
              extra: gpsPosition == null
                  ? null
                  : l.bearingFixOffGps(_metres(
                      resectionFix.position, gpsPosition)),
            ),
          ),
        ],
      ),
    ],

    // ── Vytriangulované neznáme body ────────────────────────────
    CircleLayer(
      circles: [
        for (final g in sightGroups)
          if (g.fix != null)
            CircleMarker(
              point: g.fix!.position,
              radius: g.fix!.errorRadiusMeters,
              useRadiusInMeter: true,
              color: kSightObjectColor.withValues(alpha: 0.10),
              borderColor: kSightObjectColor.withValues(alpha: 0.7),
              borderStrokeWidth: 1.5,
            ),
      ],
    ),
    MarkerLayer(
      markers: [
        for (final g in sightGroups)
          if (g.fix != null)
            Marker(
              point: g.fix!.position,
              width: 180,
              height: 56,
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () => onTapSightGroup(g),
                behavior: HitTestBehavior.opaque,
                child: _FixMarker(
                  icon: Icons.push_pin,
                  colour: kSightObjectColor,
                  title: g.name.isEmpty ? l.bearingObjectFix : g.name,
                  detail: '±${g.fix!.errorRadiusMeters.round()} m',
                  extra: g.baselineTooShort
                      ? l.bearingShortBaselineHint
                      : null,
                ),
              ),
            ),
      ],
    ),
  ];
}

/// Kde priamka končí — vzdialený koniec, na ktorý sa vešia popisok.
LatLng _tipOf(BearingLine line, double lengthNm) =>
    BearingGeometry.destination(line.origin, line.trueBearing, lengthNm);

/// Body kužeľa: vrchol v začiatku priamky, oblúk na vzdialenom konci.
List<LatLng> _conePoints(BearingLine line, double lengthNm) {
  final points = <LatLng>[line.origin];
  final from = line.trueBearing - line.uncertaintyDeg;
  final span = line.uncertaintyDeg * 2;
  for (var i = 0; i <= _arcSegments; i++) {
    points.add(BearingGeometry.destination(
        line.origin, from + span * i / _arcSegments, lengthNm));
  }
  return points;
}

String _degrees(double value) =>
    '${(value.round() % 360).toString().padLeft(3, '0')}°';

String _metres(LatLng a, LatLng b) =>
    '${const Distance().distance(a, b).round()} m';

class _DrawnBearing {
  final Bearing row;
  final BearingKind kind;
  final BearingLine line;
  const _DrawnBearing(
      {required this.row, required this.kind, required this.line});
}

class _BearingTip extends StatelessWidget {
  final Bearing bearing;
  final BearingKind kind;
  final VoidCallback onTap;
  const _BearingTip(
      {required this.bearing, required this.kind, required this.onTap});

  @override
  Widget build(BuildContext context) {
    // Pri resekcii má názov zameraného bodu prednosť pred voľnou poznámkou:
    // to, ČO sa zameriavalo, je pri hľadaní vlastnej polohy podstatné.
    final name = kind == BearingKind.resection
        ? (bearing.targetName ?? bearing.label)
        : bearing.label;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
              kind == BearingKind.resection
                  ? Icons.arrow_drop_down
                  : Icons.arrow_drop_up,
              color: kBearingColor,
              size: 20,
              shadows: const [Shadow(color: Colors.white, blurRadius: 3)]),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              // Vždy NAMERANÝ kurz — nikdy nie ten, ktorým sa čiara kreslí.
              name == null || name.isEmpty
                  ? _degrees(bearing.trueBearing)
                  : '${_degrees(bearing.trueBearing)} · $name',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  color: kBearingColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class _FixMarker extends StatelessWidget {
  final IconData icon;
  final Color colour;
  final String title;
  final String detail;
  final String? extra;

  const _FixMarker({
    required this.icon,
    required this.colour,
    required this.title,
    required this.detail,
    this.extra,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: colour, size: 24, shadows: const [
          Shadow(color: Colors.white, blurRadius: 4),
        ]),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$title $detail',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: colour,
                    fontSize: 10,
                    fontWeight: FontWeight.bold),
              ),
              if (extra != null)
                Text(
                  extra!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 9),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
