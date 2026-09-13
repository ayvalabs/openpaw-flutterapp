import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/app_colors.dart';
import 'home_page.dart';
import 'feed_screen.dart';
import 'remote_screen.dart';
import 'settings_screen.dart';
import 'auki_portals_screen.dart';

class MainScaffold extends StatefulWidget {
  final User user;
  const MainScaffold({super.key, required this.user});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 2;
  late AnimationController _animController;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _animController.repeat(reverse: true);
    _pages = [
      const FeedScreen(),
      const RemoteScreen(),
      HomePage(user: widget.user),
      const AukiPortalsScreen(),
      const SettingsScreen(),
    ];
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: _pages[_currentIndex],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.surfaceDark.withOpacity(0.92),
              AppColors.backgroundDark,
            ],
          ),
          border: Border(
            top: BorderSide(
              color: AppColors.primary.withOpacity(0.25),
              width: 0.5,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.12),
              blurRadius: 24,
              spreadRadius: 0,
              offset: const Offset(0, -4),
            ),
            BoxShadow(
              color: AppColors.accent.withOpacity(0.06),
              blurRadius: 48,
              spreadRadius: 0,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        padding: EdgeInsets.only(
          top: 8,
          bottom: MediaQuery.of(context).padding.bottom + 4,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.view_stream_outlined, 'Feed', 0),
            _navItem(Icons.gamepad_outlined, 'Remote', 1),
            _navItem(Icons.home_filled, 'Home', 2),
            _navItem(Icons.near_me_outlined, 'Portals', 3),
            _navItem(Icons.settings_outlined, 'Settings', 4),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                // Glowing gradient pill behind the active icon
                if (isSelected)
                  AnimatedBuilder(
                    animation: _animController,
                    builder: (context, child) {
                      final glowIntensity = 0.55 + _animController.value * 0.45;
                      return Container(
                        width: 46,
                        height: 32,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: AppColors.brandGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.35 * glowIntensity),
                              blurRadius: 14 * glowIntensity,
                              spreadRadius: 1,
                            ),
                            BoxShadow(
                              color: AppColors.accent.withOpacity(0.2 * glowIntensity),
                              blurRadius: 24 * glowIntensity,
                              spreadRadius: 3,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                // Icon
                Padding(
                  padding: const EdgeInsets.all(4),
                  child: Icon(
                    icon,
                    size: isSelected ? 26 : 22,
                    color: isSelected
                        ? Colors.white
                        : AppColors.textHint.withOpacity(0.65),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: isSelected ? 10 : 9,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                letterSpacing: 0.5,
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textHint.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}