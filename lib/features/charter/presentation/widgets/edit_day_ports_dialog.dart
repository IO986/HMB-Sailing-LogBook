import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';

import '../../../../core/database/app_database.dart';
import '../../../../main.dart';
import '../../providers/charter_provider.dart';

/// Ručná oprava prístavov dňa.
///
/// Mená sem spravidla napíše appka sama (reverzný geocoding polohy pri
/// odchode a príchode), ale ten sa deje presne v tých dvoch chvíľach, keď
/// telefón na lodi visí na Wi-Fi prístrojov a internet nemá — a keď sa
/// podarí, trafí najbližšiu zátoku či mólo, nie nutne to, čo by skiper
/// napísal do denníka. Bez tohto dialógu by tam ostalo, čo appka uhádla,
/// alebo prázdno.
///
/// Vracia deň po úprave, alebo `null`, keď skiper výber zrušil.
Future<DayLog?> showEditDayPortsDialog(
    BuildContext context, WidgetRef ref, DayLog day) async {
  final l = AppLocalizations.of(context);
  final fromCtrl = TextEditingController(text: day.portFrom ?? '');
  final toCtrl = TextEditingController(text: day.portTo ?? '');

  final saved = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l.editRouteTitle),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(
          controller: fromCtrl,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: l.portFromLabel),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: toCtrl,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(labelText: l.portToLabel),
        ),
        const SizedBox(height: 10),
        Text(l.routeAutoFillHint,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
      ]),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
        ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true), child: Text(l.save)),
      ],
    ),
  );
  if (saved != true) return null;

  String? clean(String v) => v.trim().isEmpty ? null : v.trim();
  final db = ref.read(databaseProvider);
  await db.updateDayLog(DayLogsCompanion(
    id: Value(day.id),
    portFrom: Value(clean(fromCtrl.text)),
    portTo: Value(clean(toCtrl.text)),
  ));
  ref.invalidate(dayLogsProvider(day.charterId));
  return db.getDayLogById(day.id);
}
