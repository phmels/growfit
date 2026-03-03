import '../entities/cycle_state_entity.dart';

abstract class CycleRepository {
  Future<CycleStateEntity> loadCycleState();
  Future<void> saveCycleState(CycleStateEntity state);
}
