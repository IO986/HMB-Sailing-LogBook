import 'dart:async';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../../../../core/models/bearing_kind.dart';
import '../../../../core/services/location_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/waypoint_picker.dart';
import '../../../bearing/providers/bearing_provider.dart';

class CompassScreen extends ConsumerStatefulWidget {
  const CompassScreen({super.key});

  @override
  ConsumerState<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends ConsumerState<CompassScreen>
    with WidgetsBindingObserver {
  CameraController? _camCtrl;
  bool _cameraReady = false;
  bool _cameraPermissionDenied = false;
  bool _cameraFailed = false;

  StreamSubscription<MagnetometerEvent>? _magSub;
  StreamSubscription<AccelerometerEvent>? _accSub;

  double _magX = 0, _magY = 0, _magZ = 0;
  double _accX = 0, _accY = 0, _accZ = 0;
  /// Pod týmto rozdielom sa kurzom na displeji nič viditeľne nezmení, takže
  /// sa neprekresľuje. Nižšie než rozlíšenie údaja (1°) aj než reálna
  /// presnosť telefónového kompasu (±8°).
  static const double _minVisibleHeadingChangeDeg = 0.3;

  double _heading = 0;
  double _smoothedHeading = 0;
  bool _headingInitialized = false;

  // Rolling variance for stability indicator
  final List<double> _recentHeadings = [];
  bool _isStable = false;

  /// Beží ukladanie zamerania — bráni dvojkliku, kým sa robí fotka.
  bool _capturing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    // Zameranie na neznámy bod sa počíta z polohy lode v okamihu ťuknutia —
    // tá musí byť čerstvá, nie 50 m stará.
    LocationService().requestPrecise(this);
    _initCamera();
    _initSensors();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_camCtrl == null || !_camCtrl!.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      _camCtrl?.dispose();
      _camCtrl = null;
      if (mounted) setState(() { _cameraReady = false; _cameraFailed = false; });
    } else if (state == AppLifecycleState.resumed) {
      _initCamera();
    }
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) setState(() => _cameraPermissionDenied = true);
      return;
    }
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      if (mounted) setState(() => _cameraFailed = true);
      return;
    }

    final back = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );
    final ctrl = CameraController(back, ResolutionPreset.medium,
        enableAudio: false, imageFormatGroup: ImageFormatGroup.jpeg);
    try {
      await ctrl.initialize();
      if (mounted) setState(() { _camCtrl = ctrl; _cameraReady = true; _cameraFailed = false; });
    } catch (_) {
      ctrl.dispose();
      if (mounted) setState(() => _cameraFailed = true);
    }
  }

  void _initSensors() {
    _magSub = magnetometerEventStream(samplingPeriod: SensorInterval.uiInterval)
        .listen((e) { _magX = e.x; _magY = e.y; _magZ = e.z; _updateHeading(); });
    _accSub = accelerometerEventStream(samplingPeriod: SensorInterval.uiInterval)
        .listen((e) { _accX = e.x; _accY = e.y; _accZ = e.z; });
  }

  void _updateHeading() {
    // Full rotation-matrix heading — works at any phone orientation.
    //
    // Step 1: East = normalize(Mag × Acc_norm)
    // Step 2: North = Acc_norm × East
    // Step 3: bearing = atan2(dot(East, fwd), dot(North, fwd))
    //   where fwd = Y axis when phone is flat, -Z axis (camera) when vertical.
    //
    // This is equivalent to Android SensorManager.getRotationMatrix / getOrientation.

    final aNorm = math.sqrt(_accX * _accX + _accY * _accY + _accZ * _accZ);
    if (aNorm < 0.5) return;
    final aXn = _accX / aNorm, aYn = _accY / aNorm, aZn = _accZ / aNorm;

    // East = Mag × Acc_norm
    final eX = _magY * aZn - _magZ * aYn;
    final eY = _magZ * aXn - _magX * aZn;
    final eZ = _magX * aYn - _magY * aXn;
    final eNorm = math.sqrt(eX * eX + eY * eY + eZ * eZ);
    if (eNorm < 0.1) return;
    final eXn = eX / eNorm, eYn = eY / eNorm, eZn = eZ / eNorm;

    // North = Acc_norm × East  (already unit length)
    final nY = aZn * eXn - aXn * eZn;
    final nZ = aXn * eYn - aYn * eXn;

    // Forward direction: Y axis (top) when flat, -Z axis (camera) when vertical
    final double eastComp, northComp;
    if (aZn.abs() >= aYn.abs()) {
      eastComp  = eYn;   // dot(East,  [0,1,0])
      northComp = nY;    // dot(North, [0,1,0])
    } else {
      eastComp  = -eZn;  // dot(East,  [0,0,-1])
      northComp = -nZ;   // dot(North, [0,0,-1])
    }

    double raw = math.atan2(eastComp, northComp) * 180 / math.pi;
    if (raw < 0) raw += 360;

    // Circular low-pass filter (alpha = 0.15 → smooth but responsive)
    if (!_headingInitialized) {
      _smoothedHeading = raw;
      _headingInitialized = true;
    } else {
      double diff = raw - _smoothedHeading;
      if (diff > 180) diff -= 360;
      if (diff < -180) diff += 360;
      _smoothedHeading = (_smoothedHeading + 0.15 * diff + 360) % 360;
    }

    // Stability: track last 20 readings, stable if variance < 4°
    _recentHeadings.add(_smoothedHeading);
    if (_recentHeadings.length > 20) _recentHeadings.removeAt(0);
    final stable = _recentHeadings.length >= 10 && _headingVariance() < 4.0;

    // Magnetometer tečie na ~15 Hz a každý vzorok prekresľoval celú obrazovku
    // vrátane camera preview a kompasového pásu. Vyhladený kurz sa pritom pri
    // pokojne držanom telefóne medzi vzorkami mení o stotiny stupňa — čo oko
    // nerozozná. Prekresli, len keď je čo vidieť.
    if (!mounted) return;
    var delta = (_smoothedHeading - _heading).abs();
    if (delta > 180) delta = 360 - delta;
    if (delta < _minVisibleHeadingChangeDeg && stable == _isStable) return;
    setState(() { _heading = _smoothedHeading; _isStable = stable; });
  }

  double _headingVariance() {
    if (_recentHeadings.isEmpty) return 999;
    final mean = _recentHeadings.reduce((a, b) => a + b) / _recentHeadings.length;
    final variance = _recentHeadings
        .map((h) { double d = h - mean; if (d > 180) d -= 360; if (d < -180) d += 360; return d * d; })
        .reduce((a, b) => a + b) / _recentHeadings.length;
    return math.sqrt(variance);
  }

  /// Uloží zameranie na to, kam kríž práve mieri.
  ///
  /// Kurz sa odčíta hneď v prvom riadku, ešte pred fotkou a zápisom: kým sa
  /// obrázok uloží, telefón sa v ruke stihne pootočiť o niekoľko stupňov a
  /// zameranie by sedelo na iný objekt, než na aký skiper mieril.
  Future<void> _capture() async {
    if (_capturing) return;
    // Kurz aj celý kontext sa odčítajú naraz v prvých riadkoch. Kým sa urobí
    // fotka a zápis, telefón sa v ruke stihne pootočiť.
    final magnetic = _heading;
    final wasStable = _isStable;
    final mode = ref.read(bearingModeProvider);
    final target = ref.read(resectionTargetProvider);
    final group = ref.read(activeSightGroupProvider);

    // Chýbajúci vstup rieš PRED fotkou: inak sa uloží súbor a zápis aj tak
    // spadne. A kým skiper vyberá bod, telefón sa pootočí, takže už odčítaný
    // kurz sa musí zahodiť, nie použiť.
    //
    // Po výbere sa ZÁMERNE nič nehlási a nezameriava: kým skiper vyberal,
    // telefón sa pootočil, takže odčítaný kurz už neplatí a nový námer si
    // vyžaduje druhé ťuknutie. Že je vybrané, povie samotný štítok — zmení
    // text a stratí jantárový rám. Hlásiť pri tom "vyber bod" by bolo
    // klamstvo, veď práve vybral.
    if (mode == BearingKind.resection && target == null) {
      await _pickResectionTarget();
      if (mounted && ref.read(resectionTargetIdProvider) == null) {
        _toast(AppLocalizations.of(context).bearingNeedsTarget);
      }
      return;
    }
    // `group == null` sama osebe nestačí: pri celkom novom bode je vybraná
    // len jeho meno (`_pendingObjectName`), skupina v databáze ešte
    // neexistuje, kým naň nepadne prvý námer — takže `group` je null aj v
    // stave, ktorý je úplne v poriadku na zameranie. Bez tejto podmienky
    // druhé ťuknutie na Zameraj po pomenovaní nového bodu znova pýtalo
    // výber, namiesto aby zamerania.
    if (mode == BearingKind.intersection &&
        group == null &&
        _pendingObjectName == null) {
      await _chooseSightObject();
      if (mounted &&
          ref.read(activeSightGroupIdProvider) == null &&
          _pendingObjectName == null) {
        _toast(AppLocalizations.of(context).bearingNeedsObject);
      }
      return;
    }

    setState(() => _capturing = true);
    unawaited(HapticFeedback.mediumImpact());

    String? photoPath;
    try {
      final camera = _camCtrl;
      if (_cameraReady && camera != null && !camera.value.isTakingPicture) {
        photoPath = (await camera.takePicture()).path;
      }
    } catch (_) {
      // Fotka je doplnok. Bez nej je zameranie stále platný navigačný údaj,
      // tak sa kvôli nej celý zápis nezahadzuje.
    }

    final repository = ref.read(bearingRepositoryProvider);
    final prepared = mode == BearingKind.resection
        ? await repository.prepareResection(
            magneticBearing: magnetic, target: target, photoPath: photoPath)
        : await repository.prepareIntersection(
            magneticBearing: magnetic,
            sightGroupId: group?.id,
            objectName: group?.name ?? _pendingObjectName,
            photoPath: photoPath);

    if (!mounted) return;
    setState(() => _capturing = false);

    if (prepared is! BearingPrepared) {
      // Chýbajúci vstup alebo chyba — nič sa nespočítalo, netreba potvrdiť.
      _reportCapture(prepared, wasStable);
      return;
    }

    // Kurz je v návrhu už zmrazený z okamihu ťuknutia, takže potvrdenie
    // meranie nijako nepokazí — čas na rozhodnutie sa do čísla nepremieta.
    final confirmed = await _confirmDraft(prepared.draft);
    if (!mounted) return;
    if (!confirmed) {
      await repository.discardDraft(prepared.draft);
      return;
    }

    final result = await repository.commit(prepared.draft);
    if (!mounted) return;

    if (result is BearingCaptured) {
      _pendingObjectName = null;
      if (result.kind == BearingKind.resection) {
        // Ďalší námer musí ísť na INÝ bod, inak sa poloha nedopočíta —
        // vyprázdnenie voľby je najrýchlejšia cesta, ako to naznačiť.
        ref.read(resectionTargetIdProvider.notifier).state = null;
      } else {
        // Ten istý objekt sa bude zameriavať znova z ďalšej polohy, aj o
        // hodinu — voľba preto zostáva.
        ref.read(activeSightGroupIdProvider.notifier).state =
            result.sightGroupId;
      }
    }
    _reportCapture(result, wasStable);
  }

  /// Odloží doterajšie zamerania z mapy a začne s čistým štítom.
  ///
  /// Nič sa nemaže: riadky zostávajú v databáze a naďalej sa zobrazujú v
  /// lodnom denníku aj v PDF exporte, len prestanú kresliť do mapy. Presne
  /// preto to nie je červené tlačidlo — z pohľadu záznamu sa nič nestráca.
  ///
  /// Sedí to na kompase, nie na mape: čistý štít potrebuje skiper vo chvíli,
  /// keď ide zameriavať, a to je práve tu.
  Future<void> _startNewSighting() async {
    final l = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(l.bearingsClearConfirm),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.bearingStartNew),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    await ref.read(bearingRepositoryProvider).hideAllFromMap();
    if (!mounted) return;
    // Aj voľby musia ísť dole, inak by ďalšie ťuknutie na Zameraj
    // pokračovalo v starom bode či objekte namiesto nového zamerania.
    ref.read(resectionTargetIdProvider.notifier).state = null;
    ref.read(activeSightGroupIdProvider.notifier).state = null;
  }

  /// Ukáže spočítaný, ešte neuložený námer a spýta sa, či ho zapísať.
  ///
  /// Vracia true na Uložiť, false na Zahodiť aj na zavretie ťuknutím mimo.
  Future<bool> _confirmDraft(BearingDraft draft) async {
    final l = AppLocalizations.of(context);
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF0D1B2A),
        title: Text(
          draft.kind == BearingKind.resection
              ? (draft.targetName ?? l.bearingModeResection)
              : (draft.label?.isNotEmpty == true
                  ? draft.label!
                  : l.bearingModeObject),
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_degrees(draft.trueBearing)} ${l.bearingTrueLabel}  '
              '(${_degrees(draft.magneticBearing)} ${l.bearingMagneticLabel})',
              style: const TextStyle(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              draft.declinationTrustworthy
                  ? l.bearingDeclinationApplied(
                      _signedDegrees(draft.declination))
                  : l.bearingDeclinationExpired,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
            for (final hint in draft.hints)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  switch (hint) {
                    BearingCaptureHint.sameTargetAsPrevious =>
                      l.bearingSameTargetHint,
                    BearingCaptureHint.shortBaseline =>
                      l.bearingShortBaselineHint,
                    BearingCaptureHint.movedDuringResection =>
                      l.bearingMovedHint,
                    BearingCaptureHint.declinationEstimated =>
                      l.bearingDeclinationFromTarget,
                    BearingCaptureHint.needsSecondSight =>
                      l.bearingNeedsSecondSight,
                  },
                  style: const TextStyle(color: Colors.amber, fontSize: 12),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l.cancel,
                style: const TextStyle(color: Colors.white60)),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l.save),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Názov novo zakladaného pátrania, kým naň nepadne prvý námer.
  String? _pendingObjectName;

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickResectionTarget() async {
    final picked = await pickWaypoint(
      context,
      dark: true,
      highlightId: ref.read(resectionTargetIdProvider),
      sortFrom: _lastKnownLatLng(),
    );
    if (picked == null || !mounted) return;
    ref.read(resectionTargetIdProvider.notifier).state = picked.id;
  }

  LatLng? _lastKnownLatLng() {
    final pos = LocationService().lastPosition;
    return pos == null ? null : LatLng(pos.latitude, pos.longitude);
  }

  /// Výber pátrania, do ktorého padne ďalší námer, alebo založenie nového.
  Future<void> _chooseSightObject() async {
    final l = AppLocalizations.of(context);
    final groups = ref.read(sightGroupsProvider);

    final chosen = await showModalBottomSheet<Object>(
      context: context,
      backgroundColor: const Color(0xFF0D1B2A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 12),
          Text(l.bearingOpenObjects,
              style: const TextStyle(color: Colors.white, fontSize: 16)),
          const Divider(color: Colors.white24, height: 20),
          for (final g in groups)
            ListTile(
              leading: const Icon(Icons.push_pin_outlined,
                  color: Colors.white54),
              title: Text(g.name.isEmpty ? l.bearingObjectFix : g.name,
                  style: const TextStyle(color: Colors.white)),
              subtitle: Text(l.bearingSightCount(g.bearings.length),
                  style: const TextStyle(
                      color: Colors.white38, fontSize: 11)),
              onTap: () => Navigator.pop(sheetContext, g.id),
            ),
          ListTile(
            leading: const Icon(Icons.add, color: Colors.amber),
            title: Text(l.bearingNewObject,
                style: const TextStyle(color: Colors.amber)),
            onTap: () => Navigator.pop(sheetContext, _newObjectSentinel),
          ),
          const SizedBox(height: 8),
        ]),
      ),
    );

    if (chosen == null || !mounted) return;
    if (chosen is String && chosen != _newObjectSentinel) {
      ref.read(activeSightGroupIdProvider.notifier).state = chosen;
      return;
    }

    final name = await _promptObjectName();
    if (name == null || !mounted) return;
    // Skupina vznikne až s prvým námerom — dovtedy sa drží len názov, aby
    // zrušené pátranie nezostalo v databáze ako prázdna skupina.
    _pendingObjectName = name;
    ref.read(activeSightGroupIdProvider.notifier).state = null;
  }

  static const _newObjectSentinel = '__new__';

  Future<String?> _promptObjectName() async {
    final l = AppLocalizations.of(context);
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        content: TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(labelText: l.bearingObjectName),
          onSubmitted: (v) => Navigator.pop(ctx, v),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, controller.text),
              child: Text(l.save)),
        ],
      ),
    );
    final trimmed = name?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  void _reportCapture(BearingCaptureResult result, bool wasStable) {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();

    switch (result) {
      case BearingCaptured(
          :final trueBearing,
          :final declination,
          :final declinationTrustworthy
        ):
        final notes = <String>[
          if (declinationTrustworthy)
            l.bearingDeclinationApplied(_signedDegrees(declination))
          else
            l.bearingDeclinationExpired,
          for (final hint in result.hints)
            switch (hint) {
              BearingCaptureHint.sameTargetAsPrevious =>
                l.bearingSameTargetHint,
              BearingCaptureHint.shortBaseline => l.bearingShortBaselineHint,
              BearingCaptureHint.movedDuringResection => l.bearingMovedHint,
              BearingCaptureHint.declinationEstimated =>
                l.bearingDeclinationFromTarget,
              BearingCaptureHint.needsSecondSight => l.bearingNeedsSecondSight,
            },
          if (!wasStable) l.compassCalibrationNote,
        ];
        messenger.showSnackBar(SnackBar(
          duration: const Duration(seconds: 6),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l.bearingSaved(
                  '${_degrees(trueBearing)} ${l.bearingTrueLabel}')),
              for (final note in notes)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(note,
                      style: const TextStyle(fontSize: 11, height: 1.3)),
                ),
            ],
          ),
        ));

      case BearingNeedsObserverPosition():
        messenger.showSnackBar(SnackBar(
          duration: const Duration(seconds: 6),
          content: Text(l.bearingNoPosition),
          backgroundColor: Colors.orange.shade800,
        ));

      case BearingNeedsTarget():
        messenger.showSnackBar(SnackBar(
          content: Text(l.bearingNeedsTarget),
          backgroundColor: Colors.orange.shade800,
        ));

      case BearingNeedsObject():
        messenger.showSnackBar(SnackBar(
          content: Text(l.bearingNeedsObject),
          backgroundColor: Colors.orange.shade800,
        ));

      case BearingCaptureFailed(:final error):
        messenger.showSnackBar(SnackBar(
          content: Text('${l.bearingSaveFailed}\n$error'),
          backgroundColor: Colors.red.shade800,
        ));

      case BearingPrepared():
        // Sem sa nedostane: _capture() návrh vždy potvrdí alebo zahodí
        // pred volaním _reportCapture. Vetva je tu len kvôli vyčerpaniu
        // switchu nad sealed typom.
        break;
    }
  }

  static String _degrees(double value) =>
      '${(value.round() % 360).toString().padLeft(3, '0')}°';

  static String _signedDegrees(double value) =>
      '${value >= 0 ? '+' : '-'}${value.abs().toStringAsFixed(1)}°';

  @override
  void dispose() {
    LocationService().releasePrecise(this);
    WidgetsBinding.instance.removeObserver(this);
    _magSub?.cancel();
    _accSub?.cancel();
    _camCtrl?.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── Camera background ─────────────────────────────
          if (_cameraReady && _camCtrl != null)
            CameraPreview(_camCtrl!)
          else if (_cameraPermissionDenied)
            _NoCamera(label: l.cameraPermissionDenied, canRetry: false)
          else if (_cameraFailed)
            _NoCamera(label: l.cameraUnavailable, canRetry: true, onRetry: () {
              setState(() { _cameraFailed = false; });
              _initCamera();
            })
          else
            const DecoratedBox(
              decoration: BoxDecoration(color: Colors.black),
              child: Center(child: CircularProgressIndicator(color: Colors.white30, strokeWidth: 1.5)),
            ),

          // ── Top gradient ──────────────────────────────────
          if (_cameraReady)
            Positioned(
              top: 0, left: 0, right: 0,
              height: topPad + 120,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.black.withValues(alpha: 0.7), Colors.transparent],
                  ),
                ),
              ),
            ),

          // ── Compass strip ─────────────────────────────────
          Positioned(
            top: topPad + 4,
            left: 0, right: 0,
            child: _CompassStrip(heading: _heading),
          ),

          // ── Screen label ──────────────────────────────────
          Positioned(
            top: topPad + 62,
            left: 0, right: 0,
            child: Center(
              child: Text(l.navCompass,
                  style: const TextStyle(
                      color: Colors.white60, fontSize: 12, letterSpacing: 2)),
            ),
          ),

          // ── Čistý štít ────────────────────────────────────
          // Hore vpravo, mimo dosahu palca, ktorý drží tlačidlo Zameraj:
          // je to akcia na začiatku práce, nie počas nej.
          Positioned(
            top: topPad + 4,
            right: 4,
            child: IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white70),
              tooltip: l.bearingStartNew,
              onPressed: _startNewSighting,
            ),
          ),

          // ── Crosshair + readout ───────────────────────────
          Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const SizedBox(height: 60),
              const _Crosshair(),
              const SizedBox(height: 20),
              _BearingReadout(heading: _heading),
            ]),
          ),

          // ── Stability indicator ──────────────────────────────
          Positioned(
            bottom: 232,
            left: 24, right: 24,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 8, height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isStable ? Colors.greenAccent : Colors.orangeAccent,
                ),
              ),
              const SizedBox(width: 6),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 500),
                style: TextStyle(
                  color: _isStable ? Colors.greenAccent : Colors.orangeAccent,
                  fontSize: 11,
                ),
                child: Text(_isStable ? 'Stable' : 'Calibrating…'),
              ),
            ]),
          ),

          // ── Poznámka o presnosti kompasu ──────────────────────
          // Celkom dole, pod všetkým ostatným: je to varovanie, nie
          // ovládací prvok, a predtým bolo skoro nečitateľné (biela na
          // svetlom pozadí kamery, ledva viditeľná).
          Positioned(
            bottom: bottomPad + 4,
            left: 16, right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(l.compassCalibrationNote,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontSize: 10)),
            ),
          ),

          // ── Režim, cieľ a zameranie ──────────────────────────
          // Jeden stĺpec prilepený k spodku, nie dve samostatné vrstvy:
          // predtým visel prepínač vysoko nad tlačidlom, takmer v strede
          // obrazovky, kde prekážal výhľadu na objekt. Takto sedí prepínač
          // aj výber bodu tesne nad tlačidlom Zameraj, čo najnižšie, a
          // tlačidlo samo zostáva presne tam, kde ho má palec zvyknutý.
          Positioned(
            bottom: 36,
            left: 16, right: 16,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              _ModeToggle(
                mode: ref.watch(bearingModeProvider),
                onChanged: (m) =>
                    ref.read(bearingModeProvider.notifier).state = m,
              ),
              const SizedBox(height: 6),
              _SightTargetChip(
                mode: ref.watch(bearingModeProvider),
                targetName: ref.watch(resectionTargetProvider)?.name,
                objectName: ref.watch(activeSightGroupProvider)?.name ??
                    _pendingObjectName,
                onTap: () => ref.read(bearingModeProvider) ==
                        BearingKind.resection
                    ? _pickResectionTarget()
                    : _chooseSightObject(),
              ),
              const SizedBox(height: 10),
              _CaptureButton(busy: _capturing, onPressed: _capture),
            ]),
          ),
        ],
      ),
    );
  }
}

