// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'us_territory_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UsTerritoryInfo _$UsTerritoryInfoFromJson(Map<String, dynamic> json) =>
    UsTerritoryInfo(
      json['name'] as String,
      json['abbr'] as String,
      json['capital'] as String?,
      json['governor'] == null
          ? null
          : Person.fromJson(json['governor'] as Map<String, dynamic>),
      (json['senators'] as List<dynamic>?)
          ?.map((e) => Person.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['flag_url'] as String?,
      json['skyline_background_url'] as String?,
      json['nickname'] as String?,
      (json['answers'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
      ),
      (json['representatives'] as List<dynamic>)
          .map((e) => Person.fromJson(e as Map<String, dynamic>))
          .toList(),
      json['representative'] == null
          ? null
          : Person.fromJson(json['representative'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UsTerritoryInfoToJson(UsTerritoryInfo instance) =>
    <String, dynamic>{
      'name': instance.name,
      'abbr': instance.abbr,
      'capital': instance.capital,
      'governor': instance.governor?.toJson(),
      'senators': instance.senators?.map((e) => e.toJson()).toList(),
      'flag_url': instance.flagUrl,
      'skyline_background_url': instance.skylineBackgroundUrl,
      'nickname': instance.nickname,
      'answers': instance.answers,
      'representatives':
          instance.representatives.map((e) => e.toJson()).toList(),
      'representative': instance.representative?.toJson(),
    };
