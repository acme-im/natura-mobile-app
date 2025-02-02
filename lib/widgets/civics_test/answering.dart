import 'package:flutter/material.dart';
import 'package:natura/utils/conf.dart';
import 'package:natura/utils/misc.dart';

class AnsweringState {
  bool isAnswering;
  int questionsToAsk;
  int curQuestionNum;
  double soundLevel;
  String lastWords;
  bool? isAnswerValid;

  AnsweringState(this.isAnswering, this.lastWords, this.questionsToAsk,
      {this.curQuestionNum = 0, this.soundLevel = 0.0, this.isAnswerValid});
}

class CivicsTestAnsweringWidget extends StatefulWidget {
  final AnsweringState _answeringState;

  const CivicsTestAnsweringWidget(AnsweringState answeringState, {super.key})
      : _answeringState = answeringState;

  @override
  _CivicsTestAnsweringWidgetState createState() => _CivicsTestAnsweringWidgetState();
}

Widget _countDownTimerWidget(final int timeout) {
  return Column(
    children: <Widget>[
      SizedBox(
        height: 100.0,
        child: Stack(
          children: <Widget>[
            Center(
              child: SizedBox(
                  width: 100,
                  height: 100,
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: 1),
                    duration: Duration(seconds: timeout),
                    builder: (context, value, _) => CircularProgressIndicator(
                      value: value,
                      strokeWidth: 3,
                    ),
                  )),
            ),
            Center(
              child: Image.asset(
                'assets/icons/icon-adaptive.png',
                width: 80.0,
                height: 80.0,
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _CivicsTestAnsweringWidgetState extends State<CivicsTestAnsweringWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
                color: widget._answeringState.isAnswerValid != null
                    ? (widget._answeringState.isAnswerValid! ? kColorBorderAnswerValid : kColorBorderAnswerWrong)
                    : kColorBorderAnswerNeutral, // set border color
                width: 3.0), // set border width
            borderRadius: BorderRadius.all(Radius.circular(16.0)), // set rounded corner radius
          ),
          child: Text(
            widget._answeringState.lastWords,
            maxLines: 5,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20.0),
          ),
        ),
        SizedBox(height: 16.0),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  blurRadius: .32,
                  spreadRadius: (widget._answeringState.soundLevel) * 1.5,
                  color: Colors.blue.withOpacity(.05))
            ],
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(50)),
          ),
          child: _countDownTimerWidget(Conf().responseTimeout),
        ),
      ],
    );
  }
}
