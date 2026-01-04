import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/divelist_bloc.dart';
import '../bloc/preferences_bloc.dart';
import '../common/common.dart';
import 'depthprofile_widget.dart';

class FullscreenProfileScreen extends StatefulWidget {
  const FullscreenProfileScreen({super.key});

  @override
  State<FullscreenProfileScreen> createState() => _FullscreenProfileScreenState();
}

class _FullscreenProfileScreenState extends State<FullscreenProfileScreen> {
  @override
  void initState() {
    super.initState();
    _setLandscapeOrientation();
  }

  @override
  void dispose() {
    _restoreOrientation();
    super.dispose();
  }

  void _setLandscapeOrientation() {
    if (Platform.isIOS || Platform.isAndroid) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    }
  }

  void _restoreOrientation() {
    if (Platform.isIOS || Platform.isAndroid) {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }

  @override
  Widget build(BuildContext context) => SafeArea(
    child: BlocBuilder<PreferencesBloc, PreferencesState>(
      builder: (context, prefsState) {
        return BlocBuilder<DiveListBloc, DiveListState>(
          builder: (context, divesState) {
            if (divesState is! DiveListLoaded) return Placeholder(); // can't happen
            final dive = divesState.selectedDive!;
            final site = divesState.selectedDiveSite;
            return ScreenScaffold(
              title: Text('Dive #${dive.number}: ${site?.name ?? 'Unknown site'}'),
              body: DepthProfileWidget(key: ValueKey((dive, prefsState.preferences)), log: dive.logs.first, preferences: prefsState.preferences),
            );
          },
        );
      },
    ),
  );
}
