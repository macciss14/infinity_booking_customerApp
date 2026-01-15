import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HowItWorksContent extends StatefulWidget {
  const HowItWorksContent({super.key});

  @override
  State<HowItWorksContent> createState() => _HowItWorksContentState();
}

class _HowItWorksContentState extends State<HowItWorksContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  int _currentStep = 0;
  PageController _pageController = PageController();

  final List<Map<String, dynamic>> _steps = [
    {
      'step': 1,
      'title': 'Browse & Discover',
      'description':
          'Explore thousands of professional services in our curated marketplace. Filter by category, rating, or location to find exactly what you need.',
      'icon': '🔍',
      'color': Color(0xFF4CAF50),
      'gradient': [Color(0xFF66BB6A), Color(0xFF43A047)],
      'illustration': '📱',
      'tips': [
        'Use filters to narrow results',
        'Read provider reviews',
        'Check service ratings'
      ],
    },
    {
      'step': 2,
      'title': 'Select & Schedule',
      'description':
          'Choose your preferred service provider and pick the perfect time slot that works for you. View real-time availability instantly.',
      'icon': '📅',
      'color': Color(0xFF2196F3),
      'gradient': [Color(0xFF42A5F5), Color(0xFF1E88E5)],
      'illustration': '⏰',
      'tips': [
        'Check provider availability',
        'Select convenient time',
        'Set reminders'
      ],
    },
    {
      'step': 3,
      'title': 'Book & Confirm',
      'description':
          'Confirm your booking with secure payment options. Get instant confirmation and all details sent directly to your email.',
      'icon': '✅',
      'color': Color(0xFFFF9800),
      'gradient': [Color(0xFFFFB74D), Color(0xFFF57C00)],
      'illustration': '💳',
      'tips': [
        'Multiple payment methods',
        'Instant confirmation',
        'Booking management'
      ],
    },
    {
      'step': 4,
      'title': 'Enjoy & Review',
      'description':
          'Receive your professional service and share your experience. Rate providers and help others make informed decisions.',
      'icon': '⭐',
      'color': Color(0xFF9C27B0),
      'gradient': [Color(0xFFBA68C8), Color(0xFF8E24AA)],
      'illustration': '🎯',
      'tips': [
        'Track service progress',
        'Rate your experience',
        'Get future discounts'
      ],
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

    _pageController.addListener(() {
      setState(() {
        _currentStep = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildStepIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          _steps.length,
          (index) => GestureDetector(
            onTap: () {
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              );
            },
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: index == _currentStep ? 32 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: index == _currentStep
                      ? _steps[index]['color']
                      : Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: index == _currentStep
                      ? [
                          BoxShadow(
                            color: _steps[index]['color'].withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: index == _currentStep
                    ? Center(
                        child: Text(
                          '${_steps[index]['step']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard(int index, bool isMobile) {
    final step = _steps[index];
    bool isActive = index == _currentStep;

    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
          margin: EdgeInsets.all(isMobile ? 4 : 8),
          padding: EdgeInsets.all(isMobile ? 16 : 24),
          decoration: BoxDecoration(
            gradient: isActive
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: step['gradient'],
                  )
                : null,
            color: isActive ? null : Colors.white,
            borderRadius: BorderRadius.circular(isMobile ? 16 : 24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isActive ? 0.15 : 0.05),
                blurRadius: isActive ? 20 : 10,
                offset: Offset(0, isActive ? 8 : 4),
              ),
            ],
            border: Border.all(
              color: isActive ? Colors.transparent : Colors.grey[200]!,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                padding: EdgeInsets.all(isMobile ? 12 : 20),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white.withOpacity(0.2)
                      : Colors.grey[50],
                  shape: BoxShape.circle,
                ),
                child: Text(
                  step['icon'],
                  style: TextStyle(
                    fontSize: isMobile ? 32 : 40,
                  ),
                ),
              ),
              SizedBox(height: isMobile ? 12 : 20),
              Text(
                step['title'],
                style: TextStyle(
                  fontSize: isMobile ? 18 : 22,
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.white : Colors.black,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: isMobile ? 8 : 12),
              Flexible(
                child: Text(
                  step['description'],
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    color: isActive
                        ? Colors.white.withOpacity(0.9)
                        : Colors.grey[700],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(height: isMobile ? 12 : 20),
              if (isActive) ...[
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: isMobile ? 12 : 20),
                ...step['tips']
                    .map<Widget>((tip) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 14,
                              ),
                              SizedBox(width: isMobile ? 6 : 8),
                              Expanded(
                                child: Text(
                                  tip,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: isMobile ? 12 : 13,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepDetail(bool isMobile) {
    final step = _steps[_currentStep];

    return Container(
      margin: EdgeInsets.only(top: isMobile ? 24 : 40),
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      decoration: BoxDecoration(
        color: step['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
        border: Border.all(
          color: step['color'].withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isMobile ? 8 : 12),
                decoration: BoxDecoration(
                  color: step['color'],
                  borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
                ),
                child: Text(
                  'Tip ${step['step']}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isMobile ? 10 : 12,
                  ),
                ),
              ),
              SizedBox(width: isMobile ? 8 : 12),
              Flexible(
                child: Text(
                  'Pro Tip for Success',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    fontWeight: FontWeight.w600,
                    color: step['color'],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            'For the best experience with step ${step['step']}, make sure to check provider availability in advance and read recent customer reviews to ensure quality service.',
            style: TextStyle(
              fontSize: isMobile ? 13 : 14,
              color: const Color.fromARGB(255, 132, 129, 129),
              height: 1.6,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySection(bool isMobile) {
    final bool isSmallMobile = MediaQuery.of(context).size.width < 400;
    
    return Container(
      margin: EdgeInsets.only(top: isMobile ? 24 : 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Section Header
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
              ),
              borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF1E88E5).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isMobile ? 10 : 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.privacy_tip_rounded,
                    color: Colors.white,
                    size: isMobile ? 24 : 32,
                  ),
                ),
                SizedBox(width: isMobile ? 12 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Privacy & Security',
                        style: TextStyle(
                          fontSize: isMobile ? 18 : 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Your trust is our priority. Learn how we protect your data.',
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 14,
                          color: Colors.white.withOpacity(0.9),
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

          SizedBox(height: isMobile ? 16 : 24),

          // Privacy Cards Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isSmallMobile ? 1 : (isMobile ? 1 : 2),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: isSmallMobile ? 4 : (isMobile ? 3.5 : 3),
            ),
            itemCount: 4,
            itemBuilder: (context, index) {
              final List<Map<String, dynamic>> privacyPoints = [
                {
                  'icon': Icons.lock_rounded,
                  'title': 'Data Protection',
                  'description':
                      'End-to-end encryption for all sensitive information',
                  'color': Color(0xFF2196F3),
                  'gradient': [Color(0xFF42A5F5), Color(0xFF1976D2)],
                },
                {
                  'icon': Icons.payment_rounded,
                  'title': 'Secure Payments',
                  'description': 'PCI-DSS compliant payment processing',
                  'color': Color(0xFF4CAF50),
                  'gradient': [Color(0xFF66BB6A), Color(0xFF388E3C)],
                },
                {
                  'icon': Icons.shield_rounded,
                  'title': 'Privacy First',
                  'description': 'No personal data sharing without consent',
                  'color': Color(0xFFFF9800),
                  'gradient': [Color(0xFFFFB74D), Color(0xFFF57C00)],
                },
                {
                  'icon': Icons.cookie_rounded,
                  'title': 'Transparency',
                  'description': 'Clear cookie policy and data usage',
                  'color': Color(0xFF9C27B0),
                  'gradient': [Color(0xFFBA68C8), Color(0xFF7B1FA2)],
                },
              ];

              return _buildPrivacyCard(privacyPoints[index], isMobile);
            },
          ),

          SizedBox(height: isMobile ? 16 : 24),

          // Key Information Panel - Simplified for mobile
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
              border: Border.all(
                color: Colors.blue.shade100,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Your Privacy Rights',
                  style: TextStyle(
                    fontSize: isMobile ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                  ),
                ),
                SizedBox(height: isMobile ? 8 : 12),
                if (isMobile && !isSmallMobile)
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildPrivacyRightItem(
                              'Data Access',
                              'View and download your personal data',
                              isMobile,
                            ),
                            _buildPrivacyRightItem(
                              'Correction',
                              'Update or correct inaccurate information',
                              isMobile,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildPrivacyRightItem(
                              'Deletion',
                              'Request removal of your personal data',
                              isMobile,
                            ),
                            _buildPrivacyRightItem(
                              'Consent Control',
                              'Manage your communication preferences',
                              isMobile,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                else if (isSmallMobile)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildPrivacyRightItem(
                        'Data Access',
                        'View and download your personal data',
                        isMobile,
                      ),
                      _buildPrivacyRightItem(
                        'Correction',
                        'Update or correct information',
                        isMobile,
                      ),
                      _buildPrivacyRightItem(
                        'Deletion',
                        'Request data removal',
                        isMobile,
                      ),
                      _buildPrivacyRightItem(
                        'Consent Control',
                        'Manage preferences',
                        isMobile,
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildPrivacyRightItem(
                              'Data Access',
                              'View and download your personal data',
                              isMobile,
                            ),
                            _buildPrivacyRightItem(
                              'Correction',
                              'Update or correct inaccurate information',
                              isMobile,
                            ),
                            _buildPrivacyRightItem(
                              'Deletion',
                              'Request removal of your personal data',
                              isMobile,
                            ),
                            _buildPrivacyRightItem(
                              'Consent Control',
                              'Manage your communication preferences',
                              isMobile,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 120,
                        color: Colors.grey[300],
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Need Assistance?',
                              style: TextStyle(
                                fontSize: isMobile ? 14 : 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1976D2),
                              ),
                            ),
                            SizedBox(height: isMobile ? 4 : 8),
                            Text(
                              'Our privacy team is here to help with any questions about your data.',
                              style: TextStyle(
                                fontSize: isMobile ? 12 : 14,
                                color: Colors.grey[700],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: isMobile ? 8 : 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.email_rounded,
                                  color: Colors.blue.shade700,
                                  size: 16,
                                ),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'privacy@infinitybooking.com',
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.w500,
                                      fontSize: isMobile ? 12 : 13,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isMobile ? 6 : 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  color: Colors.blue.shade700,
                                  size: 16,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Response: 24-48 hours',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: isMobile ? 11 : 13,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          SizedBox(height: isMobile ? 16 : 24),

          // Action Button
          SizedBox(
            width: double.infinity,
            height: isMobile ? 48 : 56,
            child: ElevatedButton(
              onPressed: () {
                _showPrivacyPolicyDialog(context, isMobile);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1E88E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isMobile ? 12 : 14),
                ),
                elevation: 5,
                shadowColor: Color(0xFF1E88E5).withOpacity(0.3),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.visibility_rounded, size: isMobile ? 18 : 20),
                  SizedBox(width: isMobile ? 8 : 12),
                  Flexible(
                    child: Text(
                      'View Full Privacy Policy',
                      style: TextStyle(
                        fontSize: isMobile ? 14 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyCard(Map<String, dynamic> point, bool isMobile) {
    bool isHovered = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            decoration: BoxDecoration(
              gradient: isHovered
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: point['gradient'],
                    )
                  : null,
              color: isHovered ? null : Colors.white,
              borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isHovered ? 0.15 : 0.05),
                  blurRadius: isHovered ? 20 : 8,
                  offset: Offset(0, isHovered ? 8 : 4),
                ),
              ],
              border: Border.all(
                color: isHovered
                    ? point['color'].withOpacity(0.3)
                    : Colors.grey[200]!,
                width: isHovered ? 2 : 1,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(isMobile ? 12 : 20),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: EdgeInsets.all(isMobile ? 8 : 12),
                    decoration: BoxDecoration(
                      color: isHovered
                          ? Colors.white
                          : point['color'].withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      point['icon'] as IconData,
                      color: isHovered ? point['color'] : point['color'],
                      size: isMobile ? 18 : 22,
                    ),
                  ),
                  SizedBox(width: isMobile ? 12 : 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          point['title'] as String,
                          style: TextStyle(
                            fontSize: isMobile ? 14 : 16,
                            fontWeight: FontWeight.w600,
                            color: isHovered ? Colors.white : point['color'],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: isMobile ? 2 : 4),
                        Text(
                          point['description'] as String,
                          style: TextStyle(
                            fontSize: isMobile ? 11 : 12,
                            color: isHovered
                                ? Colors.white.withOpacity(0.9)
                                : Colors.grey[700],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (!isMobile && isHovered)
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPrivacyRightItem(String title, String description, bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 4 : 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.check_circle_rounded,
            color: Colors.green.shade600,
            size: isMobile ? 14 : 16,
          ),
          SizedBox(width: isMobile ? 6 : 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: isMobile ? 11 : 12,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context, bool isMobile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Privacy Policy',
          style: TextStyle(
            fontSize: isMobile ? 18 : 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1976D2),
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Last Updated: January 2024',
                style: TextStyle(
                  fontSize: isMobile ? 10 : 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
              SizedBox(height: isMobile ? 12 : 16),
              Text(
                'At Infinity Booking, we are committed to protecting your privacy and personal information.',
                style: TextStyle(
                  fontSize: isMobile ? 13 : 14,
                  color: Colors.black87,
                  height: 1.6,
                ),
              ),
              SizedBox(height: isMobile ? 12 : 16),
              _buildPolicySection(
                title: 'Information We Collect',
                content:
                    'We collect information you provide directly, such as name, email, phone number, and booking preferences to provide our services effectively.',
                isMobile: isMobile,
              ),
              _buildPolicySection(
                title: 'How We Use Your Information',
                content:
                    'Your information is used to process bookings, improve our services, communicate updates, and ensure platform security.',
                isMobile: isMobile,
              ),
              _buildPolicySection(
                title: 'Data Security',
                content:
                    'We implement industry-standard security measures including encryption, access controls, and regular security audits.',
                isMobile: isMobile,
              ),
              _buildPolicySection(
                title: 'Your Rights',
                content:
                    'You have rights to access, correct, delete, or export your data. Contact us to exercise these rights.',
                isMobile: isMobile,
              ),
              SizedBox(height: isMobile ? 12 : 16),
              Container(
                padding: EdgeInsets.all(isMobile ? 10 : 12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact Our Privacy Team',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1976D2),
                        fontSize: isMobile ? 13 : 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Email: privacy@infinitybooking.com',
                      style: TextStyle(fontSize: isMobile ? 12 : 13),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'We respond within 24-48 hours',
                      style: TextStyle(
                        fontSize: isMobile ? 11 : 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: TextStyle(
                color: Color(0xFF1976D2),
                fontSize: isMobile ? 14 : 16,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1E88E5),
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Contact Team',
              style: TextStyle(fontSize: isMobile ? 14 : 16),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
        ),
      ),
    );
  }

  Widget _buildPolicySection({
    required String title,
    required String content,
    required bool isMobile,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: isMobile ? 6 : 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1976D2),
              fontSize: isMobile ? 14 : 15,
            ),
          ),
          SizedBox(height: 4),
          Text(
            content,
            style: TextStyle(
              fontSize: isMobile ? 12 : 13,
              color: Colors.black87,
              height: 1.5,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isMobile = size.width < 768;
    final bool isSmallMobile = size.width < 400;

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
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 12.0 : 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: isMobile ? 8 : 20),
              Container(
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2E7D32), Color(0xFF4CAF50)],
                  ),
                  borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF2E7D32).withOpacity(0.3),
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
                        Icons.play_circle_filled_rounded,
                        color: Colors.white,
                        size: isMobile ? 24 : 32,
                      ),
                    ),
                    SizedBox(width: isMobile ? 12 : 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'How Infinity Booking Works',
                            style: TextStyle(
                              fontSize: isMobile ? 18 : 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Get started in 4 simple steps',
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 14,
                              color: Colors.white.withOpacity(0.9),
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
              SizedBox(height: isMobile ? 24 : 40),

              _buildStepIndicator(),

              // Responsive PageView height
              SizedBox(
                height: isSmallMobile 
                    ? 500 
                    : (isMobile ? 450 : 400),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _steps.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentStep = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return _buildStepCard(index, isMobile);
                  },
                ),
              ),

              SizedBox(height: isMobile ? 16 : 20),

              if (isMobile) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _currentStep > 0
                          ? () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );
                            }
                          : null,
                      style: IconButton.styleFrom(
                        backgroundColor: _currentStep > 0
                            ? _steps[_currentStep]['color']
                            : Colors.grey[300],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(10),
                      ),
                      icon: const Icon(Icons.arrow_back_rounded, size: 18),
                    ),
                    SizedBox(width: isSmallMobile ? 12 : 20),
                    Text(
                      'Step ${_currentStep + 1} of ${_steps.length}',
                      style: TextStyle(
                        fontSize: isSmallMobile ? 14 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: isSmallMobile ? 12 : 20),
                    IconButton(
                      onPressed: _currentStep < _steps.length - 1
                          ? () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );
                            }
                          : null,
                      style: IconButton.styleFrom(
                        backgroundColor: _currentStep < _steps.length - 1
                            ? _steps[_currentStep]['color']
                            : Colors.grey[300],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(10),
                      ),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    ),
                  ],
                ),
                SizedBox(height: 16),
              ],

              _buildStepDetail(isMobile),

              SizedBox(height: isMobile ? 24 : 40),

              Container(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
                  border: Border.all(
                    color: Colors.grey[200]!,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: isMobile 
                      ? CrossAxisAlignment.start 
                      : CrossAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.help_outline_rounded,
                          color: Color(0xFF2E7D32),
                          size: isMobile ? 24 : 32,
                        ),
                        SizedBox(width: isMobile ? 12 : 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Need Help?',
                                style: TextStyle(
                                  fontSize: isMobile ? 16 : 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Contact our 24/7 support team for any questions.',
                                style: TextStyle(
                                  fontSize: isMobile ? 12 : 14,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (!isMobile) ...[
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                // Navigate to contact/help
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xFF2E7D32),
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                child: Text(
                                  'Get Help',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (isMobile) ...[
                      SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Navigate to contact/help
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF2E7D32),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Get Help',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(height: isMobile ? 24 : 40),

              // Privacy & Security Section
              _buildPrivacySection(isMobile),

              SizedBox(height: isMobile ? 40 : 60),
            ],
          ),
        ),
      ),
    );
  }
}