import 'package:growfit/features/plan/domain/entities/training_plan.dart';

abstract class PlanEvent {}

class LoadPlan extends PlanEvent {}

class UpdatePlan extends PlanEvent {
  final TrainingPlan plan; // ⚡ Aqui estava 'updatedPlan' antes
  UpdatePlan(this.plan);
}
