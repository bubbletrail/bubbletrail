import 'package:btl10n/btl10n.dart';
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
      if (equipmentSubtitleText(context, equipment).isNotEmpty) equipmentSubtitleText(context, equipment),
      if (diveCount != null) context.l10n.diveCount(diveCount!),
      if (diveSeconds != null) context.l10n.underwater(formatTotalTime(context.l10n, diveSeconds!)),
    ];
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      leading: EquipmentIcons.icon(EquipmentIcons.forType(equipment.type), color: cs.onSurface, size: 32),
      title: Row(
        spacing: 8,
        children: [
          Flexible(child: Text(equipmentTitle(context, equipment), style: Theme.of(context).textTheme.bodyMedium)),
          if (equipment.defaultForNewDives)
            TextBadge(label: context.l10n.defaultEquipment, backgroundColor: cs.primaryContainer, textColor: cs.onPrimaryContainer),
          if (equipment.archived) TextBadge(label: context.l10n.archived, backgroundColor: cs.surfaceContainerHighest, textColor: cs.onSurfaceVariant),
        ],
      ),
      subtitle: subtitleParts.isNotEmpty
          ? Text(subtitleParts.join(' \u2022 '), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor))
          : null,
      trailing: trailing != null ? Icon(trailing, color: Theme.of(context).hintColor) : null,
      onTap: () => onTap(equipment),
    );
  }

  static String equipmentTitle(BuildContext context, Equipment item) {
    if (item.manufacturer.isNotEmpty && item.name.isNotEmpty) {
      return '${item.manufacturer} ${item.name}';
    }
    if (item.name.isNotEmpty) {
      return item.name;
    }
    if (item.manufacturer.isNotEmpty && item.type.isNotEmpty) {
      return '${item.manufacturer} ${equipmentTypeLabel(context.l10n, item.type)}';
    }
    if (item.type.isNotEmpty) {
      return equipmentTypeLabel(context.l10n, item.type);
    }
    return context.l10n.equipmentWithId(item.id);
  }

  static Widget? equipmentSubtitle(BuildContext context, Equipment item) {
    final text = equipmentSubtitleText(context, item);
    if (text.isEmpty) return null;
    return Text(text);
  }

  static String equipmentSubtitleText(BuildContext context, Equipment item) {
    final parts = <String>[];
    if (item.type.isNotEmpty && item.name.isNotEmpty) {
      parts.add(equipmentTypeLabel(context.l10n, item.type));
    }
    return parts.join(' \u2022 ');
  }
}
