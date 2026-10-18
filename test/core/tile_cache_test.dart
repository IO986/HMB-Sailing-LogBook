import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/services/tile_cache.dart';

/// Dlaždica, ktorá raz bola stiahnutá, ostáva v zariadení; tá istá sa dá
/// neskôr potichu obnoviť. Testy bežia bez zariadenia a bez siete.
void main() {
  late Directory dir;
  late File file;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('hmb_tile_cache_test');
    file = File('${dir.path}/seamark/5/1/2.png');
  });

  tearDown(() async {
    if (await dir.exists()) await dir.delete(recursive: true);
  });

  Uint8List b(List<int> v) => Uint8List.fromList(v);
  Future<bool> alwaysDecodes(Uint8List _) async => true;

  List<String> tmpFiles() => dir
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.tmp'))
      .map((f) => f.path)
      .toList();

  group('TileFileCache.readUsable', () {
    test('uložený súbor sa vráti tak, ako je', () async {
      await TileFileCache.writeAtomic(file, b([1, 2, 3]));
      expect(await TileFileCache.readUsable(file), b([1, 2, 3]));
    });

    test('chýbajúci súbor nie je použiteľný', () async {
      expect(await TileFileCache.readUsable(file), isNull);
    });

    test('prázdny súbor nie je použiteľný (spadne na stiahnutie)', () async {
      await file.parent.create(recursive: true);
      await file.writeAsBytes(const []);
      expect(await TileFileCache.readUsable(file), isNull);
    });
  });

  group('TileFileCache.writeAtomic', () {
    test('zapíše nový súbor a nezanechá dočasný', () async {
      await TileFileCache.writeAtomic(file, b([9, 9]));
      expect(await file.readAsBytes(), b([9, 9]));
      expect(tmpFiles(), isEmpty);
    });

    test('zlyhaný zápis nechá starý súbor celý', () async {
      await TileFileCache.writeAtomic(file, b([1, 1, 1]));
      // Cieľ je adresár => premenovanie naň zlyhá; starý súbor nie je
      // dotknutý a dočasný súbor sa upratal.
      final blocked = File('${dir.path}/seamark/5/1/blocked.png');
      await Directory(blocked.path).create(recursive: true);
      await expectLater(
          TileFileCache.writeAtomic(blocked, b([2, 2])), throwsA(anything));
      expect(await file.readAsBytes(), b([1, 1, 1]));
      expect(tmpFiles(), isEmpty);
    });
  });

  group('TileFileCache.refresh', () {
    test('rovnaké bajty: súbor sa neprepisuje', () async {
      await TileFileCache.writeAtomic(file, b([1, 2, 3]));
      final before = await file.stat();
      await Future<void>.delayed(const Duration(milliseconds: 20));

      final r = await TileFileCache.refresh(file,
          fetch: () async => b([1, 2, 3]), validate: alwaysDecodes);

      expect(r, TileRefreshResult.same);
      expect(await file.readAsBytes(), b([1, 2, 3]));
      expect((await file.stat()).modified, before.modified);
      expect(tmpFiles(), isEmpty);
    });

    test('304 (null) znamená nezmenené', () async {
      await TileFileCache.writeAtomic(file, b([1, 2, 3]));
      final r = await TileFileCache.refresh(file,
          fetch: () async => null, validate: alwaysDecodes);
      expect(r, TileRefreshResult.same);
      expect(await file.readAsBytes(), b([1, 2, 3]));
    });

    test('odlišné bajty nahradia súbor cez premenovanie', () async {
      await TileFileCache.writeAtomic(file, b([1, 2, 3]));

      final r = await TileFileCache.refresh(file,
          fetch: () async => b([4, 5, 6, 7]), validate: alwaysDecodes);

      expect(r, TileRefreshResult.changed);
      expect(await file.readAsBytes(), b([4, 5, 6, 7]));
      expect(tmpFiles(), isEmpty);
    });

    test('kým sieť neodpovie, starý súbor je celý', () async {
      await TileFileCache.writeAtomic(file, b([1, 2, 3]));
      final gate = Completer<Uint8List?>();
      final pending = TileFileCache.refresh(file,
          fetch: () => gate.future, validate: alwaysDecodes);
      expect(await file.readAsBytes(), b([1, 2, 3]));
      gate.complete(b([8, 8]));
      expect(await pending, TileRefreshResult.changed);
    });

    test('zlyhaná sieť nechá starý súbor', () async {
      await TileFileCache.writeAtomic(file, b([1, 2, 3]));
      final r = await TileFileCache.refresh(file,
          fetch: () async => throw const SocketException('offline'),
          validate: alwaysDecodes);
      expect(r, TileRefreshResult.failed);
      expect(await file.readAsBytes(), b([1, 2, 3]));
    });

    test('nedekódovateľné nové bajty nechajú starý dobrý súbor', () async {
      await TileFileCache.writeAtomic(file, b([1, 2, 3]));
      final r = await TileFileCache.refresh(file,
          fetch: () async => b([0, 0, 0, 0]), validate: (_) async => false);
      expect(r, TileRefreshResult.failed);
      expect(await file.readAsBytes(), b([1, 2, 3]));
    });

    test('prázdna odpoveď sa nezapíše', () async {
      await TileFileCache.writeAtomic(file, b([1, 2, 3]));
      final r = await TileFileCache.refresh(file,
          fetch: () async => Uint8List(0), validate: alwaysDecodes);
      expect(r, TileRefreshResult.failed);
      expect(await file.readAsBytes(), b([1, 2, 3]));
    });

    test('prázdny súbor + dobrá odpoveď: súbor sa naplní', () async {
      await file.parent.create(recursive: true);
      await file.writeAsBytes(const []);
      final r = await TileFileCache.refresh(file,
          fetch: () async => b([5, 5]), validate: alwaysDecodes);
      expect(r, TileRefreshResult.changed);
      expect(await file.readAsBytes(), b([5, 5]));
    });
  });

  group('CachingTileProvider: uložená dlaždica a druhý snímok', () {
    const url = 'https://tiles.example.test/seamark/5/1/2.png';
    final layer = TileLayer(
        urlTemplate: 'https://tiles.example.test/seamark/{z}/{x}/{y}.png');

    Future<Uint8List> png(Color color) async {
      final rec = ui.PictureRecorder();
      Canvas(rec)
          .drawRect(const Rect.fromLTWH(0, 0, 4, 4), Paint()..color = color);
      final img = await rec.endRecording().toImage(4, 4);
      final data = await img.toByteData(format: ui.ImageByteFormat.png);
      return data!.buffer.asUint8List();
    }

    setUp(() {
      TileCacheStore.rootForTesting = dir;
      CachingTileProvider.resetRefreshState();
      CachingTileProvider.canTryNetworkOverride = () async => true;
    });

    tearDown(() {
      TileCacheStore.rootForTesting = null;
      CachingTileProvider.refreshFetchOverride = null;
      CachingTileProvider.canTryNetworkOverride = null;
      CachingTileProvider.resetRefreshState();
    });

    Future<List<ImageInfo>> load(WidgetTester tester) async {
      final frames = <ImageInfo>[];
      // Flutterova obrazová cache by druhé načítanie rovnakého kľúča vôbec
      // nepustila ku providerovi — simulujeme vyhodenie z pamäte.
      PaintingBinding.instance.imageCache
        ..clear()
        ..clearLiveImages();
      // Celé načítanie beží v skutočnej zóne: súborové I/O a dekódovanie
      // obrazu nejdú cez falošné hodiny testWidgets.
      await tester.runAsync(() async {
        final stream = CachingTileProvider('seamark')
            .getImage(const TileCoordinates(1, 2, 5), layer)
            .resolve(ImageConfiguration.empty);
        stream.addListener(
            ImageStreamListener((info, _) => frames.add(info.clone())));
        await Future<void>.delayed(const Duration(milliseconds: 300));
      });
      return frames;
    }

    Future<Uint8List> seed(WidgetTester tester, Color color) async {
      final bytes = (await tester.runAsync(() => png(color)))!;
      await tester.runAsync(() => TileFileCache.writeAtomic(
          File('${dir.path}/seamark/5/1/2.png'), bytes));
      return bytes;
    }

    Future<Uint8List?> onDisk(WidgetTester tester) => tester
        .runAsync(() => File('${dir.path}/seamark/5/1/2.png').readAsBytes());

    testWidgets('uložená dlaždica sa ukáže a zmenená príde ako 2. snímok',
        (tester) async {
      await seed(tester, const Color(0xFFFF0000));
      final newPng =
          (await tester.runAsync(() => png(const Color(0xFF0000FF))))!;
      var fetches = 0;
      CachingTileProvider.refreshFetchOverride = (u, since) async {
        fetches++;
        expect(u, url);
        expect(since, isNotNull); // podmienená požiadavka
        return newPng;
      };

      final frames = await load(tester);

      expect(frames, hasLength(2), reason: 'uložený snímok + obnovený');
      expect(fetches, 1);
      expect(await onDisk(tester), newPng);
    });

    testWidgets('identická obnova nepošle druhý snímok a súbor ostane',
        (tester) async {
      final oldPng = await seed(tester, const Color(0xFFFF0000));
      CachingTileProvider.refreshFetchOverride = (u, since) async => oldPng;

      final frames = await load(tester);

      expect(frames, hasLength(1));
      expect(await onDisk(tester), oldPng);
    });

    testWidgets('offline: ukáže sa uložená dlaždica a súbor ostane',
        (tester) async {
      final oldPng = await seed(tester, const Color(0xFFFF0000));
      CachingTileProvider.canTryNetworkOverride = () async => false;
      CachingTileProvider.refreshFetchOverride =
          (u, since) async => fail('offline nesmie siahnuť na sieť');

      final frames = await load(tester);

      expect(frames, hasLength(1));
      expect(await onDisk(tester), oldPng);
    });

    testWidgets('druhé načítanie toho istého URL už nejde na sieť',
        (tester) async {
      final oldPng = await seed(tester, const Color(0xFFFF0000));
      var fetches = 0;
      CachingTileProvider.refreshFetchOverride = (u, since) async {
        fetches++;
        return oldPng;
      };

      await load(tester);
      await load(tester);

      expect(fetches, 1);
    });

    test('rovnosť a hashCode poskytovateľa obrazu závisia len od URL', () {
      final a = CachingTileProvider('seamark')
          .getImage(const TileCoordinates(1, 2, 5), layer);
      final c = CachingTileProvider('seamark')
          .getImage(const TileCoordinates(1, 2, 5), layer);
      expect(a, c);
      expect(a.hashCode, c.hashCode);
    });
  });
}
