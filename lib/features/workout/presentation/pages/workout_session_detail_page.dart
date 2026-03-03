import 'package:flutter/material.dart';
import 'package:growfit/core/constants/theme.dart';
import 'package:growfit/features/workout/domain/entities/workout_session.dart';
import 'package:growfit/features/workout/domain/entities/set_log.dart';

class WorkoutSessionDetailPage extends StatelessWidget {
  final WorkoutSession session;

  const WorkoutSessionDetailPage({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    final entries = session.exerciseSets.entries.toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Detalhes do Treino'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.bg),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: entries.isEmpty
          ? Center(
              child: Text(
                'Nenhum exercício registrado.',
                style: AppTextStyles.subtitle,
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              itemCount: entries.length,
              itemBuilder: (context, index) {
                final entry = entries[index];
                final List<SetLog> sets = entry.value;
                final exerciseName =
                    sets.isNotEmpty ? sets.first.exerciseName : entry.key;

                return _ExerciseCard(
                  name: exerciseName,
                  sets: sets,
                );
              },
            ),
    );
  }
}

// ── EXERCISE CARD ─────────────────────────────────────────────────────────────
class _ExerciseCard extends StatelessWidget {
  final String name;
  final List<SetLog> sets;

  const _ExerciseCard({required this.name, required this.sets});

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
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          iconColor: AppColors.primary,
          collapsedIconColor: AppColors.muted,
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Text('🏋️', style: TextStyle(fontSize: 16)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  name,
                  style: AppTextStyles.title.copyWith(fontSize: 14),
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(left: 48, top: 2, bottom: 4),
            child: Text(
              '${sets.length} série(s)',
              style: AppTextStyles.subtitle.copyWith(fontSize: 11),
            ),
          ),
          children: sets.map((set) => _SetRow(set: set)).toList(),
        ),
      ),
    );
  }
}

// ── SET ROW ───────────────────────────────────────────────────────────────────
class _SetRow extends StatelessWidget {
  final SetLog set;
  const _SetRow({required this.set});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // número da série
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '${set.setNumber}',
              style: AppTextStyles.label.copyWith(fontSize: 11),
            ),
          ),
          const SizedBox(width: 12),
          // peso
          _StatChip(icon: '⚖️', value: '${set.weight} kg'),
          const SizedBox(width: 8),
          // reps
          _StatChip(icon: '🔁', value: '${set.reps} reps'),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String icon;
  final String value;
  const _StatChip({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 13)),
        const SizedBox(width: 4),
        Text(value, style: AppTextStyles.subtitle.copyWith(fontSize: 12)),
      ],
    );
  }
}