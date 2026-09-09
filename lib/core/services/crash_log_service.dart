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

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File(p.join(dir.path, fileName));
  }

  Future<void> logError(Object error, StackTrace stack, {String? context}) async {
    try {
      final info = await PackageInfo.fromPlatform();
      final entry = StringBuffer()
        ..writeln('--- ${DateTime.now().toIso8601String()} '
            '(v${info.version}+${info.buildNumber})'
            '${context != null ? ' [$context]' : ''} ---')
        ..writeln(error.toString())
        ..writeln(stack.toString());

      final file = await _file();
      final existing = await file.exists() ? await file.readAsString() : '';
      final entries = existing.isEmpty
          ? <String>[]
          : existing.split('--- ').where((s) => s.isNotEmpty).map((s) => '--- $s').toList();
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
