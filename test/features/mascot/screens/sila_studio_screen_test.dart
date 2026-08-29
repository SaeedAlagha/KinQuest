import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/core/mascot/sila_mascot.dart';
import 'package:kinquest/core/theme/app_theme.dart';
import 'package:kinquest/features/mascot/screens/sila_studio_screen.dart';
import 'package:kinquest/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('Sila Studio previews layered cosmetics and reactions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1180, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _app(const SilaStudioScreen(developerPreview: true)),
    );
    await _finishCatalogLoad(tester);
    await tester.pumpAndSettle();

    expect(find.text('Sila Studio'), findsOneWidget);
    expect(find.byKey(const ValueKey('sila-studio-mascot')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('sila-bond-progress-card')),
      findsOneWidget,
    );
    expect(find.text('Your Family Bond'), findsOneWidget);
    expect(find.text('Level 2: Family Friend'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('sila-mascot-accessory-guardian_crown')),
      findsWidgets,
    );
    expect(find.text('Headwear'), findsOneWidget);
    expect(find.byKey(const ValueKey('sila-chat-panel')), findsOneWidget);
    expect(find.text('Talk with Sila'), findsOneWidget);
    expect(find.textContaining('Private to your account'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('sila-motion-celebrate')));
    await tester.pump(const Duration(milliseconds: 300));
    final mascot = tester.widgetList<SilaMascot>(find.byType(SilaMascot)).first;
    expect(mascot.motion, SilaMascotMotion.celebrate);
    expect(
      find.text(
        'Amazing teamwork! Every moment together makes your bond stronger.',
      ),
      findsOneWidget,
    );

    await tester.tap(find.byKey(const ValueKey('sila-motion-excited')));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.byKey(const ValueKey('sila-speech-excited')), findsOneWidget);

    final outfitsCategory = find.byKey(const ValueKey('sila-category-outfits'));
    await tester.ensureVisible(outfitsCategory);
    await tester.tap(outfitsCategory);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('Game Night Jersey'), findsOneWidget);
    expect(find.text('Memory Keeper Kit'), findsOneWidget);

    await tester.ensureVisible(find.byKey(const ValueKey('sila-chat-input')));
    await tester.enterText(
      find.byKey(const ValueKey('sila-chat-input')),
      'What should we play?',
    );
    final sendButton = tester.widget<IconButton>(
      find.byKey(const ValueKey('sila-chat-send')),
    );
    expect(sendButton.onPressed, isNotNull);
    sendButton.onPressed!();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(const ValueKey('sila-chat-thinking')), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('What should we play?'), findsOneWidget);
    expect(find.byKey(const ValueKey('sila-chat-thinking')), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

Future<void> _finishCatalogLoad(WidgetTester tester) async {
  for (var frame = 0; frame < 5; frame += 1) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Widget _app(Widget home) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: TickerMode(enabled: false, child: home),
  );
}
