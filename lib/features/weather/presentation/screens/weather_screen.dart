import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:intl/intl.dart';
import '../../../../core/models/weather_data.dart';
import 'package:dio/dio.dart' as dio;
import '../../../../core/services/gps_tracking_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/weather_repository.dart';
import '../../../../core/services/weather_service.dart';
import '../../../../core/services/raymarine_connection_service.dart';
import '../../../../core/providers/raymarine_providers.dart';
import '../../../../core/models/marine_instrument_data.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';

// Reverse geocoding + fallback na súradnice
final _locationNameProvider = FutureProvider<String?>((ref) async {
  final pos = GpsTrackingService().lastPosition;
  if (pos == null) return null;

  final lat = pos.latitude;
  final lon = pos.longitude;
  final coordStr = '${lat.toStringAsFixed(4)}°N, ${lon.toStringAsFixed(4)}°E';

  try {
    final response = await dio.Dio().get(
      'https://nominatim.openstreetmap.org/reverse',
      queryParameters: {
        'lat': lat.toString(),
        'lon': lon.toString(),
        'format': 'json',
        'zoom': '10',
      },
      options: dio.Options(
        headers: {'User-Agent': 'HMBSailingLog/1.0'},
        sendTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 5),
      ),
    );
    final data = response.data as Map<String, dynamic>;
    final address = data['address'] as Map<String, dynamic>?;
    final name = address?['city'] ?? address?['town'] ??
                 address?['village'] ?? address?['county'] ??
                 address?['state'];
    return name != null ? '$name ($coordStr)' : coordStr;
  } catch (_) {
    return coordStr; // Fallback na GPS súradnice
  }
});

final weatherProvider = FutureProvider<List<WeatherData>>((ref) async {
  return WeatherService().getForecast();
});

class WeatherScreen extends ConsumerWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weatherAsync = ref.watch(weatherProvider);

    final locationName = ref.watch(_locationNameProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context).weatherTitle),
            if (locationName != null)
              Text(locationName,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: AppLocalizations.of(context).updateForecast,
            onPressed: () async {
              final l = AppLocalizations.of(context);
              final pos = GpsTrackingService().lastPosition ?? LocationService().lastPosition;
              if (pos == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l.gpsNotAvailableTracking)),
                );
                return;
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l.downloadingForecast),
                  duration: const Duration(seconds: 2),
                ),
              );
              try {
                await WeatherRepository().syncWeather(
                  lat: pos.latitude,
                  lon: pos.longitude,
                );
                ref.invalidate(weatherProvider);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(AppLocalizations.of(context).downloadError(e.toString()))),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: weatherAsync.when(
        data: (forecast) {
          if (forecast.isEmpty) {
            return _EmptyWeather();
          }
          return _WeatherContent(forecast: forecast);
        },
        loading: () => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(AppLocalizations.of(context).loadingForecast),
            ],
          ),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              Text(AppLocalizations.of(context).noConnection),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context).pressRefreshWhenOnline,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyWeather extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_download_outlined,
                size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(AppLocalizations.of(context).noWeatherData,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(color: Colors.grey)),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(context).forecastAutoDownload,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final l = AppLocalizations.of(context);
                final pos = GpsTrackingService().lastPosition ?? LocationService().lastPosition;
                if (pos == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l.enableGpsFirst)),
                  );
                  return;
                }
                try {
                  await WeatherRepository().syncWeather(
                    lat: pos.latitude,
                    lon: pos.longitude,
                  );
                  ref.invalidate(weatherProvider);
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(AppLocalizations.of(context).downloadError(e.toString()))),
                    );
                  }
                }
              },
              icon: const Icon(Icons.refresh),
              label: Text(AppLocalizations.of(context).downloadForecast),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeatherContent extends ConsumerWidget {
  final List<WeatherData> forecast;
  const _WeatherContent({required this.forecast});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (forecast.isEmpty) return const SizedBox();
    final current = forecast.first;

    final connState = ref.watch(raymarineConnectionStateProvider)
            .valueOrNull ??
        RaymarineConnectionState.disconnected;
    final marineData = ref.watch(marineDataProvider).valueOrNull;
    final showLive = connState == RaymarineConnectionState.connected &&
        marineData != null &&
        RaymarineConnectionService().hasFreshData;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (showLive) ...[
          _LiveInstrumentsCard(data: marineData!),
          const SizedBox(height: 12),
        ],
        _CurrentWeatherCard(weather: current),
        const SizedBox(height: 12),
        _BeaufortCard(beaufort: current.beaufort),
        const SizedBox(height: 12),
        _WindChart(forecast: forecast),
        const SizedBox(height: 12),
        _WaveChart(forecast: forecast),
        const SizedBox(height: 12),
        _DailyTempCard(forecast: forecast),
        const SizedBox(height: 12),
        _HourlyTable(forecast: forecast),
      ],
    );
  }
}

