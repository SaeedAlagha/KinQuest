import 'appearance_controller.dart';

enum ThemeAccessType { included, familyTokens }

class AppThemeOffer {
  const AppThemeOffer({
    required this.appearance,
    required this.accessType,
    this.tokenCost,
  });

  final AppAppearance appearance;
  final ThemeAccessType accessType;
  final int? tokenCost;

  bool get isIncluded => accessType == ThemeAccessType.included;
}

abstract final class AppThemeCatalog {
  static const offers = <AppThemeOffer>[
    AppThemeOffer(
      appearance: AppAppearance.light,
      accessType: ThemeAccessType.included,
    ),
    AppThemeOffer(
      appearance: AppAppearance.dark,
      accessType: ThemeAccessType.included,
    ),
    AppThemeOffer(
      appearance: AppAppearance.familyYear2026,
      accessType: ThemeAccessType.familyTokens,
      tokenCost: 450,
    ),
    AppThemeOffer(
      appearance: AppAppearance.space,
      accessType: ThemeAccessType.familyTokens,
      tokenCost: 650,
    ),
    AppThemeOffer(
      appearance: AppAppearance.khalifaUniversity,
      accessType: ThemeAccessType.familyTokens,
      tokenCost: 800,
    ),
    AppThemeOffer(
      appearance: AppAppearance.desertNights,
      accessType: ThemeAccessType.familyTokens,
      tokenCost: 950,
    ),
    AppThemeOffer(
      appearance: AppAppearance.pearlLagoon,
      accessType: ThemeAccessType.familyTokens,
      tokenCost: 1100,
    ),
  ];

  static AppThemeOffer offerFor(AppAppearance appearance) {
    return offers.firstWhere((offer) => offer.appearance == appearance);
  }
}
