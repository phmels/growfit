import 'package:growfit/features/plan/domain/entities/training_day.dart';

abstract class CycleState {
  const CycleState();
}

class CycleInitial extends CycleState {}

class CycleLoading extends CycleState {}

class CycleReady extends CycleState {
  final TrainingDay nextTrainingDay;

  const CycleReady({required this.nextTrainingDay});
}

class CycleError extends CycleState {
  final String message;

  const CycleError({required this.message});
}