class _LiveInstrumentsCard extends StatelessWidget {
  final MarineInstrumentData data;
  const _LiveInstrumentsCard({required this.data});

  String _windDirLabel(double deg) {
    const dirs = ['N','NNE','NE','ENE','E','ESE','SE','SSE','S','SSW','SW','WSW','W','WNW','NW','NNW'];
    return dirs[((deg / 22.5) + 0.5).toInt() % 16];
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.sensors, size: 18, color: Colors.green),
              const SizedBox(width: 6),
              Text(AppLocalizations.of(context).liveInstrumentData,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 12),
            Wrap(
              spacing: 20,
              runSpacing: 12,
              children: [
                if (data.hasWind)
                  _Metric(
                    data.windIsApparent
                        ? AppLocalizations.of(context).windRelative
                        : AppLocalizations.of(context).windTrue,
                    '${data.windSpeedKnots!.toStringAsFixed(0)} kn ${_windDirLabel(data.windAngleDegrees!)}',
                    Icons.air,
                  ),
                if (data.hasDepth)
                  _Metric(AppLocalizations.of(context).depthLabel,
                      '${data.depthMeters!.toStringAsFixed(1)} m', Icons.waves),
                if (data.waterTempCelsius != null)
                  _Metric(AppLocalizations.of(context).waterTempLabel,
                      '${data.waterTempCelsius!.toStringAsFixed(1)}°C', Icons.water),
                if (data.headingDegrees != null)
                  _Metric(
                    data.headingIsTrue
                        ? AppLocalizations.of(context).courseTrue
                        : AppLocalizations.of(context).courseMag,
                    '${data.headingDegrees!.toStringAsFixed(0)}°',
                    Icons.explore,
                  ),
                if (data.engineRpm != null)
                  _Metric(AppLocalizations.of(context).engineLabel,
                      '${data.engineRpm!.toStringAsFixed(0)} rpm', Icons.settings),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CurrentWeatherCard extends StatelessWidget {
  final WeatherData weather;
  const _CurrentWeatherCard({required this.weather});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Text('${weather.windSpeed.toStringAsFixed(0)} kn',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary)),
              const SizedBox(width: 8),
              Text('${weather.windDirectionLabel} ${weather.windDirection.toStringAsFixed(0)}°',
                  style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              const Icon(Icons.air, size: 32),
            ]),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _Metric(AppLocalizations.of(context).wavesLabel, '${weather.waveHeight.toStringAsFixed(1)} m', Icons.waves),
                _Metric(AppLocalizations.of(context).pressureLabel, '${weather.airPressure.toStringAsFixed(0)} hPa', Icons.compress),
                _Metric(AppLocalizations.of(context).airTempLabel, '${weather.airTemp.toStringAsFixed(0)}°C', Icons.thermostat),
                _Metric(AppLocalizations.of(context).waterLabel, '${weather.waterTemp.toStringAsFixed(0)}°C', Icons.water),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _Metric(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) => Column(children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ]);
}

class _BeaufortCard extends StatelessWidget {
  final int beaufort;
  const _BeaufortCard({required this.beaufort});

  Color get _color {
    if (beaufort <= 3) return Colors.green;
    if (beaufort <= 5) return Colors.orange;
    if (beaufort <= 7) return Colors.deepOrange;
    return Colors.red;
  }

