import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hmb_core/hmb_core.dart' hide LocationService;

import '../../../../core/database/app_database.dart';
import '../../../../core/providers/sync_provider.dart';
import '../../../../core/services/gps_tracking_service.dart';
import '../../../../core/services/location_service.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../main.dart';
import '../../../../shared/widgets/location_quality_badge.dart';

/// Mini-formulár po odfotení POI počas trackingu — potvrdí rýchly
/// denníkový záznam s fotkou, GPS/časom zachyteným automaticky.
class QuickPhotoLogSheet extends ConsumerStatefulWidget {
  final String photoPath;
  const QuickPhotoLogSheet({super.key, required this.photoPath});

  @override
  ConsumerState<QuickPhotoLogSheet> createState() => _QuickPhotoLogSheetState();
}

class _QuickPhotoLogSheetState extends ConsumerState<QuickPhotoLogSheet> {
  final _noteCtrl = TextEditingController();
  bool _saving = false;

  // Poloha sa zachytí raz pri otvorení sheetu (čas fotky), nie znova pri
  // uložení – medzitým mohla prísť čerstvejšia/horšia poloha.
  late final _pos = GpsTrackingService().lastPosition ?? LocationService().lastPosition;
  late final _locationSource = _pos != null ? LocationService().lastSource?.name : null;
  late final _isMocked = _pos != null ? LocationService().lastIsMocked : null;
  final _capturedAt = DateTime.now().toUtc();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(File(widget.photoPath),
                width: double.infinity, height: 180, fit: BoxFit.cover),
          ),
          const SizedBox(height: 16),
          Text(l.quickPhotoLogTitle,
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          LocationQualityBadge(
            accuracyMeters: (_pos != null && _pos.accuracy > 0) ? _pos.accuracy : null,
            locationSource: _locationSource,
            isMocked: _isMocked,
            timestamp: _capturedAt,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteCtrl,
            decoration: InputDecoration(hintText: l.quickPhotoNoteHint),
            autofocus: true,
            maxLines: 2,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l.cancel),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: _saving ? null : _save,
                icon: const Icon(Icons.save),
                label: Text(l.save),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final pos = _pos;
    final note = _noteCtrl.text.trim();
    final db = ref.read(databaseProvider);
    final engine = ref.read(syncEngineProvider);

    final companion = LogbookEntriesCompanion.insert(
      dayLogId: Value(GpsTrackingService().activeDayLogId),
      sessionId: Value(GpsTrackingService().currentSession?.sessionId),
      timestamp: _capturedAt,
      latitude: Value(pos?.latitude),
      longitude: Value(pos?.longitude),
      sog: Value(pos != null ? pos.speed * 1.94384 : null),
      cog: Value(pos?.heading),
      skipperNote: Value(note.isEmpty ? null : note),
      photoPath: Value(widget.photoPath),
      accuracyMeters: Value((pos != null && pos.accuracy > 0) ? pos.accuracy : null),
      locationSource: Value(_locationSource),
      isMocked: Value(_isMocked),
    );

    final payload = {
      'dayLogId': GpsTrackingService().activeDayLogId,
      'timestamp': _capturedAt.toIso8601String(),
      'latitude': pos?.latitude,
      'longitude': pos?.longitude,
      'sog': pos != null ? pos.speed * 1.94384 : null,
      'cog': pos?.heading,
      'skipperNote': note.isEmpty ? null : note,
    };
    final file = File(widget.photoPath);
    final attachments = await file.exists()
        ? [
            Attachment(
              localPath: widget.photoPath,
              field: 'photo',
              mimeType: 'image/jpeg',
              sizeBytes: await file.length(),
            ),
          ]
        : const <Attachment>[];

    // Lokálny zápis a enqueue() musia byť atomické — buď oboje, alebo nič.
    await db.transaction(() async {
      await db.insertLogbookEntry(companion);
      await engine.enqueue(
        entityType: 'log_entry',
        payload: payload,
        attachments: attachments,
      );
    });

    if (mounted) Navigator.pop(context);
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }
}
