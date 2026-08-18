import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color activeColor;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inactiveColor = isDark ? Colors.grey[600] : Colors.grey;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: activeColor,
      unselectedItemColor: inactiveColor,
      backgroundColor: Theme.of(context).colorScheme.surface,
      items: [
        BottomNavigationBarItem(
          icon: Icon(currentIndex == 0 ? Icons.home : Icons.home_outlined),
          label: 'Trang chủ',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            currentIndex == 1 ? Icons.bar_chart : Icons.bar_chart_outlined,
          ),
          label: 'Thống kê',
        ),
      ],
    );
  }
}

class CustomNavigationRail extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color activeColor;
  final VoidCallback onSettings;

  const CustomNavigationRail({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.activeColor,
    required this.onSettings,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      labelType: NavigationRailLabelType.all,
      groupAlignment: -0.45,
      trailingAtBottom: true,
      trailing: Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Tooltip(
          message: 'Cài đặt',
          child: InkWell(
            onTap: onSettings,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.settings_outlined,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.72),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Cài đặt',
                    style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.72),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      indicatorColor: activeColor.withValues(alpha: 0.14),
      selectedIconTheme: IconThemeData(color: activeColor),
      selectedLabelTextStyle: TextStyle(color: activeColor),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: Text('Trang chủ'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart),
          label: Text('Thống kê'),
        ),
      ],
    );
  }
}
