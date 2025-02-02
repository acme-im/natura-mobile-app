import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:natura/models/civics_test.dart';
import 'package:natura/models/person.dart';
import 'package:natura/utils/misc.dart';

void main() {
  test('civics test model should be initialized by calling a remote API', () async {
    var ct = await CivicsTest.fromUrl(state: 'CA', forceDownload: true, shuffle: false, includeEmpty: true);
    assert(ct.questionnaire[questionIdtoIx(kCapitalQuestionId)].answers[0] == 'Sacramento');
    assert(ct.questionnaire[questionIdtoIx(kGovernorQuestionId)].answers.length == 1);
    assert(ct.questionnaire[questionIdtoIx(kSenatorsQuestionId)].answers.length == 2);
    assert(ct.questionnaire[questionIdtoIx(kRepresentativeQuestionId)].answers.isEmpty);
  });

  test('civics test model should initialize from json', () async {
    await File('test/data/civics_test.json')
        .readAsString()
        .then((fileContents) => json.decode(fileContents) as Map<String, dynamic>)
        .then((jsonData) {
      var ct = CivicsTest.fromJson(jsonData, state: 'CA', includeEmpty: true, shuffle: false);
      assert(ct.questionnaire[questionIdtoIx(kCapitalQuestionId)].answers[0] == 'Sacramento');
      assert(ct.questionnaire[questionIdtoIx(kGovernorQuestionId)].answers.length == 1);
      assert(ct.questionnaire[questionIdtoIx(kSenatorsQuestionId)].answers.length == 2);
      assert(ct.questionnaire[questionIdtoIx(kRepresentativeQuestionId)].answers.isEmpty);

      // unknown representative
      ct = CivicsTest.fromJson(jsonData, state: 'CA', representative: null, includeEmpty: true, shuffle: false);
      assert(ct.questionnaire[questionIdtoIx(kRepresentativeQuestionId)].answers.isEmpty);

      ct = CivicsTest.fromJson(jsonData,
          state: 'CA',
          representative: Person('Jackie Speier', pronunciation: 'JACK-ee SPEAR'),
          includeEmpty: true,
          shuffle: false);
      assert(ct.questionnaire[questionIdtoIx(kRepresentativeQuestionId)].answers[0] == 'Jackie Speier (JACK-ee SPEAR)');

      // no state provided - all state-related question answers should be empty
      ct = CivicsTest.fromJson(jsonData, includeEmpty: true, shuffle: false);
      assert(ct.questionnaire[questionIdtoIx(kCapitalQuestionId)].answers.isEmpty);
      assert(ct.questionnaire[questionIdtoIx(kGovernorQuestionId)].answers.isEmpty);
      assert(ct.questionnaire[questionIdtoIx(kSenatorsQuestionId)].answers.isEmpty);
      assert(ct.questionnaire[questionIdtoIx(kRepresentativeQuestionId)].answers.isEmpty);

      ct = CivicsTest.fromJson(jsonData, state: 'DC', includeEmpty: true, shuffle: false);
      assert(ct.questionnaire[questionIdtoIx(kCapitalQuestionId)].answers[0] ==
          'D.C. is not a state and does not have a capital');
      assert(ct.questionnaire[questionIdtoIx(kGovernorQuestionId)].answers[0] == 'D.C. does not have a Governor');
      assert(ct.questionnaire[questionIdtoIx(kSenatorsQuestionId)].answers[0] ==
          '(District of Columbia has) no U.S. Senators');
      assert(ct.questionnaire[questionIdtoIx(kRepresentativeQuestionId)].answers.length == 2);
    });
  });

  test('civics test model returns random questions', () async {
    await File('test/data/civics_test.json')
        .readAsString()
        .then((fileContents) => json.decode(fileContents) as Map<String, dynamic>)
        .then((jsonData) {
      var ct = CivicsTest.fromJson(jsonData, is6520: true);
      assert(ct.next().is6520 == true);
    });
  });
}
