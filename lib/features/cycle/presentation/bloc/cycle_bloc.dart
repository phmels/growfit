import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:growfit/features/cycle/domain/entities/cycle_state_entity.dart';
import 'package:growfit/features/cycle/domain/repositories/cycle_repository.dart';
import 'package:growfit/features/cycle/domain/usecases/get_next_training_day.dart';
import 'package:growfit/features/cycle/presentation/bloc/cycle_event.dart';
import 'package:growfit/features/cycle/presentation/bloc/cycle_state.dart';
import 'package:growfit/features/plan/domain/entities/training_day.dart';
import 'package:growfit/features/plan/domain/entities/training_plan.dart';
import 'package:growfit/features/plan/domain/usecases/get_current_training_plan.dart';

class CycleBloc extends Bloc<CycleEvent, CycleState> {
  final GetNextTrainingDay getNextTrainingDay;
  final GetCurrentTrainingPlan getCurrentTrainingPlan;
  final CycleRepository cycleRepository;

  late TrainingPlan _plan;
  late CycleStateEntity _cycleState;

  CycleBloc({
    required this.getNextTrainingDay,
    required this.getCurrentTrainingPlan,
    required this.cycleRepository,
  }) : super(CycleInitial()) {
    on<LoadCycle>(_onLoadCycle);
    on<AdvanceCycle>(_onAdvanceCycle);
  }

  Future<void> _onLoadCycle(LoadCycle event, Emitter<CycleState> emit) async {
    try {
      emit(CycleLoading());

      _plan = await getCurrentTrainingPlan();
      _cycleState = await cycleRepository.loadCycleState();

      final TrainingDay next = getNextTrainingDay.execute(
        plan: _plan,
        cycleState: _cycleState,
      );

      emit(CycleReady(nextTrainingDay: next));
    } catch (e, stack) {
      print("ERRO AO CARREGAR CICLO:");
      print(e);
      print(stack);

      emit(CycleError(message: e.toString()));
    }
  }

  Future<void> _onAdvanceCycle(
    AdvanceCycle event,
    Emitter<CycleState> emit,
  ) async {
    try {
      // Incrementa índice do ciclo
      _cycleState = _cycleState.copyWith(
        currentIndex: _cycleState.currentIndex + 1,
      );

      // Salva o estado atualizado no Hive
      await cycleRepository.saveCycleState(_cycleState);

      // Pega o plano atualizado
      _plan = await getCurrentTrainingPlan();

      // Pega o próximo dia de treino com segurança
      final TrainingDay next = getNextTrainingDay.execute(
        plan: _plan,
        cycleState: _cycleState,
      );

      // Emite o novo estado
      emit(CycleReady(nextTrainingDay: next));
    } catch (e, st) {
      print('Erro ao avançar ciclo: $e\n$st');
      print('NEXT DAY DEBUG');
   

      emit(CycleError(message: e.toString()));
    }
  }
}
