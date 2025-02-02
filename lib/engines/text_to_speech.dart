import 'dart:io';
import 'dart:math';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:natura/utils/conf.dart';

enum TtsState { playing, stopped, paused, continued }

const double kDefaultVolume = 1.0;
const double kDefaultPitch = 1.0;
const double kDefaultRateAndroid = 0.5;
const double kDefaultRateIOS = 0.5;
const String kDefaultLanguage = 'en-US';
const Map<String, String> kDefaultVoice = {'name': 'en-us-x-iob-local', 'locale': 'en-US'};

class TextToSpeech {
  late FlutterTts _engine;

  final String _language = kDefaultLanguage;
  Map<String, String> _voice = kDefaultVoice;

  late List<Map<String, String>> _availableVoices;
  late List<String> _availableTtsEngines;

  final double _volume = kDefaultVolume;
  final double _pitch = kDefaultPitch;
  final double _rate = Platform.isAndroid ? kDefaultRateAndroid : kDefaultRateIOS;
  TtsState _state = TtsState.stopped;

  bool get isPlaying => _state == TtsState.playing;

  bool get isStopped => _state == TtsState.stopped;

  bool get isPaused => _state == TtsState.paused;

  bool get isContinued => _state == TtsState.continued;

  bool get isIOS => !kIsWeb && Platform.isIOS;

  bool get isAndroid => !kIsWeb && Platform.isAndroid;

  bool get isWeb => kIsWeb;
  bool isCurrentLanguageInstalled = false;

  Future<bool> init(final bool diversifyVoices) async {
    _engine = FlutterTts();

    if (isAndroid) {
      _availableTtsEngines = List<String>.from(await _engine.getEngines as Iterable<dynamic>);
      debugPrint('available engines:');
      for (var element in _availableTtsEngines) {
        debugPrint(element);
      }
    }

    if (!isWeb) {
      T? castOrNull<T>(dynamic x) => x is T ? x : null;
      var voices = castOrNull<Iterable<dynamic>>(await _engine.getVoices);
      if (voices != null) {
        var availVoices = List<Map<dynamic, dynamic>>.from(voices);
        _availableVoices = availVoices.map((voice) => Map<String, String>.from(voice)).toList();
        debugPrint('available voices:');
        for (Map<String, String> element in _availableVoices) {
          debugPrint(element.toString());
        }
      } else {
        return false;
      }
    }

    if (!(await _engine.isLanguageAvailable(kDefaultLanguage) as bool)) throw '$kDefaultLanguage language is missing';

    _engine.setStartHandler(() {
      debugPrint('Playing');
      _state = TtsState.playing;
    });

    _engine.setCompletionHandler(() {
      debugPrint('Complete');
      _state = TtsState.stopped;
    });

    _engine.setCancelHandler(() {
      debugPrint('Cancel');
      _state = TtsState.stopped;
    });

    if (isWeb || isIOS) {
      _engine.setPauseHandler(() {
        debugPrint('Paused');
        _state = TtsState.paused;
      });

      _engine.setContinueHandler(() {
        debugPrint('Continued');
        _state = TtsState.continued;
      });
    }

    _engine.setErrorHandler((dynamic msg) {
      debugPrint('error: $msg');
      _state = TtsState.stopped;
    });

    await _engine.setVolume(_volume);
    await _engine.setSpeechRate(_rate);
    await _engine.setPitch(_pitch);
    // should come before setVoice because it changes the default voice, or could it be dropped?
    await _engine.setLanguage(_language);
    if (_availableVoices.isNotEmpty) {
      // non-english (en-US/en-GB) voices speak numbers, dates etc in foreign languages
      // but we've updated all numbers with text repr in data.json so it's ok
      var suitableVoices = diversifyVoices
          ? _availableVoices.where((item) => item['name']!.length > 2 && !item['name']!.contains('language')).toList()
          : _availableVoices.where((item) => item['locale'] == kDefaultLanguage || item['locale'] == 'en-GB').toList();
      if (suitableVoices.isEmpty) {
        var error = 'no suitable voices (using default voice), available voices: $_availableVoices';
        debugPrint(error);
        if (Conf().isFirebaseEnabled) {
          await FirebaseCrashlytics.instance.log(error);
        }
      } else {
        _voice = suitableVoices[Random().nextInt(suitableVoices.length)];
        debugPrint('using voice: $_voice');
        await _engine.setVoice(_voice);
      }
    }
    await _engine.awaitSpeakCompletion(true);

    if (isIOS) {
      await _engine.setIosAudioCategory(IosTextToSpeechAudioCategory.playAndRecord, [
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
        IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
        IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        IosTextToSpeechAudioCategoryOptions.defaultToSpeaker
      ]);
    }

    return true;
  }

  Future<dynamic> speak(String text) async {
    debugPrint('${DateTime.now().millisecondsSinceEpoch} speak: $text');
    if (isIOS) {
      // otherwise volume drops to zero and category not defaults to speaker
      await _engine.setVolume(_volume);
      await _engine.setIosAudioCategory(IosTextToSpeechAudioCategory.playAndRecord, [
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
        IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
        IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        IosTextToSpeechAudioCategoryOptions.defaultToSpeaker
      ]);
    }
    return _engine.speak(text);
  }

  Future<dynamic> stop() async => await _engine.stop();
}
