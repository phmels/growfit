import 'package:growfit/features/plan/domain/entities/exercise.dart';
import 'package:growfit/features/plan/domain/entities/exercise_group.dart';
import 'package:growfit/features/plan/domain/entities/training_day.dart';
import 'package:growfit/features/plan/domain/entities/training_plan.dart';

final dummyPlans = [
  TrainingPlan(
    days: [
      TrainingDay(
        id: 'A',
        name: 'Treino A',
        groups: [
          ExerciseGroup(
            id: 'costas',
            name: 'Costas',
            exercises: [
              Exercise(id: 'puxada', name: 'Puxada', defaultWeight: 60, defaultSeries:3 , defaultReps: 10),
              Exercise(id: 'remada', name: 'Remada Curvada', defaultWeight: 50, defaultSeries:4 , defaultReps: 12),
            ],
          ),
          ExerciseGroup(
            id: 'biceps',
            name: 'Bíceps',
            exercises: [
              Exercise(id: 'rosca', name: 'Rosca Direta', defaultWeight: 20, defaultSeries:3 , defaultReps: 12),
              Exercise(id: 'rosca_martelo', name: 'Rosca Martelo', defaultWeight: 15, defaultSeries:3 , defaultReps: 12),
            ],
          ),
        ],
      ),
      TrainingDay(
        id: 'B',
        name: 'Treino B',
        groups: [
          ExerciseGroup(
            id: 'peito',
            name: 'Peito',
            exercises: [
              Exercise(id: 'supino', name: 'Supino Reto', defaultWeight: 70, defaultSeries:3 , defaultReps: 10),
            ],
          ),
          ExerciseGroup(
            id: 'triceps',
            name: 'Tríceps',
            exercises: [
              Exercise(id: 'triceps_corda', name: 'Tríceps Corda', defaultWeight: 25, defaultSeries:3 , defaultReps: 12),
            ],
          ),
        ],
      ),
      TrainingDay(
        id: 'C',
        name: 'Treino C',
        groups: [
          ExerciseGroup(
            id: 'pernas',
            name: 'Pernas',
            exercises: [
              Exercise(id: 'agachamento', name: 'Agachamento', defaultWeight: 80, defaultSeries:3 , defaultReps: 10),
            ],
          ),
          ExerciseGroup(
            id: 'ombros',
            name: 'Ombros',
            exercises: [
              Exercise(id: 'desenvolvimento', name: 'Desenvolvimento', defaultWeight: 30, defaultSeries:3 , defaultReps: 12),
            ],
          ),
        ],
      ),
    ],
  ),
];
