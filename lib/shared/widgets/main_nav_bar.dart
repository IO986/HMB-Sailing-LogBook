import 'package:flutter/material.dart';

import '../../core/providers/nav_prefs_provider.dart';
import '../../l10n/app_localizations.dart';

/// Spodná lišta hlavných kariet.
///
/// Popisky sú skryté zámerne: v ôsmich jazykoch mali rôznu dĺžku, lámali sa
/// na dva riadky a tým posúvali ikony hore-dole, takže tá istá karta bola
/// v každom jazyku inde. Text ostáva v [NavigationDestination.label], takže
/// ho prečíta čítačka obrazovky a ukáže sa aj ako tooltip pri podržaní.
class MainNavBar extends StatelessWidget {
  const MainNavBar({
    required this.paths,
    required this.currentIndex,
    required this.onSelected,
    required this.iconSize,
    super.key,
  });

  final List<String> paths;
  final int currentIndex;
  final ValueChanged<int> onSelected;
  final NavIconSize iconSize;

  /// Názov karty — už len pre čítačku obrazovky a tooltip.
  static String labelForPath(AppLocalizations l, String path) => switch (path) {
        '/map' => l.navMap,
        '/logbook' => l.navLogbook,
        '/weather' => l.navWeather,
        '/instruments' => l.navInstruments,
        '/safety' => l.navSafety,
        '/compass' => l.navCompass,
        kSettingsPath => l.navSettings,
        _ => '',
      };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onSelected,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
      height: iconSize.barHeight,
      destinations: [
        for (final path in paths)
          NavigationDestination(
            icon: Icon(navTabForPath(path).icon, size: iconSize.iconDim),
            selectedIcon:
                Icon(navTabForPath(path).activeIcon, size: iconSize.iconDim),
            label: labelForPath(l, path),
          ),
      ],
    );
  }
}
