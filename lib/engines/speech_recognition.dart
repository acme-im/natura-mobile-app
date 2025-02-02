import 'dart:async';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:natura/utils/conf.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

/*
Wraps SpeechToText engine so client gets only 'sound level' and 'status' updates through the callbacks
(mostly for the mic animation);
Client then gets the rest of updates (recognition results and errors) from recognize();
*/

typedef SpeechStatusListener = void Function(String status);
typedef SpeechSoundLevelChangeListener = void Function(double level);

final String defaultLocale = Platform.isAndroid ? 'en_US' : 'en-US';

class SpeechRecognition {
  bool get isListening => _engine.isListening;

  String get lastWords => _engine.lastRecognizedWords;

  String get lastError => _engine.lastError!.errorMsg;

  String get lastStatus => _engine.lastStatus;

  final SpeechToText _engine = SpeechToText();

  late Completer<SpeechRecognitionResult> _completer;

  SpeechStatusListener? _extStatusListener;
  SpeechSoundLevelChangeListener? _extSoundLevelChangeListener;

  Future<bool> init(SpeechStatusListener slCb, SpeechSoundLevelChangeListener sslclCb) async {
    var hasSpeech = await _engine.initialize(
      onError: _errorListener,
      onStatus: _statusListener,
      debugLogging: false,
      finalTimeout: Duration(milliseconds: 500),
    );
    // TODO: handle "Speech Service is disabled" - https://github.com/csdcorp/speech_to_text/issues/36
    // show help message to user
    if (hasSpeech) {
      _extSoundLevelChangeListener = sslclCb;
      _extStatusListener = slCb;
      var locales = await _engine.locales();
      if (!locales.any((element) => element.localeId == defaultLocale)) {
        if (Conf().isFirebaseEnabled) await FirebaseCrashlytics.instance.log('$defaultLocale locale is unavailable');
        hasSpeech = false;
      }
    }
    // TODO: how ListenDuration and PauseDuration relate to each other?
    return hasSpeech;
  }

  Future<SpeechRecognitionResult> recognize(final int listenDuration) {
    assert(listenDuration >= kDefaultSttResponseTimeout);
    _completer = Completer();
    _engine.listen(
        onResult: _resultListener,
        pauseFor: Duration(seconds: listenDuration - (Platform.isAndroid ? 2 : 4)),
        listenFor: Duration(seconds: listenDuration),
        partialResults: false,
        localeId: defaultLocale,
        onSoundLevelChange: _soundLevelListener,
        cancelOnError: true,
        listenMode: ListenMode.confirmation);
    return _completer.future; // Send future object back to the client so it can 'await'
  }

  void _errorListener(SpeechRecognitionError error) {
    debugPrint('_errorListener: $error, listening: ${_engine.isListening}');
    assert(!_completer.isCompleted);
    _completer.completeError(error);
  }

  void _statusListener(String status) {
    debugPrint('_statusListener: $status, listening: ${_engine.isListening}');
    if (_extStatusListener != null) {
      _extStatusListener!(status); // update client
    }
  }

  void _resultListener(SpeechRecognitionResult result) {
    // TODO: do not sort, results with worse confidence are somehow more relevant (e.g. for numbers)
    // result.alternates.sort((b, a) => a.confidence.compareTo(b.confidence));
    if (!result.finalResult) {
      throw 'only final results are expected here';
    }
    debugPrint('_resultListener: $result');
    assert(!_completer.isCompleted);
    _completer.complete(result);
  }

  void _soundLevelListener(double level) {
    // debugLog('_soundLevelListener: $level');
    if (_extSoundLevelChangeListener != null) {
      const kSoundLevelMax = 10.0;
      var levelNormalized = 0.0;
      if (Platform.isAndroid) {
        // Android level: [-2; 10]
        levelNormalized = level;
      } else {
        // iOS level: [-13; -81]
        levelNormalized = level.abs() % kSoundLevelMax;
      }
      _extSoundLevelChangeListener!(levelNormalized); // update client
    }
  }

  Future<void> stop() async {
    return await _engine.cancel();
  }
}
