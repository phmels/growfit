import 'package:hive/hive.dart';
import '../../domain/entities/cycle_state_entity.dart';
import '../../domain/repositories/cycle_repository.dart';

class CycleRepositoryImpl implements CycleRepository {
  static const _boxName = 'cycleStateBox';
  CycleStateEntity? _cache;

  /// Salva o estado do ciclo no Hive
  @override
  Future<void> saveCycleState(CycleStateEntity state) async {
    _cache = state;
    final box = await Hive.openBox<CycleStateEntity>(_boxName);
    if (box.isEmpty) {
      await box.add(state);
    } else {
      await box.putAt(0, state);
    }
  }

  /// Carrega o estado do ciclo do Hive
  @override
  Future<CycleStateEntity> loadCycleState() async {
    if (_cache != null) return _cache!;
    final box = await Hive.openBox<CycleStateEntity>(_boxName);
    if (box.isNotEmpty) {
      _cache = box.getAt(0)!;
      return _cache!;
    }
    // Se não houver nada salvo, retorna o inicial
    return const CycleStateEntity(currentIndex: 0);
  }
}
