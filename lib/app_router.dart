import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/splash/splash_screen.dart';
import 'features/instruments/presentation/instruments_screen.dart';
import 'features/charter/presentation/screens/charter_list_screen.dart';
import 'features/charter/presentation/screens/charter_edit_screen.dart';
import 'features/charter/presentation/screens/charter_detail_screen.dart';
import 'features/charter/presentation/screens/day_log_screen.dart';
import 'features/charter/presentation/screens/safety_briefing_screen.dart';
import 'features/charter/presentation/screens/handover_protocol_screen.dart';
import 'features/logbook/presentation/screens/logbook_entry_screen.dart';
import 'features/map/presentation/screens/map_screen.dart';
import 'features/weather/presentation/screens/weather_screen.dart';
import 'features/safety/presentation/screens/safety_screen.dart';
import 'features/compass/presentation/screens/compass_screen.dart';
import 'features/safety/presentation/screens/colreg_screen.dart';
import 'features/settings/presentation/screens/settings_screen.dart';
import 'features/export/presentation/export_screen.dart';
import 'features/miles/presentation/screens/miles_book_screen.dart';
import 'features/miles/presentation/screens/historical_voyage_form_screen.dart';
import 'features/gpx_import/presentation/screens/gpx_import_screen.dart';
import 'shared/widgets/main_scaffold.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      // Ak sa niekto dostane na /, presmeruj na /map
      if (state.uri.path == '/') return '/map';
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (c, s) => const SplashScreen(),
      ),
      ShellRoute(
        builder: (c, s, child) => MainScaffold(child: child),
        routes: [
          GoRoute(path: '/map', builder: (c, s) => const MapScreen()),
          GoRoute(
            path: '/logbook',
            builder: (c, s) => const CharterListScreen(),
            routes: [
              GoRoute(path: 'new', builder: (c, s) {
                final prefill = s.extra as CharterPrefill?;
                return CharterEditScreen(prefill: prefill, popOnCreate: prefill != null);
              }),
              GoRoute(
                path: ':id',
                builder: (c, s) => CharterDetailScreen(
                    charterId: int.parse(s.pathParameters['id']!)),
                routes: [
                  GoRoute(path: 'edit',
                      builder: (c, s) => CharterEditScreen(charterId: s.pathParameters['id'])),
                  GoRoute(path: 'briefing',
                      builder: (c, s) => SafetyBriefingScreen(
                          charterId: int.parse(s.pathParameters['id']!))),
                  GoRoute(path: 'export',
                      builder: (c, s) => ExportScreen(
                          charterId: int.parse(s.pathParameters['id']!))),
                  GoRoute(path: 'handover/checkIn',
                      builder: (c, s) => HandoverProtocolScreen(
                          charterId: int.parse(s.pathParameters['id']!), type: 'checkIn')),
                  GoRoute(path: 'handover/checkOut',
                      builder: (c, s) => HandoverProtocolScreen(
                          charterId: int.parse(s.pathParameters['id']!), type: 'checkOut')),
                  GoRoute(
                    path: 'day/:dayId',
                    builder: (c, s) => DayLogScreen(
                      charterId: int.parse(s.pathParameters['id']!),
                      dayLogId: int.parse(s.pathParameters['dayId']!),
                    ),
                    routes: [
                      GoRoute(path: 'entry/new',
                          builder: (c, s) => LogbookEntryScreen(
                              dayLogId: int.parse(s.pathParameters['dayId']!))),
                      GoRoute(path: 'entry/:entryId',
                          builder: (c, s) => LogbookEntryScreen(
                              dayLogId: int.parse(s.pathParameters['dayId']!),
                              entryId: s.pathParameters['entryId'])),
                      GoRoute(path: 'export',
                          builder: (c, s) => ExportScreen(
                              charterId: int.parse(s.pathParameters['id']!),
                              dayLogId: int.parse(s.pathParameters['dayId']!))),
                    ],
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            path: '/miles',
            builder: (c, s) => const MilesBookScreen(),
            routes: [
              GoRoute(path: 'historical/new',
                  builder: (c, s) => const HistoricalVoyageFormScreen()),
              GoRoute(path: 'historical/:voyageId/edit',
                  builder: (c, s) => HistoricalVoyageFormScreen(
                      voyageId: s.pathParameters['voyageId'])),
            ],
          ),
          GoRoute(path: '/gpx-import', builder: (c, s) => const GpxImportScreen()),
          GoRoute(path: '/instruments', builder: (c, s) => const InstrumentsScreen()),
          GoRoute(path: '/weather', builder: (c, s) => const WeatherScreen()),
          GoRoute(
            path: '/safety',
            builder: (c, s) => const SafetyScreen(),
            routes: [
              GoRoute(path: 'colreg', builder: (c, s) => const ColregScreen()),
            ],
          ),
          GoRoute(path: '/compass', builder: (c, s) => const CompassScreen()),
          GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
        ],
      ),
    ],
  );
});
