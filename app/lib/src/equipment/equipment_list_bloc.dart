import 'dart:io';

import 'package:btproto/btproto.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../services/store/store.dart';
import '../providers/storage_provider.dart';

abstract class EquipmentListState extends Equatable {
  const EquipmentListState();

  @override
  List<Object?> get props => [];
}

class EquipmentListInitial extends EquipmentListState {
  const EquipmentListInitial();
}

class EquipmentListLoading extends EquipmentListState {
  const EquipmentListLoading();
}

class EquipmentListLoaded extends EquipmentListState {
  final List<Equipment> equipment;
  final bool showArchived;

  const EquipmentListLoaded(this.equipment, {this.showArchived = false});

  List<Equipment> get visibleEquipment => showArchived ? equipment : equipment.where((e) => !e.archived).toList();

  @override
  List<Object?> get props => [equipment, showArchived];
}

abstract class EquipmentListEvent extends Equatable {
  const EquipmentListEvent();

  const factory EquipmentListEvent.importEquipment(String filePath) = _ImportEquipment;
  const factory EquipmentListEvent.toggleShowArchived() = _ToggleShowArchived;

  @override
  List<Object?> get props => [];
}

class _Init extends EquipmentListEvent {
  const _Init();
}

class _ImportEquipment extends EquipmentListEvent {
  final String filePath;

  const _ImportEquipment(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

class _LoadedEquipment extends EquipmentListEvent {
  final List<Equipment> equipment;

  const _LoadedEquipment(this.equipment);

  @override
  List<Object?> get props => [equipment];
}

class _ToggleShowArchived extends EquipmentListEvent {
  const _ToggleShowArchived();
}

class EquipmentListBloc extends Bloc<EquipmentListEvent, EquipmentListState> {
  final Store _store = StorageProvider.instance.store;
  VoidCallback? _equipmentListener;

  EquipmentListBloc() : super(const EquipmentListInitial()) {
    on<_Init>(_onInit);
    on<_LoadedEquipment>(_onLoadedEquipment);
    on<_ImportEquipment>(_onImportEquipment);
    on<_ToggleShowArchived>(_onToggleShowArchived);
    add(const _Init());
  }

  Future<void> _onInit(_Init event, Emitter<EquipmentListState> emit) async {
    _equipmentListener = () async {
      final equipment = await _store.equipment.getAll();
      add(_LoadedEquipment(equipment));
    };
    _store.equipment.addListener(_equipmentListener!);
    final equipment = await _store.equipment.getAll();
    emit(EquipmentListLoaded(equipment));
  }

  Future<void> _onLoadedEquipment(_LoadedEquipment event, Emitter<EquipmentListState> emit) async {
    final currentState = state;
    final showArchived = currentState is EquipmentListLoaded ? currentState.showArchived : false;
    emit(EquipmentListLoaded(event.equipment, showArchived: showArchived));
  }

  Future<void> _onToggleShowArchived(_ToggleShowArchived event, Emitter<EquipmentListState> emit) async {
    final currentState = state;
    if (currentState is EquipmentListLoaded) {
      emit(EquipmentListLoaded(currentState.equipment, showArchived: !currentState.showArchived));
    }
  }

  Future<void> _onImportEquipment(_ImportEquipment event, Emitter<EquipmentListState> emit) async {
    final importedEquipment = await compute((String path) async {
      final csvData = await File(path).readAsString();
      return importMacDiveEquipmentCsv(csvData);
    }, event.filePath);

    for (final item in importedEquipment) {
      await _store.equipment.getOrCreate(
        type: item.type,
        manufacturer: item.manufacturer,
        name: item.name,
        serial: item.serial,
        weight: item.hasWeight() ? item.weight : null,
        purchaseDate: item.hasPurchaseDate() ? item.purchaseDate : null,
        purchasePrice: item.hasPurchasePrice() ? item.purchasePrice : null,
        shop: item.hasShop() ? item.shop : null,
        warrantyUntil: item.hasWarrantyUntil() ? item.warrantyUntil : null,
        lastService: item.hasLastService() ? item.lastService : null,
      );
    }
  }

  @override
  Future<void> close() {
    if (_equipmentListener != null) {
      _store.equipment.removeListener(_equipmentListener!);
    }
    return super.close();
  }
}
