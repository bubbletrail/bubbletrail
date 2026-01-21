import 'package:flutter/material.dart';

class ListTileCard extends StatelessWidget {
  final IconData? icon;
  final String title;
  final VoidCallback onTap;

  const ListTileCard({super.key, this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: icon != null ? Icon(icon, size: 28) : null,
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        trailing: const Icon(Icons.chevron_right, size: 16),
        onTap: onTap,
      ),
    );
  }
}
