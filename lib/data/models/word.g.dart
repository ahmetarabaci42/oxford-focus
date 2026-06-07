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
      example1: json['ex1'] as String? ?? '',
      example1Tr: json['ex1_tr'] as String? ?? '',
      example2: json['ex2'] as String? ?? '',
      example2Tr: json['ex2_tr'] as String? ?? '',
      ipa: json['ipa'] as String? ?? '',
      partOfSpeech: json['pos'] as String? ?? '',
    );

Map<String, dynamic> _$$WordImplToJson(_$WordImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'english': instance.english,
      'turkish': instance.turkish,
      'definition': instance.definition,
      'difficulty': instance.difficulty,
      'is_active': instance.isActive,
      'ex1': instance.example1,
      'ex1_tr': instance.example1Tr,
      'ex2': instance.example2,
      'ex2_tr': instance.example2Tr,
      'ipa': instance.ipa,
      'pos': instance.partOfSpeech,
    };
