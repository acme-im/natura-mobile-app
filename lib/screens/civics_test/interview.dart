import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:natura/engines/speech_recognition.dart';
import 'package:natura/engines/text_to_speech.dart';
import 'package:natura/models/civics_test.dart';
import 'package:natura/models/civics_test_responses.dart';
import 'package:natura/screens/civics_test/results.dart';
import 'package:natura/utils/conf.dart';
import 'package:natura/utils/misc.dart';
import 'package:natura/widgets/civics_test/answering.dart';
import 'package:natura/widgets/civics_test/main.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

const int kInterstitialMaxFailedLoadAttempts = 3;
const int kShowRecognizedResponseSecs = 2;

class CivicsTestInterviewScreen extends StatefulWidget {
  static const routePath = '/civics_test/interview';

  const CivicsTestInterviewScreen({super.key});

  @override
  _CivicsTestInterviewScreenState createState() => _CivicsTestInterviewScreenState();
}

class _CivicsTestInterviewScreenState extends State<CivicsTestInterviewScreen> {
  bool _initialized = false;

  final TextToSpeech _textToSpeech = TextToSpeech();

  // must be static (otherwise callbacks to the old, non-existing object will be triggered after new instance created)
  static final SpeechRecognition _speechToText = SpeechRecognition();

  AnsweringState _answeringState = AnsweringState(false, '...', Conf().questionsToAsk);

  late CivicsTest _questionnaire;
  late CivicsTestResponses _responses;

  InterstitialAd? _interstitialAd;
  bool _interstitialReady = false;
  int _numInterstitialLoadAttempts = 0;

  final int _responseTimeout = Conf().responseTimeout;

  void statusListener(String status) {}

  void soundLevelListener(double level) {
    setState(() {
      // animate mic
      _answeringState.soundLevel = level;
    });
  }

