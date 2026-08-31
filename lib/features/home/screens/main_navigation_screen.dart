import 'package:flutter/material.dart';

import '../../../core/branding/app_brand.dart';
import '../../../core/widgets/family_year_banner.dart';
import '../../../l10n/app_localizations.dart';
import '../../competitions/screens/competitions_screen.dart';
import '../../games/screens/family_missions_screen.dart';
import '../../mascot/screens/sila_studio_screen.dart';
import '../../memories/screens/memories_screen.dart';
import '../../profile/screens/profile_screen.dart';
import 'home_screen.dart';
import '../../rewards/screens/rewards_hub_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key, this.developerPreview = false});

  final bool developerPreview;

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  List<NavigationDestination> _mobileDestinations(AppLocalizations strings) => [
    NavigationDestination(
      icon: const Icon(Icons.home_outlined),
      selectedIcon: const Icon(Icons.home_rounded),
      label: strings.navHome,
    ),
    NavigationDestination(
      icon: const Icon(Icons.photo_library_outlined),
      selectedIcon: const Icon(Icons.photo_library_rounded),
      label: strings.navMemories,
    ),
    NavigationDestination(
      icon: const Icon(Icons.sports_esports_outlined),
      selectedIcon: const Icon(Icons.sports_esports_rounded),
      label: strings.navPlay,
    ),
    NavigationDestination(
      icon: const Icon(Icons.groups_outlined),
      selectedIcon: const Icon(Icons.groups_rounded),
      label: strings.navMissions,
    ),
    NavigationDestination(
      key: const ValueKey('nav-sila-destination'),
      icon: const _SilaNavigationIcon(),
      selectedIcon: const _SilaNavigationIcon(selected: true),
      label: strings.navSila,
    ),
    NavigationDestination(
      icon: const Icon(Icons.redeem_outlined),
      selectedIcon: const Icon(Icons.redeem_rounded),
      label: strings.navRewards,
    ),
    NavigationDestination(
      icon: const Icon(Icons.person_outline_rounded),
      selectedIcon: const Icon(Icons.person_rounded),
      label: strings.navProfile,
    ),
  ];

  List<NavigationRailDestination> _desktopDestinations(
    AppLocalizations strings,
  ) => [
    NavigationRailDestination(
      icon: const Icon(Icons.home_outlined),
      selectedIcon: const Icon(Icons.home_rounded),
      label: Text(strings.navHome),
    ),
    NavigationRailDestination(
      icon: const Icon(Icons.photo_library_outlined),
      selectedIcon: const Icon(Icons.photo_library_rounded),
      label: Text(strings.navMemories),
    ),
    NavigationRailDestination(
      icon: const Icon(Icons.sports_esports_outlined),
      selectedIcon: const Icon(Icons.sports_esports_rounded),
      label: Text(strings.navPlay),
    ),
    NavigationRailDestination(
      icon: const Icon(Icons.groups_outlined),
      selectedIcon: const Icon(Icons.groups_rounded),
      label: Text(strings.navMissions),
    ),
    NavigationRailDestination(
      icon: const _SilaNavigationIcon(),
      selectedIcon: const _SilaNavigationIcon(selected: true),
      label: Text(strings.navSila),
    ),
    NavigationRailDestination(
      icon: const Icon(Icons.redeem_outlined),
      selectedIcon: const Icon(Icons.redeem_rounded),
      label: Text(strings.navRewards),
    ),
    NavigationRailDestination(
      icon: const Icon(Icons.person_outline_rounded),
      selectedIcon: const Icon(Icons.person_rounded),
      label: Text(strings.navProfile),
    ),
  ];

  int _selectedIndex = 0;
  int _silaChatFocusRequest = 0;
  int _silaStageFocusRequest = 0;

  List<Widget> _screens(AppLocalizations strings) {
    return widget.developerPreview
        ? [
            HomeDashboard(
              name: strings.silaDeveloper,
              familyName: strings.developerFamilyName,
              memberCount: 5,
              tokens: '480',
              developerPreview: true,
              onFamilyOverview: _openFamilyOverview,
              onSilaStudio: _openSilaChat,
            ),
            const MemoriesScreen(developerPreview: true),
            const CompetitionsScreen(developerPreview: true),
            const FamilyMissionsScreen(developerPreview: true),
            SilaStudioScreen(
              developerPreview: true,
              showBackButton: false,
              active: _selectedIndex == 4,
              chatFocusRequest: _silaChatFocusRequest,
              stageFocusRequest: _silaStageFocusRequest,
            ),
            const RewardsHubScreen(developerPreview: true),
            const ProfileScreen(developerPreview: true),
          ]
        : [
            HomeScreen(
              onFamilyOverview: _openFamilyOverview,
              onSilaStudio: _openSilaChat,
            ),
            const MemoriesScreen(),
            const CompetitionsScreen(),
            const FamilyMissionsScreen(),
            SilaStudioScreen(
              showBackButton: false,
              active: _selectedIndex == 4,
              chatFocusRequest: _silaChatFocusRequest,
              stageFocusRequest: _silaStageFocusRequest,
            ),
            const RewardsHubScreen(),
            const ProfileScreen(),
          ];
  }

  void _openFamilyOverview() {
    _selectScreen(6);
  }

  void _openSilaStudio() {
    setState(() {
      _silaChatFocusRequest = 0;
      _silaStageFocusRequest += 1;
      _selectedIndex = 4;
    });
  }

  void _openSilaChat() {
    setState(() {
      _silaChatFocusRequest += 1;
      _selectedIndex = 4;
    });
  }

  void _selectScreen(int index) {
    setState(() {
      // A tap on the regular navigation always opens Sila's character stage.
      // Chat-first is a one-shot intent reserved for the Home "Ask Sila" CTA.
      _silaChatFocusRequest = 0;
      if (index == 4) _silaStageFocusRequest += 1;
      _selectedIndex = index;
    });
  }

  Widget _buildScreenStack(BuildContext context, AppLocalizations strings) {
    final screens = _screens(strings);
    final screenStack = IndexedStack(
      index: _selectedIndex,
      children: [
        for (var index = 0; index < screens.length; index += 1)
          TickerMode(enabled: index == _selectedIndex, child: screens[index]),
      ],
    );

    if (!widget.developerPreview) {
      return screenStack;
    }

    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: _DeveloperPreviewBanner(
            onExit: () => Navigator.maybePop(context),
          ),
        ),
        Expanded(
          child: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: screenStack,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final strings = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final useDesktopNavigation = constraints.maxWidth >= 960;

        if (useDesktopNavigation) {
          return Scaffold(
            body: Row(
              children: [
                Container(
                  width: 248,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        colorScheme.surface,
                        colorScheme.surfaceContainerLow,
                      ],
                    ),
                    border: Border(
                      right: BorderSide(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.shadow.withValues(alpha: 0.12),
                        blurRadius: 24,
                        offset: const Offset(8, 0),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    right: false,
                    child: NavigationRail(
                      extended: true,
                      minExtendedWidth: 236,
                      groupAlignment: -0.45,
                      selectedIndex: _selectedIndex,
                      onDestinationSelected: _selectScreen,
                      leading: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 16, 30),
                        child: _NavigationBrand(
                          onTap: _openSilaStudio,
                          tooltip: strings.silaNavigationHint,
                        ),
                      ),
                      destinations: _desktopDestinations(strings),
                    ),
                  ),
                ),
                Expanded(child: _buildScreenStack(context, strings)),
              ],
            ),
          );
        }

        return Scaffold(
          body: _buildScreenStack(context, strings),
          bottomNavigationBar: _MobileNavigationShell(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _selectScreen,
            destinations: _mobileDestinations(strings),
          ),
        );
      },
    );
  }
}

