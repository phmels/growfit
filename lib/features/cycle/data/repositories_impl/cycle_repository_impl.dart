import 'package:hive/hive.dart';
import '../../domain/entities/cycle_state_entity.dart';
import '../../domain/repositories/cycle_repository.dart';
import 'package:flutter/foundation.dart';

class CycleRepositoryImpl implements CycleRepository {
  static const _boxName = 'cycleState';
  CycleStateEntity? _cache;

  /// Salva o estado do ciclo no Hive
  @override
  Future<void> saveCycleState(CycleStateEntity state) async {
    _cache = state;
    final box = Hive.box<CycleStateEntity>(_boxName);
    debugPrint(
      'SAVING: index=${state.currentIndex}, restEvery=${state.restEvery}, boxName=$_boxName, boxLength=${box.length}',
    );
    if (box.isEmpty) {
      await box.add(state);
    } else {
      await box.putAt(0, state);
    }
    debugPrint('SAVED: boxLength=${box.length}, value=${box.getAt(0)?.currentIndex}');
  }

  /// Carrega o estado do ciclo do Hive
  @override
  Future<CycleStateEntity> loadCycleState() async {
    if (_cache != null) return _cache!;
    final box = Hive.box<CycleStateEntity>(
      _boxName,
    ); // sem openBox, já está aberto
    debugPrint('BOX LENGTH: ${box.length}');
    if (box.isNotEmpty) {
      final state = box.getAt(0)!;
      debugPrint(
        'LOADED: index=${state.currentIndex}, restEvery=${state.restEvery}',
      );
      _cache = state;
      return _cache!;
    }
    debugPrint('EMPTY BOX — returning initial');
    return const CycleStateEntity(currentIndex: 0);
  }
}
