import 'dart:math';
import 'package:flutter/material.dart';
import 'package:growfit/core/constants/theme.dart';
import 'package:growfit/features/workout/domain/entities/set_log.dart';
import 'package:growfit/features/workout/domain/entities/workout_session.dart';
import 'package:hive/hive.dart';

// ─────────────────────────────────────────────────────────────────────────────
// DATA HELPERS
// ─────────────────────────────────────────────────────────────────────────────

/// Um ponto de dado no gráfico: data + valor
class _DataPoint {
  final DateTime date;
  final double value;
  const _DataPoint(this.date, this.value);
}

/// Agrega todos os SetLogs do Hive e organiza por exercício
class _ProgressData {
  /// exerciseName → lista de sessões ordenadas por data
  final Map<String, List<_SessionSummary>> byExercise;

  const _ProgressData(this.byExercise);

  static _ProgressData load() {
    if (!Hive.isBoxOpen('workoutSessions')) return const _ProgressData({});
    final box = Hive.box<WorkoutSession>('workoutSessions');

    // exerciseName → Map<dateKey, List<SetLog>>
    final Map<String, Map<String, List<SetLog>>> grouped = {};

    for (final session in box.values) {
      final dateKey =
          '${session.date.year}-${session.date.month}-${session.date.day}';
      for (final sets in session.exerciseSets.values) {
        for (final set in sets) {
          grouped
              .putIfAbsent(set.exerciseName, () => {})
              .putIfAbsent(dateKey, () => [])
              .add(set);
        }
      }
    }

    final Map<String, List<_SessionSummary>> result = {};
    grouped.forEach((exerciseName, byDate) {
      final summaries = byDate.entries.map((e) {
        final date = _parseDate(e.key);
        final sets = e.value;
        final maxWeight = sets.map((s) => s.weight).reduce(max);
        final totalReps = sets.fold<int>(0, (sum, s) => sum + s.reps);
        final totalSets = sets.length;
        return _SessionSummary(
          date: date,
          maxWeight: maxWeight,
          totalReps: totalReps,
          totalSets: totalSets,
          sets: sets,
        );
      }).toList()
        ..sort((a, b) => a.date.compareTo(b.date));
      result[exerciseName] = summaries;
    });

    return _ProgressData(result);
  }

  static DateTime _parseDate(String key) {
    final parts = key.split('-').map(int.parse).toList();
    return DateTime(parts[0], parts[1], parts[2]);
  }

  List<String> get exerciseNames => byExercise.keys.toList()..sort();
}

class _SessionSummary {
  final DateTime date;
  final double maxWeight;
  final int totalReps;
  final int totalSets;
  final List<SetLog> sets;

