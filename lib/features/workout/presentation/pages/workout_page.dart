import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:growfit/core/constants/theme.dart';
import 'package:growfit/features/cycle/presentation/bloc/cycle_state.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:growfit/features/cycle/presentation/bloc/cycle_bloc.dart';
import 'package:growfit/features/cycle/presentation/bloc/cycle_event.dart';
import 'package:growfit/features/plan/domain/entities/training_day.dart';
import 'package:growfit/features/workout/domain/entities/set_log.dart';
import 'package:growfit/features/workout/domain/entities/workout_exercise.dart';
import 'package:growfit/features/workout/domain/entities/workout_group.dart';
import 'package:growfit/features/workout/domain/entities/workout_session.dart';

class WorkoutPage extends StatefulWidget {
  final TrainingDay day;

  const WorkoutPage({super.key, required this.day});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  List<WorkoutGroup> workoutGroups = [];

  @override
  void initState() {
    super.initState();
    _loadWorkout();
  }

  Future<Map<String, SetLog>> _getLastExerciseValues() async {
    final box = Hive.box<WorkoutSession>('workoutSessions');
    final sessions = box.values
        .where((s) => s.trainingDayId == widget.day.id)
        .toList();

    if (sessions.isEmpty) return {};
    sessions.sort((a, b) => b.date.compareTo(a.date));
    final lastSession = sessions.first;

    final Map<String, SetLog> lastValues = {};
    lastSession.exerciseSets.forEach((exerciseId, sets) {
      if (sets.isNotEmpty) {
        lastValues[exerciseId] = sets.last;
      }
    });
    return lastValues;
  }

  Future<void> _loadWorkout() async {
    final box = Hive.box<WorkoutSession>('workoutSessions');
    final sessions = box.values
        .where((s) => s.trainingDayId == widget.day.id)
        .toList();

    Map<String, List<SetLog>> lastSets = {};
    if (sessions.isNotEmpty) {
      sessions.sort((a, b) => b.date.compareTo(a.date));
      // ⭐ copia direto as chaves compostas 'grupo__exId'
      lastSets = Map.from(sessions.first.exerciseSets);
    }

    workoutGroups = widget.day.groups.map((group) {
      return WorkoutGroup(
        name: group.name,
        exercises: group.exercises.map((ex) {
          // ⭐ lookup pela mesma chave composta usada ao salvar
          final key = '${group.name}__${ex.id}';
          final lastList = lastSets[key];
          final lastLog = lastList?.first; // ⭐ first em vez de last
          return WorkoutExercise(
            id: ex.id,
            name: ex.name,
            weight: lastLog?.weight ?? ex.defaultWeight,
            reps: lastLog?.reps ?? ex.defaultReps,
            series:
                lastLog?.setNumber ??
                ex.defaultSeries, // ⭐ setNumber = total de séries
          );
        }).toList(),
      );
    }).toList();

    setState(() {});
  }

  Future<void> _saveWorkoutSession() async {
    final sessionBox = Hive.box<WorkoutSession>('workoutSessions');
    final Map<String, List<SetLog>> logs = {};

    for (var group in workoutGroups) {
      for (var ex in group.exercises) {
        final key = '${group.name}__${ex.id}';
        logs[key] = [
          SetLog(
            exerciseId: ex.id,
            exerciseName: ex.name,
            setNumber: ex.series, // ⭐ guarda o total de séries aqui
            weight: ex.weight,
            reps: ex.reps,
          ),
        ]; // ⭐ lista com apenas 1 item
      }
    }

    final session = WorkoutSession(
      trainingDayId: widget.day.id,
      date: DateTime.now(),
      exerciseSets: logs,
    );

    await sessionBox.add(session);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Treino salvo com sucesso!')));
  }

  @override
  Widget build(BuildContext context) {
    if (workoutGroups.isEmpty && widget.day.groups.isNotEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.bg,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final isRestDay = workoutGroups.isEmpty;

    return BlocListener<CycleBloc, CycleState>(
      listenWhen: (previous, current) =>
          previous is! CycleReady && current is CycleReady,
      listener: (context, state) {
        Navigator.pop(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.bg,
        appBar: AppBar(
          title: Text(isRestDay ? 'Descanso' : widget.day.name),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.bg),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: isRestDay
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('😴', style: TextStyle(fontSize: 64)),
                    const SizedBox(height: 16),
                    Text(
                      'Dia de descanso',
                      style: AppTextStyles.title.copyWith(fontSize: 22),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Aproveite para recuperar! 💪',
                      style: AppTextStyles.subtitle,
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                itemCount: workoutGroups.length,
                itemBuilder: (context, index) {
                  final group = workoutGroups[index];
                  return _GroupCard(group: group);
                },
              ),

        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: isRestDay
            ? null
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    // BOTÃO PULAR
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.surface,
                            foregroundColor: AppColors.textMuted,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: const BorderSide(color: AppColors.border),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            context.read<CycleBloc>().add(AdvanceCycle());
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Treino pulado')),
                            );
                          },
                          icon: const Icon(Icons.skip_next, size: 20),
                          label: const Text(
                            'Pular',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // BOTÃO FINALIZAR
                    Expanded(
                      flex: 2,
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            await _saveWorkoutSession();
                            context.read<CycleBloc>().add(AdvanceCycle());
                            if (!mounted) return;
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.check, size: 20),
                          label: const Text(
                            'Finalizar Treino',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

// ── GROUP CARD ───────────────────────────────────────────────────────────────
class _GroupCard extends StatelessWidget {
  final WorkoutGroup group;
  const _GroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Theme(
        // remove o divider padrão do ExpansionTile
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.muted,
          title: Text(
            group.name,
            style: AppTextStyles.title.copyWith(fontSize: 15),
          ),
          children: group.exercises.map((exercise) {
            return _ExerciseRow(exercise: exercise);
          }).toList(),
        ),
      ),
    );
  }
}

// ── EXERCISE ROW ─────────────────────────────────────────────────────────────
class _ExerciseRow extends StatelessWidget {
  final WorkoutExercise exercise;
  const _ExerciseRow({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(exercise.name, style: AppTextStyles.subtitle)),
          const SizedBox(width: 8),
          _NumberField(
            initialValue: exercise.weight.toString(),
            label: 'Kg',
            onChanged: (v) =>
                exercise.weight = double.tryParse(v) ?? exercise.weight,
          ),
          const SizedBox(width: 8),
          _NumberField(
            initialValue: exercise.reps.toString(),
            label: 'Reps',
            onChanged: (v) => exercise.reps = int.tryParse(v) ?? exercise.reps,
          ),
          const SizedBox(width: 8),
          _NumberField(
            initialValue: exercise.series.toString(),
            label: 'Séries',
            onChanged: (v) =>
                exercise.series = int.tryParse(v) ?? exercise.series,
          ),
        ],
      ),
    );
  }
}

// ── NUMBER FIELD ─────────────────────────────────────────────────────────────
class _NumberField extends StatelessWidget {
  final String initialValue;
  final String label;
  final Function(String) onChanged;

  const _NumberField({
    required this.initialValue,
    required this.label,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: AppTextStyles.title.copyWith(fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.subtitle.copyWith(fontSize: 11),
          isDense: true,
          filled: true,
          fillColor: AppColors.card,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 10,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
