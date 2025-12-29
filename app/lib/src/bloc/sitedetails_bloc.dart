import 'package:divestore/divestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

import 'details_state.dart';
import 'sync_bloc.dart';

abstract class SiteDetailsState extends Equatable with DetailsStateMixin {
  const SiteDetailsState();

  @override
  List<Object?> get props => [];
}

class SiteDetailsInitial extends SiteDetailsState with DetailsInitialMixin {
  const SiteDetailsInitial();
}

class SiteDetailsLoading extends SiteDetailsState with DetailsLoadingMixin {
  const SiteDetailsLoading();
}

class SiteDetailsLoaded extends SiteDetailsState with DetailsLoadedMixin {
  final Site site;
  final bool isNew;

  const SiteDetailsLoaded(this.site, this.isNew);

  @override
  List<Object?> get props => [site, isNew];
}

class SiteDetailsError extends SiteDetailsState with DetailsErrorMixin {
  @override
  final String errorMessage;

  const SiteDetailsError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

abstract class SiteDetailsEvent extends Equatable {
  const SiteDetailsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSiteDetails extends SiteDetailsEvent {
  final String siteId;

  const LoadSiteDetails(this.siteId);

  @override
  List<Object?> get props => [siteId];
}

class NewSiteEvent extends SiteDetailsEvent {
  const NewSiteEvent();

  @override
  List<Object?> get props => [];
}

class UpdateSiteDetails extends SiteDetailsEvent {
  final Site site;

  const UpdateSiteDetails(this.site);

  @override
  List<Object?> get props => [site];
}

class SiteDetailsBloc extends Bloc<SiteDetailsEvent, SiteDetailsState> {
  final SyncBloc _syncBloc;

  SiteDetailsBloc(this._syncBloc) : super(const SiteDetailsInitial()) {
    on<LoadSiteDetails>(_onLoadSiteDetails);
    on<UpdateSiteDetails>(_onUpdateSiteDetails);
    on<NewSiteEvent>(_onNewSite);
  }

  Future<void> _onLoadSiteDetails(LoadSiteDetails event, Emitter<SiteDetailsState> emit) async {
    try {
      final store = await _syncBloc.store;
      final site = await store.sites.getById(event.siteId);
      if (site == null) {
        emit(const SiteDetailsError('Dive site not found'));
        return;
      }

      emit(SiteDetailsLoaded(site, false));
    } catch (e) {
      emit(SiteDetailsError('Failed to load dive site details: $e'));
    }
  }

  Future<void> _onUpdateSiteDetails(UpdateSiteDetails event, Emitter<SiteDetailsState> emit) async {
    try {
      final details = state as SiteDetailsLoaded;
      final store = await _syncBloc.store;
      if (details.isNew) {
        await store.sites.insert(event.site);
      } else {
        await store.sites.update(event.site);
      }
      add(LoadSiteDetails(event.site.id));
    } catch (e) {
      emit(SiteDetailsError('Failed to update dive site: $e'));
    }
  }

  Future<void> _onNewSite(NewSiteEvent event, Emitter<SiteDetailsState> emit) async {
    final site = Site(id: const Uuid().v4(), name: '');
    emit(SiteDetailsLoaded(site, true));
  }
}