class _MobileNavigationShell extends StatelessWidget {
  const _MobileNavigationShell({
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
  });

  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<NavigationDestination> destinations;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colorScheme.primary.withValues(alpha: 0.18),
          ),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withValues(alpha: 0.24),
              blurRadius: 28,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const UaeColorRibbon(height: 3),
            NavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              labelBehavior:
                  NavigationDestinationLabelBehavior.onlyShowSelected,
              selectedIndex: selectedIndex,
              onDestinationSelected: onDestinationSelected,
              destinations: destinations,
            ),
          ],
        ),
      ),
    );
  }
}

class _SilaNavigationIcon extends StatelessWidget {
  const _SilaNavigationIcon({this.selected = false});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final size = selected ? 34.0 : 27.0;

    return AnimatedContainer(
      duration: reduceMotion
          ? Duration.zero
          : const Duration(milliseconds: 180),
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? colors.primary : colors.outlineVariant,
          width: selected ? 2.5 : 1,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.28),
                  blurRadius: 7,
                ),
              ]
            : null,
      ),
      child: Image.asset(
        'assets/mascot/sila_app_icon.png',
        fit: BoxFit.cover,
        cacheWidth: 96,
        cacheHeight: 96,
        excludeFromSemantics: true,
      ),
    );
  }
}

class _DeveloperPreviewBanner extends StatelessWidget {
  const _DeveloperPreviewBanner({required this.onExit});

  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final strings = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      color: colorScheme.primaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.developer_mode_rounded,
            color: colorScheme.onPrimaryContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              strings.developerFamilyPreview,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          TextButton(onPressed: onExit, child: Text(strings.exit)),
        ],
      ),
    );
  }
}

class _NavigationBrand extends StatelessWidget {
  const _NavigationBrand({required this.onTap, required this.tooltip});

  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      excludeFromSemantics: true,
      child: Semantics(
        button: true,
        label: tooltip,
        excludeSemantics: true,
        onTap: onTap,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: const ValueKey('desktop-sila-brand-action'),
            excludeFromSemantics: true,
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorScheme.primary.withValues(alpha: 0.28),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withValues(alpha: 0.18),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/mascot/sila_app_icon.png',
                      fit: BoxFit.cover,
                      cacheWidth: 120,
                      cacheHeight: 120,
                      excludeFromSemantics: true,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppBrand.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        Text(
                          AppBrand.arabicName,
                          textDirection: TextDirection.rtl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: 4),
                        const SizedBox(
                          width: 56,
                          child: UaeColorRibbon(height: 3),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
