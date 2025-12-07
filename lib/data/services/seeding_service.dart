import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:oxford_focus/data/local/database_helper.dart';
import 'package:oxford_focus/data/models/word.dart';
import 'package:uuid/uuid.dart';

class SeedingService {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Future<void> seedWords(String assetPath) async {
    // Check local DB count first to avoid duplicate heavy work if not verified
    // User can force seed if they want, logic handles conflicts with replace? Uuid generates new ID always.
    // Ideally we should wipe or check duplicates.
    // For now assuming "seed" means "add more" or "fill initial".
    
    try {
      final content = await rootBundle.loadString(assetPath);
      final Map<String, dynamic> json = jsonDecode(content);
      final List<dynamic> data = json['words'] as List<dynamic>;

      print('Starting seed for ${data.length} words...');
      
      List<Word> batch = [];
      int count = 0;
      
      for (var item in data) {
        // Use existing ID if provided, else generate (but json usually doesn't have UUIDs)
        // If we generate new UUIDs every time, re-seeding duplicates data!
        // Constraint: We want unique English words?
        // SQLite doesn't check unique English.
        // Let's assume for now user seeds once or we just add.
        
        final String id = const Uuid().v4();
        final word = Word(
          id: id,
          english: item['ENG'] ?? '',
          turkish: item['TR'] ?? '',
          definition: '', // JSON doesn't seem to have definitions
          difficulty: 'medium',
          isActive: true,
        );
        
        if (word.english.isEmpty) continue;
        
        batch.add(word);
        count++;
        
        if (batch.length >= 500) {
          await _databaseHelper.insertWordsBatch(batch);
          print('Committed $count words...');
          batch.clear();
        }
      }
      
      if (batch.isNotEmpty) {
        await _databaseHelper.insertWordsBatch(batch);
        print('Committed remaining ${batch.length} words.');
      }
      
      print('Seeding complete. Total: $count');
    } catch (e) {
      print('Seeding error: $e');
      rethrow;
    }
  }
}
