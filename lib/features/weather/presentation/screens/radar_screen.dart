import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../l10n/app_localizations.dart';

/// Oficiálna radarová snímka DHMZ (meteo.hr).
///
/// Zámerne NIE JE to vrstva nad mapou. Snímka je hotová mapa s vlastným
/// podkladom, hranicami a popismi, a DHMZ nezverejňuje jej projekciu ani
/// rozsah — položiť ju na mapu appky by znamenalo odhadnúť georeferenciu.
/// Odhadnutá poloha zrážok v navigačnej appke je horšia než žiadna.
///
/// Preto sa ukazuje tak, ako ju číta skiper na meteo.hr: celá, s časom
/// merania a legendou v mm/h.
///
/// Toto je MERANIE. Vrstva zrážok v mape je model — pozri
/// `PrecipitationGridService`.
class RadarScreen extends ConsumerStatefulWidget {
  const RadarScreen({super.key});

  @override
  ConsumerState<RadarScreen> createState() => _RadarScreenState();
}

class _RadarScreenState extends ConsumerState<RadarScreen> {
  static const _url = 'https://vrijeme.hr/kompozit-stat.png';

  /// Mení sa pri obnovení, aby sa obišla vyrovnávacia pamäť obrázkov —
  /// snímka má tú istú URL a bez toho by sa nikdy nenačítala nová.
  late int _cacheBuster = DateTime.now().millisecondsSinceEpoch;

  void _refresh() => setState(
      () => _cacheBuster = DateTime.now().millisecondsSinceEpoch);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.radarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l.radarRefresh,
            onPressed: _refresh,
          ),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: InteractiveViewer(
            minScale: 1,
            maxScale: 5,
            child: Center(
              child: Image.network(
                '$_url?cb=$_cacheBuster',
                fit: BoxFit.contain,
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : const Center(child: CircularProgressIndicator()),
                errorBuilder: (context, _, __) => Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(l.radarUnavailable,
                      textAlign: TextAlign.center),
                ),
              ),
            ),
          ),
        ),
        // Atribúcia je podmienkou použitia, nie ozdoba.
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Text(
            l.radarSourceDhmz,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
      ]),
    );
  }
}
