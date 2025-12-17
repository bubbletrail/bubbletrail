import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/divesitedetails_bloc.dart';
import 'screen_scaffold.dart';

class DivesiteDetailsAvailable extends StatelessWidget {
  final Widget child;
  const DivesiteDetailsAvailable({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DivesiteDetailsBloc, DivesiteDetailsState>(
      builder: (context, state) {
        if (state is DivesiteDetailsLoaded) {
          return child;
        }

        if (state is DivesiteDetailsLoading || state is DivesiteDetailsInitial) {
          return ScreenScaffold(
            title: const Text('Loading...'),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is DivesiteDetailsError) {
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
