import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../main.dart';
import '../services/track_playback.dart';
import 'map_provider.dart';

/// Body trasy, po ktorej sa práve dá prehrávať — podľa toho, či je zapnutá
/// prehliadka jedného dňa alebo celej plavby.
///
/// Prázdny zoznam znamená, že prehliadka nebeží a panel sa nemá zobraziť.
final playbackTrackProvider = Provider<List<TrackPoint>>((ref) {
  final map = ref.watch(mapNotifierProvider);
  final dayId = map.previewDayLogId;
  if (dayId != null) {
    return ref.watch(dayTrackPointsProvider(dayId)).valueOrNull ??
        const <TrackPoint>[];
  }
  final charterId = map.previewCharterId;
  if (charterId != null) {
    return ref.watch(charterTrackPointsProvider(charterId)).valueOrNull ??
        const <TrackPoint>[];
  }
  return const <TrackPoint>[];
});

/// Záznamy denníka prehliadaného dňa — na značky udalostí na časovej osi
/// a na odčítanie počasia v zvolenom okamihu.
final playbackEntriesProvider =
    FutureProvider<List<LogbookEntry>>((ref) async {
  final map = ref.watch(mapNotifierProvider);
  final db = ref.watch(databaseProvider);

  final dayId = map.previewDayLogId;
  if (dayId != null) return db.getEntriesForDay(dayId);

  final charterId = map.previewCharterId;
  if (charterId == null) return const [];
  final out = <LogbookEntry>[];
  for (final day in await db.getDayLogs(charterId)) {
    out.addAll(await db.getEntriesForDay(day.id));
  }
  out.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  return out;
});

class PlaybackState {
  const PlaybackState({
    this.time,
    this.playing = false,
    this.speed = 60,
  });

  /// Zvolený okamih. `null` znamená "prehrávanie sa ešte nespustilo".
  final DateTime? time;
  final bool playing;

  /// Koľkokrát rýchlejšie než v skutočnosti. Osemhodinová plavba pri 60×
  /// prebehne za osem minút.
  final int speed;

  PlaybackState copyWith({DateTime? time, bool? playing, int? speed}) =>
      PlaybackState(
        time: time ?? this.time,
        playing: playing ?? this.playing,
        speed: speed ?? this.speed,
      );
}

/// Beh času v prehrávaní.
///
/// Časovač tiká len počas prehrávania a ruší sa pri pauze, na konci trasy aj
/// pri zrušení providera. Pozastavené prehrávanie nesmie nič prekresľovať —
/// mapa je obrazovka, kde appka aj tak drží GPS na plnej presnosti, a nechať
/// tu bežať časovač navyše by bolo presne to, čo sme z appky vyhadzovali.
class PlaybackNotifier extends Notifier<PlaybackState> {
  Timer? _timer;

  /// Ako často sa posunie značka. 10 snímok za sekundu stačí na plynulý dojem
  /// a je to desatina toho, čo by stála plná obnovovacia frekvencia.
  static const _tick = Duration(milliseconds: 100);

  @override
  PlaybackState build() {
    ref.onDispose(_stopTimer);
    // Zmena prehliadanej plavby zhodí prehrávanie — inak by posuvník ostal
    // stáť na čase, ktorý v novej trase nič neznamená.
    ref.listen(mapNotifierProvider, (prev, next) {
      if (prev?.previewDayLogId != next.previewDayLogId ||
          prev?.previewCharterId != next.previewCharterId) {
        _stopTimer();
        state = const PlaybackState();
      }
    });
    return const PlaybackState();
  }

  TrackPlayback get _track => TrackPlayback(ref.read(playbackTrackProvider));

  void seek(DateTime t) {
    _stopTimer();
    state = state.copyWith(time: t, playing: false);
  }

  void setSpeed(int speed) {
    state = state.copyWith(speed: speed);
    if (state.playing) _restartTimer();
  }

  void togglePlay() => state.playing ? pause() : play();

  void play() {
    final track = _track;
    final start = track.start;
    final end = track.end;
    if (start == null || end == null) return;

    // Spustenie na konci prehrá plavbu znova od začiatku.
    final from = state.time == null || !state.time!.isBefore(end)
        ? start
        : state.time!;
    state = state.copyWith(time: from, playing: true);
    _restartTimer();
  }

  void pause() {
    _stopTimer();
    state = state.copyWith(playing: false);
  }

  void _restartTimer() {
    _stopTimer();
    _timer = Timer.periodic(_tick, (_) {
      final track = _track;
      final end = track.end;
      final current = state.time;
      if (end == null || current == null) {
        pause();
        return;
      }
      final next = current.add(_tick * state.speed);
      if (!next.isBefore(end)) {
        _stopTimer();
        state = state.copyWith(time: end, playing: false);
        return;
      }
      state = state.copyWith(time: next);
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }
}

final playbackProvider =
    NotifierProvider<PlaybackNotifier, PlaybackState>(PlaybackNotifier.new);
