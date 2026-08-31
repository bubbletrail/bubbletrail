import 'package:btproto/btproto.dart';
import 'package:flutter/material.dart';

import '../app_metadata.dart';
import 'common.dart';

Future<List<Equipment>?> showEquipmentSelectionDialog({
  required BuildContext context,
  required List<Equipment> allEquipment,
  required List<Equipment> selectedEquipment,
  ValueChanged<Set<String>>? onSetAsDefault,
}) {
  // Present as a bottom sheet on mobile (the narrow, checklist layout) and a
  // dialog on desktop (which also offers the wide drag-and-drop layout).
  if (platformIsMobile) {
    return showModalBottomSheet<List<Equipment>>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _EquipmentSelectionDialog(allEquipment: allEquipment, selectedEquipment: selectedEquipment, onSetAsDefault: onSetAsDefault),
    );
  }
  return showDialog<List<Equipment>>(
    context: context,
    builder: (dialogContext) => _EquipmentSelectionDialog(allEquipment: allEquipment, selectedEquipment: selectedEquipment, onSetAsDefault: onSetAsDefault),
  );
}

class _EquipmentSelectionDialog extends StatefulWidget {
  final List<Equipment> allEquipment;
  final List<Equipment> selectedEquipment;
  // Called with the selected ids when the user asks to make the current
  // selection the default set for new dives. Absent hides that action.
  final ValueChanged<Set<String>>? onSetAsDefault;

  const _EquipmentSelectionDialog({required this.allEquipment, required this.selectedEquipment, this.onSetAsDefault});

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

  // Equipment flagged as default for new dives.
  Iterable<Equipment> get _defaultEquipment => widget.allEquipment.where((e) => e.defaultForNewDives && !e.archived);

  void _addDefaults() {
    setState(() {
      _selectedIds.addAll(_defaultEquipment.map((e) => e.id));
    });
  }

  void _setAsDefault() {
    widget.onSetAsDefault?.call(_selectedIds.toSet());
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Default equipment updated')));
  }

  // The secondary actions shared by every layout: pull in the default set, and
  // (when supported) promote the current selection to be the default.
  List<Widget> _defaultActionButtons() {
    return [
      if (_defaultEquipment.isNotEmpty) TextButton.icon(onPressed: _addDefaults, icon: const Icon(Icons.playlist_add), label: const Text('Add defaults')),
      if (widget.onSetAsDefault != null)
        TextButton.icon(onPressed: _setAsDefault, icon: const Icon(Icons.push_pin_outlined), label: const Text('Set as default')),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // On mobile we're hosted in a bottom sheet, so render sheet content.
    if (platformIsMobile) {
      return _buildSheetLayout();
    }
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

  Widget _buildSheetLayout() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 16,
          children: [
            Text('Select equipment', style: Theme.of(context).textTheme.titleMedium),
            if (widget.allEquipment.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('No equipment available')),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.allEquipment.length,
                  itemBuilder: (context, index) {
                    final equipment = widget.allEquipment[index];
                    final isSelected = _selectedIds.contains(equipment.id);
                    return EvenOddContainer(
                      index: index,
                      child: EquipmentListTile(
                        equipment: equipment,
                        onTap: (_) => _toggleEquipment(equipment),
                        trailing: isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank,
                      ),
                    );
                  },
                ),
              ),
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ..._defaultActionButtons(),
                TextButton(onPressed: _cancel, child: const Text('Cancel')),
                FilledButton(onPressed: _confirm, child: const Text('Done')),
              ],
            ),
          ],
        ),
      ),
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
        ..._defaultActionButtons(),
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
                  ..._defaultActionButtons(),
                  const Spacer(),
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
          child: EquipmentListTile(equipment: equipment, onTap: onTap, trailing: Icons.drag_indicator),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: Card(
          child: EquipmentListTile(equipment: equipment, onTap: onTap, trailing: Icons.drag_indicator),
        ),
      ),
      child: Card(
        child: EquipmentListTile(equipment: equipment, onTap: onTap, trailing: Icons.drag_indicator),
      ),
    );
  }
}