// ── Capture control ───────────────────────────────────────────

class _CaptureButton extends StatelessWidget {
  final bool busy;
  final VoidCallback onPressed;
  const _CaptureButton({required this.busy, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: FilledButton.icon(
        onPressed: busy ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.yellowAccent,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          textStyle:
              const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        icon: busy
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.black54))
            : const Icon(Icons.architecture),
        label: Text(l.bearingTakeSight),
      ),
    );
  }
}

/// Prepínač: hľadám seba, alebo hľadám bod?
///
/// Pod prepínačom je jednoveta o tom, čo daný režim potrebuje — vrátane GPS.
/// Radšej to povedať vopred než odmietnutým ťuknutím.
class _ModeToggle extends StatelessWidget {
  final BearingKind mode;
  final ValueChanged<BearingKind> onChanged;
  const _ModeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Column(mainAxisSize: MainAxisSize.min, children: [
      DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _segment(
            selected: mode == BearingKind.resection,
            icon: Icons.person_pin_circle,
            label: l.bearingModeResection,
            onTap: () => onChanged(BearingKind.resection),
          ),
          _segment(
            selected: mode == BearingKind.intersection,
            icon: Icons.push_pin_outlined,
            label: l.bearingModeObject,
            onTap: () => onChanged(BearingKind.intersection),
          ),
        ]),
      ),
      const SizedBox(height: 4),
      // Vlastné pozadie, nie holý text priamo na kamere: nad slnkom
      // zaliatou palubou bolo biele písmo na svetlom pozadí prakticky
      // nečitateľné.
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          mode == BearingKind.resection
              ? l.bearingModeResectionHint
              : l.bearingModeObjectHint,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
      ),
    ]);
  }

  Widget _segment({
    required bool selected,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? Colors.yellowAccent : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon,
                size: 15,
                color: selected ? Colors.black : Colors.white60),
            const SizedBox(width: 5),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight:
                        selected ? FontWeight.bold : FontWeight.normal,
                    color: selected ? Colors.black : Colors.white60)),
          ]),
        ),
      );
}

