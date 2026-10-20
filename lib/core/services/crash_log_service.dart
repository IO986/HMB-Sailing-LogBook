import 'dart:io';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Zachytáva neošetrené chyby do súboru na disku, keďže appka nemá
/// Crashlytics/Sentry a Play Vitals dáta z jedného zariadenia väčšinou
/// vôbec nezobrazí. Súbor cestuje von cez `.hmbbackup` (viď BackupService),
/// takže sa dá získať aj od používateľa na mori bez adb/logcat.
class CrashLogService {
  static final CrashLogService _i = CrashLogService._();
  factory CrashLogService() => _i;
  CrashLogService._();

  static const fileName = 'crash_log.txt';

  /// 200 posledných záznamov stačí na diagnostiku a súbor neprerastie.
  static const _maxEntries = 200;

  /// Hlavička záznamu vždy začína na začiatku riadku dátumom — podľa toho sa
  /// súbor delí na záznamy. Delenie podľa samotného `'--- '` trhalo záznamy,
  /// ktorých text tú postupnosť obsahoval.
  static final _entryStart = RegExp(r'^(?=--- \d{4}-)', multiLine: true);

  /// Zápisy idú jeden po druhom. Súbor sa číta, dopĺňa a prepisuje celý,
  /// takže dva súbežné zápisy (napr. dávka chýb dlaždíc v tej istej
  /// milisekunde) si ho navzájom prepisovali a v logu ostávali úlomky.
  Future<void> _queue = Future.value();

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, fileName));
  }

  Future<void> logError(Object error, StackTrace stack, {String? context}) =>
      _append(context, '$error\n$stack');

  /// Diagnostická udalosť bez výnimky — napr. diera v trase počas plavby.
  /// Ide do toho istého súboru, aby cestovala von v zálohe spolu s chybami.
  Future<void> logEvent(String message, {String context = 'event'}) =>
      _append(context, message);

  Future<void> _append(String? context, String body) {
    final at = DateTime.now();
    return _queue = _queue.then((_) => _write(at, context, body));
  }

  Future<void> _write(DateTime at, String? context, String body) async {
    try {
      final info = await PackageInfo.fromPlatform();
      final entry = StringBuffer()
        ..writeln('--- ${at.toIso8601String()} '
            '(v${info.version}+${info.buildNumber})'
            '${context != null ? ' [$context]' : ''} ---')
        ..writeln(body.trimRight())
        ..writeln();

      final file = await _file();
      final existing = await file.exists() ? await file.readAsString() : '';
      final entries = existing.isEmpty
          ? <String>[]
          : existing.split(_entryStart).where((s) => s.isNotEmpty).toList();
      entries.add(entry.toString());
      final trimmed = entries.length > _maxEntries
          ? entries.sublist(entries.length - _maxEntries)
          : entries;
      await file.writeAsString(trimmed.join());
    } catch (_) {
      // Logovanie chyby nesmie samo spôsobiť ďalšiu neošetrenú výnimku.
    }
  }
}
