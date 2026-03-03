import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:growfit/features/cycle/data/repositories_impl/cycle_repository_impl.dart';
import 'package:growfit/features/plan/domain/usecases/get_current_training_plan.dart';
import 'package:growfit/homepage.dart';

import 'features/cycle/presentation/bloc/cycle_bloc.dart';
import 'features/cycle/presentation/bloc/cycle_event.dart';
import 'features/cycle/domain/usecases/get_next_training_day.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
  debugShowCheckedModeBanner: false,    
  home: MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (_) => CycleBloc(
          getNextTrainingDay: GetNextTrainingDay(),
          getCurrentTrainingPlan: GetCurrentTrainingPlan(),
          cycleRepository: CycleRepositoryImpl(),
        )..add(LoadCycle()),
      ),
    ],
    child: const HomePage(),
  ),
);
}
}
