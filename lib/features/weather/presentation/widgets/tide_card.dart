import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/models/tide_data.dart';
import '../../../../core/services/geocoding_service.dart';
import '../../../../core/services/tide_repository.dart';
import '../../../../core/services/tide_service.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';

final tideForecastProvider = FutureProvider<TideForecast>((ref) async {
  return TideService().getForecast();
});

/// Karta prílivu/odlivu vo Weather tabe — online fetch (Open-Meteo Marine,
/// bez API kľúča), lokálny cache, offline zobrazenie z cache. Rovnaký vzor
/// ako počasie ([WeatherRepository]/[WeatherService]).
class TideCard extends ConsumerStatefulWidget {
  final double? lat;
  final double? lon;
  const TideCard({super.key, required this.lat, required this.lon});

  @override
  ConsumerState<TideCard> createState() => _TideCardState();
}

class _TideCardState extends ConsumerState<TideCard> {
  bool _downloading = false;
  TideSyncResult? _lastResult;

  Future<void> _download() async {
    if (widget.lat == null || widget.lon == null) return;
    await _run(lat: widget.lat!, lon: widget.lon!);
  }

  /// Predpoveď pre miesto, ktoré si používateľ vyhľadal — bez toho je
  /// funkcia nepoužiteľná kdekoľvek mimo pobrežia (plánovanie plavby z domu).
  Future<void> _downloadForOtherArea() async {
    final place = await showDialog<GeocodedPlace>(
      context: context,
      builder: (_) => const _AreaPickerDialog(),
    );
    if (place == null) return;
    await _run(
      lat: place.latitude,
      lon: place.longitude,
      label: place.name,
      manual: true,
    );
  }

  Future<void> _run({
    required double lat,
    required double lon,
    String? label,
    bool manual = false,
  }) async {
    setState(() => _downloading = true);

    final result = await TideRepository().syncTides(
      lat: lat,
      lon: lon,
      locationLabel: label,
      manualSelection: manual,
    );
    if (result == TideSyncResult.updated) ref.invalidate(tideForecastProvider);

    if (mounted) {
      setState(() {
        _downloading = false;
        _lastResult = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
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
              IconButton(
                icon: _downloading
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.refresh, size: 20),
                onPressed: _downloading ? null : _download,
              ),
            ]),
            forecastAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (_, __) => _hint(l.noTideData),
              data: (forecast) => _body(context, l, forecast),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(
      BuildContext context, AppLocalizations l, TideForecast forecast) {
    final now = DateTime.now();

    if (forecast.isEmpty || forecast.isExpiredAt(now)) {
      // Prázdna aj expirovaná keš vyzerajú pre používateľa rovnako — treba
      // stiahnuť. Dôvod posledného neúspechu ale rozlíšime.
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _hint(_emptyStateText(l, forecast, now),
              actionLabel: _downloading ? l.downloadingTides : l.downloadTides,
              onTap: _downloading ? null : _download),
          _otherAreaButton(l),
        ],
      );
    }

    // Pri ručne zvolenej oblasti je vzdialenosť zámerná — namiesto varovania
    // ukážeme, o ktoré miesto ide.
    final distanceKm = !forecast.manualSelection &&
            widget.lat != null &&
            widget.lon != null
        ? forecast.distanceKmFrom(widget.lat!, widget.lon!)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (forecast.manualSelection && forecast.locationLabel != null)
          _note(context, Icons.place_outlined,
              l.tideForecastForArea(forecast.locationLabel!)),
        _TideBody(forecast: forecast, now: now),
        const SizedBox(height: 10),
        // Bezpečnostné upozornenie: MSL nie je mapové datum, na hĺbku pod
        // kýlom sa tieto čísla použiť nesmú.
        _note(context, Icons.info_outline, l.tideMslWarning),
        if (distanceKm != null && distanceKm > 50)
          _note(context, Icons.location_off,
              l.tideForecastFarAway(distanceKm.round()), warn: true),
        if (forecast.downloadedAt != null &&
            now.difference(forecast.downloadedAt!).inHours >= 24)
          _note(context, Icons.schedule,
              l.tideForecastStale(
                  DateFormat.yMd().add_Hm().format(forecast.downloadedAt!)),
              warn: true),
        _otherAreaButton(l),
      ],
    );
  }

  Widget _otherAreaButton(AppLocalizations l) => Align(
        alignment: Alignment.centerLeft,
        child: TextButton.icon(
          onPressed: _downloading ? null : _downloadForOtherArea,
          icon: const Icon(Icons.travel_explore, size: 18),
          label: Text(l.tideOtherArea),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            visualDensity: VisualDensity.compact,
          ),
        ),
      );

  String _emptyStateText(
      AppLocalizations l, TideForecast forecast, DateTime now) {
    switch (_lastResult) {
      case TideSyncResult.noCoverage:
        return l.tideNoCoverage;
      case TideSyncResult.failed:
        return l.tideDownloadFailed;
      case TideSyncResult.updated:
      case null:
        return forecast.isEmpty ? l.noTideData : l.tideForecastExpired;
    }
  }

  Widget _note(BuildContext context, IconData icon, String text,
      {bool warn = false}) {
    final color = warn ? Colors.orange.shade800 : Colors.grey;
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Expanded(
            child: Text(text,
                style: TextStyle(fontSize: 11, color: color)),
          ),
        ],
      ),
    );
  }

  Widget _hint(String text, {String? actionLabel, VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(text, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          if (actionLabel != null) ...[
            const SizedBox(height: 8),
            OutlinedButton(onPressed: onTap, child: Text(actionLabel)),
          ],
        ],
      ),
    );
  }
}

