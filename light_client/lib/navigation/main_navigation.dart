import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../providers/class_provider.dart';
import '../providers/feed_provider.dart';
import '../providers/staff_provider.dart';
import '../providers/user_provider.dart';
import '../providers/workout_provider.dart';
import '../theme/colors.dart';
import '../theme/text_styles.dart';

// Client screens
import '../screens/client/home_screen.dart';
import '../screens/client/workout_screen.dart';
import '../screens/client/classes_screen.dart';
import '../screens/client/feed_screen.dart';
import '../screens/client/profile_screen.dart';

// Staff screens
import '../screens/staff/staff_hub_screen.dart';

// Admin screens
import '../screens/admin/admin_screen.dart';
import '../screens/admin/staff_reports_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    // Delay until first frame so context.read() is safe
    WidgetsBinding.instance.addPostFrameCallback((_) => _initProviders());
  }

  Future<void> _initProviders() async {
    final user = context.read<AuthProvider>().currentUser;
    if (user == null) return;

    await Future.wait([
      context.read<ClassProvider>().init(),
      context.read<WorkoutProvider>().init(),
      context.read<FeedProvider>().init(),
      if (user.isStaff) context.read<StaffProvider>().init(),
      if (user.isAdmin) context.read<UserProvider>().init(),
    ]);

    if (mounted) setState(() => _initialized = true);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser!;

    if (!_initialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final tabs = _buildTabs(user);
    final screens = tabs.map((t) => t.screen).toList();
    final navItems = tabs
        .map((t) => BottomNavigationBarItem(
              icon: Icon(t.icon),
              activeIcon:
                  Icon(t.activeIcon ?? t.icon, color: AppColors.primary),
              label: t.label,
            ))
        .toList();

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: _GlassNavBar(
        selectedIndex: _selectedIndex,
        items: navItems,
        onTap: (i) => setState(() => _selectedIndex = i),
      ),
    );
  }

  List<_NavTab> _buildTabs(User user) {
    final clientTabs = [
      _NavTab(
        label: 'HOME',
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        screen: const HomeScreen(),
      ),
      _NavTab(
        label: 'WORKOUT',
        icon: Icons.fitness_center_outlined,
        activeIcon: Icons.fitness_center,
        screen: const WorkoutScreen(),
      ),
      _NavTab(
        label: 'CLASSES',
        icon: Icons.calendar_month_outlined,
        activeIcon: Icons.calendar_month,
        screen: const ClassesScreen(),
      ),
      _NavTab(
        label: 'COMMUNITY',
        icon: Icons.people_outline,
        activeIcon: Icons.people,
        screen: const FeedScreen(),
      ),
      _NavTab(
        label: 'PROFILE',
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        screen: const ProfileScreen(),
      ),
    ];

    if (user.isAdmin) {
      return [
        ...clientTabs,
        _NavTab(
          label: 'STAFF HUB',
          icon: Icons.punch_clock_outlined,
          activeIcon: Icons.punch_clock,
          screen: const StaffHubScreen(),
        ),
        _NavTab(
          label: 'ADMIN',
          icon: Icons.admin_panel_settings_outlined,
          activeIcon: Icons.admin_panel_settings,
          screen: const AdminScreen(),
        ),
        _NavTab(
          label: 'REPORTS',
          icon: Icons.assignment_outlined,
          activeIcon: Icons.assignment,
          screen: const StaffReportsScreen(),
        ),
      ];
    }

    if (user.isStaff) {
      return [
        ...clientTabs,
        _NavTab(
          label: 'STAFF HUB',
          icon: Icons.punch_clock_outlined,
          activeIcon: Icons.punch_clock,
          screen: const StaffHubScreen(),
        ),
      ];
    }

    return clientTabs;
  }
}

class _NavTab {
  final String label;
  final IconData icon;
  final IconData? activeIcon;
  final Widget screen;

  const _NavTab({
    required this.label,
    required this.icon,
    this.activeIcon,
    required this.screen,
  });
}

class _GlassNavBar extends StatelessWidget {
  final int selectedIndex;
  final List<BottomNavigationBarItem> items;
  final ValueChanged<int> onTap;

  const _GlassNavBar({
    required this.selectedIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassNavBar,
        border: Border(
          top: BorderSide(
            color: AppColors.outline.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;
              final isSelected = i == selectedIndex;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      isSelected
                          ? (item.activeIcon ?? item.icon)
                          : item.icon,
                      const SizedBox(height: 4),
                      Text(
                        (item.label ?? '').toUpperCase(),
                        style: AppTextStyles.labelSmCaps.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.onSurfaceVariant,
                          fontSize: 8,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
