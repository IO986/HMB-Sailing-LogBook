import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/features/charter/services/handover_checklist.dart';

void main() {
  test('defaultChecklist(checkIn) builds items from all check-in categories, all OK', () {
    final items = defaultChecklist('checkIn');
    final expectedKeys = checkInCategories.expand((c) => c.items).map((i) => i.key);
    expect(items.map((e) => e.itemKey), containsAll(expectedKeys));
    expect(items.every((e) => e.status == ChecklistStatus.ok), isTrue);
  });

  test('defaultChecklist(checkOut) builds a different, smaller item set than checkIn', () {
    final checkOutItems = defaultChecklist('checkOut');
    final checkInItems = defaultChecklist('checkIn');
    expect(checkOutItems.length, lessThan(checkInItems.length));
    // Check-out items must not overlap with check-in items (distinct lists).
    final checkInKeys = checkInItems.map((e) => e.itemKey).toSet();
    expect(checkOutItems.every((e) => !checkInKeys.contains(e.itemKey)), isTrue);
  });

  test('all item keys across both checklists are unique', () {
    final allKeys = [...checkInCategories, ...checkOutCategories]
        .expand((c) => c.items)
        .map((i) => i.key)
        .toList();
    expect(allKeys.toSet().length, allKeys.length);
  });

  test('itemLabel returns Slovak for sk locale, English otherwise', () {
    final item = checkInCategories.first.items.first;
    expect(itemLabel('sk', item), item.labelSk);
    expect(itemLabel('en', item), item.labelEn);
    expect(itemLabel('de', item), item.labelEn);
    expect(itemLabel('es', item), item.labelEn);
    expect(itemLabel('uk', item), item.labelEn);
  });

  test('categoryLabel returns Slovak for sk locale, English otherwise', () {
    final cat = checkInCategories.first;
    expect(categoryLabel('sk', cat), cat.labelSk);
    expect(categoryLabel('en', cat), cat.labelEn);
  });

  test('findItemDef resolves a known key and returns null for unknown key', () {
    final known = checkOutCategories.first.items.first;
    expect(findItemDef(known.key), isNotNull);
    expect(findItemDef(known.key)!.labelSk, known.labelSk);
    expect(findItemDef('does_not_exist'), isNull);
  });

  test('JSON round-trip preserves damaged item with note, photo and position', () {
    final items = [
      const ChecklistItem(
        itemKey: 'hull_bow',
        status: ChecklistStatus.damaged,
        note: 'Trhlina na prove',
        photoPath: '/data/handover_photos/charter_1/hull_bow.jpg',
        position: 'Prova',
      ),
      const ChecklistItem(itemKey: 'electrical_fuses'),
    ];

    final json = checklistToJson(items);
    final decoded = checklistFromJson(json);

    expect(decoded, hasLength(2));
    expect(decoded[0].itemKey, 'hull_bow');
    expect(decoded[0].status, ChecklistStatus.damaged);
    expect(decoded[0].note, 'Trhlina na prove');
    expect(decoded[0].photoPath, '/data/handover_photos/charter_1/hull_bow.jpg');
    expect(decoded[0].position, 'Prova');
    expect(decoded[1].status, ChecklistStatus.ok);
    expect(decoded[1].note, isNull);
  });

  test('copyWith clears fields when explicitly requested', () {
    const item = ChecklistItem(
      itemKey: 'safety_gear_life_jackets',
      status: ChecklistStatus.missing,
      note: 'Chyba',
      photoPath: 'x.jpg',
      position: 'Kokpit',
    );

    final cleared = item.copyWith(
        status: ChecklistStatus.ok, clearNote: true, clearPhoto: true, clearPosition: true);

    expect(cleared.status, ChecklistStatus.ok);
    expect(cleared.note, isNull);
    expect(cleared.photoPath, isNull);
    expect(cleared.position, isNull);
  });

  test('unknown status string falls back to ok', () {
    final decoded = checklistFromJson('[{"itemKey":"misc_spare_rudder","status":"weird"}]');
    expect(decoded.single.status, ChecklistStatus.ok);
  });
}
