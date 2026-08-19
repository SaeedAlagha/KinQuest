import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppAppearance {
  light,
  dark,
  familyYear2026,
  space,
  khalifaUniversity,
  desertNights,
  pearlLagoon,
}

class AppearanceController extends ChangeNotifier {
  AppearanceController();

  static final AppearanceController instance = AppearanceController();

  static const preferenceKey = 'app_appearance';
  static const unlockedPreferenceKey = 'unlocked_app_appearances';

  AppAppearance _appearance = AppAppearance.light;
  String? _ownershipScope;
  Set<AppAppearance> _unlockedAppearances = {
    AppAppearance.light,
    AppAppearance.dark,
  };

  AppAppearance get appearance => _appearance;

  Set<AppAppearance> get unlockedAppearances =>
      Set.unmodifiable(_unlockedAppearances);

  bool isUnlocked(AppAppearance appearance) {
    return _unlockedAppearances.contains(appearance);
  }

  Future<void> load({String? ownershipScope}) async {
    final preferences = await SharedPreferences.getInstance();
    final storedValue = preferences.getString(preferenceKey);
    final storedUnlocks =
        preferences.getStringList(_unlockStorageKey(ownershipScope)) ?? [];
    final previousAppearance = _appearance;
    final previousUnlocks = _unlockedAppearances;

    _ownershipScope = ownershipScope;

    _unlockedAppearances = {
      AppAppearance.light,
      AppAppearance.dark,
      ...storedUnlocks.map(_appearanceFromName).whereType<AppAppearance>(),
    };

    final storedAppearance = _appearanceFromName(storedValue);
    _appearance = storedAppearance != null && isUnlocked(storedAppearance)
        ? storedAppearance
        : AppAppearance.light;

    if (previousAppearance != _appearance ||
        !setEquals(previousUnlocks, _unlockedAppearances)) {
      notifyListeners();
    }
  }

  Future<bool> setAppearance(
    AppAppearance appearance, {
    bool persist = true,
  }) async {
    if (!isUnlocked(appearance)) {
      return false;
    }

    if (_appearance == appearance) {
      return true;
    }

    _appearance = appearance;
    notifyListeners();

    if (persist) {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(preferenceKey, appearance.name);
    }

    return true;
  }

  Future<void> registerUnlocked(
    Iterable<AppAppearance> appearances, {
    bool persist = true,
  }) async {
    final nextUnlocks = {
      AppAppearance.light,
      AppAppearance.dark,
      ..._unlockedAppearances,
      ...appearances,
    };

    if (setEquals(nextUnlocks, _unlockedAppearances)) {
      return;
    }

    _unlockedAppearances = nextUnlocks;
    notifyListeners();

    if (!persist) {
      return;
    }

    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(
      _unlockStorageKey(_ownershipScope),
      _unlockedAppearances.map((appearance) => appearance.name).toList(),
    );
  }

  String _unlockStorageKey(String? ownershipScope) {
    if (ownershipScope == null || ownershipScope.isEmpty) {
      return unlockedPreferenceKey;
    }

    return '${unlockedPreferenceKey}_$ownershipScope';
  }

  AppAppearance? _appearanceFromName(String? value) {
    for (final appearance in AppAppearance.values) {
      if (appearance.name == value) {
        return appearance;
      }
    }

    return null;
  }
}
