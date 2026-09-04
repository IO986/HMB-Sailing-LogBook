import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Vlastné body brífingu a vlastné položky odovzdávacieho checklistu.
///
/// Pevný obsah oboch zoznamov je z HMB príručky a je preložený do jedenástich
/// jazykov. Loď má však vždy niečo svoje — plynový ventil na inom mieste,
/// pravidlo o vestách po zotmení, druhá kotva v kokpite — a charterová firma
/// si pýta veci, ktoré nikto nepredvídal.
///
/// Body sú **spoločné pre celú appku, nie pre jednu plavbu**: skiper hovorí
/// posádke to isté na každej plavbe a to isté si píše do každého protokolu.
/// Preto sedia v nastaveniach zariadenia a nie v databáze plavby — a preto ich
/// vidno na oboch miestach, kde sa daný zoznam zobrazuje (referenčná karta
/// v Bezpečnosti aj interaktívna verzia v plavbe).
class CustomSafetyItems {
  static const _briefingKey = 'briefing_custom_items';
  static const _checklistKey = 'handover_custom_items';

  // ── Brífing ──────────────────────────────────────────────────

  /// Vlastné body brífingu v poradí, v akom ich skiper pridal.
  static Future<List<String>> briefingPoints() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return List<String>.from(prefs.getStringList(_briefingKey) ?? const []);
    } catch (e) {
      debugPrint('[SAFETY] briefingPoints: $e');
      return const [];
    }
  }

  static Future<List<String>> addBriefingPoint(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return briefingPoints();
    final points = [...await briefingPoints(), trimmed];
    await _writeStrings(_briefingKey, points);
    return points;
  }

  static Future<List<String>> removeBriefingPoint(int index) async {
    final points = await briefingPoints();
    if (index < 0 || index >= points.length) return points;
    points.removeAt(index);
    await _writeStrings(_briefingKey, points);
    return points;
  }

  // ── Checklist protokolu ──────────────────────────────────────

  /// Vlastné položky checklistu, každá so svojou kategóriou.
  static Future<List<CustomChecklistItem>> checklistItems() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_checklistKey);
      if (raw == null || raw.isEmpty) return const [];
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return [
        for (final e in decoded)
          if (e is Map) CustomChecklistItem.fromJson(e.cast<String, dynamic>()),
      ];
    } catch (e) {
      debugPrint('[SAFETY] checklistItems: $e');
      return const [];
    }
  }

  static Future<List<CustomChecklistItem>> addChecklistItem(
      String categoryKey, String label) async {
    final trimmed = label.trim();
    if (trimmed.isEmpty) return checklistItems();
    final items = [
      ...await checklistItems(),
      CustomChecklistItem(categoryKey: categoryKey, label: trimmed),
    ];
    await _writeJson(_checklistKey, items.map((i) => i.toJson()).toList());
    return items;
  }

  /// Zmaže položku podľa kategórie a textu — kľúč položky v protokole vzniká
  /// pri každom protokole nanovo, takže sa na identifikáciu nedá použiť.
  static Future<List<CustomChecklistItem>> removeChecklistItem(
      String categoryKey, String label) async {
    // Kópia, nie výsledok priamo: prázdny zoznam sa vracia ako `const []`
    // a mazanie z nemenného zoznamu by spadlo.
    final items = [...await checklistItems()]
      ..removeWhere((i) => i.categoryKey == categoryKey && i.label == label);
    await _writeJson(_checklistKey, items.map((i) => i.toJson()).toList());
    return items;
  }

  static Future<void> _writeStrings(String key, List<String> value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(key, value);
    } catch (e) {
      debugPrint('[SAFETY] write $key: $e');
    }
  }

  static Future<void> _writeJson(String key, Object value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, jsonEncode(value));
    } catch (e) {
      debugPrint('[SAFETY] write $key: $e');
    }
  }
}

/// Vlastná položka checklistu: text a kategória, do ktorej patrí.
class CustomChecklistItem {
  final String categoryKey;
  final String label;

  const CustomChecklistItem({required this.categoryKey, required this.label});

  Map<String, dynamic> toJson() =>
      {'categoryKey': categoryKey, 'label': label};

  factory CustomChecklistItem.fromJson(Map<String, dynamic> json) =>
      CustomChecklistItem(
        categoryKey: json['categoryKey'] as String? ?? '',
        label: json['label'] as String? ?? '',
      );
}
