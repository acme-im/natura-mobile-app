import 'dart:async';
import 'dart:io';
import 'dart:isolate';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:natura/screens/intro.dart';
import 'package:natura/screens/main_menu.dart';
import 'package:natura/screens/transitions.dart';
import 'package:natura/utils/conf.dart';
import 'package:natura/utils/misc.dart';

const String kRemindersTopic = 'natura_reminders';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  if (kDebugMode) {
    print('Handling a background message ${message.messageId}');
  }
}

Future<void> registerPushNotification() async {
  var messaging = FirebaseMessaging.instance;
  var settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  if (settings.authorizationStatus == AuthorizationStatus.authorized) {
    if (kDebugMode) {
      print('user granted permission');
      print('user FCM token: ${await messaging.getToken()}');
    }
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    await messaging.subscribeToTopic(kRemindersTopic);
  } else {
    if (kDebugMode) {
      print('user declined or has not accepted permission');
    }
  }
}

void main() {
  // catch errors outside flutter context
  Isolate.current.addErrorListener(RawReceivePort((List<dynamic> pair) async {
    final errorAndStacktrace = pair;
    if (Conf().isFirebaseEnabled) {
      await FirebaseCrashlytics.instance.recordError(
        errorAndStacktrace.first,
        errorAndStacktrace.last as StackTrace?,
      );
    }
  }).sendPort);

  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await Conf().init();

    if (Conf().isFirebaseEnabled) {
      await Firebase.initializeApp();
      await registerPushNotification();
    }

    FlutterError.onError = (FlutterErrorDetails details) async {
      FlutterError.dumpErrorToConsole(details);
      if (Conf().isFirebaseEnabled) {
        await FirebaseCrashlytics.instance
            .recordError(details.exception, details.stack, reason: 'fatal error', fatal: true);
        // otherwise if image is not found (404) app just exits here, so just call "return"
        // https://github.com/Baseflow/flutter_cached_network_image/issues/336#issuecomment-1423469667
        if (details.library == "image resource service" && details.exception
                .toString()
                .startsWith("HttpException: Invalid statusCode: 404, uri")
        ) {
          return;
        }
        exit(1);
      }
    };

    if (Conf().showAds) {
      await MobileAds.instance.initialize().then((InitializationStatus status) {
        if (kDebugMode) {
          print('MobileAds initialization completed: ${status.adapterStatuses}');
        }
      });
    }

    await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);

    HttpOverrides.global = MyHttpOverrides();

    runApp(NaturaApp());
  }, (Object error, StackTrace stack) async {
    debugPrint('error: $error');
    if (Conf().isFirebaseEnabled) {
      await FirebaseCrashlytics.instance.recordError(error, stack, reason: 'fatal error', fatal: true);
      exit(1);
    }
  });
}

class NaturaApp extends StatelessWidget {
  static FirebaseAnalytics? analytics = Conf().isFirebaseEnabled ? FirebaseAnalytics.instance : null;
  static FirebaseAnalyticsObserver? observer =
      Conf().isFirebaseEnabled ? FirebaseAnalyticsObserver(analytics: analytics!) : null;

  const NaturaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NaturaTest',
      initialRoute: Conf().showIntro ? IntroScreen.routePath : MainMenuScreen.routePath,
      onGenerateRoute: (settings) => genScreenTransition(settings),
      theme: appTheme(context),
      navigatorObservers: Conf().isFirebaseEnabled ? <NavigatorObserver>[observer!] : [],
      debugShowCheckedModeBanner: !kReleaseMode,
    );
  }
}
