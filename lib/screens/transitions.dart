import 'package:flutter/cupertino.dart';
import 'package:natura/screens/civics_test/interview.dart';
import 'package:natura/screens/civics_test/qna.dart';
import 'package:natura/screens/civics_test/results.dart';
import 'package:natura/screens/intro.dart';
import 'package:natura/screens/main_menu.dart';
import 'package:natura/screens/settings.dart';
import 'package:page_transition/page_transition.dart';

Route? genScreenTransition(final RouteSettings settings) {
  PageTransitionType transitionType;
  Widget widget;
  switch (settings.name) {
    case IntroScreen.routePath:
      widget = IntroScreen();
      transitionType = PageTransitionType.fade;
      break;
    case SettingsScreen.routePath:
      widget = SettingsScreen();
      switch (settings.arguments) {
        case MainMenuScreen.routePath:
          transitionType = PageTransitionType.bottomToTop;
          break;
        case IntroScreen.routePath:
          transitionType = PageTransitionType.leftToRight;
          break;
        default:
          return null;
      }
      break;
    case MainMenuScreen.routePath:
      widget = MainMenuScreen();
      switch (settings.arguments) {
        case null: // second app run (no intro shown)
          transitionType = PageTransitionType.fade;
          break;
        case SettingsScreen.routePath:
          transitionType = PageTransitionType.topToBottom;
          break;
        case CivicsTestResultsScreen.routePath:
          transitionType = PageTransitionType.topToBottom;
          break;
        default:
          return null;
      }
      break;
    case CivicsTestQnAScreen.routePath:
      widget = CivicsTestQnAScreen();
      transitionType = PageTransitionType.rightToLeft;
      break;
    case CivicsTestInterviewScreen.routePath:
      widget = CivicsTestInterviewScreen();
      transitionType = PageTransitionType.rightToLeft;
      break;
    case CivicsTestResultsScreen.routePath:
      widget = CivicsTestResultsScreen();
      transitionType = PageTransitionType.bottomToTop;
      break;
    default:
      return null;
  }
  return PageTransition<Route>(
    child: widget,
    type: transitionType,
    settings: settings,
  );
}
