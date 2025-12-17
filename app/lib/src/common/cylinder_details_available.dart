import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/cylinderdetails_bloc.dart';
import 'screen_scaffold.dart';

class CylinderDetailsAvailable extends StatelessWidget {
  final Widget child;
  const CylinderDetailsAvailable({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CylinderDetailsBloc, CylinderDetailsState>(
      builder: (context, state) {
        if (state is CylinderDetailsLoaded) {
          return child;
        }

        if (state is CylinderDetailsLoading || state is CylinderDetailsInitial) {
          return ScreenScaffold(
            title: const Text('Loading...'),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is CylinderDetailsError) {
          return ScreenScaffold(
            title: const Text('Error'),
            body: Center(child: Text(state.message)),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
