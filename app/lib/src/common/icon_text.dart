import 'package:flutter/material.dart';

class IconText extends StatelessWidget {
  final String label;
  final IconData? icon;

  const IconText(this.icon, this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    if (icon == null) return Text(label);
    return Row(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.center, spacing: 4.0, children: [Icon(icon), Text(label)]);
  }
}
