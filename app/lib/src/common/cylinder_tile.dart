import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/preferences_bloc.dart';
import '../preferences/preferences.dart';
import 'common.dart';

class CylinderTile extends StatelessWidget {
  final int index;
  final String description;
  final int oxygenPct;
  final int heliumPct;
  final double size;
  final double workingPressure;
  final double beginPressure;
  final double endPressure;
  final double sac;

  final Widget? leading;
  final Widget? trailing;
  final void Function()? onTap;

  const CylinderTile({
    required this.index,
    required this.description,
    this.oxygenPct = 0,
    this.heliumPct = 0,
    this.size = 0,
    this.workingPressure = 0,
    this.beginPressure = 0,
    this.endPressure = 0,
    this.sac = 0,
    this.leading,
    this.trailing,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final desc = description.isNotEmpty ? description : 'Cylinder ${index + 1}';
    final details = <Widget>[];

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

    final volUnit = context.watch<PreferencesBloc>().state.preferences.volumeUnit;
    final cylinderSize = volUnit == VolumeUnit.liters ? size : size * workingPressure;

    if (cylinderSize > 0) details.add(VolumeText(cylinderSize));
    if (workingPressure > 0) details.add(PressureText(workingPressure));
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
