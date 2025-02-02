// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'person.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Person _$PersonFromJson(Map<String, dynamic> json) => Person(
      json['name'] as String,
      photoUrl: json['photo_url'] as String?,
      pronunciation: json['pronunciation'] as String?,
      party: json['party'] as String?,
    );

Map<String, dynamic> _$PersonToJson(Person instance) => <String, dynamic>{
      'name': instance.name,
      'photo_url': instance.photoUrl,
      'pronunciation': instance.pronunciation,
      'party': instance.party,
    };
