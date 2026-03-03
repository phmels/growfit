import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:growfit/core/constants/theme.dart';
import 'package:growfit/features/cycle/presentation/bloc/cycle_bloc.dart';
import 'package:growfit/features/cycle/presentation/bloc/cycle_event.dart';
import 'package:growfit/features/cycle/presentation/bloc/cycle_state.dart';
import 'package:growfit/features/plan/presentation/pages/plan_page.dart';
import 'package:growfit/features/workout/domain/entities/workout_session.dart';
import 'package:growfit/features/workout/presentation/pages/workout_calendar_page.dart';
import 'package:growfit/features/workout/presentation/pages/workout_page.dart';
import 'package:hive/hive.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> _onRefresh() async {
    context.read<CycleBloc>().add(LoadCycle());

    // Aguarda CycleReady ou CycleError, com timeout de 5s
    await context
        .read<CycleBloc>()
        .stream
        .firstWhere((s) => s is CycleReady || s is CycleError)
        .timeout(const Duration(seconds: 5), onTimeout: () => CycleInitial());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          displacement: 40,
          child: SingleChildScrollView(
            // Obrigatório para o RefreshIndicator funcionar mesmo
            // quando o conteúdo não precisa de scroll
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _Header(),
                const SizedBox(height: 4),
                const _HeroStats(),
                const SizedBox(height: 16),
                const _StartWorkoutButton(),
                const SizedBox(height: 24),
                const _SectionLabel('Acesso rápido'),
                const SizedBox(height: 12),
                const _QuickGrid(),
                const SizedBox(height: 12),
                const _ResetCard(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── HEADER ───────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'GROWFIT',
            style: AppTextStyles.title.copyWith(
              fontSize: 28,
              letterSpacing: 2,
              color: AppColors.primary,
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.accent2, AppColors.primary],
              ),
            ),
            alignment: Alignment.center,
            child: Text('GF', style: AppTextStyles.button.copyWith(fontSize: 15)),
          ),
        ],
      ),
    );
  }
}

