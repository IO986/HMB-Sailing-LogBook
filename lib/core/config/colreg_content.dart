// ── COLREG – Medzinárodné pravidlá pre zabránenie zrážkam na mori ──
// Spracované podľa: Tim Bartlett, "COLREG Komentovaná", RYA/IFP Publishing
// Preložené a skrátené pre potreby HMB Sailing Log

import 'colreg_content_en.dart';
import 'colreg_content_sk.dart';

class ColregSection {
  final String id;
  final String title;
  final String? ruleNumber;
  final List<ColregBlock> blocks;
  final List<ColregSection> children;

  const ColregSection({
    required this.id,
    required this.title,
    this.ruleNumber,
    this.blocks = const [],
    this.children = const [],
  });
}

abstract class ColregBlock {
  const ColregBlock();
}

/// Bežný odsek textu
class ColregText extends ColregBlock {
  final String text;
  const ColregText(this.text);
}

/// Nadpis v rámci sekcie
class ColregHeading extends ColregBlock {
  final String text;
  const ColregHeading(this.text);
}

/// Citácia plného znenia pravidla (zvýraznený box)
class ColregRuleBox extends ColregBlock {
  final String title;
  final String text;
  const ColregRuleBox({required this.title, required this.text});
}

/// Odrážkový zoznam
class ColregList extends ColregBlock {
  final List<String> items;
  final bool numbered;
  const ColregList(this.items, {this.numbered = false});
}

/// SVG ilustrácia (key referuje na widget v colreg_diagrams.dart)
class ColregDiagram extends ColregBlock {
  final String diagramKey;
  final String caption;
  const ColregDiagram(this.diagramKey, this.caption);
}

/// Tip / upozornenie (farebný box)
class ColregNote extends ColregBlock {
  final String text;
  final ColregNoteType type;
  const ColregNote(this.text, {this.type = ColregNoteType.info});
}

enum ColregNoteType { info, warning, danger, story }

// ════════════════════════════════════════════════════════════════
// OBSAH
// ════════════════════════════════════════════════════════════════

class ColregContent {
  /// COLREG content for the given language code.
  ///
  /// Slovak has its own full translation; every other locale falls back to
  /// English until a translation for it exists.
  static List<ColregSection> chaptersFor(String languageCode) =>
      languageCode == 'sk' ? colregChaptersSk : colregChaptersEn;
}
