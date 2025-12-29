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

class CylinderListError extends CylinderListState {
  final String message;

  const CylinderListError(this.message);

  @override
  List<Object?> get props => [message];
}

abstract class CylinderListEvent extends Equatable {
  const CylinderListEvent();

  @override
  List<Object?> get props => [];
}

class LoadCylinders extends CylinderListEvent {
  const LoadCylinders();
}

class CylinderListBloc extends Bloc<CylinderListEvent, CylinderListState> {
  final SyncBloc _syncBloc;
  StreamSubscription? _syncBlocSub;

  CylinderListBloc(this._syncBloc) : super(const CylinderListInitial()) {
    on<LoadCylinders>(_onLoadCylinders);
    add(const LoadCylinders());

    _syncBlocSub = _syncBloc.stream.listen((state) {
      add(LoadCylinders());
    });
  }

  Future<void> _onLoadCylinders(LoadCylinders event, Emitter<CylinderListState> emit) async {
    emit(const CylinderListLoading());
    try {
      final store = await _syncBloc.store;
      final cylinders = await store.cylinders.getAll();
      emit(CylinderListLoaded(cylinders));
    } catch (e) {
      emit(CylinderListError('Failed to load cylinders: $e'));
    }
  }

  @override
  Future<void> close() {
    _syncBlocSub?.cancel();
    return super.close();
  }
}