  const _SessionSummary({
    required this.date,
    required this.maxWeight,
    required this.totalReps,
    required this.totalSets,
    required this.sets,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// PAGE
// ─────────────────────────────────────────────────────────────────────────────

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage>
    with SingleTickerProviderStateMixin {
  late final _ProgressData _data;
  late TabController _tabController;

  // Exercício selecionado no dropdown
  String? _selectedExercise;

  // Qual métrica mostrar no gráfico: 'weight' ou 'reps'
  String _metric = 'weight';

  @override
  void initState() {
    super.initState();
    _data = _ProgressData.load();
    _tabController = TabController(length: 2, vsync: this);
    if (_data.exerciseNames.isNotEmpty) {
      _selectedExercise = _data.exerciseNames.first;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<_SessionSummary> get _sessions {
    if (_selectedExercise == null) return [];
    return _data.byExercise[_selectedExercise] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'EVOLUÇÃO',
          style: AppTextStyles.title.copyWith(
            fontSize: 20,
            letterSpacing: 2,
            color: AppColors.primary,
          ),
        ),
      ),
      body: _data.exerciseNames.isEmpty
          ? _EmptyState()
          : Column(
              children: [
                _ExercisePicker(
                  exercises: _data.exerciseNames,
                  selected: _selectedExercise,
                  onChanged: (v) => setState(() => _selectedExercise = v),
                ),
                const SizedBox(height: 8),
                _StatsCards(sessions: _sessions),
                const SizedBox(height: 16),
                _MetricToggle(
                  selected: _metric,
                  onChanged: (v) => setState(() => _metric = v),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _sessions.length < 2
                      ? _NotEnoughData()
                      : _LineChart(
                          sessions: _sessions,
                          metric: _metric,
                        ),
                ),
                const SizedBox(height: 8),
                _SessionList(sessions: _sessions),
                const SizedBox(height: 16),
              ],
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EXERCISE PICKER
// ─────────────────────────────────────────────────────────────────────────────

class _ExercisePicker extends StatelessWidget {
  final List<String> exercises;
  final String? selected;
  final ValueChanged<String?> onChanged;

  const _ExercisePicker({
    required this.exercises,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selected,
            isExpanded: true,
            dropdownColor: AppColors.surface,
            style: AppTextStyles.title.copyWith(fontSize: 14),
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                color: AppColors.primary),
            onChanged: onChanged,
            items: exercises
                .map((e) => DropdownMenuItem(
                      value: e,
                      child: Text(e,
                          style: AppTextStyles.title.copyWith(fontSize: 14)),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STATS CARDS
// ─────────────────────────────────────────────────────────────────────────────

class _StatsCards extends StatelessWidget {
  final List<_SessionSummary> sessions;
  const _StatsCards({required this.sessions});

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) return const SizedBox.shrink();

    final last = sessions.last;
    final pr = sessions.map((s) => s.maxWeight).reduce(max);
    final prSession = sessions.lastWhere((s) => s.maxWeight == pr);

    // Variação de peso vs sessão anterior
    String weightDelta = '—';
    Color deltaColor = AppColors.muted;
    if (sessions.length >= 2) {
      final prev = sessions[sessions.length - 2];
      final diff = last.maxWeight - prev.maxWeight;
      if (diff > 0) {
        weightDelta = '+${diff.toStringAsFixed(1)} kg';
        deltaColor = const Color(0xFF4CAF50);
      } else if (diff < 0) {
        weightDelta = '${diff.toStringAsFixed(1)} kg';
        deltaColor = AppColors.danger;
      } else {
        weightDelta = '= mesmo peso';
        deltaColor = AppColors.muted;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _StatCard(
              label: 'ÚLTIMO TREINO',
              value: '${last.maxWeight.toStringAsFixed(1)} kg',
              sub: '${last.totalSets} séries · ${last.totalReps} reps',
              delta: weightDelta,
              deltaColor: deltaColor,
              icon: '🏋️',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _StatCard(
              label: 'RECORDE (PR)',
              value: '${pr.toStringAsFixed(1)} kg',
              sub: _formatDate(prSession.date),
              icon: '🏆',
              highlight: true,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final String? delta;
  final Color? deltaColor;
  final String icon;
  final bool highlight;

  const _StatCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.icon,
    this.delta,
    this.deltaColor,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.primary.withOpacity(0.1)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight
              ? AppColors.primary.withOpacity(0.3)
              : AppColors.border,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: AppTextStyles.label.copyWith(fontSize: 9)),
              Text(icon, style: const TextStyle(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.title.copyWith(
              fontSize: 22,
              color: highlight ? AppColors.primary : null,
            ),
          ),
          const SizedBox(height: 2),
          Text(sub,
              style: AppTextStyles.subtitle.copyWith(fontSize: 10)),
          if (delta != null) ...[
            const SizedBox(height: 4),
            Text(
              delta!,
              style: AppTextStyles.subtitle.copyWith(
                fontSize: 10,
                color: deltaColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// METRIC TOGGLE
// ─────────────────────────────────────────────────────────────────────────────

class _MetricToggle extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onChanged;

  const _MetricToggle({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _ToggleChip(
            label: '⚖️  Peso',
            active: selected == 'weight',
            onTap: () => onChanged('weight'),
          ),
          const SizedBox(width: 10),
          _ToggleChip(
            label: '🔁  Reps',
            active: selected == 'reps',
            onTap: () => onChanged('reps'),
          ),
        ],
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ToggleChip(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.title.copyWith(
            fontSize: 12,
            color: active ? AppColors.bg : AppColors.muted,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LINE CHART (custom painter)
// ─────────────────────────────────────────────────────────────────────────────

class _LineChart extends StatelessWidget {
  final List<_SessionSummary> sessions;
  final String metric;

  const _LineChart({required this.sessions, required this.metric});

  @override
  Widget build(BuildContext context) {
    final points = sessions.map((s) {
      final value = metric == 'weight'
          ? s.maxWeight
          : s.totalReps.toDouble();
      return _DataPoint(s.date, value);
    }).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        padding: const EdgeInsets.fromLTRB(12, 20, 20, 12),
        child: CustomPaint(
          painter: _ChartPainter(points: points, metric: metric),
          child: const SizedBox(height: 180),
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  final List<_DataPoint> points;
  final String metric;

  const _ChartPainter({required this.points, required this.metric});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    const leftPad = 44.0;
    const bottomPad = 28.0;
    final chartW = size.width - leftPad;
    final chartH = size.height - bottomPad;

    final values = points.map((p) => p.value).toList();
    final minVal = values.reduce(min);
    final maxVal = values.reduce(max);
    final range = (maxVal - minVal).clamp(1.0, double.infinity);

    // Normaliza um valor para coordenada Y
    double toY(double v) =>
        chartH - ((v - minVal) / range * chartH * 0.8 + chartH * 0.1);

    // Normaliza índice para coordenada X
    double toX(int i) =>
        leftPad + (i / (points.length - 1)) * chartW;

    // ── Grid lines ──
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..strokeWidth = 1;

    for (int i = 0; i <= 4; i++) {
      final y = chartH * (1 - i / 4);
      canvas.drawLine(
          Offset(leftPad, y), Offset(size.width, y), gridPaint);
    }

    // ── Y axis labels ──
    final labelStyle = TextStyle(
      color: Colors.white.withOpacity(0.35),
      fontSize: 9,
      fontWeight: FontWeight.w500,
    );
    for (int i = 0; i <= 4; i++) {
      final v = minVal + (range * i / 4);
      final y = chartH * (1 - i / 4);
      final label = metric == 'weight'
          ? '${v.toStringAsFixed(0)}kg'
          : '${v.toStringAsFixed(0)}';
      _drawText(canvas, label, Offset(0, y - 5), labelStyle, 40);
    }

    // ── Gradient fill ──
    final path = Path();
    path.moveTo(toX(0), toY(points[0].value));
    for (int i = 1; i < points.length; i++) {
      final cp1x = (toX(i - 1) + toX(i)) / 2;
      path.cubicTo(
        cp1x, toY(points[i - 1].value),
        cp1x, toY(points[i].value),
        toX(i), toY(points[i].value),
      );
    }
    path.lineTo(toX(points.length - 1), chartH);
    path.lineTo(toX(0), chartH);
    path.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.primary.withOpacity(0.25),
          AppColors.primary.withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(path, fillPaint);

    // ── Line ──
    final linePath = Path();
    linePath.moveTo(toX(0), toY(points[0].value));
    for (int i = 1; i < points.length; i++) {
      final cp1x = (toX(i - 1) + toX(i)) / 2;
      linePath.cubicTo(
        cp1x, toY(points[i - 1].value),
        cp1x, toY(points[i].value),
        toX(i), toY(points[i].value),
      );
    }
    final linePaint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, linePaint);

    // ── Dots + X labels ──
    final dotPaint = Paint()..color = AppColors.primary;
    final dotBg = Paint()..color = AppColors.surface;
    final dateStyle = TextStyle(
      color: Colors.white.withOpacity(0.35),
      fontSize: 8,
    );

    for (int i = 0; i < points.length; i++) {
      final x = toX(i);
      final y = toY(points[i].value);

      // Dot
      canvas.drawCircle(Offset(x, y), 5, dotBg);
      canvas.drawCircle(Offset(x, y), 3.5, dotPaint);

      // X label (data)
      final d = points[i].date;
      final label =
          '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}';
      _drawText(
          canvas, label, Offset(x - 12, chartH + 6), dateStyle, 28);
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset,
      TextStyle style, double maxWidth) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
    tp.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(_ChartPainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.metric != metric;
}

// ─────────────────────────────────────────────────────────────────────────────
// SESSION LIST
// ─────────────────────────────────────────────────────────────────────────────

class _SessionList extends StatelessWidget {
  final List<_SessionSummary> sessions;
  const _SessionList({required this.sessions});

  @override
  Widget build(BuildContext context) {
    if (sessions.isEmpty) return const SizedBox.shrink();

    // Mostra as últimas 5 sessões, mais recente primeiro
    final recent = sessions.reversed.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
          child: Text('HISTÓRICO RECENTE',
              style: AppTextStyles.label.copyWith(fontSize: 10)),
        ),
        ...recent.map((s) => _SessionRow(session: s)),
      ],
    );
  }
}

class _SessionRow extends StatelessWidget {
  final _SessionSummary session;
  const _SessionRow({required this.session});

  @override
  Widget build(BuildContext context) {
    final date = session.date;
    final dateStr =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                '${date.day}\n${_monthAbbr(date.month)}',
                textAlign: TextAlign.center,
                style: AppTextStyles.title.copyWith(
                    fontSize: 10, height: 1.2, color: AppColors.primary),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dateStr,
                      style: AppTextStyles.title.copyWith(fontSize: 13)),
                  const SizedBox(height: 2),
                  Text(
                    '${session.totalSets} séries · ${session.totalReps} reps',
                    style:
                        AppTextStyles.subtitle.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${session.maxWeight.toStringAsFixed(1)} kg',
                  style: AppTextStyles.title
                      .copyWith(fontSize: 15, color: AppColors.primary),
                ),
                Text('peso máx.',
                    style:
                        AppTextStyles.subtitle.copyWith(fontSize: 9)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _monthAbbr(int m) {
    const months = [
      'jan', 'fev', 'mar', 'abr', 'mai', 'jun',
      'jul', 'ago', 'set', 'out', 'nov', 'dez'
    ];
    return months[m - 1];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EMPTY / NOT ENOUGH DATA
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('📊', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text('Nenhum treino registrado ainda',
              style: AppTextStyles.title.copyWith(fontSize: 16)),
          const SizedBox(height: 6),
          Text('Complete seu primeiro treino para ver a evolução',
              style: AppTextStyles.subtitle.copyWith(fontSize: 13)),
        ],
      ),
    );
  }
}

class _NotEnoughData extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        height: 180,
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('📈', style: TextStyle(fontSize: 36)),
            const SizedBox(height: 10),
            Text('Treine mais vezes para ver o gráfico',
                style: AppTextStyles.subtitle.copyWith(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}