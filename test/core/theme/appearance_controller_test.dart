import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/core/theme/appearance_controller.dart';
import 'package:kinquest/core/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'loads included themes and persists an unlocked premium theme',
    () async {
      SharedPreferences.setMockInitialValues({
        AppearanceController.preferenceKey: AppAppearance.dark.name,
      });
      final controller = AppearanceController();
      addTearDown(controller.dispose);

      await controller.load();
      expect(controller.appearance, AppAppearance.dark);

      expect(
        await controller.setAppearance(AppAppearance.familyYear2026),
        isFalse,
      );
      expect(controller.appearance, AppAppearance.dark);

      await controller.registerUnlocked([AppAppearance.familyYear2026]);
      expect(
        await controller.setAppearance(AppAppearance.familyYear2026),
        isTrue,
      );

      final preferences = await SharedPreferences.getInstance();
      expect(
        preferences.getString(AppearanceController.preferenceKey),
        AppAppearance.familyYear2026.name,
      );
      expect(
        preferences.getStringList(AppearanceController.unlockedPreferenceKey),
        contains(AppAppearance.familyYear2026.name),
      );
    },
  );

  test('does not restore a premium appearance without ownership', () async {
    SharedPreferences.setMockInitialValues({
      AppearanceController.preferenceKey: AppAppearance.space.name,
    });
    final controller = AppearanceController();
    addTearDown(controller.dispose);

    await controller.load();

    expect(controller.appearance, AppAppearance.light);
  });

  test('keeps premium ownership scoped to the signed-in account', () async {
    SharedPreferences.setMockInitialValues({});
    final controller = AppearanceController();
    addTearDown(controller.dispose);

    await controller.load(ownershipScope: 'family-member-a');
    await controller.registerUnlocked([AppAppearance.space]);
    await controller.setAppearance(AppAppearance.space);

    await controller.load(ownershipScope: 'family-member-b');

    expect(controller.appearance, AppAppearance.light);
    expect(controller.isUnlocked(AppAppearance.space), isFalse);
  });

  test('falls back to Sila Light for an unknown saved value', () async {
    SharedPreferences.setMockInitialValues({
      AppearanceController.preferenceKey: 'unknown-theme',
    });
    final controller = AppearanceController();
    addTearDown(controller.dispose);

    await controller.load();

    expect(controller.appearance, AppAppearance.light);
  });

  test('every appearance uses the bundled bilingual font', () {
    for (final appearance in AppAppearance.values) {
      final theme = AppTheme.forAppearance(appearance);

      expect(theme.textTheme.bodyMedium?.fontFamily, 'NotoSansArabic');
      expect(theme.textTheme.headlineMedium?.fontFamily, 'NotoSansArabic');
    }
  });
}