/// Na čo sa práve mieri — zameraný známy bod, alebo hľadaný neznámy objekt.
class _SightTargetChip extends StatelessWidget {
  final BearingKind mode;
  final String? targetName;
  final String? objectName;
  final VoidCallback onTap;

  const _SightTargetChip({
    required this.mode,
    required this.targetName,
    required this.objectName,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final resection = mode == BearingKind.resection;
    final name = resection ? targetName : objectName;
    final empty = name == null || name.isEmpty;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: empty ? Colors.amber.withValues(alpha: 0.6)
                  : Colors.white24),
        ),
        child: Row(children: [
          Icon(resection ? Icons.edit_location_alt : Icons.push_pin_outlined,
              size: 16, color: empty ? Colors.amber : Colors.white70),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              empty
                  ? (resection ? l.bearingPickTarget : l.bearingNewObject)
                  : name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 13,
                  color: empty ? Colors.amber : Colors.white),
            ),
          ),
          const Icon(Icons.unfold_more, size: 16, color: Colors.white38),
        ]),
      ),
    );
  }
}

// ── Compass strip ─────────────────────────────────────────────

class _CompassStrip extends StatelessWidget {
  final double heading;
  const _CompassStrip({required this.heading});

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 56,
        child: CustomPaint(painter: _StripPainter(heading: heading)),
      );
}

