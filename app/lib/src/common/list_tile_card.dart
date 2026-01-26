import 'package:flutter/material.dart';

class ListTileCard extends StatelessWidget {
  final IconData? icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const ListTileCard({super.key, this.icon, required this.title, this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: icon != null ? Icon(icon, size: 28) : null,
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing: const Icon(Icons.chevron_right, size: 16),
        onTap: onTap,
      ),
    );
  }
}