  String _desc(AppLocalizations l) {
    const keys = [0,1,2,3,4,5,6,7,8,9,10,11,12];
    final descs = [
      l.beaufort0, l.beaufort1, l.beaufort2, l.beaufort3, l.beaufort4,
      l.beaufort5, l.beaufort6, l.beaufort7, l.beaufort8, l.beaufort9,
      l.beaufort10, l.beaufort11, l.beaufort12,
    ];
    return beaufort < keys.length ? descs[beaufort] : '';
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Card(
      color: _color.withOpacity(0.1),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _color,
          child: Text('$beaufort',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        title: Text('Beaufort $beaufort'),
        subtitle: Text(_desc(l)),
        trailing: Icon(Icons.flag, color: _color),
      ),
    );
  }
}

class _WindChart extends StatelessWidget {
  final List<WeatherData> forecast;
  const _WindChart({required this.forecast});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context).wind24h,
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 16),
              SizedBox(
                height: 150,
                child: LineChart(LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            getTitlesWidget: (v, _) => Text('${v.toInt()}',
                                style: const TextStyle(fontSize: 10)))),
                    bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                            showTitles: true,
                            interval: 12,
                            getTitlesWidget: (v, _) {
                              final i = v.toInt();
                              if (i >= forecast.length) return const SizedBox();
                              final t = forecast[i].time;
                              return Text('${t.day}/${t.month}\n${t.hour}h',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 9));
                            })),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: forecast
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value.windSpeed))
                          .toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                          show: true, color: Colors.blue.withOpacity(0.1)),
                    ),
                  ],
                )),
              ),
            ],
          ),
        ),
      );
}

class _WaveChart extends StatelessWidget {
  final List<WeatherData> forecast;
  const _WaveChart({required this.forecast});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(AppLocalizations.of(context).waves24h,
                  style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 16),
              SizedBox(
                height: 120,
                child: LineChart(LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 32,
                            getTitlesWidget: (v, _) =>
                                Text('${v.toStringAsFixed(1)}m',
                                    style: const TextStyle(fontSize: 9)))),
                    bottomTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: forecast
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(), e.value.waveHeight))
                          .toList(),
                      isCurved: true,
                      color: Colors.teal,
                      barWidth: 2,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                          show: true, color: Colors.teal.withOpacity(0.1)),
                    ),
                  ],
                )),
              ),
            ],
          ),
        ),
      );
}

class _DailyTempCard extends StatelessWidget {
  final List<WeatherData> forecast;
  const _DailyTempCard({required this.forecast});

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    final dayFmt = DateFormat('EEE\nd.M.', locale);

    // Group by calendar day, compute min/max temp and dominant rain probability
    final Map<String, List<WeatherData>> byDay = {};
    for (final w in forecast) {
      final key = '${w.time.year}-${w.time.month}-${w.time.day}';
      (byDay[key] ??= []).add(w);
    }

