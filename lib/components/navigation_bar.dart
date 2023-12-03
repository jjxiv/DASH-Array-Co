import 'package:dash/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../screens/settings_screen.dart';

enum TabItem {
  Home,
  Settings,
}

const Map<TabItem, IconData> tabIcons = {
  TabItem.Home: Icons.home,
  TabItem.Settings: Icons.person,
};

class BottomNavigationBarWidget extends StatefulWidget {
  final TabItem initialTab;
  final ValueChanged<TabItem> onTabSelected;

  const BottomNavigationBarWidget({
    Key? key,
    required this.initialTab,
    required this.onTabSelected,
  }) : super(key: key);

  @override
  _BottomNavigationBarWidgetState createState() =>
      _BottomNavigationBarWidgetState();
}

class _BottomNavigationBarWidgetState extends State<BottomNavigationBarWidget> {
  late TabItem _currentTab;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.initialTab;
  }

  void _selectTab(TabItem tabItem) {
    widget.onTabSelected(tabItem);
    setState(() {
      _currentTab = tabItem;
    });

    // Navigation logic
    switch (tabItem) {
      case TabItem.Home:
        // Navigate to the Home screen
        Get.to(() => const HomeScreen(), transition: Transition.leftToRight);
        break;
      case TabItem.Settings:
        // Navigate to the Settings screen
        Get.to(() => const SettingScreen(), transition: Transition.rightToLeft);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: TabItem.values.indexOf(_currentTab),
      onTap: (index) => _selectTab(TabItem.values[index]),
      selectedItemColor: const Color.fromARGB(255, 0, 89, 231),
      showSelectedLabels: false,
      showUnselectedLabels: false,
      backgroundColor: const Color.fromARGB(255, 16, 35, 65),
      items: TabItem.values.map((tabItem) {
        return BottomNavigationBarItem(
          icon: Icon(
            tabIcons[tabItem],
            size: 30,
          ),
          label: '',
        );
      }).toList(),
    );
  }
}
