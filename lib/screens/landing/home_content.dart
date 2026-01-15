import 'package:flutter/material.dart';
import '../../config/route_helper.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  // Use your app's forest green color scheme
  final Color _primaryGreen = const Color(0xFF2E7D32);
  final Color _lightGreen = const Color(0xFF4CAF50);
  final Color _darkGreen = const Color(0xFF1B5E20);
  final Color _accentGreen = const Color(0xFF81C784);
  final Color _neutralBlue = const Color(0xFF2196F3);

  final List<Map<String, dynamic>> _features = [
    {
      'icon': Icons.search_rounded,
      'title': 'Browse Services',
      'description': 'Discover a wide range of services from trusted providers',
      'color': Color(0xFF2E7D32), // Forest green
      'gradient': [Color(0xFF2E7D32), Color(0xFF4CAF50)],
    },
    {
      'icon': Icons.schedule_rounded,
      'title': 'Easy Booking',
      'description': 'Book appointments with just a few taps',
      'color': Color(0xFF2196F3), // Blue
      'gradient': [Color(0xFF2196F3), Color(0xFF64B5F6)],
    },
    {
      'icon': Icons.calendar_today_rounded,
      'title': 'Manage Bookings',
      'description': 'Keep track of all your appointments in one place',
      'color': Color(0xFFFF9800), // Orange
      'gradient': [Color(0xFFFFB74D), Color(0xFFFF9800)],
    },
    {
      'icon': Icons.security_rounded,
      'title': 'Secure & Reliable',
      'description': 'Your data and payments are protected',
      'color': Color(0xFF9C27B0), // Purple
      'gradient': [Color(0xFFBA68C8), Color(0xFF9C27B0)],
    },
  ];

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    RouteHelper.pushNamed(context, RouteHelper.login);
  }

  void _navigateToRegister() {
    RouteHelper.pushNamed(context, RouteHelper.register);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isMobile = size.width < 600;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16.0 : 24.0,
          vertical: 8.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Animated Hero Section
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: child,
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(isMobile ? 24 : 32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_primaryGreen, _darkGreen],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryGreen.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Animated Icon
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.calendar_today_rounded,
                        size: 64,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Welcome to Infinity Booking',
                      style: TextStyle(
                        fontSize: isMobile ? 24 : 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Book services easily and manage your appointments all in one place',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Animated Button
                    MouseRegion(
                      onEnter: (_) => setState(() => _isHovered = true),
                      onExit: (_) => setState(() => _isHovered = false),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        transform: Matrix4.identity()
                          ..scale(_isHovered ? 1.05 : 1.0),
                        child: ElevatedButton(
                          onPressed: _navigateToRegister,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: _primaryGreen,
                            padding: EdgeInsets.symmetric(
                                horizontal: isMobile ? 32 : 40, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                            shadowColor: Colors.black.withOpacity(0.2),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.rocket_launch_rounded, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Get Started',
                                style: TextStyle(
                                  fontSize: isMobile ? 14 : 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Features Section Header
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: child,
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Why Choose Us?',
                    style: TextStyle(
                      fontSize: isMobile ? 20 : 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Everything you need for seamless service booking',
                    style: TextStyle(
                      fontSize: isMobile ? 13 : 14,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Interactive Features Grid - FIXED
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile ? 1 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: isMobile ? 3.5 : 2,
              ),
              itemCount: _features.length,
              itemBuilder: (context, index) {
                final feature = _features[index];
                return _buildInteractiveFeatureCard(feature, index, isMobile);
              },
            ),
            const SizedBox(height: 40),

            // CTA Section
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: Opacity(
                    opacity: _fadeAnimation.value,
                    child: child,
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(isMobile ? 20 : 28),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF1F2937), Color(0xFF111827)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.star_rate_rounded,
                      size: 48,
                      color: Color(0xFFFBBF24),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Ready to get started?',
                      style: TextStyle(
                        fontSize: isMobile ? 20 : 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Join thousands of satisfied customers who trust Infinity Booking',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 24),
                    isMobile
                        ? Column(
                            children: [
                              ElevatedButton(
                                onPressed: _navigateToRegister,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _primaryGreen,
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  'Sign Up Free',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton(
                                onPressed: _navigateToLogin,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.white),
                                  foregroundColor: Colors.white,
                                  minimumSize: const Size(double.infinity, 48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: _navigateToRegister,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _primaryGreen,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Sign Up Free',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton(
                                onPressed: _navigateToLogin,
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Colors.white),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 32, vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              ),
            ),
            SizedBox(height: isMobile ? 40 : 60),
          ],
        ),
      ),
    );
  }

  Widget _buildInteractiveFeatureCard(
      Map<String, dynamic> feature, int index, bool isMobile) {
    bool isHovered = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          // Add margin to ensure no overflow
          margin: EdgeInsets.only(bottom: isMobile ? 8 : 0),
          child: MouseRegion(
            onEnter: (_) => setState(() => isHovered = true),
            onExit: (_) => setState(() => isHovered = false),
            child: ConstrainedBox(
              // Add constraints to ensure proper height
              constraints: BoxConstraints(
                minHeight: isMobile ? 90 : 100,
                maxHeight: isMobile ? 120 : double.infinity,
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                transform: Matrix4.identity()
                  ..translate(0.0, isHovered ? -8.0 : 0.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isHovered
                        ? feature['gradient']
                        : [Colors.white, Colors.white],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isHovered
                      ? [
                          BoxShadow(
                            color: feature['color'].withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                padding: EdgeInsets.all(isMobile ? 14 : 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Icon container with fixed size
                    Container(
                      width: isMobile ? 44 : 52,
                      height: isMobile ? 44 : 52,
                      alignment: Alignment.center,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isHovered
                              ? Colors.white
                              : feature['color'].withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          feature['icon'],
                          color:
                              isHovered ? feature['color'] : feature['color'],
                          size: isMobile ? 18 : 22,
                        ),
                      ),
                    ),
                    SizedBox(width: isMobile ? 12 : 16),
                    // Content with flexible space
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title with exact line height
                          Text(
                            feature['title'],
                            style: TextStyle(
                              fontSize: isMobile ? 15 : 17,
                              fontWeight: FontWeight.w700,
                              height: 1.2, // Fixed line height
                              color:
                                  isHovered ? Colors.white : feature['color'],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: isMobile ? 2 : 4),
                          // Description with tighter spacing
                          Text(
                            feature['description'],
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 13,
                              height: 1.3, // Tighter line height for mobile
                              color: isHovered
                                  ? Colors.white.withOpacity(0.9)
                                  : const Color(0xFF6B7280),
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: isMobile ? 4 : 8),
                    // Arrow icon - only show on hover
                    if (isHovered)
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.white,
                        size: isMobile ? 14 : 16,
                      )
                    else
                      SizedBox(
                          width:
                              isMobile ? 14 : 16), // Maintain consistent width
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
