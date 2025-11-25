import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:xml/xml.dart';

import '../ssrf/ssrf.dart';

abstract class DiveListState extends Equatable {
  const DiveListState();

  @override
  List<Object?> get props => [];
}

class DiveListInitial extends DiveListState {
  const DiveListInitial();
}

class DiveListLoading extends DiveListState {
  const DiveListLoading();
}

class DiveListLoaded extends DiveListState {
  final List<Dive> dives;
  final List<Divesite> diveSites;

  const DiveListLoaded(this.dives, this.diveSites);

  @override
  List<Object?> get props => [dives];
}

class DiveListError extends DiveListState {
  final String message;

  const DiveListError(this.message);

  @override
  List<Object?> get props => [message];
}

abstract class DiveListEvent extends Equatable {
  const DiveListEvent();

  @override
  List<Object?> get props => [];
}

class LoadDives extends DiveListEvent {
  const LoadDives();
}

class DiveListBloc extends Bloc<DiveListEvent, DiveListState> {
  DiveListBloc() : super(const DiveListInitial()) {
    on<LoadDives>(_onLoadDives);

    // Automatically load dives when the bloc is created
    add(const LoadDives());
  }

  Future<void> _onLoadDives(LoadDives event, Emitter<DiveListState> emit) async {
    emit(const DiveListLoading());

    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final xmlData = await File('${docsDir.path}/dives.ssrf').readAsString();
      final doc = XmlDocument.parse(xmlData);
      final ssrf = Ssrf.fromXml(doc.rootElement);

      emit(DiveListLoaded(ssrf.dives, ssrf.diveSites));
    } catch (e) {
      emit(DiveListError('Failed to load dives: $e'));
    }
  }
}
