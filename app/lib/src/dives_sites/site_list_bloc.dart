import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';

part 'site_list_bloc.g.dart';

final _log = Logger('site_list_bloc.dart');

@CopyWith()
class SiteListState extends Equatable {
  final bool showAsMap;

  const SiteListState({this.showAsMap = false});

  @override
  List<Object?> get props => [showAsMap];
}

sealed class SiteListEvent extends Equatable {
  const SiteListEvent();

  @override
  List<Object?> get props => [];

  const factory SiteListEvent.showAsMap(bool showAsMap) = _ShowAsMap;
}

class _ShowAsMap extends SiteListEvent {
  final bool showAsMap;

  const _ShowAsMap(this.showAsMap);
}

class SiteListBloc extends Bloc<SiteListEvent, SiteListState> {
  SiteListBloc() : super(const SiteListState()) {
    _log.fine('init');
    on<SiteListEvent>((event, emit) async {
      switch (event) {
        case _ShowAsMap():
          emit(SiteListState(showAsMap: event.showAsMap));
      }
    }, transformer: sequential());
  }

  @override
  Future<void> close() {
    _log.fine('close');
    return super.close();
  }
}
