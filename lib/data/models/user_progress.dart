import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_progress.freezed.dart';
part 'user_progress.g.dart';

@freezed
class UserProgress with _$UserProgress {
  const factory UserProgress({
    @Default(1) @JsonKey(name: 'current_week') int currentWeek,
    @Default([]) @JsonKey(name: 'active_word_ids') List<String> activeWordIds,
    @Default([]) @JsonKey(name: 'learned_word_ids') List<String> learnedWordIds,
    @Default([]) @JsonKey(name: 'saved_notes_ids') List<String> savedNotesIds,
  }) = _UserProgress;

  factory UserProgress.fromJson(Map<String, dynamic> json) => _$UserProgressFromJson(json);
}
