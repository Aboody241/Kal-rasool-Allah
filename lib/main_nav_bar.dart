import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kal_rasol_allah/controllers/theme/theme_riverPod.dart';
import 'package:kal_rasol_allah/core/theme/colors.dart';
import 'package:kal_rasol_allah/features/history/history_page.dart';
import 'package:kal_rasol_allah/features/home/pages/home_page.dart';
import 'package:kal_rasol_allah/features/setting/setting_page.dart';
import 'package:kal_rasol_allah/features/tools/tools_screen.dart';

class MainNavBar extends ConsumerStatefulWidget {
  const MainNavBar({super.key});

  @override
  ConsumerState<MainNavBar> createState() => _MainNavBarState();
}

class _MainNavBarState extends ConsumerState<MainNavBar> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const ToolsScreen(),
    const HistoryPage(),
    const SettingsPage(),
  ];

  final List<_NavItem> _items = const [
    _NavItem(icon: Icons.home_rounded, label: 'الرئيسية'),
    _NavItem(icon: Icons.toc_outlined, label: 'الادوات'),
    _NavItem(icon: Icons.watch_later_outlined, label: 'السِجل'),
    _NavItem(icon: Icons.settings_outlined, label: 'الإعدادات'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: _CustomNavBar(
        currentIndex: _currentIndex,
        items: _items,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}

// ============================================================
// ✅ Custom NavBar — Style6 (icon + label, active = colored)
// ============================================================

class _CustomNavBar extends ConsumerWidget {
  final int currentIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  const _CustomNavBar({
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(ThemeRiverPod);
    return Container(
      decoration: BoxDecoration(
        color: isDark? AppColors.card : AppColors.lightGray,
        border: Border(top: BorderSide(color: isDark? AppColors.secondary: AppColors.lightGray, width: 0.8)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(
              items.length,
              (index) => Expanded(
                child: _NavBarItem(
                  item: items[index],
                  isActive: currentIndex == index,
                  onTap: () => onTap(index),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ✅ NavBar Item — icon فوق، label تحت
// ============================================================

class _NavBarItem extends StatelessWidget {
  final _NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primaryGreen : AppColors.darkGray;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, color: color, size: 26),
          const SizedBox(height: 4),
          Text(
            item.label,
            style: TextStyle(
              color: color,
              fontSize: isActive ? 15 : 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ✅ NavItem Model
// ============================================================

class _NavItem {
  final IconData icon;
  final String label;

  const _NavItem({required this.icon, required this.label});
}
