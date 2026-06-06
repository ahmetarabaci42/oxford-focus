import 'package:oxford_focus/data/local/database_helper.dart';
import 'package:oxford_focus/providers/auth_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'stats_provider.g.dart';

// ─── Stats data model (plain class, no codegen needed) ───────────────────────

class StatsData {
  final int wordsStudiedThisWeek;
  final double learningRate;
  final int currentStreak;
  final Map<String, int> activityLast30Days;

  const StatsData({
    required this.wordsStudiedThisWeek,
    required this.learningRate,
    required this.currentStreak,
    required this.activityLast30Days,
  });
}

// ─── Provider ────────────────────────────────────────────────────────────────

@riverpod
Future<StatsData> stats(StatsRef ref) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  final db = DatabaseHelper();

  final results = await Future.wait([
    db.getWordsStudiedThisWeek(userId),
    db.getLearningRate(userId),
    db.getCurrentStreak(userId),
    db.getActivityLast30Days(userId),
  ]);

  return StatsData(
    wordsStudiedThisWeek: results[0] as int,
    learningRate: results[1] as double,
    currentStreak: results[2] as int,
    activityLast30Days: results[3] as Map<String, int>,
  );
}
