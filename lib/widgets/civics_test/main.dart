import 'package:flutter/material.dart';
import 'package:natura/widgets/civics_test/answering.dart';
import 'package:natura/widgets/civics_test/asking.dart';

class CivicsTestMainWidget extends StatefulWidget {
  final AnsweringState _answeringState;

  const CivicsTestMainWidget(AnsweringState answeringState, {super.key})
      : _answeringState = answeringState;

  @override
  _CivicsTestMainWidgetState createState() => _CivicsTestMainWidgetState();
}

class _CivicsTestMainWidgetState extends State<CivicsTestMainWidget> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            flex: 4,
            child: Center(
              child: Text(
                'Question ${widget._answeringState.curQuestionNum}/${widget._answeringState.questionsToAsk}',
                style: TextStyle(
                  fontSize: 36.0,
                ),
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Center(
              child: FractionallySizedBox(
                widthFactor: 0.5,
                child: widget._answeringState.isAnswering
                    ? CivicsTestAnsweringWidget(widget._answeringState)
                    : CivicsTestAskingWidget(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
