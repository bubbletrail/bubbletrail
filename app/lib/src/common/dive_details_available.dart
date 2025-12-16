import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/divedetails_bloc.dart';
import '../common/common_widgets.dart';

class DiveDetailsAvailable extends StatelessWidget {
  final Widget child;
  const DiveDetailsAvailable({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiveDetailsBloc, DiveDetailsState>(
      builder: (context, state) {
        if (state is DiveDetailsLoaded) {
          return child;
        }

        if (state is DiveDetailsLoading || state is DiveDetailsInitial) {
          return ScreenScaffold(
            title: const Text('Loading...'),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is DiveDetailsError) {
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
