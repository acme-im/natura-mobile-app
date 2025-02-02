import 'dart:math';

import 'package:digit_to_word/digit_to_word.dart';
import 'package:flutter/cupertino.dart';
import 'package:natura/models/civics_test_question.dart';
import 'package:natura/utils/similarity.dart';
import 'package:natura/utils/w2n.dart';

const double kDefaultMinSimilarityDistance = 0.35;
const double kNumbersMinSimilarityDistance = 0.1;

String dropStopWords(final String str) {
  var result = str.toLowerCase();
  const stopWords = <String>[
    '^a ',
    ' a ',
    '^an ',
    ' an ',
    '^because ',
    ' can ',
    '^of ',
    "it's",
    ' of ',
    '^the ',
    ' the ',
    ' there ',
    ' they ',
    '^to ',
    ' to ',
    ' was ',
    ' were ',
    '^you ',
  ];
  for (var element in stopWords) {
    result = result.replaceAll(RegExp(element), ' ');
  }
  return result;
}

String normalize(final String str, {final bool dropBracketedSubstrings = false}) {
  /*
  drop bracketed words (optional)
  drop nonsense words
  replace non-letters with single space
  replace numbers with words (for text questions with numbers, e.g. "at age eighteen (18)"
  */
  var result = str;
  if (dropBracketedSubstrings) {
    result = result.replaceAll(RegExp('\\(.*\\)'), '');
  }

  result = result.replaceAll(RegExp('\\W+'), ' ').trim().toLowerCase();

  result = dropStopWords(result);

  var matches = RegExp('[0-9]+').allMatches(result);
  for (var element in matches) {
    var numStr = element.group(0).toString();
    result = result.replaceAll(numStr, DigitToWord.translate((int.parse(numStr))));
  }

  return result;
}

bool isSimilarText(final String strEtalon, final String strAny, {final double simDist = kDefaultMinSimilarityDistance}) {
  var l = Jaccard(2); // Cosine() also worked
  var strAnyNormalized = normalize(strAny);
  var strEtalonNormalizedNoBrackets = normalize(strEtalon, dropBracketedSubstrings: true);
  var strEtalonNormalizedWithBrackets = normalize(strEtalon, dropBracketedSubstrings: false);
  var distance = min(l.distance(strEtalonNormalizedNoBrackets, strAnyNormalized),
      l.distance(strEtalonNormalizedWithBrackets, strAnyNormalized));
  var isSimilar = distance < simDist;
  debugPrint('$strEtalon VS $strAny: distance is $distance, isSimilar: $isSimilar');
  return isSimilar;
}

bool isSimilarDate(final String strEtalon, final String strAny) {
  /*
  There are 4 date questions in the test
  strEtalon (valid answer) always contains some number:
    July 4
    April 15
    July 4, 1776
    1787
  strAny (user response) may contain text only or mix of text and numbers:
    Fourth of July
    July 4th
    July 4th 1776
   */
  var etalonWords = strEtalon.toLowerCase().split(RegExp('\\W+')).toSet();

  var anyWords = <String>{};
  if (strAny.contains(RegExp(r'[0-9]'))) {
    // user response recognized with numbers (e.g. July 4th):
    // convert user response string to set replacing all semi-numbers with numbers (e.g. "4th" -> "4")
    anyWords = strAny.toLowerCase().split(RegExp('\\W+')).toSet();
    anyWords = anyWords.map((val) {
      var match = RegExp('[0-9]+').firstMatch(val)?.group(0);
      return match ?? val;
    }).toSet();
  } else {
    // user response recognized as text (e.g. Fourth of July):
    // try to convert words to numbers
    strAny.toLowerCase().split(RegExp('\\W+')).forEach((word) {
      var numWord = wordToNum(word);
      anyWords.add(numWord != null ? numWord.toString() : word);
    });
  }

  return anyWords.containsAll(etalonWords);
}

