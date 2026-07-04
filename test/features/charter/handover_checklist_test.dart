import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/features/charter/services/handover_checklist.dart';

void main() {
  test('defaultChecklist contains all expected item keys, all OK', () {
    final items = defaultChecklist();
    expect(items.map((e) => e.itemKey), containsAll(defaultChecklistItemKeys));
    expect(items.every((e) => e.status == ChecklistStatus.ok), isTrue);
  });

  test('JSON round-trip preserves damaged item with note, photo and position', () {
    final items = [
      const ChecklistItem(
        itemKey: 'sails',
        status: ChecklistStatus.damaged,
        note: 'Trhlina na genoe',
        photoPath: '/data/handover_photos/charter_1/sails.jpg',
        position: 'Prova',
      ),
      const ChecklistItem(itemKey: 'lights'),
    ];

    final json = checklistToJson(items);
    final decoded = checklistFromJson(json);

    expect(decoded, hasLength(2));
    expect(decoded[0].itemKey, 'sails');
    expect(decoded[0].status, ChecklistStatus.damaged);
    expect(decoded[0].note, 'Trhlina na genoe');
    expect(decoded[0].photoPath, '/data/handover_photos/charter_1/sails.jpg');
    expect(decoded[0].position, 'Prova');
    expect(decoded[1].status, ChecklistStatus.ok);
    expect(decoded[1].note, isNull);
  });

  test('copyWith clears fields when explicitly requested', () {
    const item = ChecklistItem(
      itemKey: 'raft',
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
    final decoded = checklistFromJson('[{"itemKey":"bimini","status":"weird"}]');
    expect(decoded.single.status, ChecklistStatus.ok);
  });
}
