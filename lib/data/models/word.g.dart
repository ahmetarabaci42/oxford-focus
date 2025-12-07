// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WordImpl _$$WordImplFromJson(Map<String, dynamic> json) => _$WordImpl(
      id: json['id'] as String,
      english: json['english'] as String,
      turkish: json['turkish'] as String,
      definition: json['definition'] as String,
      difficulty: json['difficulty'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );

Map<String, dynamic> _$$WordImplToJson(_$WordImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'english': instance.english,
      'turkish': instance.turkish,
      'definition': instance.definition,
      'difficulty': instance.difficulty,
      'is_active': instance.isActive,
    };
