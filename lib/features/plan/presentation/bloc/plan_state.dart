import 'package:growfit/features/plan/domain/entities/training_plan.dart';

abstract class PlanState {}

class PlanLoading extends PlanState {}

class PlanLoaded extends PlanState {
  final TrainingPlan plan;
  PlanLoaded(this.plan);
}
