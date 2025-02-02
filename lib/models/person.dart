import 'package:json_annotation/json_annotation.dart';

part 'person.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake)
class Person {
  final String name;
  final String? photoUrl;
  final String? pronunciation;
  final String? party;

  Person(this.name, {this.photoUrl, this.pronunciation, this.party});

  factory Person.fromJson(Map<String, dynamic> json) => _$PersonFromJson(json);

  Map<String, dynamic> toJson() => _$PersonToJson(this);
}
