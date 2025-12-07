import 'package:oxford_focus/data/local/database_helper.dart';
import 'package:oxford_focus/data/models/user_progress.dart';
import 'package:oxford_focus/data/models/word.dart';
import 'package:oxford_focus/data/repositories/word_repository.dart';
import 'package:oxford_focus/providers/auth_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'word_providers.g.dart';

@riverpod
Future<WordRepository> wordRepository(WordRepositoryRef ref) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  return WordRepository(DatabaseHelper(), userId);
}

@riverpod
Future<UserProgress> userProgress(UserProgressRef ref) async {
  final repository = await ref.watch(wordRepositoryProvider.future);
  return repository.getUserProgress();
}

@riverpod
Future<List<Word>> currentWeekWords(CurrentWeekWordsRef ref) async {
  final repository = await ref.watch(wordRepositoryProvider.future);
  final progress = await ref.watch(userProgressProvider.future);
  
  if (progress.activeWordIds.isEmpty) return [];
  
  // Directly fetch from SQLite, it's fast enough.
  return repository.getWordsByIds(progress.activeWordIds);
}
