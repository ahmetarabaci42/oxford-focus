import 'package:freezed_annotation/freezed_annotation.dart';

part 'word.freezed.dart';
part 'word.g.dart';

@freezed
class Word with _$Word {
  const factory Word({
    required String id,
    required String english,
    required String turkish,
    required String definition,
    required String difficulty,
    @Default(true) @JsonKey(name: 'is_active') bool isActive,
  }) = _Word;

  factory Word.fromJson(Map<String, dynamic> json) => _$WordFromJson(json);
}
