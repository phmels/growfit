import '../../../plan/domain/entities/training_day.dart';
import '../../../plan/domain/entities/training_plan.dart';
import '../entities/cycle_state_entity.dart';

class GetNextTrainingDay {
  TrainingDay execute({
    required TrainingPlan plan,
    required CycleStateEntity cycleState,
  }) {
    if (plan.days.isEmpty) {
      // Retorna um dia de descanso padrão
      return TrainingDay(id: 'rest', name: 'Dia de Descanso', groups: []);
    }

    // Ciclo normal
    final index = cycleState.currentIndex % plan.days.length;
    return plan.days[index];
  }
}
