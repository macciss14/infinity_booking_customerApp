import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AboutContent extends StatefulWidget {
  const AboutContent({super.key});

  @override
  State<AboutContent> createState() => _AboutContentState();
}

class _AboutContentState extends State<AboutContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  final ScrollController _scrollController = ScrollController();
  int _activeValueIndex = 0;

  // Forest Green Color Scheme
  final Color _primaryGreen = const Color(0xFF2E7D32);
  final Color _lightGreen = const Color(0xFF4CAF50);
  final Color _accentGreen = const Color(0xFF81C784);
  final Color _darkGreen = const Color(0xFF1B5E20);
  final Color _neutralBlue = const Color(0xFF2196F3);
  final Color _lightBlue = const Color(0xFFE3F2FD);

  final List<Map<String, dynamic>> _sections = [
    {
      'title': 'About Infinity Booking',
      'content':
          'Infinity Booking is a revolutionary platform that transforms how people discover, book, and manage services. We connect customers with trusted professionals through a seamless digital experience that saves time, reduces stress, and ensures quality.',
      'icon': Icons.business_center_rounded,
      'color': Color(0xFF2E7D32),
      'gradient': [Color(0xFF2E7D32), Color(0xFF4CAF50)],
    },
    {
      'title': 'Our Mission',
      'content':
          'To democratize access to professional services by creating a transparent, reliable, and user-friendly platform that empowers both customers and service providers through technology.',
      'icon': Icons.flag_rounded,
      'color': Color(0xFF2196F3),
      'gradient': [Color(0xFF2196F3), Color(0xFF64B5F6)],
    },
    {
      'title': 'Our Vision',
      'content':
          'To become the world\'s most trusted service marketplace, where anyone can find and book any service with confidence, convenience, and complete peace of mind.',
      'icon': Icons.visibility_rounded,
      'color': Color(0xFF9C27B0),
      'gradient': [Color(0xFF9C27B0), Color(0xFFBA68C8)],
    },
    {
      'title': 'What We Solve',
      'content':
          'We eliminate the frustrations of traditional service booking: endless phone calls, uncertain availability, unclear pricing, and unreliable providers. Our platform brings transparency, efficiency, and trust to every transaction.',
      'icon': Icons.build_rounded,
      'color': Color(0xFFFF9800),
      'gradient': [Color(0xFFFF9800), Color(0xFFFFB74D)],
    },
    {
      'title': 'Why We Exist',
      'content':
          'Because booking services shouldn\'t be complicated. We exist to simplify life, save time, and build connections between people who need services and professionals who deliver excellence.',
      'icon': Icons.lightbulb_rounded,
      'color': Color(0xFFE91E63),
      'gradient': [Color(0xFFE91E63), Color(0xFFF48FB1)],
    },
  ];

  final List<Map<String, dynamic>> _values = [
    {
      'title': 'Customer First',
      'description': 'Every decision starts with our customers\' needs',
      'icon': Icons.people_alt_rounded,
      'color': Color(0xFF4CAF50),
    },
    {
      'title': 'Innovation',
      'description': 'We embrace change and continuously improve',
      'icon': Icons.auto_awesome_rounded,
      'color': Color(0xFF2196F3),
    },
    {
      'title': 'Reliability',
      'description': 'Consistency and trust in every interaction',
      'icon': Icons.verified_rounded,
      'color': Color(0xFFFF9800),
    },
    {
      'title': 'Transparency',
      'description': 'Clear communication, honest pricing',
      'icon': Icons.visibility_rounded,
      'color': Color(0xFF9C27B0),
    },
    {
      'title': 'Excellence',
      'description': 'Striving for the highest quality in everything',
      'icon': Icons.star_rounded,
      'color': Color(0xFFE91E63),
    },
    {
      'title': 'Integrity',
      'description': 'Ethical practices and honest relationships',
      'icon': Icons.security_rounded,
      'color': Color(0xFF607D8B),
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();

    // Auto scroll values
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _activeValueIndex = (_activeValueIndex + 1) % _values.length;
        });
        _startAutoScroll();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Widget _buildSectionCard(Map<String, dynamic> section, int index, bool isMobile) {
    bool isHovered = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isHovered
                      ? section['gradient']
                      : [Colors.white, Colors.white],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(isHovered ? 0.15 : 0.05),
                    blurRadius: isHovered ? 20 : 10,
                    offset: Offset(0, isHovered ? 10 : 4),
                  ),
                ],
                border: Border.all(
                  color: section['color'].withOpacity(isHovered ? 0.3 : 0.1),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: isMobile ? 44 : 56,
                          height: isMobile ? 44 : 56,
                          alignment: Alignment.center,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: EdgeInsets.all(isMobile ? 8 : 12),
                            decoration: BoxDecoration(
                              color: isHovered
                                  ? Colors.white
                                  : section['color'].withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              section['icon'],
                              color: isHovered
                                  ? section['color']
                                  : section['color'],
                              size: isMobile ? 20 : 24,
                            ),
                          ),
                        ),
                        SizedBox(width: isMobile ? 12 : 16),
                        Expanded(
                          child: Text(
                            section['title'],
                            style: TextStyle(
                              fontSize: isMobile ? 18 : 20,
                              fontWeight: FontWeight.bold,
                              color: isHovered ? Colors.white : section['color'],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isMobile ? 12 : 16),
                    Text(
                      section['content'],
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        height: 1.5,
                        color: isHovered
                            ? Colors.white.withOpacity(0.95)
                            : Colors.grey[700],
                      ),
                      maxLines: isHovered ? 8 : 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isHovered) ...[
                      SizedBox(height: isMobile ? 12 : 20),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildValueCard(Map<String, dynamic> value, int index, bool isMobile) {
    bool isHovered = false;
    bool isActive = index == _activeValueIndex;

    return StatefulBuilder(
      builder: (context, setState) {
        return GestureDetector(
          onTap: () {
            setState(() {
              _activeValueIndex = index;
            });
          },
          child: MouseRegion(
            onEnter: (_) => setState(() => isHovered = true),
            onExit: (_) => setState(() => isHovered = false),
            child: Container(
              width: isMobile ? 140 : 160,
              margin: EdgeInsets.only(right: isMobile ? 12 : 16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(
                        isActive ? 0.2 : isHovered ? 0.1 : 0.05,
                      ),
                      blurRadius: isActive ? 16 : isHovered ? 12 : 6,
                      offset: Offset(0, isActive ? 10 : isHovered ? 6 : 3),
                    ),
                  ],
                  border: Border.all(
                    color: isActive
                        ? value['color']
                        : Colors.grey[200]!,
                    width: isActive ? 2 : 1,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(isMobile ? 12 : 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: isMobile ? 48 : 60,
                        height: isMobile ? 48 : 60,
                        alignment: Alignment.center,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: EdgeInsets.all(isMobile ? 10 : 12),
                          decoration: BoxDecoration(
                            color: isActive
                                ? value['color'].withOpacity(0.2)
                                : Colors.grey[100],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            value['icon'],
                            color: isActive ? value['color'] : Colors.grey[600],
                            size: isMobile ? 22 : 26,
                          ),
                        ),
                      ),
                      SizedBox(height: isMobile ? 8 : 12),
                      Text(
                        value['title'],
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.bold,
                          color: isActive ? value['color'] : Colors.grey[800],
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: isMobile ? 4 : 6),
                      if (isActive || isHovered)
                        Text(
                          value['description'],
                          style: TextStyle(
                            fontSize: isMobile ? 11 : 12,
                            color: Colors.grey[600],
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      SizedBox(height: isMobile ? 4 : 8),
                      if (isActive)
                        Container(
                          width: isMobile ? 20 : 24,
                          height: 3,
                          decoration: BoxDecoration(
                            color: value['color'],
                            borderRadius: BorderRadius.circular(1.5),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;
    final double screenWidth = MediaQuery.of(context).size.width;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          ),
        );
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        controller: _scrollController,
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: isMobile ? 10 : 20),

              // Hero Section
              Container(
                padding: EdgeInsets.all(isMobile ? 20 : 32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_primaryGreen, _darkGreen],
                  ),
                  borderRadius: BorderRadius.circular(isMobile ? 20 : 28),
                  boxShadow: [
                    BoxShadow(
                      color: _primaryGreen.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(isMobile ? 12 : 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.info_rounded,
                        color: Colors.white,
                        size: isMobile ? 28 : 36,
                      ),
                    ),
                    SizedBox(width: isMobile ? 16 : 24),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'About Infinity Booking',
                            style: TextStyle(
                              fontSize: isMobile ? 22 : 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: isMobile ? 4 : 8),
                          Text(
                            'Transforming service booking through innovation, trust, and seamless technology.',
                            style: TextStyle(
                              fontSize: isMobile ? 14 : 16,
                              color: Colors.white.withOpacity(0.9),
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: isMobile ? 24 : 40),

              // Content Sections
              ..._sections.map((section) => 
                _buildSectionCard(section, _sections.indexOf(section), isMobile)),

              SizedBox(height: isMobile ? 24 : 40),

              // Values Section
              Container(
                padding: EdgeInsets.all(isMobile ? 20 : 28),
                decoration: BoxDecoration(
                  color: _lightBlue,
                  borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
                  border: Border.all(
                    color: _neutralBlue.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Our Core Values',
                      style: TextStyle(
                        fontSize: isMobile ? 22 : 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'The principles that guide everything we do',
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: isMobile ? 16 : 24),

                    // Horizontal Scrollable Values
                    SizedBox(
                      height: isMobile ? 200 : 220,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: _values.length,
                        itemBuilder: (context, index) {
                          return _buildValueCard(_values[index], index, isMobile);
                        },
                      ),
                    ),

                    SizedBox(height: isMobile ? 16 : 24),

                    // Value Indicator Dots
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _values.length,
                          (index) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: index == _activeValueIndex 
                                  ? (isMobile ? 20 : 24) 
                                  : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: index == _activeValueIndex
                                    ? _values[_activeValueIndex]['color']
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: isMobile ? 12 : 16),

                    // Active Value Detail
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      padding: EdgeInsets.all(isMobile ? 16 : 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(isMobile ? 14 : 16),
                        border: Border.all(
                          color: _values[_activeValueIndex]['color']
                              .withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: isMobile ? 40 : 48,
                            height: isMobile ? 40 : 48,
                            alignment: Alignment.center,
                            child: Icon(
                              _values[_activeValueIndex]['icon'],
                              color: _values[_activeValueIndex]['color'],
                              size: isMobile ? 22 : 28,
                            ),
                          ),
                          SizedBox(width: isMobile ? 12 : 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _values[_activeValueIndex]['title'],
                                  style: TextStyle(
                                    fontSize: isMobile ? 16 : 18,
                                    fontWeight: FontWeight.bold,
                                    color: _values[_activeValueIndex]['color'],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: isMobile ? 2 : 4),
                                Text(
                                  _values[_activeValueIndex]['description'],
                                  style: TextStyle(
                                    fontSize: isMobile ? 13 : 14,
                                    color: Colors.grey[700],
                                    height: 1.4,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: isMobile ? 24 : 40),

              // Statistics Section
              Container(
                padding: EdgeInsets.all(isMobile ? 20 : 28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'By The Numbers',
                      style: TextStyle(
                        fontSize: isMobile ? 22 : 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Our impact and growth',
                      style: TextStyle(
                        fontSize: isMobile ? 13 : 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: isMobile ? 16 : 24),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: isMobile ? 2 : 4,
                        crossAxisSpacing: isMobile ? 12 : 16,
                        mainAxisSpacing: isMobile ? 12 : 16,
                        childAspectRatio: isMobile ? 1.0 : 1.2,
                      ),
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        final stats = [
                          {'value': '10K+', 'label': 'Happy Customers'},
                          {'value': '500+', 'label': 'Service Providers'},
                          {'value': '50+', 'label': 'Service Categories'},
                          {'value': '99%', 'label': 'Satisfaction Rate'},
                        ];
                        return Container(
                          padding: EdgeInsets.all(isMobile ? 12 : 16),
                          decoration: BoxDecoration(
                            color: _lightBlue,
                            borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                            border: Border.all(
                              color: _neutralBlue.withOpacity(0.2),
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                stats[index]['value']!,
                                style: TextStyle(
                                  fontSize: isMobile ? 24 : 28,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF2196F3),
                                ),
                              ),
                              SizedBox(height: isMobile ? 4 : 8),
                              Text(
                                stats[index]['label']!,
                                style: TextStyle(
                                  fontSize: isMobile ? 11 : 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                  height: 1.2,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: isMobile ? 40 : 60),
            ],
          ),
        ),
      ),
    );
  }
}