import 'package:oxford_focus/data/local/database_helper.dart';
import 'package:oxford_focus/providers/auth_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'flashcard_provider.g.dart';

// Tracks the current card index within a session
@riverpod
class FlashcardIndex extends _$FlashcardIndex {
  @override
  int build() => 0;

  void next(int total) {
    if (state < total - 1) state++;
  }

  void previous() {
    if (state > 0) state--;
  }

  void reset() => state = 0;
}

// Records the result of studying a card
@riverpod
Future<void> recordCardResult(
  RecordCardResultRef ref, {
  required String wordId,
  required String result, // 'know', 'hard', 'dont_know'
}) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  await DatabaseHelper().recordStudySession(
    userId: userId,
    wordId: wordId,
    result: result,
  );
  // Invalidate stats so they refresh
  ref.invalidateSelf();
}
