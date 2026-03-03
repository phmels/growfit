import 'package:hive/hive.dart';

part 'cycle_state_entity.g.dart';

@HiveType(typeId: 9) // número único
class CycleStateEntity {
  @HiveField(0)
  final int currentIndex;

  const CycleStateEntity({
    required this.currentIndex,
  });

  CycleStateEntity copyWith({
    int? currentIndex,
  }) {
    return CycleStateEntity(
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}
