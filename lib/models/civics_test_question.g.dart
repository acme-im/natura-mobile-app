// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'civics_test_question.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CivicsTestQuestion _$CivicsTestQuestionFromJson(Map<String, dynamic> json) =>
    CivicsTestQuestion(
      json['id'] as int,
      json['text'] as String,
      $enumDecode(_$QuestionTypeEnumMap, json['type']),
      $enumDecode(_$QuestionCategoryEnumMap, json['category']),
      json['sub_category'] as String,
      json['is6520'] as bool,
      json['min_answers'] as int,
      (json['answers'] as List<dynamic>).map((e) => e as String).toList(),
      json['text_tts'] as String?,
    );

Map<String, dynamic> _$CivicsTestQuestionToJson(CivicsTestQuestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'text': instance.text,
      'type': _$QuestionTypeEnumMap[instance.type]!,
      'category': _$QuestionCategoryEnumMap[instance.category]!,
      'sub_category': instance.subCategory,
      'is6520': instance.is6520,
      'min_answers': instance.minAnswers,
      'answers': instance.answers,
      'text_tts': instance.textTts,
    };

const _$QuestionTypeEnumMap = {
  QuestionType.text: 0,
  QuestionType.date: 1,
  QuestionType.number: 2,
};

const _$QuestionCategoryEnumMap = {
  QuestionCategory.americanGovernment: 0,
  QuestionCategory.americanHistory: 1,
  QuestionCategory.integratedCivics: 2,
};
