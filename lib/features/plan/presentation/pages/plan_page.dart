import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:growfit/core/constants/theme.dart';
import 'package:growfit/features/plan/domain/entities/exercise.dart';
import 'package:growfit/features/plan/domain/entities/exercise_group.dart';
import 'package:growfit/features/plan/domain/entities/training_day.dart';
import 'package:growfit/features/plan/presentation/bloc/plan_bloc.dart';
import 'package:growfit/features/plan/presentation/bloc/plan_event.dart';
import 'package:growfit/features/plan/presentation/bloc/plan_state.dart';
import 'package:growfit/features/plan/presentation/widgets/group_exercise_selector.dart';

class PlanPage extends StatelessWidget {
  const PlanPage({super.key});

  void _updatePlan(BuildContext context, TrainingDay updatedDay, int dayIndex, PlanLoaded state) {
    final newDays = List.of(state.plan.days);
    newDays[dayIndex] = updatedDay;
    context.read<PlanBloc>().add(UpdatePlan(state.plan.copyWith(days: newDays)));
  }

  void _addTrainingDay(BuildContext context, PlanLoaded state) {
    final newDay = TrainingDay(
      id: 'day_${state.plan.days.length + 1}',
      name: 'Treino ${String.fromCharCode(65 + state.plan.days.length)}',
      groups: [],
    );
    final newDays = List.of(state.plan.days)..add(newDay);
    context.read<PlanBloc>().add(UpdatePlan(state.plan.copyWith(days: newDays)));
  }

  void _addGroup(BuildContext context, PlanLoaded state, int dayIndex) {
    final newGroup = ExerciseGroup(
      id: 'group_${DateTime.now().millisecondsSinceEpoch}',
      name: '', // será preenchido pelo dropdown
      exercises: [],
    );
    final day = state.plan.days[dayIndex];
    final updatedDay = day.copyWith(groups: List.of(day.groups)..add(newGroup));
    _updatePlan(context, updatedDay, dayIndex, state);
  }

  void _addExercise(BuildContext context, PlanLoaded state, int dayIndex, String groupId) {
    final day = state.plan.days[dayIndex];
    final newGroups = day.groups.map((g) {
      if (g.id == groupId) {
        final newExercise = Exercise(
          id: 'ex_${DateTime.now().millisecondsSinceEpoch}',
          name: '', // será preenchido pelo dropdown
          defaultWeight: 10,
          defaultSeries: 3,
          defaultReps: 10,
        );
        return g.copyWith(exercises: List.of(g.exercises)..add(newExercise));
      }
      return g;
    }).toList();
    final updatedDay = day.copyWith(groups: newGroups);
    _updatePlan(context, updatedDay, dayIndex, state);
  }

  void _removeExercise(BuildContext context, PlanLoaded state, int dayIndex, String groupId, String exerciseId) {
    final day = state.plan.days[dayIndex];
    final newGroups = day.groups.map((g) {
      if (g.id == groupId) {
        return g.copyWith(exercises: g.exercises.where((ex) => ex.id != exerciseId).toList());
      }
      return g;
    }).toList();
    final updatedDay = day.copyWith(groups: newGroups);
    _updatePlan(context, updatedDay, dayIndex, state);
  }

  void _updateExercise(BuildContext context, PlanLoaded state, int dayIndex, String groupId, Exercise updatedExercise) {
    final day = state.plan.days[dayIndex];
    final newGroups = day.groups.map((g) {
      if (g.id == groupId) {
        final newExercises = g.exercises.map((ex) => ex.id == updatedExercise.id ? updatedExercise : ex).toList();
        return g.copyWith(exercises: newExercises);
      }
      return g;
    }).toList();
    final updatedDay = day.copyWith(groups: newGroups);
    _updatePlan(context, updatedDay, dayIndex, state);
  }