    final days = byDay.entries.toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppLocalizations.of(context).dailyForecast,
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: days.map((entry) {
                final samples = entry.value;
                final date = samples.first.time;
                final maxT = samples.map((w) => w.airTemp).reduce((a, b) => a > b ? a : b);
                final minT = samples.map((w) => w.airTemp).reduce((a, b) => a < b ? a : b);
                // Night hours (21–06): use entries in that range for night temp
                final nightSamples = samples.where((w) => w.time.hour >= 21 || w.time.hour < 6).toList();
                final nightT = nightSamples.isNotEmpty
                    ? nightSamples.map((w) => w.airTemp).reduce((a, b) => a < b ? a : b)
                    : minT;
                // Max rain probability for the day
                final maxRain = samples
                    .map((w) => w.precipitationProbability ?? 0)
                    .reduce((a, b) => a > b ? a : b);

                final isToday = _isToday(date);
                return Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    decoration: BoxDecoration(
                      color: isToday
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(dayFmt.format(date),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: isToday ? FontWeight.bold : null,
                                color: isToday
                                    ? Theme.of(context).colorScheme.onPrimaryContainer
                                    : null)),
                        const SizedBox(height: 6),
                        // Max (day) temp
                        Text('${maxT.toStringAsFixed(0)}°',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _tempColor(maxT))),
                        // Night/min temp
                        Text('${nightT.toStringAsFixed(0)}°',
                            style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        const SizedBox(height: 4),
                        // Rain probability icon
                        if (maxRain > 0)
                          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Icon(Icons.water_drop,
                                size: 11,
                                color: maxRain >= 50
                                    ? Colors.blue.shade700
                                    : Colors.blue.shade300),
                            Text(' $maxRain%',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: maxRain >= 50
                                        ? Colors.blue.shade700
                                        : Colors.blue.shade400)),
                          ]),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  bool _isToday(DateTime d) {
    final now = DateTime.now();
    return d.year == now.year && d.month == now.month && d.day == now.day;
  }

  Color _tempColor(double t) {
    if (t >= 30) return Colors.deepOrange;
    if (t >= 22) return Colors.orange;
    if (t >= 15) return Colors.green;
    if (t >= 8) return Colors.teal;
    return Colors.blue;
  }
}

class _HourlyTable extends StatelessWidget {
  final List<WeatherData> forecast;
  const _HourlyTable({required this.forecast});

  // Deduplicate by hour — keeps first occurrence of each (date+hour) combo
  List<WeatherData> get _deduped {
    final seen = <String>{};
    return forecast.where((w) {
      final key = '${w.time.year}-${w.time.month}-${w.time.day}-${w.time.hour}';
      return seen.add(key);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;
    final timeFmt = DateFormat('HH:mm', locale);
    final dayFmt = DateFormat('EEEE d.M.', locale);

    final data = _deduped;

    // Build rows with day separators
    final rows = <TableRow>[];
    DateTime? lastDay;
    for (final w in data) {
      final day = DateTime(w.time.year, w.time.month, w.time.day);
      if (lastDay == null || !_sameDay(day, lastDay)) {
        lastDay = day;
        rows.add(TableRow(
          decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondaryContainer),
          children: List.generate(5, (i) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: i == 0
                ? Text(dayFmt.format(w.time),
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11,
                        color: Theme.of(context).colorScheme.onSecondaryContainer))
                : const SizedBox(),
          )),
        ));
      }

      final rainPct = w.precipitationProbability;
      final rainMm = w.precipitation ?? 0.0;
      final rainStr = rainPct != null
          ? '$rainPct%${rainMm > 0 ? ' ${rainMm.toStringAsFixed(1)}mm' : ''}'
          : '-';
      final rainColor = rainPct != null && rainPct >= 50
          ? Colors.blue.shade700
          : rainPct != null && rainPct >= 20
              ? Colors.blue.shade400
              : null;

      rows.add(TableRow(children: [
        _cell(timeFmt.format(w.time)),
        _cell('${w.windSpeed.toStringAsFixed(0)} kn ${w.windDirectionLabel}'),
        _cell('${w.waveHeight.toStringAsFixed(1)} m'),
        _cell('${w.airPressure.toStringAsFixed(0)}'),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(rainStr,
              style: TextStyle(fontSize: 12,
                  fontWeight: (rainPct ?? 0) >= 50 ? FontWeight.bold : null,
                  color: rainColor)),
        ),
      ]));
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.hourlyForecast, style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(1.4),
                1: FlexColumnWidth(2.4),
                2: FlexColumnWidth(1.3),
                3: FlexColumnWidth(1.4),
                4: FlexColumnWidth(1.5),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer),
                  children: [l.timeCol, l.windCol, l.wavesCol, 'hPa', l.rainCol]
                      .map((h) => Padding(
                            padding: const EdgeInsets.all(8),
                            child: Text(h,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 11)),
                          ))
                      .toList(),
                ),
                ...rows,
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _cell(String t) => Padding(
        padding: const EdgeInsets.all(8),
        child: Text(t, style: const TextStyle(fontSize: 12)),
      );
}