/// Vyhľadá miesto cez Nominatim a vráti zvolené [GeocodedPlace].
class _AreaPickerDialog extends StatefulWidget {
  const _AreaPickerDialog();

  @override
  State<_AreaPickerDialog> createState() => _AreaPickerDialogState();
}

class _AreaPickerDialogState extends State<_AreaPickerDialog> {
  final _controller = TextEditingController();
  Timer? _debounce;
  List<GeocodedPlace> _results = const [];
  bool _searching = false;
  bool _searched = false;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    // Nominatim má limit na frekvenciu — nehľadáme po každom písmene.
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () => _search(value));
  }

  Future<void> _search(String query) async {
    if (query.trim().length < 2) {
      setState(() {
        _results = const [];
        _searched = false;
      });
      return;
    }
    setState(() => _searching = true);
    final results = await GeocodingService().searchPlaces(query);
    if (!mounted) return;
    setState(() {
      _results = results;
      _searching = false;
      _searched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l.tideOtherArea),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                labelText: l.tideAreaSearchLabel,
                hintText: l.tideAreaSearchHint,
                prefixIcon: const Icon(Icons.search),
                isDense: true,
              ),
              onChanged: _onChanged,
              onSubmitted: _search,
            ),
            const SizedBox(height: 12),
            if (_searching)
              const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(),
              )
            else if (_searched && _results.isEmpty)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(l.tideAreaNoResults,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _results.length,
                  itemBuilder: (context, i) {
                    final place = _results[i];
                    return ListTile(
                      dense: true,
                      leading: const Icon(Icons.place_outlined, size: 20),
                      title: Text(place.name,
                          style: const TextStyle(fontSize: 13)),
                      onTap: () => Navigator.of(context).pop(place),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l.cancel),
        ),
      ],
    );
  }
}

class _TideBody extends StatelessWidget {
  final TideForecast forecast;
  final DateTime now;
  const _TideBody({required this.forecast, required this.now});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final timeFmt = DateFormat.Hm();
    final nowUtc = now.toUtc();

    final extremes = forecast.points
        .where((p) => p.extremeType != null && p.time.isAfter(nowUtc))
        .toList()
      ..sort((a, b) => a.time.compareTo(b.time));
    final nextHigh = extremes.where((p) => p.isHigh).firstOrNull;
    final nextLow = extremes.where((p) => p.isLow).firstOrNull;

    // Krivku orežeme na okno okolo teraz — celé 7-dňové okno je v 80 px
    // grafe nečitateľné.
    final windowStart = nowUtc.subtract(const Duration(hours: 6));
    final windowEnd = nowUtc.add(const Duration(hours: 18));
    final curve = forecast.points
        .where((p) =>
            p.extremeType == null &&
            p.time.isAfter(windowStart) &&
            p.time.isBefore(windowEnd))
        .toList()
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
            child: LineChart(_chartData(curve, nowUtc)),
          ),
        ],
      ],
    );
  }

  LineChartData _chartData(List<TidePoint> curve, DateTime nowUtc) {
    // X os je čas v minútach od prvého bodu, nie index poľa — inak by
    // prípadná medzera vo vzorkách krivku ticho pokrivila.
    double x(TidePoint p) =>
        p.time.difference(curve.first.time).inMinutes.toDouble();

    return LineChartData(
      gridData: const FlGridData(show: false),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineTouchData: const LineTouchData(enabled: false),
      extraLinesData: ExtraLinesData(
        verticalLines: [
          if (nowUtc.isAfter(curve.first.time) &&
              nowUtc.isBefore(curve.last.time))
            VerticalLine(
              x: nowUtc.difference(curve.first.time).inMinutes.toDouble(),
              color: Colors.red.withValues(alpha: 0.6),
              strokeWidth: 1.5,
              dashArray: [3, 3],
            ),
        ],
      ),
      lineBarsData: [
        LineChartBarData(
          spots: [for (final p in curve) FlSpot(x(p), p.heightM)],
          isCurved: true,
          color: Colors.blue,
          barWidth: 2,
          dotData: const FlDotData(show: false),
          belowBarData:
              BarAreaData(show: true, color: Colors.blue.withValues(alpha: 0.1)),
        ),
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
