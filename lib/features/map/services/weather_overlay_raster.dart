import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import '../../../core/services/weather_overlay_grid_service.dart';

/// Prevedie mriežku hodnôt na plynulý obrázok pre vrstvu nad mapou.
///
/// Prvá verzia kreslila každú bunku mriežky ako obdĺžnik a výsledok bol
/// nepoužiteľne kockatý — z prehánky bol štvorec cez pol mora. Hustejšia
/// mriežka sama o sebe nestačí: hranice buniek ostanú viditeľné pri
/// akejkoľvek hustote, lebo hodnota vnútri bunky je konštantná.
///
/// Preto sa medzi bodmi interpoluje bilineárne a výsledok sa vykreslí ako
/// raster. Priehľadnosť sa navyše zvyšuje smerom k prahu viditeľnosti, takže
/// plocha na okrajoch vyblednutím zaniká namiesto toho, aby končila hranou.
abstract final class WeatherOverlayRaster {
  /// Strana rastra v pixeloch.
  ///
  /// 256 je dosť na plynulý prechod a lacné na výpočet (~65 tisíc pixelov,
  /// jednotky milisekúnd). Raster sa prepočítava len keď prídu nové dáta,
  /// nie pri každom posune mapy — mapa si ho škáluje sama.
  static const _pixels = 256;

  /// Najvyššia krycia sila plochy. Pod ňou musí ostať vidieť mapa aj trasa.
  static const _maxAlpha = 0.55;

  /// Vráti hotové PNG.
  ///
  /// Zámerne bajty, nie `ui.Image`: obrázok držaný naprieč snímkami a
  /// zabalený do vlastného `ImageProvider` Flutter po čase uvoľní a vrstva
  /// zmizne. `MemoryImage` nad bajtami má životný cyklus, ktorý Flutter
  /// spravuje sám.
  static Future<Uint8List> buildPng(OverlayField field) async {
    final image = await _buildImage(field);
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      return data!.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  }

  static Future<ui.Image> _buildImage(OverlayField field) {
    final threshold = WeatherOverlayGridService.minVisible(field.overlay);

    // Horná hranica škály priehľadnosti. Pri slabých hodnotách by fixný strop
    // spravil sotva viditeľný závoj, preto sa škáluje podľa toho, čo je vo
    // výreze naozaj — ale nikdy nie pod dvojnásobok prahu, inak by aj úplne
    // zanedbateľná hodnota vyšla ako sýta plocha.
    final peak = math.max(field.maxValue, threshold * 2);

    final buffer = Uint8List(_pixels * _pixels * 4);
    for (var py = 0; py < _pixels; py++) {
      // Riadky obrázka idú od severu na juh, mriežka od juhu na sever.
      final gy = (1 - (py + 0.5) / _pixels) * (field.size - 1);
      final r0 = gy.floor();
      final fy = gy - r0;

      for (var px = 0; px < _pixels; px++) {
        final gx = (px + 0.5) / _pixels * (field.size - 1);
        final c0 = gx.floor();
        final fx = gx - c0;

        final value = field.at(r0, c0) * (1 - fx) * (1 - fy) +
            field.at(r0, c0 + 1) * fx * (1 - fy) +
            field.at(r0 + 1, c0) * (1 - fx) * fy +
            field.at(r0 + 1, c0 + 1) * fx * fy;

        if (value < threshold) continue; // ostáva priehľadné

        final colour = overlayColor(field.overlay, value);
        final strength =
            ((value - threshold) / (peak - threshold)).clamp(0.0, 1.0);
        // Odmocnina: slabé zrážky majú byť viditeľné, nie takmer priehľadné.
        final alpha = _maxAlpha * (0.35 + 0.65 * math.sqrt(strength));

        final i = (py * _pixels + px) * 4;
        buffer[i] = (colour.r * 255).round();
        buffer[i + 1] = (colour.g * 255).round();
        buffer[i + 2] = (colour.b * 255).round();
        buffer[i + 3] = (alpha * 255).round();
      }
    }

    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      buffer,
      _pixels,
      _pixels,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    return completer.future;
  }
}