class _StripPainter extends CustomPainter {
  final double heading;
  static const _cardinals = {
    0: 'N', 45: 'NE', 90: 'E', 135: 'SE',
    180: 'S', 225: 'SW', 270: 'W', 315: 'NW',
  };

  const _StripPainter({required this.heading});

  @override
  void paint(Canvas canvas, Size size) {
    const visibleDeg = 90.0;
    final pxPerDeg = size.width / visibleDeg;
    final cx = size.width / 2;

    for (int d = -180; d <= 540; d++) {
      double delta = (d - heading) % 360;
      if (delta > 180) delta -= 360;
      if (delta < -180) delta += 360;
      if (delta.abs() > visibleDeg / 2 + 1) continue;

      final x = cx + delta * pxPerDeg;
      final norm = ((d % 360) + 360) % 360;
      final isCardinal = norm % 90 == 0;
      final isInterCardinal = norm % 45 == 0;
      final isNorth = norm == 0;
      final tickH = isCardinal ? 24.0 : (isInterCardinal ? 16.0 : 8.0);

      final paint = Paint()
        ..color = isNorth
            ? Colors.redAccent
            : (isCardinal ? Colors.white : Colors.white54)
        ..strokeWidth = isCardinal ? 2.0 : 1.2;
      canvas.drawLine(Offset(x, size.height - tickH), Offset(x, size.height), paint);

      final label = _cardinals[norm];
      if (label != null) {
        _drawText(canvas, label, x, size.height - tickH - 18,
            color: isNorth ? Colors.redAccent : Colors.white,
            fontSize: isCardinal ? 13 : 11,
            bold: isCardinal);
      } else if (norm % 30 == 0) {
        _drawText(canvas, '$norm°', x, size.height - 12 - 14,
            color: Colors.white38, fontSize: 9);
      }
    }

    // Centre marker
    canvas.drawLine(Offset(cx, 0), Offset(cx, size.height),
        Paint()..color = Colors.yellowAccent..strokeWidth = 1.5);
  }

