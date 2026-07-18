import '../models/tide_data.dart';

/// Nájde vysoké a nízke vody v hodinovej krivke hladiny.
///
/// Open-Meteo (na rozdiel od platených tide API) extrémy nedáva, len krivku.
/// Tu ich preto hľadáme lokálne. Nie je to extrapolácia harmonickým modelom —
/// tá zlyhala pri skoršom pokuse — ale obyčajné hľadanie vrcholu v už
/// stiahnutých dátach, takže presnosť závisí len od hustoty vzoriek.
///
/// Surové hodinové vzorky by posunuli čas špičky až o ±30 min. Vrchol preto
/// spresňujeme parabolou preloženou cez tri body okolo neho, čím sa chyba
/// dostane pod ~5 min pri bežnej polodennej perióde (~12,4 h).
///
/// Krajné body krivky sa ignorujú — pri nich chýba sused na jednej strane,
/// takže sa vrchol nedá potvrdiť ani spresniť.
List<TidePoint> findTideExtremes(List<TidePoint> curve) {
  if (curve.length < 3) return const [];

  final sorted = [...curve]..sort((a, b) => a.time.compareTo(b.time));
  final extremes = <TidePoint>[];

  for (var i = 1; i < sorted.length - 1; i++) {
    final prev = sorted[i - 1].heightM;
    final curr = sorted[i].heightM;
    final next = sorted[i + 1].heightM;

    final isHigh = curr > prev && curr >= next;
    final isLow = curr < prev && curr <= next;
    if (!isHigh && !isLow) continue;

    final refined = _refineVertex(
      time: sorted[i].time,
      prev: prev,
      curr: curr,
      next: next,
      // Krok vzorkovania beriem z reálnych susedov, nie z predpokladaných
      // 60 minút, aby to prežilo prípadnú zmenu hustoty dát.
      stepBefore: sorted[i].time.difference(sorted[i - 1].time),
      stepAfter: sorted[i + 1].time.difference(sorted[i].time),
    );

    extremes.add(
      TidePoint(
        time: refined.time,
        heightM: refined.heightM,
        extremeType: isHigh ? 'high' : 'low',
      ),
    );
  }

  return extremes;
}

class _Vertex {
  final DateTime time;
  final double heightM;
  const _Vertex(this.time, this.heightM);
}

/// Vrchol paraboly cez tri rovnomerne vzdialené body.
///
/// Pre body v x = -1, 0, 1 leží vrchol v
///   δ = ½·(prev − next) / (prev − 2·curr + next)
/// a jeho hodnota je curr − ¼·(prev − next)·δ. δ vždy padne do ⟨−½, ½⟩,
/// takže spresnený čas nikdy neopustí okolie pôvodnej vzorky.
_Vertex _refineVertex({
  required DateTime time,
  required double prev,
  required double curr,
  required double next,
  required Duration stepBefore,
  required Duration stepAfter,
}) {
  final denominator = prev - 2 * curr + next;

  // Rovná plošina (denominator ≈ 0) nemá vrchol — necháme pôvodnú vzorku.
  if (denominator.abs() < 1e-9) return _Vertex(time, curr);

  final delta = 0.5 * (prev - next) / denominator;
  if (delta.isNaN || delta.abs() > 0.5) return _Vertex(time, curr);

  // Nerovnomerné vzorkovanie: posun škálujeme krokom na tej strane, kam
  // vrchol padol.
  final step = delta.isNegative ? stepBefore : stepAfter;
  final shift = Duration(
    microseconds: (delta.abs() * step.inMicroseconds).round(),
  );

  return _Vertex(
    delta.isNegative ? time.subtract(shift) : time.add(shift),
    curr - 0.25 * (prev - next) * delta,
  );
}
