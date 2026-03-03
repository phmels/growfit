import 'package:hive/hive.dart';
import 'set_log.dart';

part 'workout_session.g.dart';

@HiveType(typeId: 5)
class WorkoutSession extends HiveObject {
  @HiveField(0)
  String trainingDayId;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  Map<String, List<SetLog>> exerciseSets;

  WorkoutSession({
    required this.trainingDayId,
    required this.date,
    required this.exerciseSets,
  });

  WorkoutSession copyWith({
    Map<String, List<SetLog>>? exerciseSets,
  }) {
    return WorkoutSession(
      trainingDayId: trainingDayId,
      date: date,
      exerciseSets: exerciseSets ?? this.exerciseSets,
    );
  }
}