// ── HERO STATS ───────────────────────────────────────────────────────────────
class _HeroStats extends StatelessWidget {
  const _HeroStats();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const _PulseDot(),
                const SizedBox(width: 6),
                Text('ESTA SEMANA', style: AppTextStyles.label),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '3 de 4\ntreinos',
              style: AppTextStyles.title.copyWith(fontSize: 40, height: 1.05),
            ),
            const SizedBox(height: 4),
            Text('Mais 1 treino para bater sua meta!', style: AppTextStyles.subtitle),
            const SizedBox(height: 20),
            Row(
              children: [
                const _ProgressRing(percent: 0.75),
                const SizedBox(width: 20),
                Expanded(
                  child: GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.6,
                    physics: const NeverScrollableScrollPhysics(),
                    children: const [
                      _MiniStat(value: '42', unit: 'min', label: 'Média'),
                      _MiniStat(value: '12', unit: 'k',   label: 'Séries'),
                      _MiniStat(value: '8',  unit: 'd',   label: 'Sequência'),
                      _MiniStat(value: '↑',  unit: '14%', label: 'vs semana'),
                    ],
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

// ── PULSE DOT ────────────────────────────────────────────────────────────────
class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _anim,
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ── PROGRESS RING ────────────────────────────────────────────────────────────
class _ProgressRing extends StatelessWidget {
  final double percent;
  const _ProgressRing({required this.percent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: percent,
            strokeWidth: 5,
            backgroundColor: Colors.white.withOpacity(0.06),
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            strokeCap: StrokeCap.round,
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${(percent * 100).toInt()}',
                  style: AppTextStyles.title.copyWith(fontSize: 20, height: 1),
                ),
                Text(
                  '%',
                  style: AppTextStyles.subtitle.copyWith(fontSize: 8),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── MINI STAT ────────────────────────────────────────────────────────────────
class _MiniStat extends StatelessWidget {
  final String value;
  final String unit;
  final String label;
  const _MiniStat({required this.value, required this.unit, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: AppTextStyles.title.copyWith(fontSize: 20, height: 1),
                ),
                TextSpan(
                  text: unit,
                  style: AppTextStyles.subtitle.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.subtitle.copyWith(fontSize: 10, letterSpacing: 0.4),
          ),
        ],
      ),
    );
  }
}

// ── BOTÃO INICIAR TREINO ─────────────────────────────────────────────────────
class _StartWorkoutButton extends StatelessWidget {
  const _StartWorkoutButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CycleBloc, CycleState>(
      builder: (context, state) {
        // Estado de loading ou inicial — mostra dica de puxar para atualizar
        if (state is CycleLoading || state is CycleInitial) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.border),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Carregando... puxe para atualizar',
                    style: AppTextStyles.subtitle.copyWith(fontSize: 13),
                  ),
                ],
              ),
            ),
          );
        }

        // Estado de erro — orienta o usuário a criar um plano
        if (state is CycleError) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.danger.withOpacity(0.08),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.danger.withOpacity(0.2)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                children: [
                  const Text('⚠️', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nenhum plano encontrado',
                          style: AppTextStyles.title.copyWith(fontSize: 14),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Crie um plano ou puxe para tentar novamente',
                          style: AppTextStyles.subtitle.copyWith(fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Estado pronto — mostra botão de iniciar treino
        final ready = state as CycleReady;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WorkoutPage(day: ready.nextTrainingDay),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 30,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PRÓXIMO TREINO',
                        style: AppTextStyles.label.copyWith(color: AppColors.bg),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ready.nextTrainingDay.name,
                        style: AppTextStyles.title.copyWith(
                          fontSize: 26,
                          color: AppColors.bg,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black.withOpacity(0.15),
                    ),
                    alignment: Alignment.center,
                    child: const Text('💪', style: TextStyle(fontSize: 22)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── SECTION LABEL ────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(text.toUpperCase(), style: AppTextStyles.sectionLabel),
    );
  }
}

// ── QUICK GRID ───────────────────────────────────────────────────────────────
class _QuickGrid extends StatelessWidget {
  const _QuickGrid();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _GridCard(
              emoji: '📅',
              title: 'Calendário',
              subtitle: 'Veja treinos realizados',
              showDot: true,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WorkoutCalendarPage()),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _GridCard(
              emoji: '✏️',
              title: 'Editar Plano',
              subtitle: 'Personalize seus treinos',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PlanPage()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final bool showDot;
  final VoidCallback onTap;

  const _GridCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.showDot = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.card,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        splashColor: Colors.white.withOpacity(0.05),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 26)),
                  if (showDot)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 14),
              Text(title, style: AppTextStyles.title.copyWith(fontSize: 14)),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: AppTextStyles.subtitle.copyWith(fontSize: 11, height: 1.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── RESET CARD ───────────────────────────────────────────────────────────────
class _ResetCard extends StatelessWidget {
  const _ResetCard();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: AppColors.danger.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Resetar Dados'),
                content: const Text(
                  'Todos os treinos salvos serão apagados. Tem certeza?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('Cancelar', style: AppTextStyles.subtitle),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(
                      'Apagar',
                      style: AppTextStyles.subtitle.copyWith(color: AppColors.danger),
                    ),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              await Hive.box<WorkoutSession>('workoutSessions').clear();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Dados resetados com sucesso!')),
                );
              }
            }
          },
          borderRadius: BorderRadius.circular(18),
          splashColor: AppColors.danger.withOpacity(0.08),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.danger.withOpacity(0.2)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.danger.withOpacity(0.12),
                  ),
                  alignment: Alignment.center,
                  child: const Text('🗑️', style: TextStyle(fontSize: 22)),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Resetar Dados',
                      style: AppTextStyles.title.copyWith(
                        fontSize: 14,
                        color: AppColors.danger.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Apaga todos os treinos salvos',
                      style: AppTextStyles.subtitle.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}