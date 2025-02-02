import 'dart:convert';
import 'dart:core';
import 'dart:math';

import 'package:natura/models/civics_test_question.dart';
import 'package:natura/models/person.dart';
import 'package:natura/models/us_territory_info.dart';
import 'package:natura/utils/misc.dart';

const int kSenatorsQuestionId = 20;
const int kRepresentativeQuestionId = 23;
const int kGovernorQuestionId = 43;
const int kCapitalQuestionId = 44;

class CivicsTest {
  late final List<CivicsTestQuestion> _questionnaire = [];
  static final Random _rnd = Random();
  int _ix = 0; // _questionnaire pointer for next()
  final bool _shuffled;

  List<CivicsTestQuestion> get questionnaire => _questionnaire;

  static Future<CivicsTest> fromUrl(
      {final String? state,
      final Person? representative,
      final bool forceDownload = false,
      final bool shuffle = true,
      final bool is6520 = false,
      final bool includeEmpty = false}) async {
    return CivicsTest.fromJson(
      json.decode(await downloadDataFile(forceDownload: forceDownload)) as Map<String, dynamic>,
      state: state,
      representative: representative,
      shuffle: shuffle,
      is6520: is6520,
      includeEmpty: includeEmpty,
    );
  }

  CivicsTest.fromJson(final Map<String, dynamic> json,
      {final String? state,
      final Person? representative,
      bool shuffle = true,
      final bool is6520 = false,
      final bool includeEmpty = false})
      : _shuffled = shuffle {
    UsTerritoryInfo? usTerritoryInfo;
    if (state != null) {
      usTerritoryInfo = UsTerritoryInfo.fromJson(json['state_info'][state] as Map<String, dynamic>);
      if (representative != null) usTerritoryInfo.representative = representative;
    }

    var questions = List<Map<String, dynamic>>.from(json['questions'] as List<dynamic>)
        .map((e) => CivicsTestQuestion.fromJson(e))
        .toList();

    for (CivicsTestQuestion q in questions) {
      if (!is6520 || (is6520 && q.is6520)) {
        if (usTerritoryInfo != null && usTerritoryInfo.answers.containsKey(q.id.toString())) {
          q.answers = usTerritoryInfo.answers[q.id.toString()] as List<String>;
          if (q.id == kRepresentativeQuestionId && usTerritoryInfo.representative != null && q.answers.isEmpty) {
            q.answers.add('${usTerritoryInfo.representative!.name} (${usTerritoryInfo.representative!.pronunciation})');
          }
        }
        if (q.answers.isNotEmpty || includeEmpty) _questionnaire.add(q);
      }
    }
    resetQuestionnaire();
  }

  void resetQuestionnaire() {
    _ix = 0;
    if (_shuffled) _questionnaire.shuffle(_rnd);
  }

  CivicsTestQuestion next() {
    if (_ix >= _questionnaire.length) resetQuestionnaire();
    return _questionnaire[_ix++];
  }
}
