import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxford_focus/data/models/word.dart';
import 'package:oxford_focus/providers/word_providers.dart';

class FlashcardScreen extends ConsumerWidget {
  const FlashcardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wordsAsync = ref.watch(currentWeekWordsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flashcards'),
      ),
      body: wordsAsync.when(
        data: (words) {
          if (words.isEmpty) {
             return const Center(child: Text('Kelime listesi boş.'));
          }
          
          return SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: CardSwiper(
                    cardsCount: words.length,
                    cardBuilder: (context, index, percentThresholdX, percentThresholdY) {
                      return FlashcardView(word: words[index]);
                    },
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Kaydırmak için sürükleyin', style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 20),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Hata: $e')),
      ),
    );
  }
}

class FlashcardView extends ConsumerStatefulWidget {
  final Word word;
  const FlashcardView({super.key, required this.word});

  @override
  ConsumerState<FlashcardView> createState() => _FlashcardViewState();
}

class _FlashcardViewState extends ConsumerState<FlashcardView> {
  bool isFlipped = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isFlipped = !isFlipped;
        });
      },
      child: Card(
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        color: Theme.of(context).colorScheme.surface,
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.all(32),
          child: isFlipped ? _buildBack() : _buildFront(),
        ),
      ),
    );
  }

  Widget _buildFront() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.word.english,
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        const Text(
          '(Tap to flip)',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildBack() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          widget.word.turkish,
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Text(
          widget.word.definition,
          style: const TextStyle(
            fontSize: 18,
            fontStyle: FontStyle.italic,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 48),
        IconButton(
          onPressed: () async {
            // Save to notes
            final repo = await ref.read(wordRepositoryProvider.future);
            await repo.saveNote(widget.word.id);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Notlara eklendi!'), duration: Duration(seconds: 1)),
              );
            }
          },
          icon: Icon(Icons.bookmark_add, size: 32, color: Theme.of(context).colorScheme.secondary),
        ),
         const Text(
          'Notlara Ekle',
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}
