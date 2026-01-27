import 'dart:async';

import 'package:btstore/btstore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../providers/storage_provider.dart';

abstract class CylinderListState extends Equatable {
  const CylinderListState();

  @override
  List<Object?> get props => [];
}

class CylinderListInitial extends CylinderListState {
  const CylinderListInitial();
}

class CylinderListLoading extends CylinderListState {
  const CylinderListLoading();
}

class CylinderListLoaded extends CylinderListState {
  final List<Cylinder> cylinders;

  const CylinderListLoaded(this.cylinders);

  @override
  List<Object?> get props => [cylinders];
}

abstract class CylinderListEvent extends Equatable {
  const CylinderListEvent();

  @override
  List<Object?> get props => [];
}

class _Init extends CylinderListEvent {
  const _Init();
}

class _LoadedCylinders extends CylinderListEvent {
  final List<Cylinder> cylinders;

  const _LoadedCylinders(this.cylinders);

  @override
  List<Object?> get props => [cylinders];
}

class CylinderListBloc extends Bloc<CylinderListEvent, CylinderListState> {
  final _store = StorageProvider.instance.store;
  StreamSubscription? _cylindersSub;

  CylinderListBloc() : super(const CylinderListInitial()) {
    on<_Init>(_onInit);
    on<_LoadedCylinders>(_onLoadedCylinders);
    add(const _Init());
  }

  Future<void> _onInit(_Init event, Emitter<CylinderListState> emit) async {
    _cylindersSub = _store.cylinders.changes.listen((cylinders) async {
      final cylinders = await _store.cylinders.getAll();
      add(_LoadedCylinders(cylinders));
    });
    final cylinders = await _store.cylinders.getAll();
    emit(CylinderListLoaded(cylinders));
  }

  Future<void> _onLoadedCylinders(_LoadedCylinders event, Emitter<CylinderListState> emit) async {
    emit(CylinderListLoaded(event.cylinders));
  }

  @override
  Future<void> close() {
    _cylindersSub?.cancel();
    return super.close();
  }
}
