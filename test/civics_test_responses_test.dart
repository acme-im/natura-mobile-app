import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:natura/models/civics_test_question.dart';
import 'package:natura/models/civics_test.dart';
import 'package:natura/models/civics_test_responses.dart';

void main() {
  test('text is similar', () {
    assert(isSimilar('the Constitution', 'constitution'));
    assert(isSimilar('sets up the government', 'sets up goverment'));
    assert(isSimilar('protects basic rights of Americans', "protects american's basic rights"));
    assert(isSimilar('an addition (to the Constitution)', 'addition to constitution'));
    assert(isSimilar('an addition (to the Constitution)', 'an addition'));
    assert(isSimilar('saved (or preserved) the Union', 'saved the union'));
    assert(isSimilar('saved (or preserved) the Union', 'preserved the union'));
    assert(isSimilar('civil rights (movement)', 'civil rights'));
    assert(isSimilar('The Vice President', 'vice-president'));
    assert(isSimilar('at age eighteen (18)', 'at age 18'));
    assert(isSimilar('the flag', 'flag'));
    assert(isSimilar('the Bill of Rights', 'bill of rights'));
    assert(isSimilar('declared our independence', 'declared independence'));
    assert(isSimilar('You can practice any religion, or not practice a religion.',
        'practice a religion or not practice a religion'));
    assert(isSimilar('(Franklin) Roosevelt', 'Roosevelt'));
    assert(isSimilar('1786', '1786', type: QuestionType.date));
    assert(isSimilar('July 4', 'july 4', type: QuestionType.date));
    assert(isSimilar('July 4', 'July 4th', type: QuestionType.date));
    assert(isSimilar('July 4', 'Fourth of July', type: QuestionType.date));
    assert(isSimilar('July 4, 1776', 'July 4th 1776', type: QuestionType.date));
    assert(isSimilar('July 4, 1776', 'this happened on July 4th year 1776', type: QuestionType.date));
    assert(isSimilar('April 15', 'should be before April 15', type: QuestionType.date));
    assert(isSimilar('twenty-seven (27)', "it's 27", type: QuestionType.number));
    assert(isSimilar('one hundred (100)', '100', type: QuestionType.number));
    assert(isSimilar('six (6)', 'there are 6 senators', type: QuestionType.number));
    assert(isSimilar('four (4)', 'Four', type: QuestionType.number));
    assert(isSimilar('twenty-seven (27)', 'Twenty Seven', type: QuestionType.number));
    assert(isSimilar('four hundred thirty-five (435)', 'four hundred thirty-five', type: QuestionType.number));
    assert(isSimilar('four hundred thirty-five (435)', 'four hundred and thirty-five', type: QuestionType.number));
  });

  test('text is different', () {
    assert(!isSimilar('the Constitution', 'the Prostitution'));
    assert(!isSimilar('sets up the government', 'government'));
    assert(!isSimilar('1786', '1787', type: QuestionType.date));
    assert(!isSimilar('July 4', 'July 5', type: QuestionType.date));
    assert(!isSimilar('July 4, 1776', 'July 4, 1777', type: QuestionType.date));
    assert(!isSimilar('April 15', 'April 16', type: QuestionType.date));
    assert(!isSimilar('twenty-seven (27)', "it's 28", type: QuestionType.number));
    assert(!isSimilar('one hundred (100)', '1000', type: QuestionType.number));
    assert(!isSimilar('six (6)', 'there are 7 senators', type: QuestionType.number));
    assert(!isSimilar('twenty-seven (27)', 'Twenty', type: QuestionType.number));
    assert(!isSimilar('four (4)', 'Fourteen', type: QuestionType.number));
    assert(!isSimilar('four hundred thirty-five (435)', 'four hundred thirty', type: QuestionType.number));
    assert(!isSimilar('four hundred thirty-five (435)', 'four hundred and thirty', type: QuestionType.number));
  });

  test('response is valid', () async {
    await File('test/data/civics_test.json')
        .readAsString()
        .then((fileContents) => json.decode(fileContents) as Map<String, dynamic>)
        .then((jsonData) {
      var ct = CivicsTest.fromJson(jsonData, shuffle: false, includeEmpty: true);

      var q = ct.questionnaire[95];
      var r = ResponseItem(q, 'because there were thirteen original colonies');
      assert(r.isAnswerValid());

      q = ct.questionnaire[35];
      r = ResponseItem(q, 'Secretary of Education and Secretary of Energy');
      assert(r.isAnswerValid());

      r = ResponseItem(q, 'Secretary of agriculture Secretary of education');
      assert(r.isAnswerValid());

      q = ct.questionnaire[99];
      r = ResponseItem(q, 'Christmas and Thanksgiving');
      assert(r.isAnswerValid());

      q = ct.questionnaire[25];
      r = ResponseItem(q, 'Four');
      assert(r.isAnswerValid());

      r = ResponseItem(q, '4');
      assert(r.isAnswerValid());

      q = ct.questionnaire[85];
      r = ResponseItem(q, 'Terrorist attack');
      assert(r.isAnswerValid());
    });
  });

  test('response is invalid', () async {
    await File('test/data/civics_test.json')
        .readAsString()
        .then((fileContents) => json.decode(fileContents) as Map<String, dynamic>)
        .then((jsonData) {
      var ct = CivicsTest.fromJson(jsonData, shuffle: false, includeEmpty: true);

      var q = ct.questionnaire[35];
      var r = ResponseItem(q, 'Secretary of Economics Secretary of Education');
      assert(!r.isAnswerValid());

      r = ResponseItem(q, 'Secretary of Economics and Secretary of Education');
      assert(!r.isAnswerValid());

      q = ct.questionnaire[99];
      r = ResponseItem(q, 'Christmas and Harry Potter');
      assert(!r.isAnswerValid());

      q = ct.questionnaire[25];
      r = ResponseItem(q, 'Fourty');
      assert(!r.isAnswerValid());

      r = ResponseItem(q, '40');
      assert(!r.isAnswerValid());

      q = ct.questionnaire[56];
      r = ResponseItem(q, 'between age 18 and 16');
      assert(!r.isAnswerValid());

      /* TODO: fixme
      q = ct.questionnaire[95];
      r = ResponseItem(q, 'because there were fourteen original colonies');
      assert(!r.isAnswerValid());
      */
    });
  });
}
