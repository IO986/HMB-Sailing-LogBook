import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';

import '../../../../core/database/app_database.dart';
import '../../../../core/services/geocoding_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/meteoalarm_service.dart';
import '../../../../core/utils/localized_date.dart';
import '../../../../main.dart';

/// Platné výstrahy pre krajinu, v ktorej loď je.
///
/// Krajina sa zisťuje z polohy, nie z nastavenia jazyka: kto pláva chorvátske
/// vody so slovenským telefónom, potrebuje chorvátske výstrahy.
final weatherWarningsProvider =
    FutureProvider<List<WeatherWarning>>((ref) async {
  final db = ref.watch(databaseProvider);
  final pos = LocationService().lastPosition;

  if (pos != null) {
    final cc = await GeocodingService().countryCode(pos.latitude, pos.longitude);
    // Sieť nie je podmienka: keď nejde, ostane posledná keš v databáze.
    if (cc != null) await MeteoAlarmService().sync(cc);
  }

  return db.getActiveWeatherWarnings(DateTime.now().toUtc());
});

/// Úradné výstrahy pred nebezpečným počasím.
///
/// Stojí navrchu tabu zámerne. Je to jediná vec na tejto obrazovke, ktorú
/// nevypočítal model, ale rozhodol o nej človek v národnej meteorologickej
/// službe — a jediná, kvôli ktorej sa niekedy neplaví.
class WarningsCard extends ConsumerWidget {
  const WarningsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final warnings = ref.watch(weatherWarningsProvider).valueOrNull;
    // Žiadne výstrahy = žiadna karta. Prázdny rámik s nápisom „nič sa nedeje"
    // by len odsúval nadol to, čo naozaj treba čítať.
    if (warnings == null || warnings.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        for (final w in warnings) _WarningTile(warning: w),
      ],
    );
  }
}

class _WarningTile extends ConsumerStatefulWidget {
  const _WarningTile({required this.warning});

  final WeatherWarning warning;

  @override
  ConsumerState<_WarningTile> createState() => _WarningTileState();
}

class _WarningTileState extends ConsumerState<_WarningTile> {
  bool _loadingDetail = false;

  /// Farby stupnice MeteoAlarm. Tie isté, aké má výstraha na stránke národnej
  /// služby — kto ich odtiaľ pozná, nemusí sa učiť nové.
  static Color _color(int level) => switch (level) {
        4 => const Color(0xFFD32F2F),
        3 => const Color(0xFFF57C00),
        2 => const Color(0xFFFBC02D),
        _ => const Color(0xFF388E3C),
      };

  Future<void> _loadDetail() async {
    if (widget.warning.description != null || _loadingDetail) return;
    setState(() => _loadingDetail = true);
    final lang = Localizations.localeOf(context).languageCode;
    await MeteoAlarmService().fetchDetail(widget.warning, lang);
    if (!mounted) return;
    setState(() => _loadingDetail = false);
    ref.invalidate(weatherWarningsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final w = widget.warning;
    final colour = _color(w.awarenessLevel);
    final date = AppDate.of(context, ref);
    final appLanguage = Localizations.localeOf(context).languageCode;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colour, width: 2),
      ),
      child: ExpansionTile(
        onExpansionChanged: (open) {
          if (open) _loadDetail();
        },
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Icon(Icons.warning_amber_rounded, color: colour),
        title: Text(w.event,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(
          '${w.areaDesc}\n'
          '${date.shortWithTime(w.onset.toLocal())} – '
          '${date.shortWithTime(w.expires.toLocal())}',
          style: const TextStyle(fontSize: 12),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_loadingDetail)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            if (w.description != null) Text(w.description!),
            if (w.instruction != null) ...[
              const SizedBox(height: 8),
              Text(w.instruction!,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
            if (w.description == null && !_loadingDetail)
              Text(l.warningNoDetail,
                  style: TextStyle(
                      fontSize: 12, color: Theme.of(context).hintColor)),
            const SizedBox(height: 10),
            // Vydavateľ sa menuje vždy — je to podmienka používania feedu a
            // zároveň to, čo výstrahe dáva váhu: nie je to model, je to úrad.
            Text(
              w.sender == null
                  ? l.warningSourceMeteoalarm
                  : '${l.warningSourceMeteoalarm} · ${w.sender}',
              style:
                  TextStyle(fontSize: 11, color: Theme.of(context).hintColor),
            ),
            // Keď text nie je v jazyku appky, povie sa to. Tvrdiť opak by
            // znamenalo nechať človeka hádať, či rozumie tomu, čo číta.
            if (w.language != null &&
                !w.language!.toLowerCase().startsWith(appLanguage))
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  l.warningLanguageNote(w.language!.split('-').first),
                  style: TextStyle(
                      fontSize: 11, color: Theme.of(context).hintColor),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
