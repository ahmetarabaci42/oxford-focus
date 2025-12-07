import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxford_focus/providers/word_providers.dart';
import 'package:oxford_focus/data/services/seeding_service.dart';
import 'package:oxford_focus/ui/screens/flashcard_screen.dart';
import 'package:oxford_focus/ui/screens/notes_screen.dart';
// Using native LinearProgressIndicator for now to avoid extra dependency unless requested.

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(userProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Oxford Focus'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload),
            onPressed: () async {
              // Trigger Seeding
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veri yükleniyor...')));
              try {
                await SeedingService().seedWords('oxford_3000.json');
                 // Invalidate to trigger reload and potential auto-fill
                 ref.invalidate(wordRepositoryProvider);
                 ref.invalidate(userProgressProvider);
                 ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Yükleme Tamamlandı!')));
              } catch (e) {
                 ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: $e')));
              }
            },
            tooltip: 'Veritabanını Doldur',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: progressAsync.when(
            data: (progress) {
              final totalLearned = progress.learnedWordIds.length;
              // Assuming Oxford 3000 goal
              final double percent = (totalLearned / 3000).clamp(0.0, 1.0);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Merhaba!',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: Colors.grey,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Hafta ${progress.currentWeek}',
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                           Navigator.push(context, MaterialPageRoute(builder: (_) => const NotesScreen()));
                        },
                        icon: const Icon(Icons.bookmark, size: 32),
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),
                  
                  // Progress Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Genel İlerleme',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: percent,
                          minHeight: 12,
                          backgroundColor: Colors.grey[800],
                          valueColor: AlwaysStoppedAnimation(
                            Theme.of(context).colorScheme.secondary,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '$totalLearned / 3000 Kelime Öğrenildi',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Start Button
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const FlashcardScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                        elevation: 10,
                      ),
                      child: const Text(
                        'Çalışmaya Başla',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                   // Complete Week Button (Debug/Cycle)
                  Center(
                    child: TextButton(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (c) => AlertDialog(
                            title: const Text('Haftayı Tamamla?'),
                            content: const Text('Bu işlem yeni haftaya geçiş yapacak ve kelimeleri karıştıracaktır.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('İptal')),
                              TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Evet')),
                            ],
                          ),
                        );
                        
                        if (confirm == true) {
                          await ref.read(wordRepositoryProvider.future).then((r) => r.nextWeek());
                          ref.invalidate(userProgressProvider);
                        }
                      },
                      child: Text('Haftayı Tamamla (Manuel)', style: TextStyle(color: Colors.grey[600])),
                    ),
                  ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, s) => Center(child: Text('Hata: $e')),
          ),
        ),
      ),
    );
  }
}
