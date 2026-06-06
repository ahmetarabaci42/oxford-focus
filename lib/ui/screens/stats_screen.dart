import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxford_focus/providers/stats_provider.dart';
import 'package:oxford_focus/providers/word_providers.dart';
import 'package:shimmer/shimmer.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);
    final progressAsync = ref.watch(userProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
        automaticallyImplyLeading: false,
      ),
      body: statsAsync.when(
        loading: () => _buildShimmer(),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $e', textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(statsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (stats) {
          final totalLearned = progressAsync.maybeWhen(
            data: (p) => p.learnedWordIds.length,
            orElse: () => 0,
          );

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(statsProvider);
              ref.invalidate(userProgressProvider);
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Top stat cards ──────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: _StatCard(
                          icon: Icons.calendar_today_rounded,
                          value: '${stats.wordsStudiedThisWeek}',
                          label: 'This Week',
                          color: const Color(0xFF00E5FF),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.trending_up_rounded,
                          value:
                              '${stats.learningRate.toStringAsFixed(0)}%',
                          label: 'Learn Rate',
                          color: const Color(0xFF69FF47),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _StatCard(
                          icon: Icons.local_fire_department_rounded,
                          value: '${stats.currentStreak}',
                          label: 'Day Streak',
                          color: const Color(0xFFFF4081),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ─── Overall progress ────────────────────────────────────
                  _SectionCard(
                    title: 'Overall Progress',
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$totalLearned words learned',
                              style: TextStyle(
                                  color: Colors.grey[400], fontSize: 13),
                            ),
                            Text(
                              '${(totalLearned / 3000 * 100).toStringAsFixed(1)}%',
                              style: const TextStyle(
                                  color: Color(0xFF00E5FF),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: (totalLearned / 3000).clamp(0.0, 1.0),
                            minHeight: 10,
                            backgroundColor: Colors.grey[800],
                            valueColor: const AlwaysStoppedAnimation(
                                Color(0xFF00E5FF)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$totalLearned / 3000 Oxford Words',
                          style: TextStyle(
                              color: Colors.grey[600], fontSize: 12),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ─── Streak banner ───────────────────────────────────────
                  if (stats.currentStreak >= 1)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFF4081).withOpacity(0.15),
                            const Color(0xFFFF6E40).withOpacity(0.08),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFFF4081).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 40)),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${stats.currentStreak} Day Streak!',
                                style: const TextStyle(
                                  color: Color(0xFFFF4081),
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Keep studying daily to maintain it!',
                                style: TextStyle(
                                    color: Colors.grey[500], fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  else
                    _SectionCard(
                      title: 'Streak',
                      child: Column(
                        children: [
                          const Text('😴',
                              style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 8),
                          Text(
                            'No streak yet',
                            style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 16,
                                fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Study at least one word today to start!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 13),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 16),

                  // ─── 30-day heatmap ──────────────────────────────────────
                  _SectionCard(
                    title: 'Last 30 Days Activity',
                    child: stats.activityLast30Days.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Column(
                                children: [
                                  Icon(Icons.grid_on_rounded,
                                      size: 48, color: Colors.grey[700]),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No activity yet',
                                    style: TextStyle(
                                        color: Colors.grey[500],
                                        fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : _ActivityHeatmap(
                            activityData: stats.activityLast30Days),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF2A2A2A),
      highlightColor: const Color(0xFF3A3A3A),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: List.generate(
                3,
                (i) => Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: i < 2 ? 12 : 0),
                    height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ...List.generate(
              3,
              (_) => Container(
                margin: const EdgeInsets.only(bottom: 16),
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stat Card ────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: Colors.grey[500], fontSize: 11),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Section Card ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ─── Activity Heatmap ─────────────────────────────────────────────────────────

class _ActivityHeatmap extends StatelessWidget {
  final Map<String, int> activityData;

  const _ActivityHeatmap({required this.activityData});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(30, (i) {
      final date = now.subtract(Duration(days: 29 - i));
      final key = date.toIso8601String().substring(0, 10);
      return MapEntry(key, activityData[key] ?? 0);
    });

    // Find max for normalization
    final maxVal = days.map((e) => e.value).fold(0, (a, b) => a > b ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Grid
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: days.map((entry) {
            final intensity = maxVal > 0 ? entry.value / maxVal : 0.0;
            final color = _heatColor(intensity);
            return Tooltip(
              message:
                  '${entry.key}: ${entry.value} words',
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        // Legend
        Row(
          children: [
            Text('Less', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
            const SizedBox(width: 6),
            ...List.generate(
              5,
              (i) => Container(
                margin: const EdgeInsets.only(right: 4),
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: _heatColor(i / 4),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            Text('More', style: TextStyle(color: Colors.grey[600], fontSize: 11)),
          ],
        ),
      ],
    );
  }

  Color _heatColor(double intensity) {
    if (intensity == 0) return const Color(0xFF2A2A2A);
    // Interpolate from dark cyan to bright cyan
    return Color.lerp(
      const Color(0xFF003A45),
      const Color(0xFF00E5FF),
      intensity,
    )!;
  }
}
