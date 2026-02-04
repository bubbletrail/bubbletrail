import 'package:btproto/btproto.dart';
import 'package:flutter/material.dart';

import 'common.dart';

class EquipmentListTile extends StatelessWidget {
  final Equipment equipment;
  final void Function(Equipment) onTap;

  const EquipmentListTile({super.key, required this.equipment, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: EquipmentIcons.icon(EquipmentIcons.forType(equipment.type), color: Theme.of(context).colorScheme.onSurface, size: 32),
      title: Row(
        spacing: 8,
        children: [
          Flexible(child: Text(equipmentTitle(equipment), style: Theme.of(context).textTheme.bodyMedium)),
          if (equipment.defaultForNewDives) _DefaultBadge(),
        ],
      ),
      subtitle: equipmentSubtitle(equipment) != null
          ? Text(equipmentSubtitleText(equipment), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).hintColor))
          : null,
      trailing: Icon(Icons.drag_indicator, color: Theme.of(context).hintColor, size: 20),
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

class _DefaultBadge extends StatelessWidget {
  const _DefaultBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const .symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: .circular(4)),
      child: Text('Default', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer)),
    );
  }
}
