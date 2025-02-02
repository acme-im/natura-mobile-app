import 'package:flutter/cupertino.dart';

class CivicsTestAskingWidget extends StatelessWidget {
  const CivicsTestAskingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      'Listen to the question and prepare to answer',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 20.0,
      ),
    );
  }
}