bool isSimilarNumber(final String strEtalon, final String strAny) {
  /*
  strEtalon (valid answer) always contains a number in brackets for numeric questions:
    one hundred (100)
    four hundred thirty-five (435)
  strAny (user response) may contain a number or text:
    27
    Four
   */
  var match = RegExp('[0-9]+').firstMatch(strAny)?.group(0);
  if (match != null) {
    // user response contains number (27), compare as numbers
    return int.parse(RegExp('[0-9]+').firstMatch(strEtalon)!.group(0)!) == int.parse(match);
  } else {
    // user response contains text (Four), compare as texts
    return isSimilarText(strEtalon, strAny, simDist: kNumbersMinSimilarityDistance);
  }
}

bool isSimilar(final String strEtalon, final String strAny, {final QuestionType type = QuestionType.text}) {
  switch (type) {
    case QuestionType.text:
      return isSimilarText(strEtalon, strAny);

    case QuestionType.date:
      return isSimilarDate(strEtalon, strAny);

    case QuestionType.number:
      return isSimilarNumber(strEtalon, strAny);

    default:
      throw 'Unknown string type: $type';
  }
}

bool findCoincidences(final String haystack, final List<String> needles, final int cnt) {
  var coin = 0;
  var haystackNorm = normalize(haystack);
  for (var element in needles) {
    if (haystackNorm.contains(normalize(element))) coin++;
  }
  return coin == cnt;
}

class ResponseItem {
  final CivicsTestQuestion question;
  final String userAnswer;
  bool? _isAnswerValid;

  ResponseItem(this.question, this.userAnswer);

  bool isAnswerValid() {
    return _isAnswerValid ??= () {
      if (question.type == QuestionType.date || question.type == QuestionType.number) {
        // date and numeric questions always have only one valid response
        return isSimilar(question.answers[0], userAnswer, type: question.type);
      } else {
        // QuestionType.text
        // this should be done before normalization. Google speech recognizer sometimes puts "&".
        // this replacement is useful for both single and multi-answer choices questions.
        userAnswer.replaceAll('&', 'and');
        if (question.minAnswers == 1) {
          return question.answers.any((element) {
            return isSimilar(element, userAnswer, type: question.type);
          });
        } else if (question.minAnswers == 2) {
          // list of trimmed non-empty user responses
          var userAnswers = userAnswer.split('and').map((e) => e.trim()).toList().where((e) => e.isNotEmpty).toList();
          if (userAnswers.length == 2) {
            return userAnswers.every((el1) {
              return question.answers.any((element) {
                return isSimilar(element, el1, type: question.type);
              });
            });
          }
          // user said no "and" (delimiter), so trying to find coincidences
          return findCoincidences(userAnswer, question.answers, question.minAnswers);
        } else {
          // there is only one question with 3 answers: 64. "There were 13 original states. Name three."
          // using a "findCoincidences" algo here because of a words separation difficulties.
          return findCoincidences(userAnswer, question.answers, question.minAnswers);
        }
      }
    }();
  }
}

class CivicsTestResponses {
  final List<ResponseItem> _responses = [];
  int questionsToAsk;
  double validResponsesPercent;
  final int _validResponsesToPass;
  final int _invalidResponsesToFail;
  int _cntFailed = 0;

  CivicsTestResponses(this.questionsToAsk, this.validResponsesPercent)
      : _validResponsesToPass = (questionsToAsk * validResponsesPercent).round(),
        _invalidResponsesToFail = questionsToAsk - (questionsToAsk * validResponsesPercent).round() + 1;

  void add(final CivicsTestQuestion q, final String answer) {
    var ri = ResponseItem(q, answer);
    _responses.add(ri);
    if (!ri.isAnswerValid()) {
      ++_cntFailed;
    }
  }

  bool get isFailed => _cntFailed >= _invalidResponsesToFail;

  bool get isPassed => _responses.length - _cntFailed >= _validResponsesToPass;

  int get cntFailed => _cntFailed;

  List<ResponseItem> get responses => _responses;
}
