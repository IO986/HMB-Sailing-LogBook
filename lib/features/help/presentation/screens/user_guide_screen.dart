import 'package:flutter/material.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';

class UserGuideScreen extends StatelessWidget {
  const UserGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.userGuide),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        children: [
          // ── Quick start card ─────────────────────────────────
          Container(
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.green.shade300),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(Icons.rocket_launch, color: Colors.green.shade700),
                const SizedBox(width: 8),
                Text(l.guideQuickStart,
                    style: TextStyle(fontWeight: FontWeight.bold,
                        fontSize: 15, color: Colors.green.shade800)),
              ]),
              const SizedBox(height: 10),
              ...l.guideQuickStartBody.split('\n').map((line) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(line,
                    style: TextStyle(fontSize: 13, color: Colors.green.shade900,
                        height: 1.4)),
              )),
            ]),
          ),
          const SizedBox(height: 12),

          // ── Sections ─────────────────────────────────────────
          _GuideSection(
            icon: Icons.map_outlined,
            color: scheme.primary,
            title: l.guideMapTitle,
            body: l.guideMapBody,
          ),
          _GuideSection(
            icon: Icons.speed,
            color: const Color(0xFF27AE60),
            title: l.guideInstrTitle,
            body: l.guideInstrBody,
          ),
          _GuideSection(
            icon: Icons.book_outlined,
            color: Colors.indigo,
            title: l.guideLogbookTitle,
            body: l.guideLogbookBody,
          ),
          _GuideSection(
            icon: Icons.cloud_outlined,
            color: Colors.blue.shade700,
            title: l.guideWeatherTitle,
            body: l.guideWeatherBody,
          ),
          _GuideSection(
            icon: Icons.person_off,
            color: Colors.red.shade700,
            title: l.guideSafetyMobTitle,
            body: l.guideSafetyMobBody,
          ),
          _GuideSection(
            icon: Icons.checklist,
            color: Colors.orange.shade700,
            title: l.guideSafetyBriefingTitle,
            body: l.guideSafetyBriefingBody,
          ),
          _GuideSection(
            icon: Icons.explore_outlined,
            color: Colors.teal.shade600,
            title: l.guideCompassTitle,
            body: l.guideCompassBody,
          ),
          _GuideSection(
            icon: Icons.settings_outlined,
            color: Colors.blueGrey.shade600,
            title: l.guideSettingsTitle,
            body: l.guideSettingsBody,
          ),
          _GuideSection(
            icon: Icons.picture_as_pdf_outlined,
            color: Colors.deepOrange.shade600,
            title: l.guideExportTitle,
            body: l.guideExportBody,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Expandable section
// ─────────────────────────────────────────────────────────────

class _GuideSection extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String body;

  const _GuideSection({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: color.withOpacity(0.12),
          child: Icon(icon, color: color, size: 18),
        ),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 12),
          ..._buildBody(context, body),
        ],
      ),
    );
  }

  List<Widget> _buildBody(BuildContext context, String text) {
    final paragraphs = text.split('\n\n');
    final widgets = <Widget>[];
    for (final para in paragraphs) {
      final lines = para.split('\n');
      for (final line in lines) {
        if (line.startsWith('•') || line.startsWith('-')) {
          widgets.add(Padding(
            padding: const EdgeInsets.only(bottom: 4, left: 4),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('• ', style: TextStyle(color: color, fontWeight: FontWeight.bold)),
              Expanded(child: Text(line.replaceFirst(RegExp(r'^[•\-]\s*'), ''),
                  style: const TextStyle(fontSize: 13, height: 1.45))),
            ]),
          ));
        } else if (line.trim().isEmpty) {
          widgets.add(const SizedBox(height: 6));
        } else {
          widgets.add(Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Text(line, style: const TextStyle(fontSize: 13, height: 1.45)),
          ));
        }
      }
      widgets.add(const SizedBox(height: 4));
    }
    return widgets;
  }
}
