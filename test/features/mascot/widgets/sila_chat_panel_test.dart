import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:kinquest/core/theme/app_theme.dart';
import 'package:kinquest/core/voice/sila_voice_service.dart';
import 'package:kinquest/features/mascot/models/sila_chat_message.dart';
import 'package:kinquest/features/mascot/services/sila_chat_service.dart';
import 'package:kinquest/features/mascot/widgets/sila_chat_panel.dart';
import 'package:kinquest/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets(
    'developer preview stays local and sends a complete conversation',
    (tester) async {
      var networkRequests = 0;
      final chatService = _chatService(
        MockClient((_) async {
          networkRequests += 1;
          return http.Response('{}', 500);
        }),
      );

      await tester.pumpWidget(
        _app(
          SilaChatPanel(
            developerPreview: true,
            chatService: chatService,
            voiceService: SilaVoiceService(
              engine: _RecordingSpeechEngine(),
              platformSupported: false,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('sila-chat-input')),
        'What should we play?',
      );
      await tester.tap(find.byKey(const ValueKey('sila-chat-send')));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byKey(const ValueKey('sila-chat-thinking')), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('What should we play?'), findsOneWidget);
      expect(find.byKey(const ValueKey('sila-chat-thinking')), findsNothing);
      expect(networkRequests, 0);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Arabic chat stays usable at 320px and 200% text scaling', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _app(
        SilaChatPanel(
          developerPreview: true,
          voiceService: SilaVoiceService(
            engine: _RecordingSpeechEngine(),
            platformSupported: false,
          ),
        ),
        locale: const Locale('ar'),
        textScaler: const TextScaler.linear(2),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final title = find.text('تحدث مع صلة');
    expect(title, findsOneWidget);
    expect(Directionality.of(tester.element(title)), TextDirection.rtl);
    expect(find.byKey(const ValueKey('sila-chat-input')), findsOneWidget);
    expect(find.byTooltip('إرسال إلى صلة'), findsOneWidget);

    const previewReply =
        'أنا هنا! لنختر لعبة أو نخطط للحظة عائلية جميلة أو نحتفل بإنجاز حققتموه معًا.';
    final reply = find.text(previewReply);
    final avatar = find.byType(CircleAvatar);
    expect(reply, findsOneWidget);
    expect(avatar, findsOneWidget);
    expect(
      tester.getCenter(avatar).dx,
      greaterThan(tester.getCenter(reply).dx),
    );
    expect(
      tester
          .widgetList<Row>(find.ancestor(of: reply, matching: find.byType(Row)))
          .where((row) => row.textDirection == TextDirection.ltr),
      isEmpty,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'load and send lock the composer and clear action and expose live updates',
    (tester) async {
      final history = Completer<List<SilaChatMessage>>();
      final send = Completer<SilaChatExchange>();
      final chatService = _FakeChatService(
        onLoad: () => history.future,
        onSend: (_, _) => send.future,
      );

      await tester.pumpWidget(
        _app(
          SilaChatPanel(
            chatService: chatService,
            voiceService: SilaVoiceService(
              engine: _RecordingSpeechEngine(),
              platformSupported: false,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(_chatInput(tester).enabled, isFalse);
      expect(_sendButton(tester).onPressed, isNull);
      expect(_clearButton(tester).onPressed, isNull);

      history.complete([
        const SilaChatMessage(
          id: 'history-reply',
          role: SilaChatRole.assistant,
          content: 'Welcome back.',
          pose: SilaChatPose.welcome,
        ),
      ]);
      await tester.pumpAndSettle();

      expect(_chatInput(tester).enabled, isTrue);
      expect(_clearButton(tester).onPressed, isNotNull);

      await tester.enterText(
        find.byKey(const ValueKey('sila-chat-input')),
        'Plan a family game',
      );
      await tester.tap(find.byKey(const ValueKey('sila-chat-send')));
      await tester.pump();

      expect(_chatInput(tester).enabled, isFalse);
      expect(_sendButton(tester).onPressed, isNull);
      expect(_clearButton(tester).onPressed, isNull);
      expect(_hasLiveRegionLabel(tester, 'Sila is thinking…'), isTrue);

      send.complete(
        _exchange(
          prompt: 'Plan a family game',
          reply: 'Try a five-round emoji challenge together!',
        ),
      );
      await tester.pumpAndSettle();

      expect(_chatInput(tester).enabled, isTrue);
      expect(_clearButton(tester).onPressed, isNotNull);
      expect(
        _hasLiveRegionLabel(
          tester,
          'Try a five-round emoji challenge together!',
        ),
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('a stale history completion cannot replace newer state', (
    tester,
  ) async {
    final staleHistory = Completer<List<SilaChatMessage>>();
    final currentHistory = Completer<List<SilaChatMessage>>();
    var loadCount = 0;
    final chatService = _FakeChatService(
      onLoad: () {
        loadCount += 1;
        return switch (loadCount) {
          1 => Future<List<SilaChatMessage>>.error(
            StateError('initial load failed'),
          ),
          2 => staleHistory.future,
          _ => currentHistory.future,
        };
      },
    );

    await tester.pumpWidget(
      _app(
        SilaChatPanel(
          chatService: chatService,
          voiceService: SilaVoiceService(
            engine: _RecordingSpeechEngine(),
            platformSupported: false,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    final retry = find.text('Try Again');
    expect(retry, findsOneWidget);

    // Both callbacks run before a frame rebuild disables/replaces the button.
    await tester.tap(retry);
    await tester.tap(retry);
    expect(loadCount, 3);

    currentHistory.complete([
      const SilaChatMessage(
        id: 'current',
        role: SilaChatRole.assistant,
        content: 'Newest family context',
      ),
    ]);
    await tester.pump();
    staleHistory.complete([
      const SilaChatMessage(
        id: 'stale',
        role: SilaChatRole.assistant,
        content: 'Outdated family context',
      ),
    ]);
    await tester.pumpAndSettle();

    expect(find.text('Newest family context'), findsOneWidget);
    expect(find.text('Outdated family context'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('family and rate-limit failures have useful localized guidance', (
    tester,
  ) async {
    final familyRequiredService = _FakeChatService(
      onLoad: () => Future<List<SilaChatMessage>>.error(
        const SilaChatException(SilaChatFailure.familyRequired),
      ),
    );

    await tester.pumpWidget(
      _app(
        SilaChatPanel(
          chatService: familyRequiredService,
          voiceService: SilaVoiceService(
            engine: _RecordingSpeechEngine(),
            platformSupported: false,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.text('Join or create a family before chatting with Sila.'),
      findsOneWidget,
    );

    final rateLimitedService = _FakeChatService(
      onLoad: () async => const [],
      onSend: (_, _) => Future<SilaChatExchange>.error(
        const SilaChatException(SilaChatFailure.rateLimited),
      ),
    );
    await tester.pumpWidget(
      _app(
        SilaChatPanel(
          key: const ValueKey('rate-limited-panel'),
          chatService: rateLimitedService,
          voiceService: SilaVoiceService(
            engine: _RecordingSpeechEngine(),
            platformSupported: false,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.enterText(
      find.byKey(const ValueKey('sila-chat-input')),
      'One more idea',
    );
    final sendButton = _sendButton(tester);
    expect(sendButton.onPressed, isNotNull);
    sendButton.onPressed!();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.text('Sila needs a quick pause. Try again in about a minute.'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'unsupported device voice shows localized notice and disables controls',
    (tester) async {
      const preferenceKey = 'sila_chat_auto_voice_developer-preview';
      SharedPreferences.setMockInitialValues({preferenceKey: true});
      final engine = _RecordingSpeechEngine(languageAvailable: false);

      await tester.pumpWidget(
        _app(
          SilaChatPanel(
            developerPreview: true,
            voiceService: SilaVoiceService(
              engine: engine,
              platformSupported: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
      await tester.tap(find.byTooltip('Listen to this reply'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(
        find.text(
          'A compatible English or Arabic voice is not available on this '
          'device. You can still read every reply.',
        ),
        findsOneWidget,
      );
      expect(find.byTooltip('Listen to this reply'), findsNothing);
      expect(tester.widget<Switch>(find.byType(Switch)).onChanged, isNull);

      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getBool(preferenceKey), isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('disposing the panel stops an injected device voice', (
    tester,
  ) async {
    final engine = _RecordingSpeechEngine();
    final voiceService = SilaVoiceService(
      engine: engine,
      platformSupported: true,
    );

    await tester.pumpWidget(
      _app(SilaChatPanel(developerPreview: true, voiceService: voiceService)),
    );
    await tester.pumpAndSettle();
    final stopsBeforeDispose = engine.stopCount;

    await tester.pumpWidget(_app(const SizedBox.shrink()));
    await tester.pump();

    expect(engine.stopCount, stopsBeforeDispose + 1);
    expect(tester.takeException(), isNull);
  });
}

SilaChatService _chatService(http.Client client) {
  return SilaChatService(
    client: client,
    endpointBuilder: (path) => Uri.parse('https://api.sila.test$path'),
    headersProvider: () async => {'Authorization': 'Bearer test-token'},
  );
}

TextField _chatInput(WidgetTester tester) {
  return tester.widget<TextField>(
    find.byKey(const ValueKey('sila-chat-input')),
  );
}

IconButton _sendButton(WidgetTester tester) {
  return tester.widget<IconButton>(
    find.byKey(const ValueKey('sila-chat-send')),
  );
}

IconButton _clearButton(WidgetTester tester) {
  return tester.widget<IconButton>(
    find.widgetWithIcon(IconButton, Icons.delete_sweep_outlined),
  );
}

bool _hasLiveRegionLabel(WidgetTester tester, String label) {
  return tester
      .widgetList<Semantics>(find.byType(Semantics))
      .any(
        (semantics) =>
            semantics.properties.liveRegion == true &&
            semantics.properties.label == label,
      );
}

SilaChatExchange _exchange({required String prompt, required String reply}) {
  return SilaChatExchange(
    userMessage: SilaChatMessage.user(
      id: 'server-user',
      content: prompt,
      createdAt: DateTime.utc(2026, 8, 29),
    ),
    silaMessage: SilaChatMessage(
      id: 'server-reply',
      role: SilaChatRole.assistant,
      content: reply,
      pose: SilaChatPose.encouraging,
      createdAt: DateTime.utc(2026, 8, 29),
    ),
  );
}

Widget _app(
  Widget child, {
  Locale locale = const Locale('en'),
  TextScaler textScaler = TextScaler.noScaling,
}) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    locale: locale,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: MediaQuery(
      data: MediaQueryData(textScaler: textScaler),
      child: Scaffold(body: SingleChildScrollView(child: child)),
    ),
  );
}

class _FakeChatService extends SilaChatService {
  _FakeChatService({required this.onLoad, this.onSend})
    : super(
        client: MockClient((_) async => http.Response('{}', 500)),
        endpointBuilder: (path) => Uri.parse('https://api.sila.test$path'),
        headersProvider: () async => {'Authorization': 'Bearer test-token'},
      );

  final Future<List<SilaChatMessage>> Function() onLoad;
  final Future<SilaChatExchange> Function(String message, String languageCode)?
  onSend;

  @override
  Future<List<SilaChatMessage>> loadHistory() => onLoad();

  @override
  Future<SilaChatExchange> sendMessage({
    required String message,
    required String languageCode,
  }) {
    final callback = onSend;
    if (callback == null) {
      return Future<SilaChatExchange>.error(
        StateError('Unexpected sendMessage call'),
      );
    }
    return callback(message, languageCode);
  }

  @override
  Future<int> clearHistory() => Future<int>.value(0);
}

class _RecordingSpeechEngine implements SilaSpeechEngine {
  _RecordingSpeechEngine({this.languageAvailable = true});

  final bool languageAvailable;
  int stopCount = 0;

  @override
  Future<void> configure({
    required double pitch,
    required double speechRate,
    required double volume,
  }) async {}

  @override
  Future<bool> selectLanguage(String language) async => languageAvailable;

  @override
  Future<void> speak(String text) async {}

  @override
  Future<void> stop() async {
    stopCount += 1;
  }
}
