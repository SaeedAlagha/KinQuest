import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/features/authentication/screens/create_family_screen.dart';
import 'package:kinquest/l10n/app_localizations.dart';

void main() {
  testWidgets('invitation code starts hidden and can be shown and hidden', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(const InvitationCodeReveal(code: 'ABC123')),
    );

    expect(find.text('ABC123'), findsNothing);
    expect(
      find.byKey(const ValueKey('hidden-invitation-code')),
      findsOneWidget,
    );
    expect(find.byTooltip('Show invitation code'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('invitation-code-visibility-toggle')),
    );
    await tester.pumpAndSettle();

    expect(find.text('ABC123'), findsOneWidget);
    expect(find.byTooltip('Hide invitation code'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('invitation-code-visibility-toggle')),
    );
    await tester.pumpAndSettle();

    expect(find.text('ABC123'), findsNothing);
    expect(
      find.byKey(const ValueKey('hidden-invitation-code')),
      findsOneWidget,
    );
  });

  testWidgets('invitation code visibility control is localized in Arabic', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        const InvitationCodeReveal(code: 'ABC123'),
        locale: const Locale('ar'),
      ),
    );

    expect(find.byTooltip('إظهار رمز الدعوة'), findsOneWidget);
  });
}

Widget _testApp(Widget child, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Center(child: SizedBox(width: 360, child: child)),
    ),
  );
}
