import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:yadl/src/divelist/divelist_widget.dart';
import 'package:yadl/src/divelist/divelist_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yet Another Dive Log',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
          primary: Colors.lightBlue,
          secondary: Colors.lightBlueAccent,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: BlocProvider(create: (context) => DiveListBloc(), child: const DiveListScreen()),
    );
  }
}
