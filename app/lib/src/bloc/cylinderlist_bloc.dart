import 'dart:async';

import 'package:divestore/divestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'sync_bloc.dart';

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
  final SyncBloc _syncBloc;
  StreamSubscription? _cylindersSub;

  CylinderListBloc(this._syncBloc) : super(const CylinderListInitial()) {
    on<_Init>(_onInit);
    on<_LoadedCylinders>(_onLoadedCylinders);
    add(const _Init());
  }

  Future<void> _onInit(_Init event, Emitter<CylinderListState> emit) async {
    final store = await _syncBloc.store;
    _cylindersSub = store.cylinders.changes.listen((cylinders) {
      add(_LoadedCylinders(cylinders));
    });
    final cylinders = await store.cylinders.getAll();
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
