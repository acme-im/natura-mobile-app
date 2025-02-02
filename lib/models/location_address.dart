import 'package:json_annotation/json_annotation.dart';

part 'location_address.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class LocationAddress {
  String? streetNumber;
  String? street;
  String? city;
  String? stateAbbr;
  String? stateName;
  String? zipCode;
  String? countryAbbr;
  String? countryName;
  String? formatted;

  LocationAddress({
    this.streetNumber,
    this.street,
    this.city,
    this.stateAbbr,
    this.stateName,
    this.zipCode,
    this.countryAbbr,
    this.countryName,
    this.formatted,
  });

  @override
  String toString() {
    return formatted ?? '';
  }

  factory LocationAddress.fromJson(Map<String, dynamic> json) => _$LocationAddressFromJson(json);

  Map<String, dynamic> toJson() => _$LocationAddressToJson(this);
}
