import 'package:flutter/material.dart';
import 'package:natura/screens/civics_test/qna.dart';
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
    return MaterialApp(
      home: Scaffold(
        body: CivicsTestQnAScreen(),
      ),
      theme: appTheme(context),
      debugShowCheckedModeBanner: false,
    );
  }
}
