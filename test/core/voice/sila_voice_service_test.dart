import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/core/voice/sila_voice_service.dart';

void main() {
  test('stops previous speech before configured Arabic speech', () async {
    final engine = _FakeSpeechEngine();
    final service = SilaVoiceService(engine: engine, platformSupported: true);

    final result = await service.speak(
      text: '  مرحباً بالعائلة  ',
      languageCode: 'ar',
    );

    expect(result, SilaVoiceResult.spoken);
    expect(engine.calls, [
      'stop',
      'language:ar-AE',
      'configure:0.46:1.0:1.0',
      'speak:مرحباً بالعائلة',
    ]);
  });

  test('falls back through regional voices in a stable order', () async {
    final engine = _FakeSpeechEngine(
      languageAvailability: {'ar-AE': false, 'ar-SA': false, 'ar': true},
    );
    final service = SilaVoiceService(engine: engine, platformSupported: true);

    expect(
      await service.speak(text: 'أهلاً', languageCode: 'ar'),
      SilaVoiceResult.spoken,
    );
    expect(engine.calls.take(4), [
      'stop',
      'language:ar-AE',
      'language:ar-SA',
      'language:ar',
    ]);
  });

  test('reports unsupported when no matching voice is installed', () async {
    final engine = _FakeSpeechEngine(
      languageAvailability: {'en-AE': false, 'en-GB': false, 'en-US': false},
    );
    final service = SilaVoiceService(engine: engine, platformSupported: true);

    expect(
      await service.speak(text: 'Hello', languageCode: 'en'),
      SilaVoiceResult.unsupported,
    );
    expect(engine.calls, [
      'stop',
      'language:en-AE',
      'language:en-GB',
      'language:en-US',
    ]);
  });

  test('empty speech and unsupported platforms fail gracefully', () async {
    final engine = _FakeSpeechEngine();
    final supported = SilaVoiceService(engine: engine, platformSupported: true);
    final unsupported = SilaVoiceService(
      engine: engine,
      platformSupported: false,
    );

    expect(
      await supported.speak(text: '  ', languageCode: 'en'),
      SilaVoiceResult.empty,
    );
    expect(
      await unsupported.speak(text: 'Hello', languageCode: 'en'),
      SilaVoiceResult.unsupported,
    );
    expect(engine.calls, isEmpty);
  });

  test(
    'a missing platform plugin returns unsupported instead of throwing',
    () async {
      final service = SilaVoiceService(
        engine: _FakeSpeechEngine(error: MissingPluginException()),
        platformSupported: true,
      );

      expect(
        await service.speak(text: 'Hello', languageCode: 'en'),
        SilaVoiceResult.unsupported,
      );
    },
  );

  test('stop interrupts the active request and dispose is safe', () async {
    final engine = _FakeSpeechEngine();
    final service = SilaVoiceService(engine: engine, platformSupported: true);

    expect(await service.stop(), SilaVoiceResult.stopped);
    service.dispose();
    expect(service.isSupported, isFalse);
    expect(
      await service.speak(text: 'Hello', languageCode: 'en'),
      SilaVoiceResult.unsupported,
    );
  });

  test('platform support is explicit and testable', () {
    expect(
      SilaVoiceService.supportsPlatform(
        isWeb: false,
        platform: TargetPlatform.android,
      ),
      isTrue,
    );
    expect(
      SilaVoiceService.supportsPlatform(
        isWeb: false,
        platform: TargetPlatform.linux,
      ),
      isFalse,
    );
    expect(
      SilaVoiceService.supportsPlatform(
        isWeb: true,
        platform: TargetPlatform.linux,
      ),
      isTrue,
    );
  });
}

class _FakeSpeechEngine implements SilaSpeechEngine {
  _FakeSpeechEngine({this.error, this.languageAvailability = const {}});

  final Object? error;
  final Map<String, bool> languageAvailability;
  final List<String> calls = [];

  void _throwIfNeeded() {
    final value = error;
    if (value != null) throw value;
  }

  @override
  Future<void> configure({
    required double speechRate,
    required double pitch,
    required double volume,
  }) async {
    _throwIfNeeded();
    calls.add('configure:$speechRate:$pitch:$volume');
  }

  @override
  Future<bool> selectLanguage(String language) async {
    _throwIfNeeded();
    calls.add('language:$language');
    return languageAvailability[language] ?? true;
  }

  @override
  Future<void> speak(String text) async {
    _throwIfNeeded();
    calls.add('speak:$text');
  }

  @override
  Future<void> stop() async {
    _throwIfNeeded();
    calls.add('stop');
  }
}
