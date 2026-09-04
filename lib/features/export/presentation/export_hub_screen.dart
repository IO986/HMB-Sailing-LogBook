import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../core/database/app_database.dart';
import '../../../core/providers/sync_settings_provider.dart';
import '../../../core/utils/localized_date.dart';
import '../../../main.dart';
import '../../bearing/providers/bearing_provider.dart';
import '../../charter/providers/charter_provider.dart';
import '../services/handover_export.dart';

/// Jedno miesto pre všetko, čo z appky vychádza ako dokument.
///
/// Exporty boli roztrúsené po siedmich obrazovkách: denník plavby pod tromi
/// bodkami v detaile plavby, deň v menu dňa, protokol na svojej obrazovke,
/// potvrdenia posádky inde, potvrdenie o míľach v Knihe míľ, zamerania na
/// svojej obrazovke. Kto hľadal „ako to dostanem von", musel vedieť, kde to
/// vzniklo. Tu je to zoradené podľa toho, čo sa exportuje, nie podľa toho,
/// kde v appke to býva.
///
/// Zámerne tu NIE JE záloha databázy: nie je to dokument pre niekoho, ale
/// obraz dát, ktorý patrí k obnove — ostáva v Nastaveniach vedľa nej.
class ExportHubScreen extends ConsumerStatefulWidget {
  const ExportHubScreen({super.key});

  @override
  ConsumerState<ExportHubScreen> createState() => _ExportHubScreenState();
}

class _ExportHubScreenState extends ConsumerState<ExportHubScreen> {
  /// Plavba, ktorej sa týka prvá sekcia. `null` = ešte nevybraná, platí
  /// predvolená (prebiehajúca, inak posledná).
  int? _charterId;

  Charter? _current(List<Charter> charters) {
    if (charters.isEmpty) return null;
    if (_charterId != null) {
      for (final c in charters) {
        if (c.id == _charterId) return c;
      }
    }
    final sorted = [...charters]
      ..sort((a, b) => b.dateFrom.compareTo(a.dateFrom));
    // Prebiehajúca plavba je tá, ktorá ešte nebola odovzdaná — z nej sa
    // exportuje najčastejšie, a to hneď po zakotvení.
    for (final c in sorted) {
      if (!c.checkOutDone) return c;
    }
    return sorted.first;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final chartersAsync = ref.watch(chartersProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l.exportsTitle)),
      body: chartersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (charters) {
          final charter = _current(charters);
          return ListView(
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              _VoyagePicker(
                charters: charters,
                current: charter,
                onPicked: (c) => setState(() => _charterId = c.id),
              ),
              _SectionHeader(l.exportsThisVoyage),
              if (charter == null)
                _EmptyRow(l.exportsNoVoyages)
              else ...[
                _ExportRow(
                  icon: Icons.menu_book_outlined,
                  title: l.exportsWholeVoyage,
                  subtitle: l.exportsWholeVoyageDesc,
                  trailing: l.exportsFormatPdfGpx,
                  onTap: () => context.push('/logbook/${charter.id}/export'),
                ),
                _DaysTile(charter: charter),
                _HandoverTile(charter: charter),
                _ExportRow(
                  icon: Icons.workspace_premium_outlined,
                  title: l.crewCertTitle,
                  subtitle: l.exportsCrewCertsDesc,
                  trailing: l.exportsFormatPdf,
                  onTap: () =>
                      context.push('/logbook/${charter.id}/crew-certificates'),
                ),
              ],
              _SectionHeader(l.exportsAcrossVoyages),
              _ExportRow(
                icon: Icons.military_tech_outlined,
                title: l.milesExportTitle,
                subtitle: l.exportsMilesCertDesc,
                trailing: l.exportsFormatPdf,
                onTap: () => context.push('/miles/export'),
              ),
              const _BearingsTile(),
              _SectionHeader(l.exportsAutomatic),
              const _CloudStatusRow(),
            ],
          );
        },
      ),
    );
  }
}

// ── Výber plavby ──────────────────────────────────────────────

class _VoyagePicker extends ConsumerWidget {
  final List<Charter> charters;
  final Charter? current;
  final ValueChanged<Charter> onPicked;
  const _VoyagePicker({
    required this.charters,
    required this.current,
    required this.onPicked,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = AppDate.of(context, ref);
    final c = current;

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: ListTile(
        leading: const Icon(Icons.sailing),
        title: Text(c?.title ?? l.exportsNoVoyages,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: c == null
            ? null
            : Text('${fmt.short(c.dateFrom)} – ${fmt.short(c.dateTo)}'),
        trailing: charters.length < 2 ? null : const Icon(Icons.swap_horiz),
        onTap: charters.length < 2
            ? null
            : () async {
                final picked = await showModalBottomSheet<Charter>(
                  context: context,
                  showDragHandle: true,
                  isScrollControlled: true,
                  builder: (ctx) => SafeArea(
                    child: ListView(shrinkWrap: true, children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: Text(l.exportsPickVoyage,
                            style: Theme.of(ctx).textTheme.titleMedium),
                      ),
                      for (final ch in [...charters]
                        ..sort((a, b) => b.dateFrom.compareTo(a.dateFrom)))
                        ListTile(
                          leading: const Icon(Icons.sailing),
                          title: Text(ch.title),
                          subtitle: Text(
                              '${fmt.short(ch.dateFrom)} – ${fmt.short(ch.dateTo)}'),
                          selected: ch.id == c?.id,
                          onTap: () => Navigator.pop(ctx, ch),
                        ),
                    ]),
                  ),
                );
                if (picked != null) onPicked(picked);
              },
      ),
    );
  }
}

