import 'package:flutter/material.dart';
import '../../../../core/config/colreg_content.dart';
import '../../../../core/config/colreg_diagrams.dart';
import '../../../../l10n/app_localizations.dart';

class ColregScreen extends StatefulWidget {
  const ColregScreen({super.key});

  @override
  State<ColregScreen> createState() => _ColregScreenState();
}

class _ColregScreenState extends State<ColregScreen> {
  // null = zobrazený register (TOC), inak = ID otvorenej kapitoly
  String? _openChapterId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context).colregTitle),
        leading: _openChapterId != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _openChapterId = null),
              )
            : null,
      ),
      body: _openChapterId == null
          ? _TableOfContents(
              onSelect: (id) => setState(() => _openChapterId = id),
            )
          : _ChapterView(
              chapterId: _openChapterId!,
              onBackToToc: () => setState(() => _openChapterId = null),
            ),
    );
  }
}

// ── Register (klikateľný obsah) ─────────────────────────────────

class _TableOfContents extends StatelessWidget {
  final Function(String) onSelect;
  const _TableOfContents({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Text(AppLocalizations.of(context).tableOfContents, style: const TextStyle(
              fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.grey)),
        ),
        ...ColregContent.chaptersFor(Localizations.localeOf(context).languageCode)
            .map((chapter) => _ChapterTile(
          chapter: chapter,
          onSelect: onSelect,
        )),
        const SizedBox(height: 40),
      ],
    );
  }
}

class _ChapterTile extends StatelessWidget {
  final ColregSection chapter;
  final Function(String) onSelect;
  const _ChapterTile({required this.chapter, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => onSelect(chapter.id),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(chapter.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15))),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ]),
            if (chapter.children.isNotEmpty) ...[
              const SizedBox(height: 6),
              Wrap(
                spacing: 6, runSpacing: 4,
                children: chapter.children.map((sub) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    sub.ruleNumber != null ? AppLocalizations.of(context).ruleNumberLabel(sub.ruleNumber!) : sub.title,
                    style: const TextStyle(fontSize: 10),
                  ),
                )).toList(),
              ),
            ],
          ]),
        ),
      ),
    );
  }
}

// ── Zobrazenie kapitoly ──────────────────────────────────────────

class _ChapterView extends StatelessWidget {
  final String chapterId;
  final VoidCallback onBackToToc;
  const _ChapterView({required this.chapterId, required this.onBackToToc});

  @override
  Widget build(BuildContext context) {
    final chapter = ColregContent
        .chaptersFor(Localizations.localeOf(context).languageCode)
        .firstWhere((c) => c.id == chapterId);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(chapter.title, style: Theme.of(context).textTheme.headlineSmall
            ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),

        ...chapter.blocks.map(_buildBlock),

        // Mini-register podkapitol ak ich je viac
        if (chapter.children.length > 1) ...[
          const SizedBox(height: 8),
          Card(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(AppLocalizations.of(context).inThisChapter, style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface)),
                const SizedBox(height: 6),
                ...chapter.children.map((s) => Text('•  ${s.title}',
                    style: TextStyle(fontSize: 12,
                        color: Theme.of(context).colorScheme.onSurface))),
              ]),
            ),
          ),
          const SizedBox(height: 16),
        ],

        ...chapter.children.map((section) => _SectionView(section: section)),

        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: onBackToToc,
          icon: const Icon(Icons.list),
          label: Text(AppLocalizations.of(context).backToToc),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildBlock(ColregBlock block) => _BlockWidget(block: block);
}

class _SectionView extends StatelessWidget {
  final ColregSection section;
  const _SectionView({required this.section});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 4),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(
                color: Theme.of(context).colorScheme.primary, width: 2)),
          ),
          child: Text(section.title, style: Theme.of(context).textTheme.titleLarge
              ?.copyWith(fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary)),
        ),
        const SizedBox(height: 10),
        ...section.blocks.map((b) => _BlockWidget(block: b)),
      ]),
    );
  }
}

// ── Renderer pre jednotlivé typy blokov ─────────────────────────

class _BlockWidget extends StatelessWidget {
  final ColregBlock block;
  const _BlockWidget({required this.block});

  @override
  Widget build(BuildContext context) {
    if (block is ColregText) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text((block as ColregText).text,
            style: const TextStyle(fontSize: 14, height: 1.4)),
      );
    }

    if (block is ColregHeading) {
      return Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 6),
        child: Text((block as ColregHeading).text,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary)),
      );
    }

    if (block is ColregRuleBox) {
      final rb = block as ColregRuleBox;
      final cs = Theme.of(context).colorScheme;
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cs.secondaryContainer,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: cs.secondary.withOpacity(0.4)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(rb.title, style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 13,
              color: cs.onSecondaryContainer)),
          const SizedBox(height: 8),
          Text(rb.text, style: TextStyle(
              fontSize: 13, height: 1.45, color: cs.onSecondaryContainer)),
        ]),
      );
    }

    if (block is ColregList) {
      final list = block as ColregList;
      return Padding(
        padding: const EdgeInsets.only(bottom: 12, left: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: list.items.asMap().entries.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 5),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(width: 22, child: Text(
                list.numbered ? '${e.key + 1}.' : '•',
                style: const TextStyle(fontWeight: FontWeight.bold))),
              Expanded(child: Text(e.value, style: const TextStyle(fontSize: 13.5, height: 1.35))),
            ]),
          )).toList(),
        ),
      );
    }

    if (block is ColregDiagram) {
      final d = block as ColregDiagram;
      final widget = buildColregDiagram(d.diagramKey);
      if (widget == null) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(children: [
          widget,
          const SizedBox(height: 6),
          Text(d.caption, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic)),
        ]),
      );
    }

    if (block is ColregNote) {
      final note = block as ColregNote;
      final colors = _noteColors(note.type, context);
      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.bg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: colors.border),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(colors.icon, color: colors.iconColor, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(note.text,
              style: TextStyle(fontSize: 13, color: colors.text, height: 1.4))),
        ]),
      );
    }

    return const SizedBox.shrink();
  }

  ({Color bg, Color border, Color text, Color iconColor, IconData icon}) _noteColors(
      ColregNoteType type, BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    switch (type) {
      case ColregNoteType.danger:
        return (
          bg: Colors.red.withOpacity(0.12), border: Colors.red.shade400,
          text: onSurface, iconColor: Colors.red.shade400,
          icon: Icons.warning_amber_rounded,
        );
      case ColregNoteType.warning:
        return (
          bg: Colors.orange.withOpacity(0.12), border: Colors.orange.shade400,
          text: onSurface, iconColor: Colors.orange.shade500,
          icon: Icons.error_outline,
        );
      case ColregNoteType.story:
        return (
          bg: Colors.purple.withOpacity(0.10), border: Colors.purple.shade300,
          text: onSurface, iconColor: Colors.purple.shade300,
          icon: Icons.history_edu,
        );
      case ColregNoteType.info:
        return (
          bg: Colors.blue.withOpacity(0.10), border: Colors.blue.shade300,
          text: onSurface, iconColor: Colors.blue.shade300,
          icon: Icons.info_outline,
        );
    }
  }
}
