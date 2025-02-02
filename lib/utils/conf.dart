import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:natura/models/location_address.dart';
import 'package:natura/models/us_territory_info.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EnvConf {
  // without const on the right they're coming empty
  static const kGoogleApiKey = const String.fromEnvironment('GOOGLE_API_KEY'); // ignore: unnecessary_const
  static const kShowAds = const String.fromEnvironment('SHOW_ADS'); // ignore: unnecessary_const
  static const kShowIntro = const String.fromEnvironment('SHOW_INTRO'); // ignore: unnecessary_const
}

String googleApiKey() {
  return EnvConf.kGoogleApiKey;
}

String appLandingUrl() {
  // return kReleaseMode ? 'https://natura.acme.im' : 'https://dev.natura.acme.im';
  return 'https://natura.acme.im';
}

String appCdnUrl() {
  // return kReleaseMode ? 'https://cdn.natura.acme.im' : 'https://cdn.dev.natura.acme.im';
  return 'https://cdn.natura.acme.im';
}

const String kRemoveAdsProductId = 'natura_remove_all_ads';

const String kGoogleMobileAdsFooterKeyAndroidTest = 'ca-app-pub-3940256099942544/6300978111';
const String kGoogleMobileAdsFooterKeyIosTest = 'ca-app-pub-3940256099942544/2934735716';
const String kGoogleMobileAdsTransitKeyAndroidTest = 'ca-app-pub-3940256099942544/8691691433';
const String kGoogleMobileAdsTransitKeyIosTest = 'ca-app-pub-3940256099942544/5135589807';

const String kGoogleMobileAdsFooterKeyAndroid = 'ca-app-pub-8541797843079117/5995147612';
const String kGoogleMobileAdsFooterKeyIos = 'ca-app-pub-8541797843079117/6805682310';
const String kGoogleMobileAdsTransitKeyAndroid = 'ca-app-pub-8541797843079117/7253156876';
const String kGoogleMobileAdsTransitKeyIos = 'ca-app-pub-8541797843079117/5584851983';

const String kFbanInterstitionalPlacementIdAndroid = '509982903780324_573954330716514';
const String kFbanInterstitionalPlacementIdIos = '509982903780324_573954027383211';

const int kDefaultSttResponseTimeout = 8;
const int kDefaultQuestionsToAsk = 10;
const double kDefaultValidResponsesPercent = 0.6;

class Conf {
  static SharedPreferences? _conf;

  factory Conf() => Conf._internal();

  Conf._internal();

  Future<void> init() async {
    _conf ??= await SharedPreferences.getInstance();
  }

  int get rateUsLastRequestedTimestamp => _conf!.getInt('rate_us_last_requested_timestamp') ?? 0;

  set rateUsLastRequestedTimestamp(int value) {
    _conf!.setInt('rate_us_last_requested_timestamp', value);
  }

  int get interviewCounter => _conf!.getInt('interview_counter') ?? 0;

  set interviewCounter(int value) {
    _conf!.setInt('interview_counter', value);
  }

  bool get isFirebaseEnabled {
    return kReleaseMode;
  }

  bool get showIntro {
    if (EnvConf.kShowIntro.isNotEmpty) {
      return EnvConf.kShowIntro.toLowerCase() == 'true';
    }
    return _conf!.getBool('show_intro') ?? true;
  }

  set showIntro(bool value) {
    _conf!.setBool('show_intro', value);
  }

  bool get is6520 => _conf!.getBool('is_6520') ?? false;

  set is6520(bool value) {
    _conf!.setBool('is_6520', value);
  }

  bool get showAds {
    if (EnvConf.kShowAds.isNotEmpty) {
      return EnvConf.kShowAds.toLowerCase() == 'true';
    }
    return _conf!.getBool('show_ads') ?? true;
  }

  set showAds(bool value) {
    _conf!.setBool('show_ads', value);
  }

  UsTerritoryInfo? get usTerritoryInfo {
    var usTerritoryInfoEnc = _conf!.getString('us_territory_info');
    return usTerritoryInfoEnc != null
        ? UsTerritoryInfo.fromJson(jsonDecode(usTerritoryInfoEnc) as Map<String, dynamic>)
        : null;
  }

  set usTerritoryInfo(UsTerritoryInfo? value) {
    value != null ? _conf!.setString('us_territory_info', jsonEncode(value)) : _conf!.remove('us_territory_info');
  }

  LocationAddress? get locationAddress {
    var locationAddressEnc = _conf!.getString('location_address');
    return locationAddressEnc != null
        ? LocationAddress.fromJson(jsonDecode(locationAddressEnc) as Map<String, dynamic>)
        : null;
  }

  set locationAddress(LocationAddress? value) {
    value != null ? _conf!.setString('location_address', jsonEncode(value)) : _conf!.remove('location_address');
  }

  bool get diversifyVoices {
    return _conf!.getBool('diversify_voices') ?? false;
  }

  set diversifyVoices(bool value) {
    _conf!.setBool('diversify_voices', value);
  }

  int get responseTimeout {
    return _conf!.getInt('response_timeout') ?? kDefaultSttResponseTimeout;
  }

  set responseTimeout(int value) {
    assert(value >= kDefaultSttResponseTimeout);
    _conf!.setInt('response_timeout', value);
  }

  int get questionsToAsk {
    return _conf!.getInt('questions_to_ask') ?? kDefaultQuestionsToAsk;
  }

  set questionsToAsk(int value) {
    assert(value > 0 && value <= 100);
    _conf!.setInt('questions_to_ask', value);
  }

  double get validResponsesPercent {
    return _conf!.getDouble('valid_responses_percent') ?? kDefaultValidResponsesPercent;
  }

  set validResponsesPercent(double value) {
    assert(value > 0 && value <= 1);
    _conf!.setDouble('valid_responses_percent', value);
  }
}
