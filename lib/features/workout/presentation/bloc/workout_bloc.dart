import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/workout_session.dart';
import '../../domain/entities/set_log.dart';
import '../../domain/entities/exercise.dart';
import 'workout_event.dart';
import 'workout_state.dart';

class WorkoutBloc extends Bloc<WorkoutEvent, WorkoutState> {
  WorkoutBloc() : super(WorkoutIdle()) {
    on<StartWorkout>(_onStart);
    on<LogSet>(_onLogSet);
    on<FinishWorkout>(_onFinish);
  }

  void _onStart(StartWorkout event, Emitter<WorkoutState> emit) {
    // criar exercícios dummy para o treino
    final exercises = [
      Exercise(id: 'peito', name: 'Peito'),
      Exercise(id: 'costas', name: 'Costas'),
      Exercise(id: 'pernas', name: 'Pernas'),
    ];

    final exerciseSets = {
      for (var e in exercises) e.id: <SetLog>[]
    };

    emit(
      WorkoutInProgress(
        WorkoutSession(
          trainingDayId: event.trainingDayId,
          date: DateTime.now(),
          exerciseSets: exerciseSets,
        ),
      ),
    );
  }

  void _onLogSet(LogSet event, Emitter<WorkoutState> emit) {
    final current = state as WorkoutInProgress;

    final sets = List<SetLog>.from(
        current.session.exerciseSets[event.setLog.exerciseId] ?? []);
    sets.add(event.setLog);

    final updatedMap = Map<String, List<SetLog>>.from(
        current.session.exerciseSets);
    updatedMap[event.setLog.exerciseId] = sets;

    emit(
      WorkoutInProgress(
        current.session.copyWith(exerciseSets: updatedMap),
      ),
    );
  }

  void _onFinish(FinishWorkout event, Emitter<WorkoutState> emit) {
    emit(WorkoutCompleted());
  }
}
