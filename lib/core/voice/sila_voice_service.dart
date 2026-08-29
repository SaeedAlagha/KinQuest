import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

abstract interface class SilaSpeechEngine {
  Future<void> stop();

  Future<bool> selectLanguage(String language);

  Future<void> configure({
    required double speechRate,
    required double pitch,
    required double volume,
  });

  Future<void> speak(String text);
}

class FlutterTtsSpeechEngine implements SilaSpeechEngine {
  FlutterTtsSpeechEngine({FlutterTts? flutterTts})
    : _flutterTts = flutterTts ?? FlutterTts();

  final FlutterTts _flutterTts;

  @override
  Future<bool> selectLanguage(String language) async {
    final result = await _flutterTts.setLanguage(language);
    if (result == 0 || result == false) return false;
    // Android and Apple platforms return 1/0. Some supported engines return
    // no value, so only an explicit rejection should trigger a fallback.
    return true;
  }

  @override
  Future<void> configure({
    required double speechRate,
    required double pitch,
    required double volume,
  }) async {
    await _flutterTts.awaitSpeakCompletion(true);
    await _flutterTts.setSpeechRate(speechRate);
    await _flutterTts.setPitch(pitch);
    await _flutterTts.setVolume(volume);
  }

  @override
  Future<void> speak(String text) async {
    await _flutterTts.speak(text);
  }

  @override
  Future<void> stop() async {
    await _flutterTts.stop();
  }
}

enum SilaVoiceResult {
  spoken,
  stopped,
  empty,
  interrupted,
  unsupported,
  failed,
}

class SilaVoiceService {
  SilaVoiceService({SilaSpeechEngine? engine, bool? platformSupported})
    : _engine = engine ?? FlutterTtsSpeechEngine(),
      _platformSupported =
          platformSupported ??
          supportsPlatform(isWeb: kIsWeb, platform: defaultTargetPlatform);

  final SilaSpeechEngine _engine;
  final bool _platformSupported;

  bool _disposed = false;
  int _requestVersion = 0;

  bool get isSupported => _platformSupported && !_disposed;

  static bool supportsPlatform({
    required bool isWeb,
    required TargetPlatform platform,
  }) {
    if (isWeb) return true;
    return switch (platform) {
      TargetPlatform.android ||
      TargetPlatform.iOS ||
      TargetPlatform.macOS ||
      TargetPlatform.windows => true,
      TargetPlatform.fuchsia || TargetPlatform.linux => false,
    };
  }

  Future<SilaVoiceResult> speak({
    required String text,
    required String languageCode,
  }) async {
    final normalizedText = text.trim();
    if (normalizedText.isEmpty) return SilaVoiceResult.empty;
    if (!isSupported) return SilaVoiceResult.unsupported;

    final requestVersion = ++_requestVersion;

    try {
      // Stopping first prevents a previous response from talking over the next.
      await _engine.stop();
      if (!_isCurrent(requestVersion)) return SilaVoiceResult.interrupted;

      final languageSelected = await _selectLanguage(languageCode);
      if (!languageSelected) return SilaVoiceResult.unsupported;
      if (!_isCurrent(requestVersion)) return SilaVoiceResult.interrupted;

      await _engine.configure(speechRate: 0.46, pitch: 1, volume: 1);
      if (!_isCurrent(requestVersion)) return SilaVoiceResult.interrupted;

      await _engine.speak(normalizedText);
      return _isCurrent(requestVersion)
          ? SilaVoiceResult.spoken
          : SilaVoiceResult.interrupted;
    } on MissingPluginException {
      return SilaVoiceResult.unsupported;
    } on PlatformException {
      return SilaVoiceResult.failed;
    } on Object {
      return SilaVoiceResult.failed;
    }
  }

  Future<SilaVoiceResult> stop() async {
    _requestVersion += 1;
    if (!isSupported) return SilaVoiceResult.unsupported;

    try {
      await _engine.stop();
      return SilaVoiceResult.stopped;
    } on MissingPluginException {
      return SilaVoiceResult.unsupported;
    } on Object {
      return SilaVoiceResult.failed;
    }
  }

  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _requestVersion += 1;
    unawaited(_stopSilently());
  }

  bool _isCurrent(int requestVersion) {
    return !_disposed && requestVersion == _requestVersion;
  }

  Future<bool> _selectLanguage(String languageCode) async {
    final candidates = languageCode.trim().toLowerCase().startsWith('ar')
        ? const ['ar-AE', 'ar-SA', 'ar']
        : const ['en-AE', 'en-GB', 'en-US'];
    for (final candidate in candidates) {
      if (await _engine.selectLanguage(candidate)) return true;
    }
    return false;
  }

  Future<void> _stopSilently() async {
    if (!_platformSupported) return;
    try {
      await _engine.stop();
    } on Object {
      // A platform channel may already be unavailable during app teardown.
    }
  }
}
