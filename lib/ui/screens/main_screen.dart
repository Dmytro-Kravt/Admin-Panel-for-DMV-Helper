import 'package:dmv_admin/ui/providers/settings_provider.dart';
import 'package:dmv_admin/ui/screens/home_screen.dart';
import 'package:dmv_admin/ui/screens/log_in.dart';
import 'package:dmv_admin/ui/screens/map_screen.dart';
import 'package:dmv_admin/ui/screens/practice_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  List<Widget> currentScreen = [HomeScreen(), PracticeScreen(), MapScreen()];

  @override
  Widget build(BuildContext context) {
    final authProv = context.watch<AuthProvider>();
    final settProve = context.watch<SettingsProvider>();
    return authProv.userLogedIn
        ? Row(
      children: [
        NavigationRail(
          trailingAtBottom: true,
          trailing: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: IconButton(
              onPressed: () => settProve.toggleCurrentTheme(),
              icon: Icon(
                Theme.of(context).brightness == Brightness.light
                    ? Icons.dark_mode_outlined
                    : Icons.light_mode_outlined,
              ),
            ),
          ),
          destinations: <NavigationRailDestination>[
            NavigationRailDestination(
              icon: Icon(Icons.home_outlined),
              label: Text('Dashboard'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.menu_book_sharp),
              label: Text('Practice'),
            ),
            NavigationRailDestination(
              icon: Icon(Icons.map_outlined),
              label: Text('Map'),
            ),
          ],
          selectedIndex: _selectedIndex,
          elevation: 5,
          labelType: NavigationRailLabelType.all,
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
        ),
        Expanded(
          child: IndexedStack(index: _selectedIndex, children: currentScreen),
        ),
      ],
    )
        : LogInScreen();
  }
}