  void _drawText(Canvas c, String text, double x, double y,
      {required Color color, required double fontSize, bool bold = false}) {
    final tp = TextPainter(
      text: TextSpan(
          text: text,
          style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(c, Offset(x - tp.width / 2, y));
  }

  @override
  bool shouldRepaint(_StripPainter old) => old.heading != heading;
}

// ── Crosshair ─────────────────────────────────────────────────

class _Crosshair extends StatelessWidget {
  const _Crosshair();

  @override
  Widget build(BuildContext context) =>
      SizedBox(width: 80, height: 80, child: CustomPaint(painter: _CrossPainter()));
}

class _CrossPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.yellowAccent..strokeWidth = 1.5;
    final cx = size.width / 2;
    final cy = size.height / 2;
    const g = 10.0;
    const a = 30.0;
    canvas.drawLine(Offset(cx, cy - g), Offset(cx, cy - a), p);
    canvas.drawLine(Offset(cx, cy + g), Offset(cx, cy + a), p);
    canvas.drawLine(Offset(cx - g, cy), Offset(cx - a, cy), p);
    canvas.drawLine(Offset(cx + g, cy), Offset(cx + a, cy), p);
    canvas.drawCircle(Offset(cx, cy), 3, p..style = PaintingStyle.fill);
    canvas.drawCircle(Offset(cx, cy), g, p..style = PaintingStyle.stroke..strokeWidth = 1);
  }

