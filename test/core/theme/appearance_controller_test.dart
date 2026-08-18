import 'package:flutter_test/flutter_test.dart';
import 'package:kinquest/core/theme/appearance_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads and persists the selected appearance', () async {
    SharedPreferences.setMockInitialValues({
      AppearanceController.preferenceKey: AppAppearance.dark.name,
    });
    final controller = AppearanceController();
    addTearDown(controller.dispose);

    await controller.load();
    expect(controller.appearance, AppAppearance.dark);

    await controller.setAppearance(AppAppearance.familyYear2026);

    final preferences = await SharedPreferences.getInstance();
    expect(
      preferences.getString(AppearanceController.preferenceKey),
      AppAppearance.familyYear2026.name,
    );
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
}
