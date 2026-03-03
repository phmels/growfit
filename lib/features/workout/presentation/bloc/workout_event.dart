import 'package:equatable/equatable.dart';
import 'package:growfit/features/workout/domain/entities/set_log.dart';

abstract class WorkoutEvent extends Equatable {
  const WorkoutEvent();

  @override
  List<Object?> get props => [];
}

class StartWorkout extends WorkoutEvent {
  final String trainingDayId;
  const StartWorkout(this.trainingDayId);
}

class LogSet extends WorkoutEvent {
  final SetLog setLog;
  const LogSet(this.setLog);

  @override
  List<Object?> get props => [setLog];
}

class FinishWorkout extends WorkoutEvent {}
