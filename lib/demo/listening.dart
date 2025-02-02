import 'package:flutter/material.dart';
import 'package:natura/utils/conf.dart';
import 'package:natura/utils/misc.dart';
import 'package:natura/widgets/civics_test/answering.dart';
import 'package:natura/widgets/civics_test/main.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Conf().init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      home: Scaffold(
        body: CivicsTestMainWidget(AnsweringState(true, '...', Conf().questionsToAsk, curQuestionNum: 9)),
      ),
      theme: appTheme(context),
      debugShowCheckedModeBanner: false,
    );
  }
}
