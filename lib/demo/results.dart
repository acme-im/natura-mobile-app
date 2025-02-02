import 'package:flutter/material.dart';
import 'package:natura/models/civics_test_question.dart';
import 'package:natura/models/civics_test_responses.dart';
import 'package:natura/screens/civics_test/results.dart';
import 'package:natura/utils/conf.dart';
import 'package:natura/utils/misc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Conf().init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var dummyResults = CivicsTestResponses(Conf().questionsToAsk, Conf().validResponsesPercent);
    dummyResults.add(
        CivicsTestQuestion(1, 'What are the two major political parties in the United States?', QuestionType.text,
            QuestionCategory.americanGovernment, 'A', false, 1, ['Democratic and Republican'], null),
        'Big-Endians and Little-Endians');
    dummyResults.add(
        CivicsTestQuestion(
            1,
            'There are four amendments to the Constitution about who can vote. Describe one of them.',
            QuestionType.text,
            QuestionCategory.americanGovernment,
            'A',
            false,
            1,
            [
              'Citizens eighteen (18) and older (can vote).',
              "You don't have to pay (a poll tax) to vote.",
              'Any citizen can vote. (Women and men can vote.)',
              'A male citizen of any race (can vote).'
            ],
            null),
        "I don't remember");
    dummyResults.add(
        CivicsTestQuestion(
            3, 'question numba 3', QuestionType.text, QuestionCategory.americanGovernment, 'A', true, 1, ['42'], null),
        '42');
    dummyResults.add(
        CivicsTestQuestion(
            3, 'question numba 3', QuestionType.text, QuestionCategory.americanGovernment, 'A', true, 1, ['42'], null),
        '42');
    dummyResults.add(
        CivicsTestQuestion(
            3, 'question numba 3', QuestionType.text, QuestionCategory.americanGovernment, 'A', true, 1, ['42'], null),
        '42');
    dummyResults.add(
        CivicsTestQuestion(
            3, 'question numba 3', QuestionType.text, QuestionCategory.americanGovernment, 'A', true, 1, ['42'], null),
        '42');
    dummyResults.add(
        CivicsTestQuestion(
            3, 'question numba 3', QuestionType.text, QuestionCategory.americanGovernment, 'A', true, 1, ['42'], null),
        '42');
    dummyResults.add(
        CivicsTestQuestion(
            3, 'question numba 3', QuestionType.text, QuestionCategory.americanGovernment, 'A', true, 1, ['42'], null),
        '42');

    return MaterialApp(
      home: Scaffold(
        body: CivicsTestResultsScreen(
          responses: dummyResults,
        ),
      ),
      theme: appTheme(context),
      debugShowCheckedModeBanner: false,
    );
  }
}
