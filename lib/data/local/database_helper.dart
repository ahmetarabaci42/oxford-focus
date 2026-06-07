import 'dart:async';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:oxford_focus/data/models/word.dart';
import 'package:oxford_focus/data/models/user_progress.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'oxford_focus.db');

    return await openDatabase(
      path,
      version: 4,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createWordsTable(db);
    await _createUserProgressTable(db);
    await _createStudySessionsTable(db);
    await _createDailyStreaksTable(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createStudySessionsTable(db);
      await _createDailyStreaksTable(db);
    }
    if (oldVersion < 3) {
      await db.execute('DROP TABLE IF EXISTS words');
      await _createWordsTable(db);
    }
    if (oldVersion < 4) {
      await db.execute('DROP TABLE IF EXISTS words');
      await _createWordsTable(db);
    }
  }

  Future<void> _createWordsTable(Database db) async {
    await db.execute('''
      CREATE TABLE words(
        id TEXT PRIMARY KEY,
        english TEXT,
        turkish TEXT,
        definition TEXT,
        difficulty TEXT,
        is_active INTEGER,
        example1 TEXT,
        example1Tr TEXT,
        example2 TEXT,
        example2Tr TEXT,
        ipa TEXT,
        partOfSpeech TEXT
      )
    ''');
  }

  Future<void> _createUserProgressTable(Database db) async {
    await db.execute('''
      CREATE TABLE user_progress(
        userId TEXT PRIMARY KEY,
        currentWeek INTEGER,
        activeWordIds TEXT,
        learnedWordIds TEXT,
        savedNotesIds TEXT
      )
    ''');
  }

  Future<void> _createStudySessionsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS study_sessions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        wordId TEXT NOT NULL,
        result TEXT NOT NULL,
        studiedAt TEXT NOT NULL
      )
    ''');
  }

  Future<void> _createDailyStreaksTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS daily_streaks(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId TEXT NOT NULL,
        date TEXT NOT NULL,
        wordsStudied INTEGER DEFAULT 0,
        UNIQUE(userId, date)
      )
    ''');
  }

  // ─── UserProgress ────────────────────────────────────────────────────────────

  Future<void> saveUserProgress(UserProgress progress, String userId) async {
    final db = await database;
    await db.insert(
      'user_progress',
      {
        'userId': userId,
        'currentWeek': progress.currentWeek,
        'activeWordIds': jsonEncode(progress.activeWordIds),
        'learnedWordIds': jsonEncode(progress.learnedWordIds),
        'savedNotesIds': jsonEncode(progress.savedNotesIds),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<UserProgress?> getUserProgress(String userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'user_progress',
      where: 'userId = ?',
      whereArgs: [userId],
    );

    if (maps.isEmpty) return null;

    final data = maps.first;
    return UserProgress(
      currentWeek: data['currentWeek'] as int,
      activeWordIds: List<String>.from(jsonDecode(data['activeWordIds'])),
      learnedWordIds: List<String>.from(jsonDecode(data['learnedWordIds'])),
      savedNotesIds: List<String>.from(jsonDecode(data['savedNotesIds'])),
    );
  }

  // ─── Words ───────────────────────────────────────────────────────────────────

  Future<void> insertWord(Word word) async {
    final db = await database;
    await db.insert(
      'words',
      {
        'id': word.id,
        'english': word.english,
        'turkish': word.turkish,
        'definition': word.definition,
        'difficulty': word.difficulty,
        'is_active': word.isActive ? 1 : 0,
        'example1': word.example1,
        'example1Tr': word.example1Tr,
        'example2': word.example2,
        'example2Tr': word.example2Tr,
        'ipa': word.ipa,
        'partOfSpeech': word.partOfSpeech,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertWordsBatch(List<Word> words) async {
    final db = await database;
    final batch = db.batch();
    for (var word in words) {
      batch.insert(
        'words',
        {
          'id': word.id,
          'english': word.english,
          'turkish': word.turkish,
          'definition': word.definition,
          'difficulty': word.difficulty,
          'is_active': word.isActive ? 1 : 0,
          'example1': word.example1,
          'example1Tr': word.example1Tr,
          'example2': word.example2,
          'example2Tr': word.example2Tr,
          'ipa': word.ipa,
          'partOfSpeech': word.partOfSpeech,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Word>> getWordsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final db = await database;
    final placeholders = List.filled(ids.length, '?').join(',');
    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      where: 'id IN ($placeholders)',
      whereArgs: ids,
    );
    return maps.map(_wordFromMap).toList();
  }

  Future<List<Word>> getActiveWords({int? limit}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      where: 'is_active = ?',
      whereArgs: [1],
      limit: limit,
    );
    return maps.map(_wordFromMap).toList();
  }

  Future<List<Word>> getAllWords() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('words');
    return maps.map(_wordFromMap).toList();
  }

  Future<int> getWordCount() async {
    final db = await database;
    return Sqflite.firstIntValue(
            await db.rawQuery('SELECT COUNT(*) FROM words')) ??
        0;
  }

  Word _wordFromMap(Map<String, dynamic> e) => Word(
        id: e['id'] as String,
        english: e['english'] as String,
        turkish: e['turkish'] as String,
        definition: (e['definition'] as String?) ?? '',
        difficulty: (e['difficulty'] as String?) ?? '1',
        isActive: (e['is_active'] as int) == 1,
        example1: (e['example1'] as String?) ?? '',
        example1Tr: (e['example1Tr'] as String?) ?? '',
        example2: (e['example2'] as String?) ?? '',
        example2Tr: (e['example2Tr'] as String?) ?? '',
        ipa: (e['ipa'] as String?) ?? '',
        partOfSpeech: (e['partOfSpeech'] as String?) ?? '',
      );

  // ─── Study Sessions (Statistics) ─────────────────────────────────────────────

  /// Record a single card result: 'know', 'hard', 'dont_know'
  Future<void> recordStudySession({
    required String userId,
    required String wordId,
    required String result,
  }) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    await db.insert('study_sessions', {
      'userId': userId,
      'wordId': wordId,
      'result': result,
      'studiedAt': now,
    });
    // Also upsert into daily_streaks
    await _upsertDailyStreak(db, userId);
  }

  Future<void> _upsertDailyStreak(Database db, String userId) async {
    final today = _todayStr();
    await db.rawInsert('''
      INSERT INTO daily_streaks(userId, date, wordsStudied)
      VALUES(?, ?, 1)
      ON CONFLICT(userId, date) DO UPDATE SET wordsStudied = wordsStudied + 1
    ''', [userId, today]);
  }

  /// Sessions in the last N days
  Future<List<Map<String, dynamic>>> getSessionsLastDays(
      String userId, int days) async {
    final db = await database;
    final cutoff =
        DateTime.now().subtract(Duration(days: days)).toIso8601String();
    return db.query(
      'study_sessions',
      where: 'userId = ? AND studiedAt >= ?',
      whereArgs: [userId, cutoff],
    );
  }

  /// Words studied today
  Future<int> getWordsStudiedToday(String userId) async {
    final db = await database;
    final today = _todayStr();
    final result = await db.query(
      'daily_streaks',
      where: 'userId = ? AND date = ?',
      whereArgs: [userId, today],
    );
    if (result.isEmpty) return 0;
    return (result.first['wordsStudied'] as int?) ?? 0;
  }

  /// Daily streak count (consecutive days with at least 1 word studied)
  Future<int> getCurrentStreak(String userId) async {
    final db = await database;
    final rows = await db.query(
      'daily_streaks',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
    if (rows.isEmpty) return 0;
    int streak = 0;
    DateTime cursor = DateTime.now();
    for (final row in rows) {
      final dateStr = row['date'] as String;
      final date = DateTime.parse(dateStr);
      final diff = cursor.difference(date).inDays;
      if (diff <= 1) {
        streak++;
        cursor = date;
      } else {
        break;
      }
    }
    return streak;
  }

  /// Returns a map of date-string → wordsStudied for the last 30 days
  Future<Map<String, int>> getActivityLast30Days(String userId) async {
    final db = await database;
    final cutoff =
        DateTime.now().subtract(const Duration(days: 30)).toIso8601String().substring(0, 10);
    final rows = await db.query(
      'daily_streaks',
      where: 'userId = ? AND date >= ?',
      whereArgs: [userId, cutoff],
    );
    final Map<String, int> result = {};
    for (final row in rows) {
      result[row['date'] as String] = (row['wordsStudied'] as int?) ?? 0;
    }
    return result;
  }

  /// Words studied this week (Mon–Sun)
  Future<int> getWordsStudiedThisWeek(String userId) async {
    final db = await database;
    final now = DateTime.now();
    final weekStart =
        now.subtract(Duration(days: now.weekday - 1)).toIso8601String().substring(0, 10);
    final rows = await db.query(
      'daily_streaks',
      where: 'userId = ? AND date >= ?',
      whereArgs: [userId, weekStart],
    );
    int total = 0;
    for (final row in rows) {
      total += (row['wordsStudied'] as int?) ?? 0;
    }
    return total;
  }

  /// Learning rate = (know sessions) / (total sessions) in last 30 days, as 0–100
  Future<double> getLearningRate(String userId) async {
    final sessions = await getSessionsLastDays(userId, 30);
    if (sessions.isEmpty) return 0;
    final known = sessions.where((s) => s['result'] == 'know').length;
    return (known / sessions.length * 100);
  }

  Future<void> resetUserProgress(String userId) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete(
        'user_progress',
        where: 'userId = ?',
        whereArgs: [userId],
      );
      await txn.delete(
        'study_sessions',
        where: 'userId = ?',
        whereArgs: [userId],
      );
      await txn.delete(
        'daily_streaks',
        where: 'userId = ?',
        whereArgs: [userId],
      );
    });
  }

  Future<bool> isWordsTableEmpty() async {
    final db = await database;
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM words'));
    return count == 0;
  }

  String _todayStr() => DateTime.now().toIso8601String().substring(0, 10);
}
