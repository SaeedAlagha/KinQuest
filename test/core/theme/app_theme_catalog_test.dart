import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/core/theme/appearance_controller.dart';
import 'package:kinquest/core/theme/app_theme.dart';
import 'package:kinquest/core/theme/app_theme_catalog.dart';

void main() {
  test('every premium theme is unlocked only with Family Tokens', () {
    final premiumOffers = AppThemeCatalog.offers.where(
      (offer) => !offer.isIncluded,
    );

    expect(premiumOffers, hasLength(5));
    expect(
      premiumOffers.every(
        (offer) =>
            offer.accessType == ThemeAccessType.familyTokens &&
            (offer.tokenCost ?? 0) > 0,
      ),
      isTrue,
    );
    expect(
      premiumOffers.map((offer) => offer.tokenCost),
      orderedEquals([450, 650, 800, 950, 1100]),
    );
  });

  test('premium themes expose five distinct visual identities', () {
    final premiumAppearances = AppAppearance.values.where(
      (appearance) => !AppThemeCatalog.offerFor(appearance).isIncluded,
    );
    final visualStyles = premiumAppearances.map(
      (appearance) => AppTheme.forAppearance(
        appearance,
      ).extension<SilaThemeTokens>()!.visualStyle,
    );

    expect(visualStyles.toSet(), hasLength(5));
    expect(visualStyles, isNot(contains(SilaVisualStyle.classic)));
  });
}
