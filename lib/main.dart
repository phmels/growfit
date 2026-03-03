import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:growfit/features/cycle/domain/entities/cycle_state_entity.dart';
import 'package:growfit/features/cycle/presentation/bloc/cycle_event.dart';
import 'package:growfit/features/plan/domain/usecases/get_current_training_plan.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'features/plan/domain/entities/exercise.dart';
import 'features/plan/domain/entities/exercise_group.dart';
import 'features/plan/domain/entities/training_day.dart';
import 'features/plan/domain/entities/training_plan.dart';
import 'features/workout/domain/entities/workout_exercise.dart';
import 'features/workout/domain/entities/workout_group.dart';
import 'features/workout/domain/entities/set_log.dart';
import 'features/workout/domain/entities/workout_session.dart';

import 'features/plan/presentation/bloc/plan_bloc.dart';
import 'features/cycle/presentation/bloc/cycle_bloc.dart';
import 'features/cycle/domain/usecases/get_next_training_day.dart';
import 'features/cycle/data/repositories_impl/cycle_repository_impl.dart';
import 'homepage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Registrando adapters
  Hive.registerAdapter(ExerciseAdapter());
  Hive.registerAdapter(ExerciseGroupAdapter());
  Hive.registerAdapter(WorkoutExerciseAdapter());
  Hive.registerAdapter(WorkoutGroupAdapter());
  Hive.registerAdapter(SetLogAdapter());
  Hive.registerAdapter(WorkoutSessionAdapter());
  Hive.registerAdapter(TrainingDayAdapter());
  Hive.registerAdapter(TrainingPlanAdapter());
  Hive.registerAdapter(CycleStateEntityAdapter());

  // Abrindo boxes
  await Hive.openBox<TrainingPlan>('trainingPlans');
  await Hive.openBox<WorkoutSession>('workoutSessions');
  await Hive.openBox<CycleStateEntity>('cycleState');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => PlanBloc(), // inicializa PlanBloc
        ),
        BlocProvider(
          create: (_) => CycleBloc(
            getCurrentTrainingPlan: GetCurrentTrainingPlan(),
            getNextTrainingDay: GetNextTrainingDay(),
            cycleRepository: CycleRepositoryImpl(),
          )..add(LoadCycle()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const HomePage(),
      ),
    );
  }
}
