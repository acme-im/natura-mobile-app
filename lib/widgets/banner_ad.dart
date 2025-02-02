import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:natura/utils/conf.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<StatefulWidget> createState() => BannerAdState();
}

class BannerAdState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  final Completer<BannerAd> bannerCompleter = Completer<BannerAd>();

  @override
  void didChangeDependencies() {
    // because we ref context, can't do the same in initState()
    AdSize.getAnchoredAdaptiveBannerAdSize(
      Orientation.portrait,
      MediaQuery.of(context).size.width.truncate(),
    ).then((size) {
      if (size == null) {
        throw ('Unable to get height of anchored banner.');
      }
      String strAdUnitId = Platform.isAndroid ? kGoogleMobileAdsFooterKeyAndroid : kGoogleMobileAdsFooterKeyIos;
      String testAdUnitId = Platform.isAndroid ? kGoogleMobileAdsFooterKeyAndroidTest : kGoogleMobileAdsFooterKeyIosTest;
      String adUnitId = kReleaseMode ? strAdUnitId : testAdUnitId;

      _bannerAd = BannerAd(
        adUnitId: adUnitId,
        request: AdRequest(),
        size: size,
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            if (kDebugMode) {
              print('$BannerAd loaded.');
            }
            bannerCompleter.complete(ad as BannerAd);
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            if (kDebugMode) {
              print('$BannerAd failedToLoad: $error');
            }
            ad.dispose();
            bannerCompleter.completeError(error);
          },
          onAdOpened: (Ad ad) => print('$BannerAd onAdOpened.'),
          onAdClosed: (Ad ad) => print('$BannerAd onAdClosed.'),
        ),
      );
      _bannerAd!.load();
    });

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  Widget _placementBannerWidget(double width, double height) {
    var imgId = (DateTime.now().minute % 5) + 1;
    return Image.asset(
      'assets/images/placeholder_banners/$imgId.png',
      width: width,
      height: height,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BannerAd>(
      future: bannerCompleter.future,
      builder: (BuildContext context, AsyncSnapshot<BannerAd> snapshot) {
        Widget child;

        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
          case ConnectionState.active:
            child = Container();
            break;
          case ConnectionState.done:
            if (snapshot.hasData) {
              child = AdWidget(ad: _bannerAd!);
            } else {
              if (kDebugMode) {
                print('Error loading $BannerAd');
              }
              child = _placementBannerWidget(320.0, 50.0);
            }
        }

        return Container(
          width: _bannerAd?.size.width.toDouble(),
          height: _bannerAd?.size.height.toDouble() ?? 50,
          decoration: _bannerAd == null
              ? BoxDecoration(
                  border: Border.all(color: Color(0xffdddddd)),
                  color: Colors.white,
                )
              : null,
          child: child,
        );
      },
    );
  }
}
