import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guards the five .arb files against drifting apart.
///
/// gen-l10n only warns about a missing translation, and a warning in a long
/// build log is a warning nobody reads. A key added to the Slovak template and
/// forgotten elsewhere shows up in the app as English text — or, for a key with
/// placeholders, as a build failure much later.
void main() {
  const locales = ['sk', 'en', 'de', 'es', 'uk'];

  Map<String, dynamic> load(String locale) => jsonDecode(
        File('lib/l10n/app_$locale.arb').readAsStringSync(),
      ) as Map<String, dynamic>;

  /// Message keys only — '@@locale' and the '@key' metadata entries are not
  /// translations.
  Set<String> messageKeys(Map<String, dynamic> arb) =>
      arb.keys.where((k) => !k.startsWith('@')).toSet();

  test('every locale defines exactly the same message keys', () {
    // sk is the template per l10n.yaml.
    final template = messageKeys(load('sk'));

    for (final locale in locales.where((l) => l != 'sk')) {
      final keys = messageKeys(load(locale));

      final missing = template.difference(keys).toList()..sort();
      final extra = keys.difference(template).toList()..sort();

      expect(missing, isEmpty,
          reason: 'app_$locale.arb is missing: ${missing.join(', ')}');
      expect(extra, isEmpty,
          reason: 'app_$locale.arb has keys the template lacks: '
              '${extra.join(', ')}');
    }
  });

  test('no translation is left as an empty string', () {
    for (final locale in locales) {
      final arb = load(locale);
      for (final entry in arb.entries) {
        if (entry.key.startsWith('@')) continue;
        expect((entry.value as String).trim(), isNotEmpty,
            reason: '${entry.key} is empty in app_$locale.arb');
      }
    }
  });

  test('placeholder metadata matches across locales', () {
    // A key declaring {name} in one file and not another generates a different
    // method signature per locale and fails the build in a confusing place.
    final template = load('sk');
    final withPlaceholders = template.keys
        .where((k) => k.startsWith('@') && k != '@@locale')
        .toSet();

    for (final locale in locales.where((l) => l != 'sk')) {
      final arb = load(locale);
      for (final metaKey in withPlaceholders) {
        final messageKey = metaKey.substring(1);
        if (!arb.containsKey(messageKey)) continue;
        final placeholders =
            (template[metaKey] as Map)['placeholders'] as Map? ?? const {};
        for (final name in placeholders.keys) {
          expect(arb[messageKey], contains('{$name}'),
              reason: '$messageKey in app_$locale.arb does not use {$name}');
        }
      }
    }
  });
}
