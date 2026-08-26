import 'package:flutter/widgets.dart';

import '../../../l10n/app_localizations.dart';
import 'digital_reward_service.dart';

String localizedDigitalRewardError(BuildContext context, Object error) {
  final strings = AppLocalizations.of(context)!;
  final failure = error is DigitalRewardException
      ? error.failure
      : DigitalRewardFailure.updateFailed;

  return switch (failure) {
    DigitalRewardFailure.signInRequired => strings.digitalRewardSignInRequired,
    DigitalRewardFailure.unavailable => strings.digitalRewardUnavailable,
    DigitalRewardFailure.userNotFound => strings.digitalRewardUserNotFound,
    DigitalRewardFailure.familyRequired => strings.digitalRewardFamilyRequired,
    DigitalRewardFailure.familyNotFound => strings.digitalRewardFamilyNotFound,
    DigitalRewardFailure.notFamilyMember =>
      strings.digitalRewardNotFamilyMember,
    DigitalRewardFailure.alreadyOwned => strings.digitalRewardAlreadyOwned,
    DigitalRewardFailure.insufficientTokens =>
      strings.digitalRewardInsufficientTokens,
    DigitalRewardFailure.notOwned => strings.digitalRewardNotOwned,
    DigitalRewardFailure.invalidReward => strings.digitalRewardInvalid,
    DigitalRewardFailure.updateFailed => strings.digitalRewardUpdateFailed,
  };
}
