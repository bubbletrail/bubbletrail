import 'package:btproto/btproto.dart';
import 'package:flutter/material.dart';

import '../statistics/statistics_screen.dart';
import 'common.dart';

class EquipmentListTile extends StatelessWidget {
  final Equipment equipment;
  final void Function(Equipment) onTap;
  final IconData? trailing;
  final int? diveCount;
  final int? diveSeconds;

  const EquipmentListTile({super.key, required this.equipment, required this.onTap, this.trailing, this.diveCount, this.diveSeconds});

  @override
  Widget build(BuildContext context) {
    final subtitleParts = [
      if (equipmentSubtitleText(equipment).isNotEmpty) equipmentSubtitleText(equipment),
      if (diveCount != null) '$diveCount ${diveCount == 1 ? 'dive' : 'dives'}',
      if (diveSeconds != null) '${formatTotalTime(diveSeconds!)} underwater',
    ];
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: EquipmentIcons.icon(EquipmentIcons.forType(equipment.type), color: cs.onSurface, size: 32),
      title: Row(
        spacing: 8,
        children: [
          Flexible(child: Text(equipmentTitle(equipment), style: Theme.of(context).textTheme.bodyMedium)),
          if (equipment.defaultForNewDives) TextBadge(label: 'Default', backgroundColor: cs.primaryContainer, textColor: cs.onPrimaryContainer),
          if (equipment.archived) TextBadge(label: 'Archived', backgroundColor: cs.surfaceContainerHighest, textColor: cs.onSurfaceVariant),
        ],
      ),
      subtitle: subtitleParts.isNotEmpty
          ? Text(subtitleParts.join(' \u2022 '), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor))
          : null,
      trailing: trailing != null ? Icon(trailing, color: Theme.of(context).hintColor) : null,
      onTap: () => onTap(equipment),
    );
  }

  static String equipmentTitle(Equipment item) {
    if (item.manufacturer.isNotEmpty && item.name.isNotEmpty) {
      return '${item.manufacturer} ${item.name}';
    }
    if (item.name.isNotEmpty) {
      return item.name;
    }
    if (item.manufacturer.isNotEmpty && item.type.isNotEmpty) {
      return '${item.manufacturer} ${item.type}';
    }
    if (item.type.isNotEmpty) {
      return item.type;
    }
    return 'Equipment #${item.id}';
  }

  static Widget? equipmentSubtitle(Equipment item) {
    final text = equipmentSubtitleText(item);
    if (text.isEmpty) return null;
    return Text(text);
  }

  static String equipmentSubtitleText(Equipment item) {
    final parts = <String>[];
    if (item.type.isNotEmpty && item.name.isNotEmpty) {
      parts.add(item.type);
    }
    return parts.join(' \u2022 ');
  }
}
