import 'dart:convert';

enum ChecklistStatus { ok, damaged, missing }

ChecklistStatus _statusFromString(String s) => ChecklistStatus.values.firstWhere(
      (v) => v.name == s,
      orElse: () => ChecklistStatus.ok,
    );

/// Jedna položka kontrolného zoznamu odovzdávacieho protokolu. Foto a
/// poloha na lodi sú relevantné len keď [status] nie je [ChecklistStatus.ok].
class ChecklistItem {
  final String itemKey;
  final ChecklistStatus status;
  final String? note;
  final String? photoPath;
  final String? position;

  const ChecklistItem({
    required this.itemKey,
    this.status = ChecklistStatus.ok,
    this.note,
    this.photoPath,
    this.position,
  });

  ChecklistItem copyWith({
    ChecklistStatus? status,
    String? note,
    String? photoPath,
    String? position,
    bool clearNote = false,
    bool clearPhoto = false,
    bool clearPosition = false,
  }) =>
      ChecklistItem(
        itemKey: itemKey,
        status: status ?? this.status,
        note: clearNote ? null : (note ?? this.note),
        photoPath: clearPhoto ? null : (photoPath ?? this.photoPath),
        position: clearPosition ? null : (position ?? this.position),
      );

  Map<String, dynamic> toJson() => {
        'itemKey': itemKey,
        'status': status.name,
        if (note != null) 'note': note,
        if (photoPath != null) 'photoPath': photoPath,
        if (position != null) 'position': position,
      };

  factory ChecklistItem.fromJson(Map<String, dynamic> json) => ChecklistItem(
        itemKey: json['itemKey'] as String,
        status: _statusFromString(json['status'] as String? ?? 'ok'),
        note: json['note'] as String?,
        photoPath: json['photoPath'] as String?,
        position: json['position'] as String?,
      );
}

/// Statický zoznam položiek kontroly pri odovzdaní/prevzatí lode.
const List<String> defaultChecklistItemKeys = [
  'sails',
  'rigging',
  'anchorChain',
  'navInstruments',
  'lifeJackets',
  'raft',
  'firstAidKit',
  'dinghyMotor',
  'lights',
  'bimini',
];

List<ChecklistItem> defaultChecklist() =>
    defaultChecklistItemKeys.map((k) => ChecklistItem(itemKey: k)).toList();

List<ChecklistItem> checklistFromJson(String json) {
  final decoded = jsonDecode(json) as List;
  return decoded
      .map((e) => ChecklistItem.fromJson(e as Map<String, dynamic>))
      .toList();
}

String checklistToJson(List<ChecklistItem> items) =>
    jsonEncode(items.map((e) => e.toJson()).toList());
