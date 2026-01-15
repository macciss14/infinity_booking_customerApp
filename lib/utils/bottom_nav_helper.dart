// lib/utils/bottom_nav_helper.dart
import 'package:flutter/material.dart';

class BottomNavHelper {
  static bool shouldShowBottomNav(ScrollController scrollController) {
    if (!scrollController.hasClients) return true;

    final offset = scrollController.offset;
    final isAtTop = offset <= 0;
    final isScrollingUp = offset < 50;

    return isAtTop || isScrollingUp;
  }

  static Widget buildAnimatedBottomNav({
    required bool isVisible,
    required int currentIndex,
    required ValueChanged<int> onTap,
    List<BottomNavigationBarItem> items = const [],
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      height: isVisible ? 70 : 0,
      child: Wrap(
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isVisible ? 1.0 : 0.0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                child: BottomNavigationBar(
                  currentIndex: currentIndex,
                  onTap: onTap,
                  type: BottomNavigationBarType.fixed,
                  backgroundColor: Colors.white,
                  selectedItemColor:
                      Colors.blue, // Use your app's primary color
                  unselectedItemColor: Colors.grey[600],
                  selectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 12,
                  ),
                  elevation: 10,
                  items: items,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
