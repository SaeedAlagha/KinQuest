import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../competitions/screens/competitions_screen.dart';
import '../../games/screens/games_screen.dart';
import '../../memories/screens/memories_screen.dart';
import '../../profile/screens/profile_screen.dart';
import 'home_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  static const List<Widget> _screens = [
    HomeScreen(),
    GamesScreen(),
    MemoriesScreen(),
    CompetitionsScreen(),
    ProfileScreen(),
  ];

  static const List<NavigationDestination> _mobileDestinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.sports_esports_outlined),
      selectedIcon: Icon(Icons.sports_esports_rounded),
      label: 'Games',
    ),
    NavigationDestination(
      icon: Icon(Icons.photo_library_outlined),
      selectedIcon: Icon(Icons.photo_library_rounded),
      label: 'Memories',
    ),
    NavigationDestination(
      icon: Icon(Icons.emoji_events_outlined),
      selectedIcon: Icon(Icons.emoji_events_rounded),
      label: 'Compete',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline_rounded),
      selectedIcon: Icon(Icons.person_rounded),
      label: 'Profile',
    ),
  ];

  static const List<NavigationRailDestination> _desktopDestinations = [
    NavigationRailDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home_rounded),
      label: Text('Home'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.sports_esports_outlined),
      selectedIcon: Icon(Icons.sports_esports_rounded),
      label: Text('Games'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.photo_library_outlined),
      selectedIcon: Icon(Icons.photo_library_rounded),
      label: Text('Memories'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.emoji_events_outlined),
      selectedIcon: Icon(Icons.emoji_events_rounded),
      label: Text('Competitions'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.person_outline_rounded),
      selectedIcon: Icon(Icons.person_rounded),
      label: Text('Profile'),
    ),
  ];

  int _selectedIndex = 0;

  void _selectScreen(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final useDesktopNavigation = constraints.maxWidth >= 960;

        if (useDesktopNavigation) {
          return Scaffold(
            body: Row(
              children: [
                SafeArea(
                  right: false,
                  child: NavigationRail(
                    extended: true,
                    minExtendedWidth: 236,
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: _selectScreen,
                    leading: const Padding(
                      padding: EdgeInsets.fromLTRB(20, 18, 20, 34),
                      child: _NavigationBrand(),
                    ),
                    destinations: _desktopDestinations,
                  ),
                ),
                const VerticalDivider(),
                Expanded(
                  child: IndexedStack(
                    index: _selectedIndex,
                    children: _screens,
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: IndexedStack(index: _selectedIndex, children: _screens),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: _selectScreen,
            destinations: _mobileDestinations,
          ),
        );
      },
    );
  }
}

class _NavigationBrand extends StatelessWidget {
  const _NavigationBrand();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: AppTheme.brandGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.family_restroom_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'KinQuest',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: AppTheme.primaryDark,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}
