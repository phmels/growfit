import 'package:hive/hive.dart';

part 'exercise.g.dart'; // <-- necessário para gerar o adapter

@HiveType(typeId: 0) // cada entidade precisa de um typeId único
class Exercise extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  double defaultWeight;

  @HiveField(3)
  int defaultSeries;

  @HiveField(4)
  int defaultReps;

  Exercise({
    required this.id,
    required this.name,
    required this.defaultWeight,
    required this.defaultSeries,
    required this.defaultReps,
  });

  Exercise copyWith({
    String? id,
    String? name,
    double? defaultWeight,
    int? defaultSeries,
    int? defaultReps,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      defaultWeight: defaultWeight ?? this.defaultWeight,
      defaultSeries: defaultSeries ?? this.defaultSeries,
      defaultReps: defaultReps ?? this.defaultReps,
    );
  }
}
