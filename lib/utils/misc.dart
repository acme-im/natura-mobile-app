import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:in_app_review/in_app_review.dart';
import 'package:natura/utils/conf.dart';
import 'package:path_provider/path_provider.dart';

const int kMaxDataAgeDays = 7;

const Color kColorBorderAnswerValid = Color(0xff9bc53d);
const Color kColorBorderAnswerWrong = Color(0xffd62828);
const Color kColorBorderAnswerNeutral = Colors.blue;

const Color kColorBorderBannerPlacement = Color(0xffdddddd);

int questionIdtoIx(final int questionId) {
  return questionId - 1;
}

Future<String> downloadDataFile({bool forceDownload = false}) async {
  var appDataDir = await getApplicationDocumentsDirectory();
  var dataFilePath = '${appDataDir.path}/data.json';
  var f = File(dataFilePath);
  if (forceDownload ||
      !f.existsSync() ||
      f.lastModifiedSync().difference(DateTime.now()).inDays.abs() >= kMaxDataAgeDays) {
    var url = '${appCdnUrl()}/civics_test/2008/data.json';
    var response = await http.get(Uri.parse(url));
    debugPrint('downloading data file from $url');
    f.writeAsBytesSync(response.bodyBytes);
  }
  return f.readAsStringSync();
}

ThemeData appTheme(BuildContext context) {
  var googleTextTheme = GoogleFonts.merriweatherTextTheme(
    Theme.of(context).textTheme,
  );
  return ThemeData(
    textTheme: googleTextTheme,
    primaryTextTheme: googleTextTheme,
    appBarTheme: AppBarTheme(
      elevation: 0.0,
      centerTitle: true,
      backgroundColor: Colors.white,
      iconTheme: IconThemeData(
        color: Colors.blueAccent,
      ),
    ),
  );
}

Future<void> rateUsHandler() async {
  // if interview was taken 5 times - request "Rate Us" once per week
  var now = DateTime.now().millisecondsSinceEpoch;
  var rateUsLastRequestedTimestamp = Conf().rateUsLastRequestedTimestamp;
  final inAppReview = InAppReview.instance;
  var askRateUs = (await inAppReview.isAvailable()) &&
      Conf().interviewCounter > 5 &&
      ((now - rateUsLastRequestedTimestamp) >= Duration(days: 7).inMilliseconds);
  if (askRateUs) {
    await logEvent(name: 'rate_us_show');
    await inAppReview.requestReview();
    Conf().rateUsLastRequestedTimestamp = now;
  }
}

Future<void> logEvent({required String name, Map<String, Object>? parameters}) async {
  if (Conf().isFirebaseEnabled) {
    await FirebaseAnalytics.instance.logEvent(
      name: name,
      parameters: parameters,
    );
  }
}
