import 'dart:math';

import 'package:btbuhlmann/btbuhlmann.dart' as buhlmann;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../dives_sites/dive_list_bloc.dart';
import '../dives_sites/tissue_calculator.dart';

const desatGF = 5; // Below this, do not even show the indicator
const cutoffGF = 30; // GF 30 seems quite safe
const flyPressure = 0.753; // 75.3 kPa at 8000 ft, lowest allowed cabin pressure

class NoFlyIndicator extends StatelessWidget {
  const NoFlyIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DiveListBloc, DiveListState>(
      builder: (context, state) {
        if (state is! DiveListLoaded || state.dives.isEmpty) {
          return SizedBox();
        }

        final dive = state.dives.first;

        // Calculate current state, assuming air at surface pressure since the dive
        final flightDeco = buhlmann.BuhlmannDeco(config: buhlmann.BuhlmannConfig(), tissues: protoToTissueState(dive.endTissues));
        flightDeco.addSegment(
          0,
          buhlmann.GasMix.air,
          DateTime.now().difference(dive.start.toDateTime().add(Duration(seconds: dive.duration))).inSeconds.toDouble(),
        );

        // Calculate the current FlightGF
        final curFlightGF = max(0, flightDeco.gradientFactor(flyPressure).floor());
        if (curFlightGF <= desatGF) {
          return SizedBox();
        }
        if (curFlightGF <= cutoffGF) {
          return _ClearToFlyIndicator(gf: curFlightGF);
        }

        // Iterate to see how many hours it takes to get FlightGF < cutoff
        var waitHours = 0;
        var waitFlightGF = curFlightGF;
        while (waitFlightGF > cutoffGF) {
          flightDeco.addSegment(0, buhlmann.GasMix.air, 3600);
          waitHours++;
          waitFlightGF = max(0, flightDeco.gradientFactor(flyPressure).floor());
        }

        return _NoFlyIndicator(waitHours: waitHours, curFlightGF: curFlightGF, waitFlightGF: waitFlightGF);
      },
    );
  }
}

class _NoFlyIndicator extends StatelessWidget {
  const _NoFlyIndicator({super.key, required this.waitHours, required this.curFlightGF, required this.waitFlightGF});

  final int waitHours;
  final int curFlightGF;
  final int waitFlightGF;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Wait a bit'),
              content: Text(
                'Wait $waitHours hours, then your gradient factor at flight level will be $waitFlightGF%. Right now, if teleported to 8000 ft, your GF would be $curFlightGF%.',
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Got it'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
      icon: Icon(Icons.airplanemode_off),
    );
  }
}

class _ClearToFlyIndicator extends StatelessWidget {
  const _ClearToFlyIndicator({super.key, required this.gf});

  final int gf;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('You can fly'),
              content: Text('Your gradient factor at flight level will be $gf%, which is considered safe.'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Got it'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
      icon: Icon(Icons.airplanemode_active),
    );
  }
}