  void _saveGroup(BuildContext context, PlanLoaded state, int dayIndex, String groupId) {
    final day = state.plan.days[dayIndex];
    final group = day.groups.firstWhere((g) => g.id == groupId);
    final updatedGroups = day.groups.map((g) => g.id == groupId ? group : g).toList();
    final updatedDay = day.copyWith(groups: updatedGroups);
    _updatePlan(context, updatedDay, dayIndex, state);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Grupamento salvo com sucesso ✅')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar:  AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Editar Plano',
          style: AppTextStyles.title.copyWith(
            fontSize: 20,
            letterSpacing: 2,
            color: AppColors.primary,
          ),
        ),
      ),
      body: BlocBuilder<PlanBloc, PlanState>(
        builder: (context, state) {
          if (state is PlanLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (state is PlanLoaded) {
            final plan = state.plan;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                children: [
                  ...plan.days.asMap().entries.map((entry) {
                    final dayIndex = entry.key;
                    final day = entry.value;
                    return _DayCard(
                      day: day,
                      dayIndex: dayIndex,
                      state: state,
                      onAddGroup: () => _addGroup(context, state, dayIndex),
                      onAddExercise: (groupId) => _addExercise(context, state, dayIndex, groupId),
                      onRemoveExercise: (groupId, exId) => _removeExercise(context, state, dayIndex, groupId, exId),
                      onUpdateExercise: (groupId, ex) => _updateExercise(context, state, dayIndex, groupId, ex),
                      onSaveGroup: (groupId) => _saveGroup(context, state, dayIndex, groupId),
                      onRemoveGroup: (group) {
                        final newGroups = List.of(day.groups)..remove(group);
                        final updatedDay = day.copyWith(groups: newGroups);
                        _updatePlan(context, updatedDay, dayIndex, state);
                      },
                      onUpdateGroupName: (groupId, name) {
                        final updatedDay = day.copyWith(
                          groups: day.groups.map((g) => g.id == groupId ? g.copyWith(name: name) : g).toList(),
                        );
                        _updatePlan(context, updatedDay, dayIndex, state);
                      },
                    );
                  }),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: () => _addTrainingDay(context, state),
                      icon: const Icon(Icons.add, size: 20),
                      label: const Text('Adicionar Novo Dia'),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

// ── DAY CARD ──────────────────────────────────────────────────────────────────
class _DayCard extends StatelessWidget {
  final TrainingDay day;
  final int dayIndex;
  final PlanLoaded state;
  final VoidCallback onAddGroup;
  final Function(String groupId) onAddExercise;
  final Function(String groupId, String exId) onRemoveExercise;
  final Function(String groupId, Exercise ex) onUpdateExercise;
  final Function(String groupId) onSaveGroup;
  final Function(ExerciseGroup group) onRemoveGroup;
  final Function(String groupId, String name) onUpdateGroupName;

  const _DayCard({
    required this.day,
    required this.dayIndex,
    required this.state,
    required this.onAddGroup,
    required this.onAddExercise,
    required this.onRemoveExercise,
    required this.onUpdateExercise,
    required this.onSaveGroup,
    required this.onRemoveGroup,
    required this.onUpdateGroupName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.muted,
          title: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Text(
                  '${dayIndex + 1}',
                  style: AppTextStyles.label.copyWith(fontSize: 13),
                ),
              ),
              const SizedBox(width: 12),
              Text(day.name, style: AppTextStyles.title.copyWith(fontSize: 15)),
            ],
          ),
          children: [
            ...day.groups.map((group) => _GroupCard(
              group: group,
              onAddExercise: () => onAddExercise(group.id),
              onRemoveExercise: (exId) => onRemoveExercise(group.id, exId),
              onUpdateExercise: (ex) => onUpdateExercise(group.id, ex),
              onSaveGroup: () => onSaveGroup(group.id),
              onRemoveGroup: () => onRemoveGroup(group),
              onUpdateGroupName: (name) => onUpdateGroupName(group.id, name),
            )),
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
              child: SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: AppColors.primary.withOpacity(0.25)),
                    ),
                  ),
                  onPressed: onAddGroup,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Adicionar Grupamento',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── GROUP CARD ────────────────────────────────────────────────────────────────
class _GroupCard extends StatelessWidget {
  final ExerciseGroup group;
  final VoidCallback onAddExercise;
  final Function(String exId) onRemoveExercise;
  final Function(Exercise ex) onUpdateExercise;
  final VoidCallback onSaveGroup;
  final VoidCallback onRemoveGroup;
  final Function(String name) onUpdateGroupName;

  const _GroupCard({
    required this.group,
    required this.onAddExercise,
    required this.onRemoveExercise,
    required this.onUpdateExercise,
    required this.onSaveGroup,
    required this.onRemoveGroup,
    required this.onUpdateGroupName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.muted,
          // ── TÍTULO: dropdown de grupamento ──
          title: GroupDropdown(
            initialValue: group.name.isEmpty ? null : group.name,
            onChanged: onUpdateGroupName,
          ),
          children: [
            ...group.exercises.map((ex) => _ExerciseItem(
              exercise: ex,
              groupName: group.name,
              onRemove: () => onRemoveExercise(ex.id),
              onUpdate: (updated) => onUpdateExercise(updated),
            )),
            const SizedBox(height: 4),
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    icon: Icons.add,
                    label: 'Exercício',
                    color: AppColors.primary,
                    onTap: onAddExercise,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.save_outlined,
                    label: 'Salvar',
                    color: AppColors.accent2,
                    onTap: onSaveGroup,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionButton(
                    icon: Icons.delete_outline,
                    label: 'Grupo',
                    color: AppColors.danger,
                    onTap: onRemoveGroup,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── EXERCISE ITEM ─────────────────────────────────────────────────────────────
class _ExerciseItem extends StatelessWidget {
  final Exercise exercise;
  final String groupName;
  final VoidCallback onRemove;
  final Function(Exercise) onUpdate;

  const _ExerciseItem({
    required this.exercise,
    required this.groupName,
    required this.onRemove,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(exercise.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppColors.danger.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.danger),
      ),
      onDismissed: (_) => onRemove(),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Dropdown de exercício filtrado pelo grupamento ──
            ExerciseDropdown(
              group: groupName.isEmpty ? null : groupName,
              initialValue: exercise.name.isEmpty ? null : exercise.name,
              onChanged: (name) => onUpdate(exercise.copyWith(name: name)),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _PlanNumberField(
                  label: 'Kg',
                  initialValue: exercise.defaultWeight.toString(),
                  onChanged: (val) => onUpdate(
                    exercise.copyWith(
                        defaultWeight: double.tryParse(val) ?? exercise.defaultWeight),
                  ),
                ),
                const SizedBox(width: 8),
                _PlanNumberField(
                  label: 'Séries',
                  initialValue: exercise.defaultSeries.toString(),
                  onChanged: (val) => onUpdate(
                    exercise.copyWith(
                        defaultSeries: int.tryParse(val) ?? exercise.defaultSeries),
                  ),
                ),
                const SizedBox(width: 8),
                _PlanNumberField(
                  label: 'Reps',
                  initialValue: exercise.defaultReps.toString(),
                  onChanged: (val) => onUpdate(
                    exercise.copyWith(
                        defaultReps: int.tryParse(val) ?? exercise.defaultReps),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── ACTION BUTTON ─────────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      style: TextButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: color.withOpacity(0.25)),
        ),
        backgroundColor: color.withOpacity(0.07),
      ),
      onPressed: onTap,
      icon: Icon(icon, size: 16),
      label: Text(label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

// ── NUMBER FIELD ──────────────────────────────────────────────────────────────
class _PlanNumberField extends StatelessWidget {
  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;

  const _PlanNumberField({
    required this.label,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextFormField(
        initialValue: initialValue,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: AppTextStyles.title.copyWith(fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppTextStyles.subtitle.copyWith(fontSize: 11),
          isDense: true,
          filled: true,
          fillColor: AppColors.surface,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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
            borderSide:
                const BorderSide(color: AppColors.primary, width: 1.5),
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}