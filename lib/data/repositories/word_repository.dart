import 'package:oxford_focus/data/local/database_helper.dart';
import 'package:oxford_focus/data/models/user_progress.dart';
import 'package:oxford_focus/data/models/word.dart';

class WordRepository {
  final DatabaseHelper _databaseHelper;
  final String userId;

  WordRepository(this._databaseHelper, this.userId);

  Future<UserProgress> getUserProgress() async {
    var progress = await _databaseHelper.getUserProgress(userId);
    
    if (progress == null) {
      // Initialize new user
      progress = UserProgress(
        currentWeek: 1,
        activeWordIds: [],
        learnedWordIds: [],
        savedNotesIds: [],
      );
      await _databaseHelper.saveUserProgress(progress, userId);
    }
    
    // Recovery check: If active words are empty, try to fetch some
    if (progress.activeWordIds.isEmpty) {
       final initialWords = await _fetchRandomWords(100, []);
       if (initialWords.isNotEmpty) {
          progress = progress.copyWith(
            activeWordIds: initialWords.map((e) => e.id).toList(),
          );
          await _databaseHelper.saveUserProgress(progress, userId);
       }
    }

    return progress;
  }

  Future<List<Word>> getWordsByIds(List<String> ids) async {
    return _databaseHelper.getWordsByIds(ids);
  }

  Future<void> nextWeek() async {
    final progress = await getUserProgress();
    final currentActive = List<String>.from(progress.activeWordIds);
    
    // 1. Keep 50 random
    currentActive.shuffle();
    final kept = currentActive.take(50).toList();
    final learned = currentActive.skip(50).toList();

    // 2. Add to learned list
    final allLearned = {...progress.learnedWordIds, ...learned}.toList();

    // 3. Fetch 50 new words
    // Exclude currently kept + all learned
    final excludeIds = {...kept, ...allLearned}.toList();
    final newWords = await _fetchRandomWords(50, excludeIds);
    final newWordIds = newWords.map((e) => e.id).toList();

    // 4. Combine
    final nextActive = [...kept, ...newWordIds];
    nextActive.shuffle();

    // 5. Update
    final updatedProgress = progress.copyWith(
      currentWeek: progress.currentWeek + 1,
      activeWordIds: nextActive,
      learnedWordIds: allLearned,
    );

    await _databaseHelper.saveUserProgress(updatedProgress, userId);
  }

  Future<List<Word>> _fetchRandomWords(int count, List<String> excludeIds) async {
    final db = await _databaseHelper.database;
    
    String whereClause = 'is_active = 1';
    List<dynamic> whereArgs = [];
    
    if (excludeIds.isNotEmpty) {
      final placeholders = List.filled(excludeIds.length, '?').join(',');
      whereClause += ' AND id NOT IN ($placeholders)';
      whereArgs.addAll(excludeIds);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'RANDOM()',
      limit: count,
    );

    return maps.map((e) => Word(
      id: e['id'] as String,
      english: e['english'] as String,
      turkish: e['turkish'] as String,
      definition: e['definition'] as String,
      difficulty: e['difficulty'] as String,
      isActive: (e['is_active'] as int) == 1,
    )).toList();
  }

  Future<void> saveNote(String wordId) async {
     final progress = await getUserProgress();
     if (!progress.savedNotesIds.contains(wordId)) {
       final newNotes = [...progress.savedNotesIds, wordId];
       final updatedProgress = progress.copyWith(savedNotesIds: newNotes);
       await _databaseHelper.saveUserProgress(updatedProgress, userId);
     }
  }
}
