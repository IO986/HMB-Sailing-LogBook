import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Jedna karta spodného menu. Registry nižšie je jediný zdroj pravdy pre
/// ikony/cesty; `main_scaffold` aj obrazovka nastavení z neho čerpajú.
class NavTab {
  final String path;
  final IconData icon;
  final IconData activeIcon;
  const NavTab(this.path, this.icon, this.activeIcon);
}

/// Nastavenia (`/settings`) sú výnimka: v spodnom menu vždy zobrazené, vždy
/// posledné a nedajú sa presunúť ani skryť — cez ne sa dá dostať na skryté
/// karty, preto musia ostať fixné.
const String kSettingsPath = '/settings';

/// Kanonické poradie a ikony všetkých kariet. Poradie tu je len default —
/// reálne poradie/viditeľnosť riadi [NavPrefs] (uchované ako user setting).
const List<NavTab> kNavTabs = [
  NavTab('/map', Icons.map_outlined, Icons.map),
  NavTab('/logbook', Icons.book_outlined, Icons.book),
  NavTab('/weather', Icons.cloud_outlined, Icons.cloud),
  NavTab('/instruments', Icons.speed_outlined, Icons.speed),
  NavTab('/safety', Icons.shield_outlined, Icons.shield),
  NavTab('/compass', Icons.explore_outlined, Icons.explore),
  NavTab(kSettingsPath, Icons.settings_outlined, Icons.settings),
];

NavTab navTabForPath(String path) =>
    kNavTabs.firstWhere((t) => t.path == path,
        orElse: () => kNavTabs.first);

/// Veľkosť ikon + popiskov spodného menu (user setting). `medium` je
/// pôvodný default.
enum NavIconSize {
  small(24, 9),
  medium(28, 10),
  // L: veľká ikona, ale popisok ostáva 10 px — pri 12 px sa jednoslovné
  // popisky ("Bezpečnosť", "Nastavenia") lámali/orezávali na dva riadky.
  large(34, 10);

  const NavIconSize(this.iconDim, this.labelFont);
  final double iconDim;
  final double labelFont;
}

/// Presúvateľné karty (všetky okrem fixných Nastavení), v default poradí.
List<String> get _reorderableDefaults =>
    [for (final t in kNavTabs) if (t.path != kSettingsPath) t.path];

class NavPrefs {
  /// Poradie presúvateľných kariet (bez `/settings`), ako si ho user nastavil.
  final List<String> order;

  /// Cesty skryté zo spodného menu (nikdy neobsahuje `/settings`). Skryté
  /// karty sa dajú otvoriť cez Nastavenia.
  final Set<String> hidden;

  /// Veľkosť ikon a popiskov spodného menu.
  final NavIconSize iconSize;

  const NavPrefs({
    required this.order,
    required this.hidden,
    this.iconSize = NavIconSize.medium,
  });

  factory NavPrefs.initial() =>
      NavPrefs(order: _reorderableDefaults, hidden: const {});

  /// Presúvateľné karty v užívateľskom poradí, ktoré sú viditeľné.
  List<String> get visibleOrdered =>
      [for (final p in order) if (!hidden.contains(p)) p];

  NavPrefs copyWith({
    List<String>? order,
    Set<String>? hidden,
    NavIconSize? iconSize,
  }) =>
      NavPrefs(
        order: order ?? this.order,
        hidden: hidden ?? this.hidden,
        iconSize: iconSize ?? this.iconSize,
      );
}

class NavPrefsNotifier extends Notifier<NavPrefs> {
  static const _kOrder = 'nav_tab_order';
  static const _kHidden = 'nav_tab_hidden';
  static const _kIconSize = 'nav_icon_size';

  @override
  NavPrefs build() {
    _load();
    return NavPrefs.initial();
  }

  Future<void> _load() async {
    final p = await SharedPreferences.getInstance();
    final orderRaw = p.getString(_kOrder);
    final hiddenRaw = p.getString(_kHidden);

    var order = _reorderableDefaults;
    if (orderRaw != null) {
      try {
        final saved = (jsonDecode(orderRaw) as List).cast<String>();
        // Zachovaj uložené poradie, ale zahoď neznáme cesty a doplň nové
        // karty pridané v novej verzii appky (na koniec) — inak by po
        // update chýbali v menu.
        final valid = saved.where(_reorderableDefaults.contains).toList();
        final missing =
            _reorderableDefaults.where((p) => !valid.contains(p));
        order = [...valid, ...missing];
      } catch (_) {}
    }

    var hidden = <String>{};
    if (hiddenRaw != null) {
      try {
        hidden = (jsonDecode(hiddenRaw) as List)
            .cast<String>()
            .where(_reorderableDefaults.contains)
            .toSet();
      } catch (_) {}
    }

    final sizeName = p.getString(_kIconSize);
    final iconSize = NavIconSize.values.firstWhere(
      (s) => s.name == sizeName,
      orElse: () => NavIconSize.medium,
    );

    state = NavPrefs(order: order, hidden: hidden, iconSize: iconSize);
  }

  Future<void> _persist() async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_kOrder, jsonEncode(state.order));
    await p.setString(_kHidden, jsonEncode(state.hidden.toList()));
    await p.setString(_kIconSize, state.iconSize.name);
  }

  void setIconSize(NavIconSize size) {
    state = state.copyWith(iconSize: size);
    _persist();
  }

  /// Presun karty v zozname presúvateľných (indexy do `state.order`).
  void reorder(int oldIndex, int newIndex) {
    final list = [...state.order];
    if (newIndex > oldIndex) newIndex -= 1;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    state = state.copyWith(order: list);
    _persist();
  }

  /// Skryť/zobraziť kartu. Vždy nechá aspoň jednu presúvateľnú kartu
  /// viditeľnú — `NavigationBar` potrebuje aspoň 2 ciele (tá jedna + fixné
  /// Nastavenia), inak by spadol.
  void setHidden(String path, bool hidden) {
    if (path == kSettingsPath) return;
    final next = {...state.hidden};
    if (hidden) {
      if (state.visibleOrdered.length <= 1) return; // nechaj aspoň jednu
      next.add(path);
    } else {
      next.remove(path);
    }
    state = state.copyWith(hidden: next);
    _persist();
  }
}

final navPrefsProvider =
    NotifierProvider<NavPrefsNotifier, NavPrefs>(NavPrefsNotifier.new);
