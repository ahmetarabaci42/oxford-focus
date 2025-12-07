// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_progress.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProgressImpl _$$UserProgressImplFromJson(Map<String, dynamic> json) =>
    _$UserProgressImpl(
      currentWeek: (json['current_week'] as num?)?.toInt() ?? 1,
      activeWordIds: (json['active_word_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      learnedWordIds: (json['learned_word_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      savedNotesIds: (json['saved_notes_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$UserProgressImplToJson(_$UserProgressImpl instance) =>
    <String, dynamic>{
      'current_week': instance.currentWeek,
      'active_word_ids': instance.activeWordIds,
      'learned_word_ids': instance.learnedWordIds,
      'saved_notes_ids': instance.savedNotesIds,
    };
