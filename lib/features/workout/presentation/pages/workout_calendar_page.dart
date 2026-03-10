import 'package:flutter/material.dart';
import 'package:growfit/core/constants/theme.dart';
import 'package:growfit/features/plan/domain/entities/training_plan.dart';
import 'package:growfit/features/workout/presentation/pages/workout_session_detail_page.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:growfit/features/workout/domain/entities/workout_session.dart';
import 'package:growfit/features/plan/domain/entities/training_day.dart'; // ⭐ import

class WorkoutCalendarPage extends StatefulWidget {
  const WorkoutCalendarPage({super.key});

  @override
  State<WorkoutCalendarPage> createState() => _WorkoutCalendarPageState();
}

class _WorkoutCalendarPageState extends State<WorkoutCalendarPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<WorkoutSession>> _events = {};
  Map<String, String> _dayNames = {}; // ⭐ trainingDayId → nome do treino

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  DateTime _normalize(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  void _loadSessions() {
    final sessionBox = Hive.box<WorkoutSession>('workoutSessions');
    final planBox = Hive.box<TrainingPlan>('trainingPlans'); // ⭐ tipo correto

    // ⭐ Monta mapa trainingDayId → nome do treino
    final Map<String, String> dayNames = {};
    for (final plan in planBox.values) {
      for (final TrainingDay day in plan.days) {
        dayNames[day.id] = day.name;
      }
    }

    final Map<DateTime, List<WorkoutSession>> data = {};
    for (var session in sessionBox.values) {
      final day = _normalize(session.date);
      data[day] ??= [];
      data[day]!.add(session);
    }

    setState(() {
      _events = data;
      _dayNames = dayNames;
    });
  }

  List<WorkoutSession> _getEventsForDay(DateTime day) =>
      _events[_normalize(day)] ?? [];

  // ⭐ Retorna nome do treino ou fallback
  String _getTrainingName(WorkoutSession session) =>
      _dayNames[session.trainingDayId] ?? 'Treino';

  @override
  Widget build(BuildContext context) {
    final sessions = _getEventsForDay(_selectedDay ?? _focusedDay);

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
          'Calendário de Treinos',
          style: AppTextStyles.title.copyWith(
            fontSize: 20,
            letterSpacing: 2,
            color: AppColors.primary,
          ),
        ),
      ),

      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.border),
            ),
            child: TableCalendar<WorkoutSession>(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              eventLoader: _getEventsForDay,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: AppTextStyles.title.copyWith(fontSize: 15),
                leftChevronIcon: const Icon(
                  Icons.chevron_left,
                  color: AppColors.textLight,
                ),
                rightChevronIcon: const Icon(
                  Icons.chevron_right,
                  color: AppColors.textLight,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: AppTextStyles.subtitle.copyWith(fontSize: 12),
                weekendStyle: AppTextStyles.subtitle.copyWith(
                  fontSize: 12,
                  color: AppColors.muted,
                ),
              ),
              calendarStyle: CalendarStyle(
                defaultTextStyle: AppTextStyles.subtitle.copyWith(fontSize: 13),
                weekendTextStyle: AppTextStyles.subtitle.copyWith(
                  fontSize: 13,
                  color: AppColors.muted,
                ),
                outsideTextStyle: AppTextStyles.subtitle.copyWith(
                  fontSize: 13,
                  color: AppColors.muted.withOpacity(0.4),
                ),
                todayDecoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: AppTextStyles.title.copyWith(
                  fontSize: 13,
                  color: AppColors.primary,
                ),
                selectedDecoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: AppTextStyles.title.copyWith(
                  fontSize: 13,
                  color: AppColors.bg,
                ),
                markerDecoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                markersMaxCount: 1,
                markerSize: 5,
                markerMargin: const EdgeInsets.only(top: 1),
              ),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
            ),
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Text('SESSÕES', style: AppTextStyles.sectionLabel),
                const SizedBox(width: 8),
                if (sessions.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${sessions.length}',
                      style: AppTextStyles.label.copyWith(fontSize: 10),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          Expanded(
            child: sessions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('📅', style: TextStyle(fontSize: 40)),
                        const SizedBox(height: 12),
                        Text(
                          'Nenhum treino neste dia',
                          style: AppTextStyles.subtitle,
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: sessions.length,
                    itemBuilder: (context, index) {
                      final session = sessions[index];
                      final dateStr = DateFormat(
                        'dd/MM/yyyy · HH:mm',
                      ).format(session.date);
                      final totalExercises = session.exerciseSets.length;

                      return _SessionCard(
                        name: _getTrainingName(
                          session,
                        ), // ⭐ "Treino A", "Treino B"...
                        date: dateStr,
                        exerciseCount: totalExercises,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                WorkoutSessionDetailPage(session: session),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final String name;
  final String date;
  final int exerciseCount;
  final VoidCallback onTap;

  const _SessionCard({
    required this.name,
    required this.date,
    required this.exerciseCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.primary.withOpacity(0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: const Text('💪', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTextStyles.title.copyWith(fontSize: 14),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$date · $exerciseCount exercício(s)', // ⭐ era totalExercises, correto é exerciseCount
                        style: AppTextStyles.subtitle.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 14,
                  color: AppColors.muted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
