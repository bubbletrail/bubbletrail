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
      details.add(Text('${formatDisplayValue(volumeCuft)} cuft'));
      details.add(Text('${formatDisplayValue(workingPressurePsi)} psi'));
    } else {
      if (volumeL > 0) details.add(Text('${formatDisplayValue(volumeL)} L'));
      if (workingPressureBar > 0) details.add(Text('${formatDisplayValue(workingPressureBar)} bar'));
    }

    // Gas mixture
    if (oxygenPct + heliumPct > 0) {
      var mix = 'Air';
      if (heliumPct > 0) {
        mix = 'Tx$oxygenPct/$heliumPct';
      } else if (oxygenPct != 21) {
        mix = 'EAN$oxygenPct';
      }
      details.add(IconText(Icons.speed, mix));
    }

    if (beginPressure > 0) details.add(PressureText(beginPressure, icon: Icons.battery_5_bar_outlined));
    if (endPressure > 0) details.add(PressureText(endPressure, icon: Icons.battery_1_bar_outlined));
    if (sac > 0) details.add(VolumeText(sac, icon: Icons.av_timer, suffix: '/min'));

    return ListTile(
      title: Text(desc),
      subtitle: Wrap(spacing: 8, runSpacing: 8, children: details),
      leading: leading,
      trailing: trailing,
      onTap: onTap,
    );
  }
}
