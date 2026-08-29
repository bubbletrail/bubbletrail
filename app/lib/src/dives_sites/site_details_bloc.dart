import 'dart:ui';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:btproto/btproto.dart';

import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import '../common/details_state.dart';
import '../providers/storage_provider.dart';

part 'site_details_bloc.g.dart';

final _log = Logger('site_details_bloc.dart');

abstract class SiteDetailsState extends Equatable with DetailsStateMixin {
  const SiteDetailsState();

  @override
  List<Object?> get props => [];
}

class SiteDetailsInitial extends SiteDetailsState {
  const SiteDetailsInitial();
}

@CopyWith()
class SiteDetailsLoaded extends SiteDetailsState {
  final Site site;

  const SiteDetailsLoaded(this.site);

  @override
  bool get isLoaded => true;

  @override
  List<Object?> get props => [site];
}

class SiteDetailsClosed extends SiteDetailsState {
  const SiteDetailsClosed();

  @override
  List<Object?> get props => [];
}

sealed class SiteDetailsEvent extends Equatable {
  const SiteDetailsEvent();

  @override
  List<Object?> get props => [];

  const factory SiteDetailsEvent.newSite() = _NewSite;
  const factory SiteDetailsEvent.loadSite(String siteId) = _LoadSite;
  const factory SiteDetailsEvent.save(Site site) = _Save;
  const factory SiteDetailsEvent.deleteAndClose(String siteID) = _DeleteAndClose;
}

class _NewSite extends SiteDetailsEvent {
  const _NewSite();
}

class _LoadSite extends SiteDetailsEvent {
  final String siteId;

  const _LoadSite(this.siteId);
}

class _Save extends SiteDetailsEvent {
  final Site site;

  const _Save(this.site);
}

class _DeleteAndClose extends SiteDetailsEvent {
  final String siteID;

  const _DeleteAndClose(this.siteID);
}

class SiteDetailsBloc extends Bloc<SiteDetailsEvent, SiteDetailsState> {
  final _store = StorageProvider.instance.store;
  VoidCallback? _storageListener;

  SiteDetailsBloc() : super(const SiteDetailsInitial()) {
    _log.fine('init');
    on<SiteDetailsEvent>((event, emit) async {
      switch (event) {
        case _NewSite():
          // Give the site a stable id up front so inline edits can save it, but
          // don't persist until the first edit — an untouched new site that's
          // navigated away from leaves nothing behind.
          emit(SiteDetailsLoaded(Site(id: Uuid().v7())..freeze()));
        case _LoadSite():
          await _onLoadSite(event, emit);
        case _Save():
          // Persist without closing, then reload so the view updates in place
          // (and the storage listener is registered for a first-time save of a
          // newly created site).
          await _store.sites.update(event.site);
          _log.fine('saved ${event.site.name}');
          await _onLoadSite(_LoadSite(event.site.id), emit);
        case _DeleteAndClose():
          await _store.deleteSite(event.siteID);
          _log.fine('deleted ${event.siteID}');
          emit(SiteDetailsClosed());
      }
    }, transformer: sequential());
  }

  Future<void> _onLoadSite(_LoadSite event, Emitter<SiteDetailsState> emit) async {
    final site = await _store.sites.getById(event.siteId);
    if (site == null) {
      emit(SiteDetailsClosed());
      return;
    }

    if (_storageListener == null) {
      _storageListener = () {
        // Reload the site when storage changes
        add(_LoadSite(event.siteId));
      };
      _store.sites.addListener(_storageListener!);
    }

    _log.fine('loaded ${site.name}');
    emit(SiteDetailsLoaded(site));
  }

  @override
  Future<void> close() {
    _log.fine('close');
    if (_storageListener != null) {
      _store.sites.removeListener(_storageListener!);
    }
    return super.close();
  }
}
