import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'package:natura/engines/store.dart';
import 'package:natura/screens/civics_test/interview.dart';
import 'package:natura/screens/civics_test/qna.dart';
import 'package:natura/screens/settings.dart';
import 'package:natura/utils/conf.dart';
import 'package:natura/utils/misc.dart';

class MainMenuScreen extends StatefulWidget {
  static const routePath = '/main';

  const MainMenuScreen({super.key});

  @override
  _MainMenuScreenState createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> {
  late Store _store;

  void purchaseListener(String productId, bool succeeded) {
    if (productId == kRemoveAdsProductId) {
      Conf().showAds = !succeeded;
    }
    setState(() {});
  }

  Widget _menuButtons() {
    return Container(
      child: Column(
        children: [
          IconButton(
            icon: Icon(
              Icons.play_arrow,
            ),
            iconSize: 96,
            color: Colors.blue,
            splashColor: Colors.lightBlueAccent,
            onPressed: () {
              Navigator.pushNamed(context, CivicsTestInterviewScreen.routePath, arguments: MainMenuScreen.routePath);
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.list_outlined,
                ),
                iconSize: 48,
                color: Colors.blue,
                splashColor: Colors.lightBlueAccent,
                onPressed: () {
                  Navigator.pushNamed(context, CivicsTestQnAScreen.routePath, arguments: MainMenuScreen.routePath);
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.settings,
                ),
                iconSize: 48,
                color: Colors.blue,
                splashColor: Colors.lightBlueAccent,
                onPressed: () {
                  Navigator.pushNamed(context, SettingsScreen.routePath, arguments: MainMenuScreen.routePath);
                },
              ),
              IconButton(
                icon: Icon(
                  Icons.share,
                ),
                iconSize: 48,
                color: Colors.blue,
                splashColor: Colors.lightBlueAccent,
                onPressed: () {
                  Share.share(
                      'NaturaTest App - Get ready for your US Civics Interview! ${appLandingUrl()}?utm_source=app&utm_medium=button&utm_campaign=main_screen',
                      subject: 'Check NaturaTest App');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _store = Store()..init([kRemoveAdsProductId], purchaseListener);
    () async {
      await rateUsHandler();
    }();
  }

  @override
  void dispose() {
    _store.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget mainMenuTitle = Text(
      'NaturaTest',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.grey[600],
        fontSize: 48,
      ),
      softWrap: true,
    );

    Widget mainMenuText = Text(
      'Listen to the questions and speak the answers\n to pass the test.',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: Colors.grey[600],
        fontSize: 18,
      ),
      softWrap: true,
    );

    return Scaffold(
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 10.0, 0, 0),
                    child: Column(
                      children: [
                        mainMenuTitle,
                        FractionallySizedBox(
                          widthFactor: 0.66,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 16.0),
                            child: mainMenuText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                _menuButtons(),
              ],
            ),
            if (Conf().showAds)
              Positioned(
                bottom: 0,
                child: TextButton(
                  onPressed: () async {
                    await logEvent(name: 'remove_ads_tap');
                    await _store.buyNonConsumable(kRemoveAdsProductId);
                  },
                  child: Text(
                    'Remove Ads',
                    style: TextStyle(fontSize: 20),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
