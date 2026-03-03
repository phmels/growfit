import 'package:hive/hive.dart';

part 'set_log.g.dart';

@HiveType(typeId: 4)
class SetLog extends HiveObject {
  @HiveField(0)
  String exerciseId;

  @HiveField(1)
  String exerciseName; // ⭐ NOVO CAMPO

  @HiveField(2)
  int setNumber;

  @HiveField(3)
  double weight;

  @HiveField(4)
  int reps;

  SetLog({
    required this.exerciseId,
    required this.exerciseName, // ⭐ obrigatório agora
    required this.setNumber,
    required this.weight,
    required this.reps,
  });
}
