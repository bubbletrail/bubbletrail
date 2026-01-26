import 'package:btstore/btstore.dart' hide Container;
import 'package:flutter/material.dart';

import 'common.dart';

Future<List<Equipment>?> showEquipmentSelectionDialog({
  required BuildContext context,
  required List<Equipment> allEquipment,
  required List<Equipment> selectedEquipment,
}) {
  return showDialog<List<Equipment>>(
    context: context,
    builder: (dialogContext) => _EquipmentSelectionDialog(allEquipment: allEquipment, selectedEquipment: selectedEquipment),
  );
}

class _EquipmentSelectionDialog extends StatefulWidget {
  final List<Equipment> allEquipment;
  final List<Equipment> selectedEquipment;

  const _EquipmentSelectionDialog({required this.allEquipment, required this.selectedEquipment});

  @override
  State<_EquipmentSelectionDialog> createState() => _EquipmentSelectionDialogState();
}

class _EquipmentSelectionDialogState extends State<_EquipmentSelectionDialog> {
  late Set<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = widget.selectedEquipment.map((e) => e.id).toSet();
  }

  List<Equipment> get _selectedEquipment => widget.allEquipment.where((e) => _selectedIds.contains(e.id)).toList();

  List<Equipment> get _availableEquipment => widget.allEquipment.where((e) => !_selectedIds.contains(e.id)).toList();

  void _toggleEquipment(Equipment equipment) {
    setState(() {
      if (_selectedIds.contains(equipment.id)) {
        _selectedIds.remove(equipment.id);
      } else {
        _selectedIds.add(equipment.id);
      }
    });
  }

  void _selectEquipment(Equipment equipment) {
    setState(() {
      _selectedIds.add(equipment.id);
    });
  }

  void _deselectEquipment(Equipment equipment) {
    setState(() {
      _selectedIds.remove(equipment.id);
    });
  }

  void _confirm() {
    Navigator.of(context).pop(_selectedEquipment);
  }

  void _cancel() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 600;
        if (isWide) {
          return _buildWideLayout();
        } else {
          return _buildNarrowLayout();
        }
      },
    );
  }

  Widget _buildNarrowLayout() {
    return AlertDialog(
      title: const Text('Select equipment'),
      content: SizedBox(
        width: double.maxFinite,
        child: widget.allEquipment.isEmpty
            ? const Center(child: Text('No equipment available'))
            : ListView.builder(
                shrinkWrap: true,
                itemCount: widget.allEquipment.length,
                itemBuilder: (context, index) {
                  final equipment = widget.allEquipment[index];
                  final isSelected = _selectedIds.contains(equipment.id);
                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (_) => _toggleEquipment(equipment),
                    secondary: EquipmentIcons.icon(EquipmentIcons.forType(equipment.type), color: Theme.of(context).colorScheme.onSurface, size: 32),
                    title: Text(EquipmentListTile.equipmentTitle(equipment)),
                    subtitle: EquipmentListTile.equipmentSubtitle(equipment),
                  );
                },
              ),
      ),
      actions: [
        TextButton(onPressed: _cancel, child: const Text('Cancel')),
        TextButton(onPressed: _confirm, child: const Text('Done')),
      ],
    );
  }

  Widget _buildWideLayout() {
    final selected = _selectedEquipment;
    final available = _availableEquipment;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              Text('Select equipment', style: Theme.of(context).textTheme.headlineSmall),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Used Equipment column
                    Expanded(
                      child: _buildDragColumn(
                        title: 'Used this dive',
                        items: selected,
                        isSelectedColumn: true,
                        onItemDropped: _selectEquipment,
                        onItemTapped: _deselectEquipment,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Available Equipment column
                    Expanded(
                      child: _buildDragColumn(
                        title: 'Available equipment',
                        items: available,
                        isSelectedColumn: false,
                        onItemDropped: _deselectEquipment,
                        onItemTapped: _selectEquipment,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                spacing: 8,
                children: [
                  Text('Drag or tap items to move'),
                  Spacer(),
                  TextButton(onPressed: _cancel, child: const Text('Cancel')),
                  FilledButton(onPressed: _confirm, child: const Text('Done')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDragColumn({
    required String title,
    required List<Equipment> items,
    required bool isSelectedColumn,
    required void Function(Equipment) onItemDropped,
    required void Function(Equipment) onItemTapped,
  }) {
    return DragTarget<Equipment>(
      onWillAcceptWithDetails: (details) {
        // Accept if the item is moving to this column
        final isCurrentlySelected = _selectedIds.contains(details.data.id);
        return isSelectedColumn ? !isCurrentlySelected : isCurrentlySelected;
      },
      onAcceptWithDetails: (details) => onItemDropped(details.data),
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;
        return Container(
          decoration: BoxDecoration(
            color: isHighlighted ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3) : Theme.of(context).colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isHighlighted ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.outlineVariant,
              width: isHighlighted ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  spacing: 8,
                  children: [
                    Icon(isSelectedColumn ? Icons.check_circle_outline : Icons.inventory_2_outlined, size: 20, color: Theme.of(context).colorScheme.primary),
                    Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Text('${items.length}', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.outline)),
                  ],
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Text(isSelectedColumn ? 'Drag equipment here' : 'No more equipment', style: TextStyle(color: Theme.of(context).hintColor)),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final equipment = items[index];
                          return _buildDraggableItem(equipment, onItemTapped);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDraggableItem(Equipment equipment, void Function(Equipment) onTap) {
    return Draggable<Equipment>(
      data: equipment,
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 280,
          child: EquipmentListTile(equipment: equipment, onTap: onTap),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: Card(
          child: EquipmentListTile(equipment: equipment, onTap: onTap),
        ),
      ),
      child: Card(
        child: EquipmentListTile(equipment: equipment, onTap: onTap),
      ),
    );
  }
}
