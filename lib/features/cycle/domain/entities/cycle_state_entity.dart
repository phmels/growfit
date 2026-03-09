import 'package:hive/hive.dart';

part 'cycle_state_entity.g.dart';

@HiveType(typeId: 9)
class CycleStateEntity {
  @HiveField(0)
  final int currentIndex;

  @HiveField(1)
  final int restEvery; // 0 = sem descanso automático

  const CycleStateEntity({
    required this.currentIndex,
    this.restEvery = 0,
  });

  CycleStateEntity copyWith({
    int? currentIndex,
    int? restEvery,
  }) {
    return CycleStateEntity(
      currentIndex: currentIndex ?? this.currentIndex,
      restEvery: restEvery ?? this.restEvery,
    );
  }
}
