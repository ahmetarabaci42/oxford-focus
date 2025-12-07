import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxford_focus/providers/word_providers.dart';

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the new provider directly
    final savedWordsAsync = ref.watch(savedWordsProvider);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Notlarım')),
      body: savedWordsAsync.when(
        data: (words) {
          if (words.isEmpty) {
            return const Center(child: Text('Henüz kaydedilmiş not yok.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: words.length,
            itemBuilder: (context, index) {
              final word = words[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                color: Theme.of(context).colorScheme.surface,
                child: ListTile(
                  title: Text(word.english, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text('${word.turkish} • ${word.definition ?? ""}'), // Handle null def if JSON didn't have it
                  leading: Icon(Icons.bookmark, color: Theme.of(context).colorScheme.secondary),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Hata: $e')),
      ),
    );
  }
}
