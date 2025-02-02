// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_address.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationAddress _$LocationAddressFromJson(Map<String, dynamic> json) =>
    LocationAddress(
      streetNumber: json['street_number'] as String?,
      street: json['street'] as String?,
      city: json['city'] as String?,
      stateAbbr: json['state_abbr'] as String?,
      stateName: json['state_name'] as String?,
      zipCode: json['zip_code'] as String?,
      countryAbbr: json['country_abbr'] as String?,
      countryName: json['country_name'] as String?,
      formatted: json['formatted'] as String?,
    );

Map<String, dynamic> _$LocationAddressToJson(LocationAddress instance) =>
    <String, dynamic>{
      'street_number': instance.streetNumber,
      'street': instance.street,
      'city': instance.city,
      'state_abbr': instance.stateAbbr,
      'state_name': instance.stateName,
      'zip_code': instance.zipCode,
      'country_abbr': instance.countryAbbr,
      'country_name': instance.countryName,
      'formatted': instance.formatted,
    };
