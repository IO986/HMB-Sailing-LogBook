import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/tide_data.dart';
import '../../../../core/providers/tide_settings_provider.dart';
import '../../../../core/services/tide_repository.dart';
import '../../../../core/services/tide_service.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';

final tideForecastProvider = FutureProvider<List<TidePoint>>((ref) async {
  return TideService().getForecast();
});

/// Karta prílivu/odlivu vo Weather tabe — online fetch (WorldTides), lokálny
/// cache, offline zobrazenie z cache. Rovnaký vzor ako počasie
/// ([WeatherRepository]/[WeatherService]).
class TideCard extends ConsumerStatefulWidget {
  final double? lat;
  final double? lon;
  const TideCard({super.key, required this.lat, required this.lon});

  @override
  ConsumerState<TideCard> createState() => _TideCardState();
}

class _TideCardState extends ConsumerState<TideCard> {
  bool _downloading = false;

  Future<void> _download(String apiKey) async {
    if (widget.lat == null || widget.lon == null) return;
    setState(() => _downloading = true);
    try {
      await TideRepository().syncTides(
        lat: widget.lat!, lon: widget.lon!, apiKey: apiKey,
      );
      ref.invalidate(tideForecastProvider);
    } catch (_) {
      // Best effort — chyba (chýbajúci/zlý kľúč, offline) sa jednoducho
      // prejaví ako prázdny stav karty nižšie.
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final apiKey = ref.watch(tideApiKeyProvider).valueOrNull;
    final forecastAsync = ref.watch(tideForecastProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.waves, size: 18, color: Colors.blue),
              const SizedBox(width: 6),
              Text(l.tideCardTitle,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const Spacer(),
              if (apiKey != null && apiKey.isNotEmpty)
                IconButton(
                  icon: _downloading
                      ? const SizedBox(
                          width: 16, height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.refresh, size: 20),
                  onPressed: _downloading ? null : () => _download(apiKey),
                ),
            ]),
            if (apiKey == null || apiKey.isEmpty)
              _hint(context, l.noTideApiKey, onTap: () => context.push('/settings'))
            else
              forecastAsync.when(
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (_, __) => _hint(context, l.noTideData),
                data: (points) => points.isEmpty
                    ? _hint(context, l.noTideData,
                        actionLabel: l.downloadTides,
                        onTap: () => _download(apiKey))
                    : _TideBody(points: points),
              ),
          ],
        ),
      ),
    );
  }

  Widget _hint(BuildContext context, String text,
      {String? actionLabel, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          if (actionLabel != null) ...[
            const SizedBox(height: 8),
            OutlinedButton(onPressed: onTap, child: Text(actionLabel)),
          ] else if (onTap != null)
            TextButton(onPressed: onTap, child: Text(AppLocalizations.of(context).settingsTitle)),
        ],
      ),
    );
  }
}

class _TideBody extends StatelessWidget {
  final List<TidePoint> points;
  const _TideBody({required this.points});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final timeFmt = DateFormat.Hm();
    final now = DateTime.now().toUtc();
    final extremes = points.where((p) => p.extremeType != null && p.time.isAfter(now)).toList()
      ..sort((a, b) => a.time.compareTo(b.time));
    final nextHigh = extremes.where((p) => p.isHigh).firstOrNull;
    final nextLow = extremes.where((p) => p.isLow).firstOrNull;
    final curve = points.where((p) => p.extremeType == null).toList()
      ..sort((a, b) => a.time.compareTo(b.time));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(children: [
          if (nextHigh != null)
            Expanded(
              child: _Extreme(
                icon: Icons.arrow_upward, color: Colors.green,
                label: l.nextHighTideLabel,
                time: timeFmt.format(nextHigh.time.toLocal()),
                height: nextHigh.heightM,
              ),
            ),
          if (nextLow != null)
            Expanded(
              child: _Extreme(
                icon: Icons.arrow_downward, color: Colors.orange,
                label: l.nextLowTideLabel,
                time: timeFmt.format(nextLow.time.toLocal()),
                height: nextLow.heightM,
              ),
            ),
        ]),
        if (curve.length > 1) ...[
          const SizedBox(height: 12),
          SizedBox(
            height: 80,
            child: LineChart(LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: const FlTitlesData(show: false),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: curve
                      .asMap()
                      .entries
                      .map((e) => FlSpot(e.key.toDouble(), e.value.heightM))
                      .toList(),
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 2,
                  dotData: const FlDotData(show: false),
                  belowBarData:
                      BarAreaData(show: true, color: Colors.blue.withValues(alpha: 0.1)),
                ),
              ],
            )),
          ),
        ],
      ],
    );
  }
}

class _Extreme extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label, time;
  final double height;
  const _Extreme({
    required this.icon, required this.color,
    required this.label, required this.time, required this.height,
  });

  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$time  ${height.toStringAsFixed(2)}m',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ]);
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
