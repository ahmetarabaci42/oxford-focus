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
      version: 1,
      onCreate: _onCreate,
    );
  }
  
  Future<void> _onCreate(Database db, int version) async {
    // Words table
    await db.execute('''
      CREATE TABLE words(
        id TEXT PRIMARY KEY,
        english TEXT,
        turkish TEXT,
        definition TEXT,
        difficulty TEXT,
        is_active INTEGER
      )
    ''');
    
    // UserProgress table
    // Storing lists as JSON strings for simplicity
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
  
  // Helper methods for UserProgress
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

  // Helper methods for Words
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
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Word>> getWordsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    final db = await database;
    
    // SQLite has a limit on variables in WHERE IN clause (usually 999). 
    // If ids is very large, this needs chunking.
    // Assuming reasonable size for now.
    
    final placeholders = List.filled(ids.length, '?').join(',');
    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      where: 'id IN ($placeholders)',
      whereArgs: ids,
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
  
  Future<List<Word>> getActiveWords({int? limit}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'words',
      where: 'is_active = ?',
      whereArgs: [1],
      limit: limit,
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
  
  Future<List<Word>> getAllWords() async {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query('words');
       return maps.map((e) => Word(
        id: e['id'] as String,
        english: e['english'] as String,
        turkish: e['turkish'] as String,
        definition: e['definition'] as String,
        difficulty: e['difficulty'] as String,
        isActive: (e['is_active'] as int) == 1,
      )).toList();
  }

  Future<int> getWordCount() async {
    final db = await database;
    return Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM words')) ?? 0;
  }
}
