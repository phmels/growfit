import 'package:hive/hive.dart';
import 'exercise_group.dart';
part 'training_day.g.dart';

@HiveType(typeId: 6)
class TrainingDay extends HiveObject {
  @HiveField(0)
  final String id; // A, B, C

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<ExerciseGroup> groups;

  TrainingDay({
    required this.id,
    required this.name,
    required this.groups,
  });

  TrainingDay copyWith({
    String? id,
    String? name,
    List<ExerciseGroup>? groups,
  }) {
    return TrainingDay(
      id: id ?? this.id,
      name: name ?? this.name,
      groups: groups ?? this.groups,
    );
  }
}
