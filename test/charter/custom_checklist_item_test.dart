import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/features/charter/services/handover_checklist.dart';

/// Zoznam v protokole je pevný a preložený do jedenástich jazykov. Loď má však
/// vždy niečo svoje — a to si skiper doteraz nemal kam zapísať.
void main() {
  test('vlastná položka si nesie svoj text, pevná sa preloží', () {
    const own = ChecklistItem(
      itemKey: 'custom_1',
      customLabel: 'Náhradný kľúč od kajuty',
      categoryKey: 'electrical',
    );
    expect(own.isCustom, isTrue);
    expect(checklistItemLabel('en', own), 'Náhradný kľúč od kajuty');

    const fixed = ChecklistItem(itemKey: 'electrical_vhf');
    expect(fixed.isCustom, isFalse);
    expect(checklistItemLabel('en', fixed), 'VHF radio');
    expect(checklistItemLabel('sk', fixed), 'VHF rádio');
  });

  /// Protokol z novšej verzie appky môže niesť kľúč, ktorý táto nepozná.
  /// Prázdny riadok v podpísanom doklade by bol horší než slug.
  test('neznámy kľúč sa vytlačí ako kľúč, nie ako prázdno', () {
    const unknown = ChecklistItem(itemKey: 'something_new');
    expect(checklistItemLabel('sk', unknown), 'something_new');
  });

  test('vlastná položka prežije uloženie a načítanie protokolu', () {
    final items = [
      const ChecklistItem(itemKey: 'electrical_vhf', status: ChecklistStatus.ok),
      const ChecklistItem(
        itemKey: 'custom_42',
        customLabel: 'Plynový ventil pod schodíkom',
        categoryKey: 'safety',
        status: ChecklistStatus.damaged,
        note: 'tuhne',
      ),
    ];

    final restored = checklistFromJson(checklistToJson(items));

    expect(restored, hasLength(2));
    final custom = restored.last;
    expect(custom.customLabel, 'Plynový ventil pod schodíkom');
    expect(custom.categoryKey, 'safety');
    expect(custom.status, ChecklistStatus.damaged);
    expect(custom.note, 'tuhne');
  });

  test('copyWith vlastnej položke text ani kategóriu nezahodí', () {
    const own = ChecklistItem(
      itemKey: 'custom_7',
      customLabel: 'Druhá kotva',
      categoryKey: 'deck',
    );

    final updated = own.copyWith(status: ChecklistStatus.missing);

    expect(updated.customLabel, 'Druhá kotva');
    expect(updated.categoryKey, 'deck');
    expect(updated.status, ChecklistStatus.missing);
  });

  test('kľúče vlastných položiek sa neopakujú', () {
    final keys = {for (var i = 0; i < 5; i++) customChecklistKey()};
    expect(keys, hasLength(5));
    expect(keys.every((k) => k.startsWith('custom_')), isTrue);
  });
}
