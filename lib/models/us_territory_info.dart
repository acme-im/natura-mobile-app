import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:natura/models/civics_test_responses.dart';
import 'package:natura/models/person.dart';
import 'package:natura/utils/conf.dart';
import 'package:natura/utils/misc.dart';

part 'us_territory_info.g.dart';

@JsonSerializable(explicitToJson: true, fieldRename: FieldRename.snake)
class UsTerritoryInfo {
  late final String name;
  late final String abbr;
  late final String? capital; // DC doesn't have one
  late final Person? governor; // DC doesn't have one
  late final List<Person>? senators; // US territories doesn't have ones
  late final String? flagUrl;
  late final String? skylineBackgroundUrl;
  late final String? nickname;
  late final Map<String, List<String>> answers; // questionId: answers list
  late final List<Person> representatives; // all possible candidates
  // a concrete representative (mapped from representatives by name from google civic api)
  Person? representative;

  UsTerritoryInfo(this.name, this.abbr, this.capital, this.governor, this.senators, this.flagUrl,
      this.skylineBackgroundUrl, this.nickname, this.answers, this.representatives, this.representative);

  static Future<UsTerritoryInfo> fromUrl({final String? state, final bool forceDownload = false}) async {
    var dataFileDecoded = json.decode(await downloadDataFile(forceDownload: forceDownload)) as Map<String, dynamic>;
    return UsTerritoryInfo.fromJson(
      dataFileDecoded['state_info'][state] as Map<String, dynamic>,
    );
  }

  void setRepresentative(String? name) {
    if (representatives.length == 1) {
      // if there is a single candidate, use her as a representative;
      // this is useful for US territories (google civic info api returns no data for these).
      representative = representatives[0];
    } else if (name != null) {
      // try to match one from candidates
      representative = representatives.firstWhereOrNull((Person p) => isSimilar(p.name, name));
    } else {
      if (Conf().isFirebaseEnabled) {
        FirebaseCrashlytics.instance.log('trying to set representative $name for state $abbr, db is probably outdated');
      }
    }
  }

  factory UsTerritoryInfo.fromJson(Map<String, dynamic> json) => _$UsTerritoryInfoFromJson(json);

  Map<String, dynamic> toJson() => _$UsTerritoryInfoToJson(this);
}
