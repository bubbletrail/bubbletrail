import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../app_metadata.dart';
import '../common/common.dart';
import 'depth_profile_widget.dart';
import 'dive_details_bloc.dart';

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
    if (platformIsMobile) {
      SystemChrome.setPreferredOrientations([.landscapeLeft, .landscapeRight]);
    }
  }

  void _restoreOrientation() {
    if (platformIsMobile) {
      SystemChrome.setPreferredOrientations([.portraitUp]);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final decoration = platformIsDesktop
        ? BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [cs.tertiaryContainer, cs.onTertiaryFixedVariant],
              tileMode: .mirror,
            ),
          )
        : BoxDecoration(color: Theme.of(context).canvasColor);

    return Container(
      decoration: decoration,
      child: SafeArea(
        child: BlocBuilder<DiveDetailsBloc, DiveDetailsState>(
          builder: (context, state) {
            if (state is! DiveDetailsLoaded) return Placeholder();
            return ScreenScaffold(
              title: Text('Dive #${state.dive.number}: ${state.site?.name ?? 'Unknown site'}'),
              body: Padding(
                padding: platformIsMobile ? EdgeInsets.zero : const EdgeInsets.all(8.0),
                child: DepthProfile(key: ValueKey(state.dive), dive: state.dive),
              ),
              transparent: true,
            );
          },
        ),
      ),
    );
  }
}