  void _createInterstitialAd() {
    String strAdUnitId = Platform.isAndroid ? kGoogleMobileAdsTransitKeyAndroid : kGoogleMobileAdsTransitKeyIos;
    String testAdUnitId = Platform.isAndroid ? kGoogleMobileAdsTransitKeyAndroidTest : kGoogleMobileAdsTransitKeyIosTest;
    String adUnitId = kReleaseMode ? strAdUnitId : testAdUnitId;

    InterstitialAd.load(
        adUnitId: adUnitId,
        request: AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            if (kDebugMode) {
              print('$ad loaded');
            }
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            _interstitialReady = true;
          },
          onAdFailedToLoad: (LoadAdError error) {
            if (kDebugMode) {
              print('InterstitialAd failed to load: $error.');
            }
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            _interstitialReady = false;
            if (_numInterstitialLoadAttempts <= kInterstitialMaxFailedLoadAttempts) {
              _createInterstitialAd();
            }
          },
        ));
  }

  @override
  void dispose() {
    _speechToText.stop().then((_) {
      _textToSpeech.stop();
    });
    WakelockPlus.disable();
    _interstitialAd?.dispose();
    super.dispose();
  }

  void _startInterviewLoop() async {
    await logEvent(name: 'civics_test_start');
    Conf().interviewCounter++;
    var usTerritoryInfo = Conf().usTerritoryInfo;
    _questionnaire = await CivicsTest.fromUrl(
        state: usTerritoryInfo?.abbr, representative: usTerritoryInfo?.representative, is6520: Conf().is6520);
    if (Conf().showAds) _createInterstitialAd();
    _responses = CivicsTestResponses(Conf().questionsToAsk, Conf().validResponsesPercent);
    _answeringState = AnsweringState(false, '', Conf().questionsToAsk);
    var fin = false;
    while (mounted && !fin && _answeringState.curQuestionNum <= _responses.questionsToAsk) {
      var q = _questionnaire.next();
      setState(() {
        _answeringState.lastWords = '...';
        _answeringState.isAnswerValid = null;
        _answeringState.curQuestionNum++;
      });
      var success = false;
      while (mounted && !fin && !success) {
        try {
          setState(() {
            _answeringState.isAnswering = false;
          });
          await _textToSpeech.speak(q.textTts ?? q.text);
          setState(() {
            _answeringState.isAnswering = true;
          });

          SpeechRecognitionResult? result;
          await _speechToText.recognize(_responseTimeout).then((SpeechRecognitionResult data) async {
            if (data.recognizedWords.isEmpty) {
              await logEvent(name: 'speech_recognition_empty_text');
              throw 'nothing was recognized'; // this happens on Samsung Galaxy S10e
            }
            result = data;
          }).timeout(Duration(seconds: _responseTimeout + 5), onTimeout: () async {
            // using timeout is a temp workaround for iOS bug (https://github.com/csdcorp/speech_to_text/issues/218)
            await logEvent(name: 'speech_recognition_timeout');
            throw 'timeout';
          });

          _responses.add(q, result!.recognizedWords);
          setState(() {
            _answeringState.lastWords = result!.recognizedWords;
            _answeringState.isAnswerValid = _responses.responses.last.isAnswerValid();
          });
          if (_responses.responses.last.isAnswerValid()) {
            await logEvent(name: 'civics_test_answer_valid');
          } else {
            await logEvent(name: 'civics_test_answer_invalid');
          }

          if (_responses.isFailed || _responses.isPassed) {
            if (Conf().showAds && _interstitialReady) {
              await _interstitialAd!.show();
              _interstitialReady = false;
              _interstitialAd = null;
            }
            if (_responses.isPassed) {
              await logEvent(name: 'civics_test_complete_success');
            } else if (_responses.isFailed) {
              await logEvent(name: 'civics_test_complete_fail');
            }
            fin = true;
            await Navigator.pushNamed(context, CivicsTestResultsScreen.routePath, arguments: _responses).then((_) {
              _startInterviewLoop();
            });
            return;
          }
          success = true;
          await logEvent(name: 'speech_recognition_success');
        } catch (e) {
          debugPrint(e.toString());
          await _speechToText.stop();
          if (!mounted) return;
          await _textToSpeech.speak("Sorry, I didn't get that, please try again.");
          await logEvent(name: 'speech_recognition_error');
        }
        // so user is able to see a recognized text for a moment
        await Future<void>.delayed(Duration(seconds: kShowRecognizedResponseSecs));
      }
    }
  }

  void showSpeechNotAvailableDialog() {
    String errMsg = '  Speech recognition feature is not available on this device.\n';
    if (Platform.isAndroid) {
      errMsg += '  The Play Store must be installed and Android 5 or later must be used.';
    }
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Error'),
        content: Text(errMsg),
      ),
    );
  }

  Future<void> _initEverything() async {
    if (kDebugMode) {
      print('interview screen: init started');
    }
    WakelockPlus.enable(); // when device deactivates - speech recognizer becomes unavailable
    bool speechRecAvail = false;
    try {
      speechRecAvail = await _speechToText.init(statusListener, soundLevelListener);
    } catch(e) {
      showSpeechNotAvailableDialog();
      await logEvent(name: 'speech_recognition_not_available');
      throw 'speech recognizer is not available';
    }
    if (!speechRecAvail) {
      showSpeechNotAvailableDialog();
      await logEvent(name: 'speech_recognition_not_available');
      throw 'speech recognizer is not available';
    }
    if (!(await _textToSpeech.init(Conf().diversifyVoices))) {
      await logEvent(name: 'text_reader_not_available');
      throw 'text reader is not available';
    }
    if (kDebugMode) {
      print('interview screen: init completed');
    }
    return;
  }

  @override
  void initState() {
    super.initState();
    _initEverything().then((void _) {
      setState(() {
        _initialized = true;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startInterviewLoop();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Interview'),
      ),
      body: _initialized
          ? CivicsTestMainWidget(
              _answeringState,
            )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
