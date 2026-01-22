import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:btstore/btstore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

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

abstract class SiteDetailsEvent extends Equatable {
  const SiteDetailsEvent();

  @override
  List<Object?> get props => [];

  const factory SiteDetailsEvent.newSite() = _NewSite;
  const factory SiteDetailsEvent.loadSite(String siteId) = _LoadSite;
  const factory SiteDetailsEvent.close() = _Close;
  const factory SiteDetailsEvent.saveAndClose(Site site) = _SaveAndClose;
}

class _NewSite extends SiteDetailsEvent {
  const _NewSite();
}

class _LoadSite extends SiteDetailsEvent {
  final String siteId;

  const _LoadSite(this.siteId);
}

class _Close extends SiteDetailsEvent {
  const _Close();
}

class _SaveAndClose extends SiteDetailsEvent {
  final Site site;

  const _SaveAndClose(this.site);
}

class SiteDetailsBloc extends Bloc<SiteDetailsEvent, SiteDetailsState> {
  SiteDetailsBloc() : super(const SiteDetailsInitial()) {
    _log.fine('init');
    on<SiteDetailsEvent>((event, emit) async {
      if (event is _NewSite) {
        emit(SiteDetailsLoaded(Site()..freeze()));
      } else if (event is _LoadSite) {
        final s = await StorageProvider.store;
        final site = await s.sites.getById(event.siteId);
        if (site != null) {
          _log.fine('loaded ${site.name}');
          emit(SiteDetailsLoaded(site));
        } // XXX else error
      } else if (event is _Close) {
        emit(SiteDetailsClosed());
      } else if (event is _SaveAndClose) {
        final s = await StorageProvider.store;
        await s.sites.update(event.site);
        _log.fine('saved ${event.site.name}');
        emit(SiteDetailsClosed());
      }
    }, transformer: sequential());
  }

  @override
  Future<void> close() {
    _log.fine('close');
    return super.close();
  }
}
