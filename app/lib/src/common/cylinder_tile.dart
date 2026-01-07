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

  final Widget? leading;
  final Widget? trailing;
  final void Function()? onTap;

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
    this.leading,
    this.trailing,
    this.onTap,
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
    details.add(LabeledChip(label: 'Mix', child: Text(formatGasPercentage(oxygenPct, heliumPct))));
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

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Padding(padding: const EdgeInsets.only(left: 8.0, bottom: 8.0), child: Text(desc)),
      subtitle: Wrap(spacing: 8, runSpacing: 8, children: details),
      leading: leading,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