  @override
  bool shouldRepaint(_CrossPainter old) => false;
}

// ── Bearing readout ───────────────────────────────────────────

class _BearingReadout extends StatelessWidget {
  final double heading;
  const _BearingReadout({required this.heading});

  String _cardinal(double h) {
    const dirs = ['N','NNE','NE','ENE','E','ESE','SE','SSE',
                   'S','SSW','SW','WSW','W','WNW','NW','NNW'];
    return dirs[((h + 11.25) / 22.5).floor() % 16];
  }

  @override
  Widget build(BuildContext context) {
    final deg = heading.round() % 360;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          Text(
            '${deg.toString().padLeft(3, '0')}°',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 52,
              fontWeight: FontWeight.w200,
              letterSpacing: 3,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 14),
          Text(
            _cardinal(heading),
            style: const TextStyle(
                color: Colors.yellowAccent, fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// ── No camera placeholder ─────────────────────────────────────

class _NoCamera extends StatelessWidget {
  final String label;
  final bool canRetry;
  final VoidCallback? onRetry;
  const _NoCamera({required this.label, this.canRetry = false, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return DecoratedBox(
        decoration: const BoxDecoration(color: Colors.black),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.no_photography_outlined, color: Colors.white38, size: 56),
              const SizedBox(height: 16),
              Text(label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white54, fontSize: 14)),
              const SizedBox(height: 16),
              if (canRetry && onRetry != null)
                OutlinedButton(
                  onPressed: onRetry,
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.white70),
                  child: Text(l.retry),
                )
              else
                OutlinedButton(
                  onPressed: openAppSettings,
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.white70),
                  child: Text(l.openSettingsAction),
                ),
            ]),
          ),
        ),
      );
  }
}
