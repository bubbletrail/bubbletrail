import 'package:flutter/material.dart';

import 'common.dart';

class CylinderTile extends StatelessWidget {
  final int index;
  final String description;
  final int oxygenPct;
  final int heliumPct;
  final double volumeL;
  final double workingPressureBar;
  final double beginPressure;
  final double endPressure;
  final double sac;
  final double workingPressurePsi;
  final double volumeCuft;
  final bool defaultForBackgas;
  final bool defaultForDeepDeco;
  final bool defaultForShallowDeco;

  final Widget? trailing;
  final void Function()? onTap;
  final EdgeInsets? contentPadding;

  const CylinderTile({
    required this.index,
    required this.description,
    this.oxygenPct = 0,
    this.heliumPct = 0,
    this.volumeL = 0,
    this.workingPressureBar = 0,
    this.beginPressure = 0,
    this.endPressure = 0,
    this.sac = 0,
    this.workingPressurePsi = 0,
    this.volumeCuft = 0,
    this.defaultForBackgas = false,
    this.defaultForDeepDeco = false,
    this.defaultForShallowDeco = false,
    this.trailing,
    this.onTap,
    this.contentPadding,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final desc = description.isNotEmpty ? description : 'Cylinder ${index + 1}';
    final details = <Widget>[];

    if (workingPressurePsi > 0 && volumeCuft > 0) {
      details.add(LabeledChip(label: 'Volume', child: Text('${formatDisplayValue(volumeCuft)} cuft')));
      details.add(LabeledChip(label: 'WP', child: Text('${formatDisplayValue(workingPressurePsi)} psi')));
    } else {
      if (volumeL > 0) details.add(LabeledChip(label: 'Volume', child: Text('${formatDisplayValue(volumeL)} L')));
      if (workingPressureBar > 0) details.add(LabeledChip(label: 'WP', child: Text('${formatDisplayValue(workingPressureBar)} bar')));
    }
    if (oxygenPct > 0) details.add(LabeledChip(label: 'Mix', child: Text(formatGasPercentage(oxygenPct, heliumPct))));
    if (beginPressure > 0) details.add(LabeledChip(label: 'Start', child: PressureText(beginPressure)));
    if (endPressure > 0) details.add(LabeledChip(label: 'End', child: PressureText(endPressure)));
    if (sac > 0) {
      details.add(
        LabeledChip(
          label: 'SAC',
          child: VolumeText(sac, suffix: '/min'),
        ),
      );
    }

    final defaults = <Widget>[];
    if (defaultForBackgas) defaults.add(_DefaultBadge(label: 'Backgas'));
    if (defaultForDeepDeco) defaults.add(_DefaultBadge(label: 'Deep deco'));
    if (defaultForShallowDeco) defaults.add(_DefaultBadge(label: 'Shallow deco'));

    return ListTile(
      contentPadding: contentPadding,
      title: Padding(
        padding: const .only(left: 8.0, bottom: 8.0),
        child: Row(spacing: 8, children: [Text(desc), if (defaults.isNotEmpty) ...defaults]),
      ),
      subtitle: Wrap(spacing: 8, runSpacing: 8, children: details),
      trailing: trailing,
      onTap: onTap,
    );
  }
}

class _DefaultBadge extends StatelessWidget {
  final String label;

  const _DefaultBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const .symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer)),
    );
  }
}
