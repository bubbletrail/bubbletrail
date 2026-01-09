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
      SystemChrome.setPreferredOrientations([.landscapeLeft, .landscapeRight]);
    }
  }

  void _restoreOrientation() {
    if (Platform.isIOS || Platform.isAndroid) {
      SystemChrome.setPreferredOrientations([.portraitUp]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final decoration = BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [cs.tertiaryContainer, cs.onTertiaryFixedVariant],
        tileMode: .mirror,
      ),
    );

    return Container(
      decoration: decoration,
      child: SafeArea(
        child: BlocBuilder<PreferencesBloc, PreferencesState>(
          builder: (context, prefsState) {
            return BlocBuilder<DiveListBloc, DiveListState>(
              builder: (context, divesState) {
                if (divesState is! DiveListLoaded) return Placeholder(); // can't happen
                final dive = divesState.selectedDive!;
                final site = divesState.selectedDiveSite;
                return ScreenScaffold(
                  title: Text('Dive #${dive.number}: ${site?.name ?? 'Unknown site'}'),
                  body: Padding(
                    padding: Platform.isIOS ? EdgeInsets.zero : const .all(8.0),
                    child: DepthProfileWidget(
                      key: ValueKey((dive, prefsState.preferences)),
                      log: dive.logs.first,
                      preferences: prefsState.preferences,
                      events: dive.events,
                      cylinders: dive.cylinders,
                    ),
                  ),
                  transparent: true,
                );
              },
            );
          },
        ),
      ),
    );
  }
}
