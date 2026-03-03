import 'package:hive/hive.dart';
import 'exercise.dart';

part 'exercise_group.g.dart';

@HiveType(typeId: 1) // cada entidade precisa de um typeId único, diferente do Exercise
class ExerciseGroup extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<Exercise> exercises;

  ExerciseGroup({
    required this.id,
    required this.name,
    required this.exercises,
  });

  ExerciseGroup copyWith({
    String? id,
    String? name,
    List<Exercise>? exercises,
  }) {
    return ExerciseGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      exercises: exercises ?? this.exercises,
    );
  }
}
