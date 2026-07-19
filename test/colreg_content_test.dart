import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/config/colreg_content.dart';

/// Collects every section id in tree order.
List<String> _ids(List<ColregSection> sections) => [
      for (final s in sections) ...[s.id, ..._ids(s.children)],
    ];

/// Collects every diagram key in tree order.
List<String> _diagramKeys(List<ColregSection> sections) => [
      for (final s in sections) ...[
        for (final b in s.blocks)
          if (b is ColregDiagram) b.diagramKey,
        ..._diagramKeys(s.children),
      ],
    ];

void main() {
  group('ColregContent.chaptersFor', () {
    test('Slovak gets its own content, every other locale gets English', () {
      final sk = ColregContent.chaptersFor('sk');
      final en = ColregContent.chaptersFor('en');

      expect(sk, isNot(same(en)));
      for (final lang in ['en', 'de', 'es', 'uk', 'fr', '']) {
        expect(ColregContent.chaptersFor(lang), same(en),
            reason: '"$lang" must fall back to English');
      }
    });

    test('section ids are identical across languages', () {
      // The screen looks a chapter up by id after a language switch, so a
      // mismatch here would throw at runtime rather than just look wrong.
      expect(_ids(ColregContent.chaptersFor('en')),
          equals(_ids(ColregContent.chaptersFor('sk'))));
    });

    test('diagram keys are identical across languages', () {
      // Diagrams are shared between languages; a key present in only one of
      // them would silently render nothing.
      expect(_diagramKeys(ColregContent.chaptersFor('en')),
          equals(_diagramKeys(ColregContent.chaptersFor('sk'))));
    });

    test('English content is not empty and carries no Slovak diacritics', () {
      final en = ColregContent.chaptersFor('en');
      expect(en, hasLength(7));

      final titles = _titles(en).join(' ');
      expect(titles, isNot(matches(RegExp(r'[ľščťžýáíéúňďôĺŕäö]'))),
          reason: 'untranslated Slovak title leaked into the English content');
    });
  });
}

List<String> _titles(List<ColregSection> sections) => [
      for (final s in sections) ...[s.title, ..._titles(s.children)],
    ];
