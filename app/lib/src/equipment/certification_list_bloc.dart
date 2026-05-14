import 'package:btproto/btproto.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../providers/storage_provider.dart';

abstract class CertificationListState extends Equatable {
  const CertificationListState();

  @override
  List<Object?> get props => [];
}

class CertificationListInitial extends CertificationListState {
  const CertificationListInitial();
}

class CertificationListLoading extends CertificationListState {
  const CertificationListLoading();
}

class CertificationListLoaded extends CertificationListState {
  final List<Certification> certifications;

  const CertificationListLoaded(this.certifications);

  @override
  List<Object?> get props => [certifications];
}

abstract class CertificationListEvent extends Equatable {
  const CertificationListEvent();

  @override
  List<Object?> get props => [];
}

class _Init extends CertificationListEvent {
  const _Init();
}

class _LoadedCertifications extends CertificationListEvent {
  final List<Certification> certifications;

  const _LoadedCertifications(this.certifications);

  @override
  List<Object?> get props => [certifications];
}

class CertificationListBloc extends Bloc<CertificationListEvent, CertificationListState> {
  final _store = StorageProvider.instance.store;
  VoidCallback? _certificationsListener;

  CertificationListBloc() : super(const CertificationListInitial()) {
    on<_Init>(_onInit);
    on<_LoadedCertifications>(_onLoadedCertifications);
    add(const _Init());
  }

  Future<void> _onInit(_Init event, Emitter<CertificationListState> emit) async {
    _certificationsListener = () async {
      final certs = await _store.certifications.getAll();
      add(_LoadedCertifications(certs));
    };
    _store.certifications.addListener(_certificationsListener!);
    final certs = await _store.certifications.getAll();
    emit(CertificationListLoaded(certs));
  }

  Future<void> _onLoadedCertifications(_LoadedCertifications event, Emitter<CertificationListState> emit) async {
    emit(CertificationListLoaded(event.certifications));
  }

  @override
  Future<void> close() {
    if (_certificationsListener != null) {
      _store.certifications.removeListener(_certificationsListener!);
    }
    return super.close();
  }
}
