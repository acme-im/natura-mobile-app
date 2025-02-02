import 'package:flutter/material.dart';
import 'package:natura/models/civics_test_responses.dart';
import 'package:natura/screens/main_menu.dart';
import 'package:natura/utils/misc.dart';

class Item {
  Item({
    required this.headerValue,
    required this.expandedValue,
    this.isExpanded = true,
  });

  List<String> headerValue;
  List<String> expandedValue;
  bool isExpanded;
}

List<Item> generateItems(List<ResponseItem> responses) {
  return responses.map((element) {
    return Item(
      headerValue: [element.question.text, element.userAnswer],
      expandedValue: element.question.answers,
    );
  }).toList();
}

class CivicsTestResultsScreen extends StatefulWidget {
  static const routePath = '/civics_test/results';

  final CivicsTestResponses? _responses;

  const CivicsTestResultsScreen({super.key, CivicsTestResponses? responses})
      : _responses = responses;

  @override
  CivicsTestResultsScreenState createState() => CivicsTestResultsScreenState();
}

class CivicsTestResultsScreenState extends State<CivicsTestResultsScreen> {
  List<Item> _data = [];

  Widget _answerWidget(final String text, final Color color) {
    return Container(
      margin: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
      decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(8.0)), border: Border.all(color: color)),
      child: Text(text),
    );
  }

  Widget _header(final bool isPassed, final int numValidResponses, final int numResponses) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          isPassed ? 'Congratulations!' : 'You failed.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32.0,
          ),
        ),
        Text(
          isPassed ? 'You\'ve passed the test!' : 'Review wrong answers below and try again!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isPassed ? 32.0 : 16.0,
          ),
        ),
        Center(
          child: Text(
            '\n$numValidResponses/$numResponses',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 32.0,
              height: 0.75,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: OutlinedButton(
            onPressed: () async {
              await logEvent(name: 'civics_test_start_over');
              Navigator.pop(context);
            },
            child: Text('Start Over'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final responses = widget._responses ?? ModalRoute.of(context)!.settings.arguments as CivicsTestResponses;
    if (_data.isEmpty) _data = generateItems(responses.responses.where((element) => !element.isAnswerValid()).toList());
    var numValidResponses = responses.responses.length - responses.cntFailed;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Civics Test Results'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.popUntil(context, ModalRoute.withName(MainMenuScreen.routePath));
            },
          )
        ],
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Stack(children: [
          SingleChildScrollView(
            child: Column(children: [
              Container(
                margin: EdgeInsets.all(16),
                child: _header(responses.isPassed, numValidResponses, responses.responses.length),
              ),
              Container(
                child: _buildPanelList(),
              ),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildPanelList() {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          _data[index].isExpanded = !isExpanded;
        });
      },
      children: _data.map<ExpansionPanel>((Item item) {
        return ExpansionPanel(
          canTapOnHeader: true,
          headerBuilder: (BuildContext context, bool isExpanded) {
            return Column(
                // crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Q:',
                        style: TextStyle(
                          fontSize: 24.0,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 16.0, 0, 16.0),
                        child: Text(item.headerValue[0]),
                      ),
                    ),
                  ]),
                  Container(
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                          child: Text(
                            'A:',
                            textAlign: TextAlign.right,
                            style: TextStyle(
                              fontSize: 24.0,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 11,
                          child: _answerWidget(item.headerValue[1], kColorBorderAnswerWrong),
                        )
                      ],
                    ),
                  ),
                ]);
          },
          body: Container(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.topLeft,
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text('Valid answers:'),
                    ),
                    ...item.expandedValue.map((e) => _answerWidget(e, kColorBorderAnswerValid))
                  ],
                ),
              ),
            ),
          ),
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );
  }
}
