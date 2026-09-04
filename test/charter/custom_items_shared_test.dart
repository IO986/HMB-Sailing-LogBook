import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/config/hmb_handbook.dart';
import 'package:hmb_sailing_log/features/charter/services/handover_checklist.dart';
import 'package:hmb_sailing_log/features/safety/services/custom_safety_items.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Brífing aj checklist sa zobrazujú na dvoch miestach — referenčná karta
/// v Bezpečnosti a interaktívna verzia v plavbe. Skiper nahlásil, že to nebolo
/// zosúladené: brífing mal na každom mieste iný zoznam a vlastnú položku sa
/// dalo dopísať len v jednom z nich.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('brífing má jeden zdroj', () {
    test('príručka nesie rovnaký počet bodov vo všetkých jazykoch', () {
      final counts = {
        for (final loc in [
          'sk', 'en', 'de', 'es', 'uk', 'cs', 'pl', 'el', 'hr', 'sl', 'it'
        ])
          loc: briefingPointCount(SafetyBriefingContent.sectionsFor(loc)),
      };

      // Index vlastných bodov začína za príručkovými, takže rozdielny počet
      // medzi jazykmi by pri prepnutí jazyka rozhodil zaškrtnutia.
      expect(counts.values.toSet(), hasLength(1),
          reason: 'nerovnaké počty bodov: $counts');
      expect(counts['sk'], greaterThan(12));
    });
  });

  group('vlastné body brífingu', () {
    test('pridanie a zmazanie vidí každé miesto, kde sa brífing zobrazuje',
        () async {
      expect(await CustomSafetyItems.briefingPoints(), isEmpty);

      await CustomSafetyItems.addBriefingPoint('Plynový ventil pod schodíkom');
      await CustomSafetyItems.addBriefingPoint('Vesty po zotmení povinne');
      expect(await CustomSafetyItems.briefingPoints(), hasLength(2));

      await CustomSafetyItems.removeBriefingPoint(0);
      expect(await CustomSafetyItems.briefingPoints(),
          ['Vesty po zotmení povinne']);
    });

    test('prázdny text sa nepridá', () async {
      await CustomSafetyItems.addBriefingPoint('   ');
      expect(await CustomSafetyItems.briefingPoints(), isEmpty);
    });
  });

  group('vlastné položky checklistu', () {
    test('uložia sa globálne a dostane ich každý nový protokol', () async {
      await CustomSafetyItems.addChecklistItem(
          'electrical', 'Druhá nabíjačka v kokpite');
      final saved = await CustomSafetyItems.checklistItems();
      expect(saved, hasLength(1));

      final checklist = withCustomItems(
        defaultChecklist('checkIn'),
        'checkIn',
        [for (final c in saved) (categoryKey: c.categoryKey, label: c.label)],
      );

      final custom = checklist.where((i) => i.isCustom).toList();
      expect(custom, hasLength(1));
      expect(custom.single.customLabel, 'Druhá nabíjačka v kokpite');
      expect(custom.single.categoryKey, 'electrical');
    });

    test('to isté sa nepridá dvakrát, keď už v protokole je', () async {
      const customs = [(categoryKey: 'electrical', label: 'Druhá nabíjačka')];
      final once = withCustomItems(defaultChecklist('checkIn'), 'checkIn', customs);
      final twice = withCustomItems(once, 'checkIn', customs);

      expect(twice.where((i) => i.isCustom), hasLength(1));
    });

    /// Check-in a check-out majú vlastné kategórie; položka z cudzej kategórie
    /// by v protokole nemala kam patriť a nevykreslila by sa.
    test('položka pre kategóriu, ktorú tento protokol nemá, sa preskočí', () {
      final checklist = withCustomItems(
        defaultChecklist('checkOut'),
        'checkOut',
        [(categoryKey: 'electrical', label: 'Patrí do check-inu')],
      );

      expect(checklist.where((i) => i.isCustom), isEmpty);
    });

    test('zmazanie ju vezme aj zo zoznamu uložených', () async {
      await CustomSafetyItems.addChecklistItem('deck', 'Druhá kotva');
      await CustomSafetyItems.removeChecklistItem('deck', 'Druhá kotva');
      expect(await CustomSafetyItems.checklistItems(), isEmpty);
    });
  });
}
