import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/features/rewards/digital/digital_reward_error_localization.dart';
import 'package:kinquest/features/rewards/digital/digital_reward_service.dart';
import 'package:kinquest/l10n/app_localizations.dart';

void main() {
  testWidgets('reward failures stay Arabic and hide raw server messages', (
    tester,
  ) async {
    late String localizedMessage;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) {
            localizedMessage = localizedDigitalRewardError(
              context,
              const DigitalRewardException(
                DigitalRewardFailure.insufficientTokens,
                debugMessage: 'You do not have enough Tokens.',
              ),
            );
            return Text(localizedMessage);
          },
        ),
      ),
    );

    expect(localizedMessage, contains('رموز العائلة'));
    expect(localizedMessage, isNot(contains('Tokens')));
    expect(find.text(localizedMessage), findsOneWidget);
  });

  testWidgets('unknown technical errors use a safe localized fallback', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Text(
            localizedDigitalRewardError(
              context,
              StateError('private implementation detail'),
            ),
          ),
        ),
      ),
    );

    expect(
      find.text('Your reward could not be updated. No Tokens were spent.'),
      findsOneWidget,
    );
    expect(find.textContaining('private implementation detail'), findsNothing);
  });
}
