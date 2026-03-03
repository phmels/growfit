import 'package:hive/hive.dart';
import 'training_day.dart';
part 'training_plan.g.dart';

@HiveType(typeId: 7)
class TrainingPlan extends HiveObject {
  @HiveField(0)
  final List<TrainingDay> days;

  TrainingPlan({required this.days});

  TrainingPlan copyWith({List<TrainingDay>? days}) {
    return TrainingPlan(days: days ?? this.days);
  }
}
