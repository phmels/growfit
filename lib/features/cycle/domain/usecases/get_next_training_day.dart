import '../../../plan/domain/entities/training_day.dart';
import '../../../plan/domain/entities/training_plan.dart';
import '../entities/cycle_state_entity.dart';

class GetNextTrainingDay {
  TrainingDay execute({
    required TrainingPlan plan,
    required CycleStateEntity cycleState,
  }) {
    if (plan.days.isEmpty) {
      return TrainingDay(id: 'rest', name: 'Dia de Descanso', groups: []);
    }

    final restEvery = cycleState.restEvery;

    // Sem descanso configurado — comportamento original
    if (restEvery <= 0) {
      final index = cycleState.currentIndex % plan.days.length;
      return plan.days[index];
    }

    // Com descanso: ciclo virtual tem (restEvery + 1) slots
    // Ex: restEvery=3 → [treino, treino, treino, descanso, treino, treino, ...]
    final cycleSize = restEvery + 1;
    final posInCycle = cycleState.currentIndex % cycleSize;

    if (posInCycle == restEvery) {
      // É o slot de descanso
      return TrainingDay(id: 'rest', name: 'Dia de Descanso', groups: []);
    }

    // É slot de treino — qual dia do plano?
    // Conta quantos treinos já passaram no total
    final completedCycles = cycleState.currentIndex ~/ cycleSize;
    final trainingsInCurrentCycle = posInCycle;
    final totalTrainings =
        completedCycles * restEvery + trainingsInCurrentCycle;
    final dayIndex = totalTrainings % plan.days.length;

    return plan.days[dayIndex];
  }
}