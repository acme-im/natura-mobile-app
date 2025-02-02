import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:natura/models/us_territory_info.dart';

void main() {
  test('US territory info model should be initialized by calling a remote API', () async {
    var info = await UsTerritoryInfo.fromUrl(state: 'CA');
    assert(info.name == 'California');
    assert(info.abbr == 'CA');
    assert(info.capital == 'Sacramento');
    assert(info.governor!.name.isNotEmpty);
    assert(info.senators!.length == 2);
    assert(info.flagUrl!.isNotEmpty);
    assert(info.skylineBackgroundUrl!.isNotEmpty);
    assert(info.nickname!.isNotEmpty);
    assert(info.representatives.isNotEmpty);
    assert(info.representative == null);
  });

  test('US territory info model should be initialized from json', () async {
    await File('test/data/civics_test.json')
        .readAsString()
        .then((String fileContents) => json.decode(fileContents) as Map<String, dynamic>)
        .then((jsonData) {
      var infoJson = jsonData['state_info']['CA'] as Map<String, dynamic>;
      var info = UsTerritoryInfo.fromJson(infoJson);
      assert(info.name == 'California');
      assert(info.abbr == 'CA');
      assert(info.capital == 'Sacramento');
      assert(info.governor!.name.isNotEmpty);
      assert(info.senators!.length == 2);
      assert(info.flagUrl!.isNotEmpty);
      assert(info.skylineBackgroundUrl!.isNotEmpty);
      assert(info.nickname!.isNotEmpty);
      assert(info.representatives.isNotEmpty);
      assert(info.representative == null);

      // invalid representative
      info = UsTerritoryInfo.fromJson(infoJson);
      info.setRepresentative('My Dear Repr');
      assert(info.representative == null);

      // valid representative
      info = UsTerritoryInfo.fromJson(infoJson);
      info.setRepresentative('Jackie Speier');
      assert(info.representative!.name == 'Jackie Speier');
      assert(info.representative!.pronunciation == 'JACK-ee SPEAR');

      infoJson = jsonData['state_info']['VI'] as Map<String, dynamic>;
      info = UsTerritoryInfo.fromJson(infoJson);
      info.setRepresentative(null);
      assert(info.name == 'Virgin Islands');
      assert(info.abbr == 'VI');
      assert(info.capital == 'Charlotte Amalie');
      assert(info.governor!.name.isNotEmpty);
      assert(info.senators == null);
      assert(info.flagUrl == null);
      assert(info.skylineBackgroundUrl == null);
      assert(info.nickname == null);
      assert(info.representatives.isNotEmpty);
      assert(info.representative!.name.isNotEmpty);

      infoJson = jsonData['state_info']['DC'] as Map<String, dynamic>;
      info = UsTerritoryInfo.fromJson(infoJson);
      info.setRepresentative('Eleanor Holmes Norton');
      assert(info.name == 'District of Columbia');
      assert(info.abbr == 'DC');
      assert(info.capital == null);
      assert(info.governor == null);
      assert(info.senators == null);
      assert(info.flagUrl == null);
      assert(info.skylineBackgroundUrl == null);
      assert(info.nickname == null);
      assert(info.representatives.isNotEmpty);
      assert(info.representative!.name == 'Norton, Eleanor Holmes');
    });
  });
}