// ── Dni plavby ────────────────────────────────────────────────

class _DaysTile extends ConsumerWidget {
  final Charter charter;
  const _DaysTile({required this.charter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = AppDate.of(context, ref);
    final daysAsync = ref.watch(dayLogsProvider(charter.id));

    return ExpansionTile(
      leading: const Icon(Icons.today_outlined),
      title: Text(l.exportsDay),
      subtitle: Text(l.exportsDayDesc),
      children: daysAsync.when(
        loading: () => const [
          Padding(
            padding: EdgeInsets.all(12),
            child: Center(child: CircularProgressIndicator()),
          )
        ],
        error: (e, _) => [_EmptyRow('$e')],
        data: (days) {
          if (days.isEmpty) return [_EmptyRow(l.exportsNoDays)];
          final sorted = [...days]..sort((a, b) => b.date.compareTo(a.date));
          return [
            for (final day in sorted)
              ListTile(
                dense: true,
                contentPadding: const EdgeInsets.only(left: 56, right: 16),
                title: Text(fmt.longNoYear(day.date)),
                subtitle: Text(
                    '${day.portFrom ?? "?"} → ${day.portTo ?? "?"}'),
                trailing: Text(l.exportsFormatPdfGpx,
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
                onTap: () => context
                    .push('/logbook/${charter.id}/day/${day.id}/export'),
              ),
          ];
        },
      ),
    );
  }
}

// ── Odovzdávací protokol ──────────────────────────────────────

/// Prevzatie a odovzdanie ako dva riadky, každý so svojím stavom.
///
/// Riadok bez protokolu ostáva neaktívny namiesto toho, aby zmizol: skiper
/// tak vidí, že check-out ešte nevyplnil, a nehľadá ho inde.
class _HandoverTile extends ConsumerWidget {
  final Charter charter;
  const _HandoverTile({required this.charter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final db = ref.watch(databaseProvider);

    return ExpansionTile(
      leading: const Icon(Icons.handshake_outlined),
      title: Text(l.handoverMenuTitle),
      subtitle: Text(l.exportsHandoverDesc),
      children: [
        for (final (type, label) in [
          ('checkIn', l.checkInProtocol),
          ('checkOut', l.checkOutProtocol),
        ])
          FutureBuilder<HandoverProtocol?>(
            future: db.getHandoverProtocol(charter.id, type),
            builder: (ctx, snap) {
              final protocol = snap.data;
              final ready = protocol != null;
              return ListTile(
                dense: true,
                contentPadding: const EdgeInsets.only(left: 56, right: 16),
                enabled: ready,
                title: Text(label),
                subtitle: Text(ready ? l.exportsFormatPdf : l.exportsNotFilledIn),
                onTap: ready
                    ? () => exportHandoverProtocolPdf(context, ref,
                        charter: charter, type: type)
                    : null,
              );
            },
          ),
      ],
    );
  }
}

// ── Zamerania mimo plavby ─────────────────────────────────────

class _BearingsTile extends ConsumerWidget {
  const _BearingsTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final fmt = AppDate.of(context, ref);
    final sessions = ref.watch(orphanBearingSessionsProvider);

    return ExpansionTile(
      leading: const Icon(Icons.architecture),
      title: Text(l.bearingsTitle),
      subtitle: Text(l.exportsBearingsDesc),
      children: sessions.isEmpty
          ? [_EmptyRow(l.exportsNoBearings)]
          : [
              for (final s in sessions)
                ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.only(left: 56, right: 16),
                  title: Text(fmt.long(s.date)),
                  subtitle: Text(l.entriesShort(s.bearings.length)),
                  trailing: Text(l.exportsFormatPdf,
                      style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  // Zameranie sa tlačí aj s mapou, a tú vie odfotiť len jeho
                  // vlastná obrazovka — otvorí sa s pokynom exportovať, hneď
                  // ako je snímka mapy hotová.
                  onTap: () => context.push(
                      '/logbook/bearings/${DateFormat('yyyy-MM-dd').format(s.date)}'
                      '?export=1'),
                ),
            ],
    );
  }
}

// ── Cloud ─────────────────────────────────────────────────────

class _CloudStatusRow extends ConsumerWidget {
  const _CloudStatusRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final enabled =
        ref.watch(syncSettingsProvider).valueOrNull?.cloudEnabled ?? false;

    return ListTile(
      leading: Icon(enabled ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
          color: enabled ? Colors.green : Colors.grey),
      title: Text(l.exportsCloudTitle),
      subtitle: Text(enabled ? l.exportsCloudOn : l.exportsCloudOff),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.push('/settings'),
    );
  }
}

// ── Spoločné kúsky ────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader(this.label);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
        child: Text(label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              letterSpacing: 1,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            )),
      );
}

class _ExportRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String trailing;
  final VoidCallback onTap;
  const _ExportRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Text(trailing,
            style: const TextStyle(fontSize: 11, color: Colors.grey)),
        onTap: onTap,
      );
}

class _EmptyRow extends StatelessWidget {
  final String label;
  const _EmptyRow(this.label);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(56, 8, 16, 12),
        child: Text(label, style: const TextStyle(color: Colors.grey)),
      );
}
