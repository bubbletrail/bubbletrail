import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'details_state.dart';
import 'screen_scaffold.dart';

/// A generic wrapper widget that shows loading/error states for a details BLoC.
///
/// This widget listens to a BLoC of type [B] with state type [S] (which must
/// implement [DetailsStateMixin]) and shows:
/// - A loading indicator when the state is loading or initial
/// - An error message when the state is an error
/// - The [child] widget when the state is loaded
///
/// Example usage:
/// ```dart
/// DetailsAvailable<DiveDetailsBloc, DiveDetailsState>(
///   child: DiveDetailsScreen(),
/// )
/// ```
class DetailsAvailable<B extends BlocBase<S>, S extends DetailsStateMixin> extends StatelessWidget {
  final Widget child;

  const DetailsAvailable({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<B, S>(
      builder: (context, state) {
        if (state.isLoaded) {
          return child;
        }

        if (state.isLoading || state.isInitial) {
          return ScreenScaffold(
            title: const Text('Loading...'),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state.isError) {
          return ScreenScaffold(
            title: const Text('Error'),
            body: Center(child: Text(state.errorMessage ?? 'An error occurred')),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
