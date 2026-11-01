import 'package:btl10n/btl10n.dart';
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
    final desc = description.isNotEmpty ? description : context.l10n.cylinderNumber(index + 1);
    final details = <Widget>[];

    if (workingPressurePsi > 0 && volumeCuft > 0) {
      details.add(LabeledChip(label: context.l10n.volume, child: Text(context.l10n.measurement(formatDisplayValue(volumeCuft), context.l10n.unitCubicFeet))));
      details.add(LabeledChip(label: context.l10n.wp, child: Text(context.l10n.measurement(formatDisplayValue(workingPressurePsi), context.l10n.unitPsi))));
    } else {
      if (volumeL > 0) {
        details.add(LabeledChip(label: context.l10n.volume, child: Text(context.l10n.measurement(formatDisplayValue(volumeL), context.l10n.unitLiters))));
      }
      if (workingPressureBar > 0) {
        details.add(LabeledChip(label: context.l10n.wp, child: Text(context.l10n.measurement(formatDisplayValue(workingPressureBar), context.l10n.unitBar))));
      }
    }
    if (oxygenPct > 0) details.add(LabeledChip(label: context.l10n.mix, child: Text(formatGasPercentage(context, oxygenPct, heliumPct))));
    if (beginPressure > 0) details.add(LabeledChip(label: context.l10n.start, child: PressureText(beginPressure)));
    if (endPressure > 0) details.add(LabeledChip(label: context.l10n.end, child: PressureText(endPressure)));
    if (sac > 0) {
      details.add(
        LabeledChip(
          label: context.l10n.sac,
          child: VolumeText(sac, suffix: context.l10n.perMinute, precise: true),
        ),
      );
    }

    final defaults = <Widget>[];
    final cs = Theme.of(context).colorScheme;
    if (defaultForBackgas) defaults.add(TextBadge(label: context.l10n.backgas, backgroundColor: cs.primaryContainer, textColor: cs.onPrimaryContainer));
    if (defaultForDeepDeco) defaults.add(TextBadge(label: context.l10n.deepDeco, backgroundColor: cs.primaryContainer, textColor: cs.onPrimaryContainer));
    if (defaultForShallowDeco) defaults.add(TextBadge(label: context.l10n.shallowDeco, backgroundColor: cs.primaryContainer, textColor: cs.onPrimaryContainer));

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
