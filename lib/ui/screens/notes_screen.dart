import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oxford_focus/data/models/word.dart';
import 'package:oxford_focus/providers/word_providers.dart';

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progressAsync = ref.watch(userProgressProvider);
    // Needed to fetch word details for notes ids.
    // We can use a FutureProviderFamily or a dedicated provider.
    // Simplifying: Fetch list inside page using repo or a new provider.
    
    return Scaffold(
      appBar: AppBar(title: const Text('Notlarım')),
      body: progressAsync.when(
        data: (progress) {
          if (progress.savedNotesIds.isEmpty) {
            return const Center(child: Text('Henüz kaydedilmiş not yok.'));
          }

          return SavedWordsList(ids: progress.savedNotesIds);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, s) => Center(child: Text('Hata: $e')),
      ),
    );
  }
}

class SavedWordsList extends ConsumerStatefulWidget {
  final List<String> ids;
  const SavedWordsList({super.key, required this.ids});

  @override
  ConsumerState<SavedWordsList> createState() => _SavedWordsListState();
}

class _SavedWordsListState extends ConsumerState<SavedWordsList> {
  late Future<List<Word>> _wordsFuture;

  @override
  void initState() {
    super.initState();
    _loadWords();
  }
  
  void _loadWords() {
    // We access repo manually here. Ideally use provider.
     _wordsFuture = ref.read(wordRepositoryProvider.future).then((repo) {
       return repo.getWordsByIds(widget.ids);
     });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Word>>(
      future: _wordsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text('Hata: ${snapshot.error}'));
        }
        final words = snapshot.data ?? [];
        
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
                 subtitle: Text('${word.turkish} • ${word.definition}'),
                 leading: Icon(Icons.bookmark, color: Theme.of(context).colorScheme.secondary),
               ),
             );
          },
        );
      },
    );
  }
}
