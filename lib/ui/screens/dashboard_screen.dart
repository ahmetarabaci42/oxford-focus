import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxford_focus/providers/word_providers.dart';
import 'package:oxford_focus/providers/stats_provider.dart';
import 'package:oxford_focus/data/services/seeding_service.dart';
import 'package:shimmer/shimmer.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(userProgressProvider);
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      body: SafeArea(
        child: progressAsync.when(
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
                  onPressed: () {
                    ref.invalidate(userProgressProvider);
                    ref.invalidate(wordRepositoryProvider);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (progress) {
            final totalLearned = progress.learnedWordIds.length;
            final activeWords = progress.activeWordIds.length;
            final percent = (totalLearned / 3000).clamp(0.0, 1.0);
            final streak = statsAsync.maybeWhen(
              data: (s) => s.currentStreak,
              orElse: () => 0,
            );

            return CustomScrollView(
              slivers: [
                // ─── App bar ───────────────────────────────────────────────
                SliverAppBar(
                  pinned: true,
                  expandedHeight: 100,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    title: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Oxford Focus',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Week ${progress.currentWeek}',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    // Streak badge
                    if (streak > 0)
                      Container(
                        margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF4081).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: const Color(0xFFFF4081).withOpacity(0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            Text(
                              '$streak',
                              style: const TextStyle(
                                  color: Color(0xFFFF4081),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    // Seed button
                    IconButton(
                      icon: const Icon(Icons.cloud_upload_rounded),
                      onPressed: () async {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Loading words...'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        try {
                          await SeedingService().seedWords('oxford_3000.json');
                          ref.invalidate(wordRepositoryProvider);
                          ref.invalidate(userProgressProvider);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('✅ Words loaded successfully!'),
                                backgroundColor:
                                    const Color(0xFF69FF47).withOpacity(0.8),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error: $e'),
                                backgroundColor: Colors.red[800],
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            );
                          }
                        }
                      },
                      tooltip: 'Load word database',
                    ),
                  ],
                ),

                SliverPadding(
                  padding: const EdgeInsets.all(20),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // ─── Hero progress card ──────────────────────────────
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1E2A3A), Color(0xFF1A1E2E)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFF00E5FF).withOpacity(0.2),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  const Color(0xFF00E5FF).withOpacity(0.08),
                              blurRadius: 30,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Overall Progress',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '${(percent * 100).toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    color: Color(0xFF00E5FF),
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: percent,
                                minHeight: 10,
                                backgroundColor: Colors.grey[800],
                                valueColor: const AlwaysStoppedAnimation(
                                    Color(0xFF00E5FF)),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: [
                                _ProgressStat(
                                    label: 'Learned',
                                    value: '$totalLearned',
                                    color: const Color(0xFF69FF47)),
                                _ProgressStat(
                                    label: 'Active',
                                    value: '$activeWords',
                                    color: const Color(0xFF00E5FF)),
                                _ProgressStat(
                                    label: 'Goal',
                                    value: '3000',
                                    color: Colors.grey),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // ─── Quick stats row ─────────────────────────────────
                      statsAsync.when(
                        loading: () => const SizedBox(),
                        error: (_, __) => const SizedBox(),
                        data: (s) => Row(
                          children: [
                            Expanded(
                              child: _QuickStatTile(
                                icon: Icons.local_fire_department_rounded,
                                value: '${s.currentStreak}d',
                                label: 'Streak',
                                color: const Color(0xFFFF4081),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _QuickStatTile(
                                icon: Icons.trending_up_rounded,
                                value:
                                    '${s.learningRate.toStringAsFixed(0)}%',
                                label: 'Learn Rate',
                                color: const Color(0xFF69FF47),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _QuickStatTile(
                                icon: Icons.calendar_today_rounded,
                                value: '${s.wordsStudiedThisWeek}',
                                label: 'This Week',
                                color: const Color(0xFFFFD740),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // ─── Active words info ───────────────────────────────
                      if (activeWords == 0)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                                color: Colors.orange.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline,
                                  color: Colors.orange),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'No words loaded yet. Tap the upload icon above to seed the Oxford 3000 database.',
                                  style: TextStyle(
                                      color: Colors.orange, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF69FF47).withOpacity(0.06),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF69FF47).withOpacity(0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_outline,
                                  color: Color(0xFF69FF47), size: 20),
                              const SizedBox(width: 10),
                              Text(
                                '$activeWords words ready to study',
                                style: const TextStyle(
                                    color: Color(0xFF69FF47), fontSize: 13),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 32),

                      // ─── Next week (debug) ───────────────────────────────
                      Center(
                        child: TextButton(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (c) => AlertDialog(
                                backgroundColor: const Color(0xFF1E1E1E),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                                title: const Text('Advance to Next Week?'),
                                content: const Text(
                                  'This will rotate your active word set and advance the week counter.',
                                  style: TextStyle(color: Colors.grey),
                                ),
                                actions: [
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(c, false),
                                      child: const Text('Cancel')),
                                  ElevatedButton(
                                      onPressed: () =>
                                          Navigator.pop(c, true),
                                      child: const Text('Advance')),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await ref
                                  .read(wordRepositoryProvider.future)
                                  .then((r) => r.nextWeek());
                              ref.invalidate(userProgressProvider);
                            }
                          },
                          child: Text(
                            'Advance Week (Week ${progress.currentWeek} → ${progress.currentWeek + 1})',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 12),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
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
            const SizedBox(height: 100),
            Container(
              height: 140,
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24)),
            ),
            const SizedBox(height: 16),
            Row(
              children: List.generate(
                3,
                (i) => Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: i < 2 ? 12 : 0),
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Small widgets ────────────────────────────────────────────────────────────

class _ProgressStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _ProgressStat(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label,
            style: TextStyle(color: Colors.grey[500], fontSize: 11)),
      ],
    );
  }
}

class _QuickStatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _QuickStatTile({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  color: color, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(color: Colors.grey[600], fontSize: 10),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
