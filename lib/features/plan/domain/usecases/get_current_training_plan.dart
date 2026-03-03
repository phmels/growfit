import 'package:growfit/features/plan/domain/entities/training_plan.dart';
import 'package:hive/hive.dart';

class GetCurrentTrainingPlan {
  Future<TrainingPlan> call() async {
    final box = await Hive.openBox<TrainingPlan>('trainingPlans');
    if (box.isNotEmpty) {
      return box.getAt(0)!;
    }
    throw Exception('Nenhum plano encontrado');
  }
}
