import 'dart:async';

import 'package:btstore/btstore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  const EquipmentListLoaded(this.equipment);

  @override
  List<Object?> get props => [equipment];
}

abstract class EquipmentListEvent extends Equatable {
  const EquipmentListEvent();

  @override
  List<Object?> get props => [];
}

class _Init extends EquipmentListEvent {
  const _Init();
}

class _LoadedEquipment extends EquipmentListEvent {
  final List<Equipment> equipment;

  const _LoadedEquipment(this.equipment);

  @override
  List<Object?> get props => [equipment];
}

class EquipmentListBloc extends Bloc<EquipmentListEvent, EquipmentListState> {
  StreamSubscription? _equipmentSub;

  EquipmentListBloc() : super(const EquipmentListInitial()) {
    on<_Init>(_onInit);
    on<_LoadedEquipment>(_onLoadedEquipment);
    add(const _Init());
  }

  Future<void> _onInit(_Init event, Emitter<EquipmentListState> emit) async {
    final store = await StorageProvider.store;
    _equipmentSub = store.equipment.changes.listen((equipment) async {
      final equipment = await store.equipment.getAll();
      add(_LoadedEquipment(equipment));
    });
    final equipment = await store.equipment.getAll();
    emit(EquipmentListLoaded(equipment));
  }

  Future<void> _onLoadedEquipment(_LoadedEquipment event, Emitter<EquipmentListState> emit) async {
    emit(EquipmentListLoaded(event.equipment));
  }

  @override
  Future<void> close() {
    _equipmentSub?.cancel();
    return super.close();
  }
}
