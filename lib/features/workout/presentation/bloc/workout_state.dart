import 'package:equatable/equatable.dart';
import '../../domain/entities/workout_session.dart';

abstract class WorkoutState extends Equatable {
  const WorkoutState();

  @override
  List<Object?> get props => [];
}

class WorkoutIdle extends WorkoutState {}

class WorkoutInProgress extends WorkoutState {
  final WorkoutSession session;
  const WorkoutInProgress(this.session);

  @override
  List<Object?> get props => [session];
}

class WorkoutCompleted extends WorkoutState {}
