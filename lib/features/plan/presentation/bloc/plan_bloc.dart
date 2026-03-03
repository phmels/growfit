import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:growfit/features/plan/domain/entities/training_plan.dart';
import 'plan_event.dart';
import 'plan_state.dart';

class PlanBloc extends Bloc<PlanEvent, PlanState> {
  PlanBloc() : super(PlanLoading()) {
    on<LoadPlan>(_onLoadPlan);
    on<UpdatePlan>(_onUpdatePlan);
  }

  Future<void> _onLoadPlan(LoadPlan event, Emitter<PlanState> emit) async {
    emit(PlanLoading());
    final box = await Hive.openBox<TrainingPlan>('trainingPlans');
    if (box.isNotEmpty) {
      emit(PlanLoaded(box.getAt(0)!));
    } else {
      // Se não existir, cria um plano vazio
      final newPlan = TrainingPlan(days: []);
      await box.add(newPlan);
      emit(PlanLoaded(newPlan));
    }
  }

  Future<void> _onUpdatePlan(UpdatePlan event, Emitter<PlanState> emit) async {
    final box = await Hive.openBox<TrainingPlan>('trainingPlans');

    // Atualiza o primeiro índice do Hive
    if (box.isEmpty) {
      await box.add(event.plan);
    } else {
      await box.putAt(0, event.plan);
    }

    // Emite a versão atualizada do estado
    emit(PlanLoaded(event.plan));
  }
}
