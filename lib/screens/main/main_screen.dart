// lib/screens/main/main_screen.dart (FINAL VERSION)
import 'package:flutter/material.dart';
import 'home_screen.dart';
import '../service/service_list_screen.dart';
import 'bookings_screen.dart';
import 'profile_screen.dart';
import '../notifications/notifications_screen.dart';
import '../../config/route_helper.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  // Forest Green Color Scheme
  final Color _primaryGreen = const Color(0xFF2E7D32);
  final Color _darkGreen = const Color(0xFF1B5E20);
  final Color _lightGreen = const Color(0xFF4CAF50);
  final Color _accentGreen = const Color(0xFF81C784);
  final Color _background = const Color(0xFFF8FDF8);
  final Color _textLight = const Color(0xFF666666);

  // Navigation items
  final List<Map<String, dynamic>> _navItems = const [
    {
      'title': 'Home',
      'icon': Icons.home_outlined,
      'activeIcon': Icons.home_rounded,
    },
    {
      'title': 'Services',
      'icon': Icons.explore_outlined,
      'activeIcon': Icons.explore_rounded,
    },
    {
      'title': 'Bookings',
      'icon': Icons.bookmark_outlined,
      'activeIcon': Icons.bookmark_rounded,
    },
    {
      'title': 'Profile',
      'icon': Icons.person_outlined,
      'activeIcon': Icons.person_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );
    _animationController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadNotifications();
    });
  }

  Future<void> _loadNotifications() async {
    try {
      final notificationProvider = context.read<NotificationProvider>();
      await notificationProvider.loadNotifications(refresh: true);
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ==================== APP BAR ====================

  Widget _buildAppBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 50.0,
          bottom: 16,
          left: 16,
          right: 16,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                );
              },
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_primaryGreen, _lightGreen],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.calendar_today_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'INFINITY BOOKING',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: _darkGreen,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        _navItems[_currentIndex]['title'],
                        style: TextStyle(
                          fontSize: 14,
                          color: _textLight,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Consumer<NotificationProvider>(
              builder: (context, provider, child) {
                return Row(
                  children: [
                    // Notifications button with badge
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const NotificationsScreen(),
                                ),
                              );
                              provider.refresh();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _primaryGreen.withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.notifications_outlined,
                                color: Color(0xFF2E7D32),
                                size: 22,
                              ),
                            ),
                          ),
                        ),
                        if (provider.unreadCount > 0)
                          Positioned(
                            right: -4,
                            top: -4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              child: Text(
                                provider.unreadCount > 9
                                    ? '9+'
                                    : provider.unreadCount.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 12),
                    // Settings button
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: _showSettings,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _primaryGreen.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.settings_outlined,
                            color: Color(0xFF2E7D32),
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // ==================== MAIN BUILD ====================

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: Scaffold(
        backgroundColor: _background,
        body: Stack(
          children: [
            _buildGradientBackground(),
            SafeArea(
              child: Column(
                children: [
                  _buildAppBar(),
                  Expanded(
                    child: _buildCurrentScreen(),
                  ),
                ],
              ),
            ),
            if (!isMobile) _buildDesktopNavigationRail(),
          ],
        ),
        bottomNavigationBar: isMobile ? _buildMobileNavigation() : null,
        floatingActionButton: _buildFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  // ==================== CURRENT SCREEN DISPLAY ====================

  Widget _buildCurrentScreen() {
    // Simple switch to show the correct screen based on index
    switch (_currentIndex) {
      case 0:
        return const HomeScreen();
      case 1:
        return const ServiceListScreen();
      case 2:
        return const BookingsScreen();
      case 3:
        return const ProfileScreen();
      default:
        return const HomeScreen();
    }
  }

  Widget _buildGradientBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _background,
            _background.withOpacity(0.9),
            const Color(0xFFE8F5E9),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  // ==================== DESKTOP NAVIGATION RAIL ====================

  Widget _buildDesktopNavigationRail() {
    return Positioned(
      left: 20,
      top: MediaQuery.of(context).size.height * 0.4,
      child: AnimatedBuilder(
        animation: _opacityAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: _opacityAnimation.value,
            child: child,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(
              _navItems.length,
              (index) => MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: index == _currentIndex
                          ? _primaryGreen.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      index == _currentIndex
                          ? _navItems[index]['activeIcon']
                          : _navItems[index]['icon'],
                      color: index == _currentIndex ? _primaryGreen : _textLight,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== MOBILE NAVIGATION ====================

  Widget _buildMobileNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              _navItems.length,
              (index) => GestureDetector(
                onTap: () {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: index == _currentIndex
                            ? _primaryGreen.withOpacity(0.1)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        index == _currentIndex
                            ? _navItems[index]['activeIcon']
                            : _navItems[index]['icon'],
                        color: index == _currentIndex ? _primaryGreen : _textLight,
                        size: 22,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _navItems[index]['title'],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: index == _currentIndex ? _primaryGreen : _textLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== FLOATING ACTION BUTTON ====================

  Widget? _buildFloatingActionButton() {
    // Show FAB only on Home and Services tabs
    if (_currentIndex != 0 && _currentIndex != 1) {
      return null;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 70),
      child: FloatingActionButton(
        onPressed: _handleFloatingAction,
        backgroundColor: _primaryGreen,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        elevation: 4,
        child: Icon(
          _currentIndex == 0 ? Icons.search : Icons.filter_alt,
          size: 24,
        ),
      ),
    );
  }

  void _handleFloatingAction() {
    switch (_currentIndex) {
      case 0: // Home - Navigate to search
        RouteHelper.pushNamed(context, '/search');
        break;
      case 1: // Services - Show filters
        _showAdvancedFilters();
        break;
    }
  }

  // ==================== HELPER METHODS ====================

  void _showAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.6,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Advanced Filters',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: _primaryGreen,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    _buildAdvancedFilterSection('Category', ['All', 'Cleaning', 'Repair', 'Beauty']),
                    const SizedBox(height: 16),
                    _buildAdvancedFilterSection('Price Range', ['Any', '\$0-50', '\$50-100', '\$100+']),
                    const SizedBox(height: 16),
                    _buildAdvancedFilterSection('Rating', ['Any', '4+ Stars', '3+ Stars', '2+ Stars']),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: _primaryGreen),
                      ),
                      child: Text(
                        'Reset',
                        style: TextStyle(color: _primaryGreen),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryGreen,
                        minimumSize: const Size(0, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAdvancedFilterSection(String title, List<String> options) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _darkGreen,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            return FilterChip(
              label: Text(option),
              selected: option == 'All',
              onSelected: (_) {},
              selectedColor: _primaryGreen.withOpacity(0.2),
              checkmarkColor: _primaryGreen,
              labelStyle: const TextStyle(fontSize: 14),
            );
          }).toList(),
        )
      ],
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Settings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: _primaryGreen,
                ),
              ),
              const SizedBox(height: 20),
              _buildSettingsOption('Notifications', Icons.notifications),
              _buildSettingsOption('Dark Mode', Icons.dark_mode),
              _buildSettingsOption('Language', Icons.language),
              _buildSettingsOption('Help & Support', Icons.help),
              _buildSettingsOption('Terms & Privacy', Icons.security),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: _primaryGreen),
                ),
                child: Text(
                  'Close',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _primaryGreen,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsOption(String title, IconData icon) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(icon, color: _primaryGreen, size: 20),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: () {
        Navigator.pop(context);
        if (title == 'Terms & Privacy') {
          RouteHelper.pushNamed(context, '/terms-and-privacy');
        }
      },
    );
  }
}