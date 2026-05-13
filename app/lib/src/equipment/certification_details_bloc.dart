import 'dart:typed_data';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:btproto/btproto.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

import '../common/details_state.dart';
import '../providers/storage_provider.dart';

final _log = Logger('certification_details_bloc.dart');

abstract class CertificationDetailsState extends Equatable with DetailsStateMixin {
  const CertificationDetailsState();

  @override
  List<Object?> get props => [];
}

class CertificationDetailsInitial extends CertificationDetailsState with DetailsInitialMixin {
  const CertificationDetailsInitial();
}

class CertificationDetailsClosed extends CertificationDetailsState with DetailsInitialMixin {
  const CertificationDetailsClosed();
}

class CertificationDetailsLoading extends CertificationDetailsState with DetailsLoadingMixin {
  const CertificationDetailsLoading();
}

class CertificationDetailsLoaded extends CertificationDetailsState with DetailsLoadedMixin {
  final Certification certification;
  final bool isNew;

  const CertificationDetailsLoaded(this.certification, this.isNew);

  @override
  List<Object?> get props => [certification, isNew];
}

class CertificationDetailsError extends CertificationDetailsState with DetailsErrorMixin {
  @override
  final String errorMessage;

  const CertificationDetailsError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

sealed class CertificationDetailsEvent extends Equatable {
  const CertificationDetailsEvent();

  @override
  List<Object?> get props => [];

  const factory CertificationDetailsEvent.load(String certificationId) = _Load;
  const factory CertificationDetailsEvent.newCertification() = _New;
  const factory CertificationDetailsEvent.updateAndClose(
    Certification certification, {
    Uint8List? newCardFront,
    Uint8List? newCardBack,
    bool clearCardFront,
    bool clearCardBack,
  }) = _UpdateAndClose;
  const factory CertificationDetailsEvent.deleteAndClose(String certificationId) = _DeleteAndClose;
  const factory CertificationDetailsEvent.close() = _Close;
}

class _Load extends CertificationDetailsEvent {
  final String certificationId;

  const _Load(this.certificationId);

  @override
  List<Object?> get props => [certificationId];
}

class _New extends CertificationDetailsEvent {
  const _New();
}

class _UpdateAndClose extends CertificationDetailsEvent {
  final Certification certification;
  final Uint8List? newCardFront;
  final Uint8List? newCardBack;
  final bool clearCardFront;
  final bool clearCardBack;

  const _UpdateAndClose(this.certification, {this.newCardFront, this.newCardBack, this.clearCardFront = false, this.clearCardBack = false});

  @override
  List<Object?> get props => [certification, newCardFront, newCardBack, clearCardFront, clearCardBack];
}

class _DeleteAndClose extends CertificationDetailsEvent {
  final String certificationId;

  const _DeleteAndClose(this.certificationId);

  @override
  List<Object?> get props => [certificationId];
}

class _Close extends CertificationDetailsEvent {
  const _Close();
}

class CertificationDetailsBloc extends Bloc<CertificationDetailsEvent, CertificationDetailsState> {
  final _store = StorageProvider.instance.store;

  CertificationDetailsBloc() : super(const CertificationDetailsInitial()) {
    on<CertificationDetailsEvent>((event, emit) async {
      switch (event) {
        case _Load():
          await _onLoad(event, emit);
        case _New():
          emit(CertificationDetailsLoaded(Certification()..freeze(), true));
        case _UpdateAndClose():
          await _onUpdateAndClose(event, emit);
        case _DeleteAndClose():
          await _onDelete(event, emit);
        case _Close():
          emit(const CertificationDetailsClosed());
      }
    }, transformer: sequential());
  }

  Future<void> _onLoad(_Load event, Emitter<CertificationDetailsState> emit) async {
    try {
      final cert = await _store.certifications.getById(event.certificationId);
      if (cert == null) {
        emit(const CertificationDetailsError('Certification not found'));
        return;
      }
      emit(CertificationDetailsLoaded(cert, false));
    } catch (e) {
      emit(CertificationDetailsError('Failed to load certification details: $e'));
    }
  }

  Future<void> _onUpdateAndClose(_UpdateAndClose event, Emitter<CertificationDetailsState> emit) async {
    try {
      var cert = event.certification;

      // Handle card front photo
      if (event.newCardFront != null) {
        // Replacing front: delete old, create new
        if (cert.cardFrontId.isNotEmpty) {
          await _store.photos.delete(cert.cardFrontId);
        }
        final photo = await _store.photos.create(event.newCardFront!);
        cert = cert.rebuild((b) => b.cardFrontId = photo.id);
      } else if (event.clearCardFront && cert.cardFrontId.isNotEmpty) {
        await _store.photos.delete(cert.cardFrontId);
        cert = cert.rebuild((b) => b.clearCardFrontId());
      }

      // Handle card back photo
      if (event.newCardBack != null) {
        if (cert.cardBackId.isNotEmpty) {
          await _store.photos.delete(cert.cardBackId);
        }
        final photo = await _store.photos.create(event.newCardBack!);
        cert = cert.rebuild((b) => b.cardBackId = photo.id);
      } else if (event.clearCardBack && cert.cardBackId.isNotEmpty) {
        await _store.photos.delete(cert.cardBackId);
        cert = cert.rebuild((b) => b.clearCardBackId());
      }

      await _store.certifications.update(cert);
      emit(const CertificationDetailsClosed());
    } catch (e) {
      _log.warning('failed to update certification', e);
      emit(CertificationDetailsError('Failed to update certification: $e'));
    }
  }

  Future<void> _onDelete(_DeleteAndClose event, Emitter<CertificationDetailsState> emit) async {
    try {
      final cert = await _store.certifications.getById(event.certificationId);
      if (cert != null) {
        if (cert.cardFrontId.isNotEmpty) await _store.photos.delete(cert.cardFrontId);
        if (cert.cardBackId.isNotEmpty) await _store.photos.delete(cert.cardBackId);
      }
      await _store.certifications.delete(event.certificationId);
      emit(const CertificationDetailsClosed());
    } catch (e) {
      _log.warning('failed to delete certification', e);
      emit(CertificationDetailsError('Failed to delete certification: $e'));
    }
  }
}
