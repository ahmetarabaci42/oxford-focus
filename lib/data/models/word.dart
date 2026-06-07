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
    @Default('') @JsonKey(name: 'ex1') String example1,
    @Default('') @JsonKey(name: 'ex1_tr') String example1Tr,
    @Default('') @JsonKey(name: 'ex2') String example2,
    @Default('') @JsonKey(name: 'ex2_tr') String example2Tr,
    @Default('') @JsonKey(name: 'ipa') String ipa,
    @Default('') @JsonKey(name: 'pos') String partOfSpeech,
  }) = _Word;

  factory Word.fromJson(Map<String, dynamic> json) => _$WordFromJson(json);
}
