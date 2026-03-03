import 'package:hive/hive.dart';
import 'workout_exercise.dart';

part 'workout_group.g.dart';

@HiveType(typeId: 3)
class WorkoutGroup extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  List<WorkoutExercise> exercises;

  WorkoutGroup({
    required this.name,
    required this.exercises,
  });
}
