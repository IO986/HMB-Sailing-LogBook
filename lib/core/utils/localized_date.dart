import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/units_service.dart';

/// Formátovanie dátumov pre oči skipera.
///
/// Dve veci naraz:
///
/// 1. Jazyk. Predtým bolo po appke rozkopírované `DateFormat(pattern, 'sk')`,
///    takže názvy dní a mesiacov ostávali slovenské aj v anglickej verzii.
/// 2. Zvyklosť. Skiper si v nastaveniach vyberie [DateStyle] a tá platí
///    všade, kde dátum vidí.
///
/// Volá sa cez sémantiku (dlhý / stredný / krátky), nie cez vzorec: vzorec
/// zadaný na mieste volania by voľbu z nastavení obišiel, čo je presne tá
/// chyba, ktorú to má odstrániť.
///
/// Symboly pre všetky podporované jazyky načíta `initializeDateFormatting`
/// v `main()` ešte pred `runApp`.
///
/// Zámerne to NEPOUŽÍVAJ na obsah exportovaných súborov (GPX, názvy súborov):
/// tam dátum nie je text pre oči, ale súčasť dát, a nemá sa meniť podľa toho,
/// aký jazyk či zvyklosť mal kto práve zapnutú.
class AppDate {
  const AppDate._(this._locale, this._style);

  final String _locale;
  final DateStyle _style;

  /// Formátovač bez `BuildContext` — pre PDF a iné miesta mimo stromu
  /// widgetov, ktoré si jazyk a voľbu dostanú podané zvonka.
  const AppDate.raw(String locale, DateStyle style) : this._(locale, style);

  /// Formátovač pre kód mimo stromu widgetov — služby na pozadí (cloud
  /// export, hromadný export), ktoré nemajú `context` ani `ref`, ale majú
  /// vytvárať rovnaké dokumenty ako keby ich spustil používateľ ručne.
  ///
  /// Číta tie isté kľúče, do ktorých píše prepínač jazyka a nastavenie
  /// formátu; keď ešte nič uložené nie je, platia predvolené hodnoty.
  static Future<AppDate> fromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final styleIndex = prefs.getInt('units_date_style') ?? 0;
    return AppDate._(
      prefs.getString('app_locale') ?? 'en',
      DateStyle.values[styleIndex.clamp(0, DateStyle.values.length - 1)],
    );
  }

  /// Formátovač podľa aktuálneho jazyka a voľby v nastaveniach.
  factory AppDate.of(BuildContext context, WidgetRef ref) => AppDate._(
        Localizations.localeOf(context).languageCode,
        ref.watch(unitsSyncProvider).dateStyle,
      );

  /// Dlhý dátum s názvom dňa — hlavičky denných záznamov, nadpisy obrazoviek.
  ///
  /// Názov dňa sa necháva aj pri číselných zvyklostiach: je to nadpis, ktorý
  /// má byť čitateľný na prvý pohľad, a deň v týždni je pri plavbe užitočný
  /// údaj. Číselné zvyklosti menia len samotný dátum za ním.
  String long(DateTime d) => switch (_style) {
        DateStyle.appLanguage =>
          DateFormat('EEEE d. MMMM yyyy', _locale).format(d),
        _ => '${DateFormat('EEEE', _locale).format(d)} ${short(d)}',
      };

  /// Dlhý dátum bez roka — zoznamy dní vnútri jednej plavby, kde rok
  /// vyplýva z kontextu.
  String longNoYear(DateTime d) => switch (_style) {
        DateStyle.appLanguage => DateFormat('EEEE d. MMMM', _locale).format(d),
        _ => '${DateFormat('EEEE', _locale).format(d)} ${shortNoYear(d)}',
      };

  /// Plný dátum bez názvu dňa — hlavičky dokumentov (bezpečnostný brífing).
  String full(DateTime d) => switch (_style) {
        DateStyle.appLanguage => DateFormat('d. MMMM yyyy', _locale).format(d),
        _ => short(d),
      };

  /// Stredný dátum — riadky zoznamov, kde sa nazvyš miesto.
  String medium(DateTime d) => switch (_style) {
        DateStyle.appLanguage => DateFormat('d. MMM yyyy', _locale).format(d),
        _ => short(d),
      };

  /// Krátky, čisto číselný dátum.
  String short(DateTime d) => switch (_style) {
        DateStyle.appLanguage => DateFormat('d.M.yyyy', _locale).format(d),
        DateStyle.dmy => DateFormat('dd.MM.yyyy').format(d),
        DateStyle.mdy => DateFormat('MM/dd/yyyy').format(d),
        DateStyle.iso => DateFormat('yyyy-MM-dd').format(d),
      };

  /// Krátky dátum bez roka.
  String shortNoYear(DateTime d) => switch (_style) {
        DateStyle.appLanguage => DateFormat('d.M.', _locale).format(d),
        DateStyle.dmy => DateFormat('dd.MM.').format(d),
        DateStyle.mdy => DateFormat('MM/dd').format(d),
        DateStyle.iso => DateFormat('MM-dd').format(d),
      };

  /// Dátum s časom — záznamy, ktoré potrebujú aj hodinu (zameranie,
  /// protokol o prevzatí). Čas je vždy 24-hodinový: na mori sa hovorí v
  /// 24-hodinovom formáte bez ohľadu na zvyklosti krajiny.
  String shortWithTime(DateTime d) =>
      '${short(d)} ${DateFormat('HH:mm').format(d)}';

  /// Dátum s časom na sekundy — časová pečiatka podpisu v dokumente.
  /// Do QR kódu ani do hashu nevstupuje, je to údaj pre čitateľa.
  String shortWithSeconds(DateTime d) =>
      '${short(d)} ${DateFormat('HH:mm:ss').format(d)}';

  /// Názov dňa v týždni, dlhý aj skrátený — pre pásy dní a hlavičky, kde si
  /// volajúci skladá vlastné rozloženie (napr. názov a dátum pod sebou).
  String weekdayLong(DateTime d) => DateFormat('EEEE', _locale).format(d);
  String weekdayShort(DateTime d) => DateFormat('EEE', _locale).format(d);

  /// Krátky dátum s trojpísmenovým názvom dňa — dialógy trackingu.
  String shortWithWeekday(DateTime d) =>
      '${DateFormat('EEE', _locale).format(d)} ${shortNoYear(d)}';

  /// Ukážka pre prepínač v nastaveniach — ten istý deň v každom štýle, aby
  /// bolo z čoho vyberať bez čítania skratiek.
  static String sample(String locale, DateStyle style) =>
      AppDate._(locale, style).long(DateTime(2026, 8, 21));
}
