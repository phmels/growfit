import 'package:hive/hive.dart';

part 'workout_exercise.g.dart';

@HiveType(typeId: 2)
class WorkoutExercise extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double weight;

  @HiveField(3)
  int reps;

  @HiveField(4)
  int series;

  @HiveField(5)
  bool completed;

  WorkoutExercise({
    required this.id,
    required this.name,
    required this.weight,
    required this.reps,
    required this.series,
    this.completed = false,
  });
}
