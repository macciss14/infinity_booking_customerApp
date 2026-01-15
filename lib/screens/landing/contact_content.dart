import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ContactContent extends StatefulWidget {
  const ContactContent({super.key});

  @override
  State<ContactContent> createState() => _ContactContentState();
}

class _ContactContentState extends State<ContactContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _isSubmitting = false;
  bool _showSuccess = false;

  // Forest Green Color Scheme
  final Color _primaryGreen = const Color(0xFF2E7D32);
  final Color _lightGreen = const Color(0xFF4CAF50);
  final Color _accentGreen = const Color(0xFF81C784);
  final Color _darkGreen = const Color(0xFF1B5E20);

  final List<Map<String, dynamic>> _contactMethods = [
    {
      'title': 'Email Support',
      'description': 'Get detailed help via email',
      'icon': Icons.email_rounded,
      'value': 'support@infinitybooking.com',
      'action': 'Send Email',
      'color': Color(0xFF2196F3),
      'gradient': [Color(0xFF42A5F5), Color(0xFF1976D2)],
    },
    {
      'title': 'Call Us',
      'description': 'Speak directly with our team',
      'icon': Icons.phone_rounded,
      'value': '+251 979 108 969',
      'action': 'Call Now',
      'color': Color(0xFF4CAF50),
      'gradient': [Color(0xFF66BB6A), Color(0xFF388E3C)],
    },
    {
      'title': 'Live Chat',
      'description': 'Instant messaging support',
      'icon': Icons.chat_rounded,
      'value': 'Available 24/7',
      'action': 'Start Chat',
      'color': Color(0xFFFF9800),
      'gradient': [Color(0xFFFFB74D), Color(0xFFF57C00)],
    },
    {
      'title': 'Visit Office',
      'description': 'Meet us in person',
      'icon': Icons.location_on_rounded,
      'value': 'Mekelle, Tigray\nEthiopia',
      'action': 'Get Directions',
      'color': Color(0xFF9C27B0),
      'gradient': [Color(0xFFBA68C8), Color(0xFF7B1FA2)],
    },
  ];

  final List<Map<String, dynamic>> _socialLinks = [
    {
      'icon': Icons.facebook_rounded,
      'label': 'Facebook',
      'color': Color(0xFF1877F2)
    },
    {
      'icon': Icons.camera_alt_rounded,
      'label': 'Instagram',
      'color': Color(0xFFE4405F)
    },
    {
      'icon': Icons.chat_bubble_rounded,
      'label': 'Twitter',
      'color': Color(0xFF1DA1F2)
    },
    {
      'icon': Icons.linked_camera_rounded,
      'label': 'LinkedIn',
      'color': Color(0xFF0A66C2)
    },
    {
      'icon': Icons.play_circle_filled_rounded,
      'label': 'YouTube',
      'color': Color(0xFFFF0000)
    },
  ];

  final List<Map<String, dynamic>> _faqItems = [
    {
      'question': 'How quickly do you respond?',
      'answer':
          'We typically respond within 1-2 business hours during working hours.'
    },
    {
      'question': 'Is there phone support?',
      'answer':
          'Yes, our phone support is available from 9 AM to 6 PM, Monday to Friday.'
    },
    {
      'question': 'Can I book services via contact?',
      'answer':
          'While you can inquire, we recommend using our app for instant booking.'
    },
    {
      'question': 'Do you offer enterprise solutions?',
      'answer': 'Yes, contact our sales team for custom enterprise packages.'
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

    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isSubmitting = false;
      _showSuccess = true;
    });

    // Reset form
    _formKey.currentState!.reset();

    // Hide success message after 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() => _showSuccess = false);
    }
  }

  Widget _buildContactMethodCard(Map<String, dynamic> method, bool isMobile) {
    bool isHovered = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: GestureDetector(
            onTap: () {
              // Handle contact method action
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Opening ${method['title']}...'),
                  backgroundColor: method['color'],
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: EdgeInsets.all(isMobile ? 16 : 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isHovered
                        ? method['gradient']
                        : [Colors.white, Colors.white],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(isHovered ? 0.1 : 0.05),
                      blurRadius: isHovered ? 20 : 10,
                      offset: Offset(0, isHovered ? 8 : 4),
                    ),
                  ],
                  border: Border.all(
                    color: method['color'].withOpacity(isHovered ? 0.2 : 0.1),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: isMobile ? 44 : 52,
                      height: isMobile ? 44 : 52,
                      alignment: Alignment.center,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        padding: EdgeInsets.all(isMobile ? 10 : 12),
                        decoration: BoxDecoration(
                          color: isHovered
                              ? Colors.white
                              : method['color'].withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          method['icon'],
                          color: isHovered ? method['color'] : method['color'],
                          size: isMobile ? 20 : 24,
                        ),
                      ),
                    ),
                    SizedBox(width: isMobile ? 12 : 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            method['title'],
                            style: TextStyle(
                              fontSize: isMobile ? 15 : 16,
                              fontWeight: FontWeight.w700,
                              color: isHovered ? Colors.white : method['color'],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            method['description'],
                            style: TextStyle(
                              fontSize: isMobile ? 11 : 12,
                              color: isHovered
                                  ? Colors.white.withOpacity(0.9)
                                  : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            method['value'],
                            style: TextStyle(
                              fontSize: isMobile ? 13 : 14,
                              fontWeight: FontWeight.w500,
                              color: isHovered ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: isMobile ? 8 : 12),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 12 : 16,
                        vertical: isMobile ? 6 : 8,
                      ),
                      constraints: BoxConstraints(
                        minWidth: isMobile ? 70 : 80,
                      ),
                      decoration: BoxDecoration(
                        color: isHovered ? Colors.white : method['color'],
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        method['action'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: isMobile ? 11 : 12,
                          fontWeight: FontWeight.w600,
                          color: isHovered ? method['color'] : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSocialButton(Map<String, dynamic> social, bool isMobile) {
    bool isHovered = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Opening ${social['label']}...'),
                  backgroundColor: social['color'],
                ),
              );
            },
            child: Column(
              children: [
                Container(
                  width: isMobile ? 50 : 60,
                  height: isMobile ? 50 : 60,
                  alignment: Alignment.center,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: EdgeInsets.all(isMobile ? 12 : 16),
                    decoration: BoxDecoration(
                      color: isHovered ? social['color'] : Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color:
                              Colors.black.withOpacity(isHovered ? 0.2 : 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      social['icon'],
                      color: isHovered ? Colors.white : social['color'],
                      size: isMobile ? 20 : 24,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  social['label'],
                  style: TextStyle(
                    fontSize: isMobile ? 10 : 11,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFAQItem(Map<String, dynamic> faq, bool isMobile) {
    bool isExpanded = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Material(
            borderRadius: BorderRadius.circular(12),
            color: Colors.white,
            elevation: 2,
            child: ExpansionTile(
              tilePadding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 20,
                vertical: isMobile ? 12 : 16,
              ),
              childrenPadding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 20,
                vertical: isMobile ? 12 : 16,
              ),
              leading: Icon(
                Icons.help_outline_rounded,
                color: _primaryGreen,
                size: isMobile ? 20 : 24,
              ),
              title: Text(
                faq['question'],
                style: TextStyle(
                  fontSize: isMobile ? 13 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              children: [
                Text(
                  faq['answer'],
                  style: TextStyle(
                    fontSize: isMobile ? 12 : 13,
                    color: Colors.grey[700],
                    height: 1.6,
                  ),
                ),
              ],
              onExpansionChanged: (expanded) {
                setState(() => isExpanded = expanded);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildFooterSection(bool isMobile) {
    return Container(
      margin: EdgeInsets.only(top: isMobile ? 20 : 40),
      padding: EdgeInsets.all(isMobile ? 20 : 28),
      decoration: BoxDecoration(
        color: _darkGreen,
        borderRadius: BorderRadius.circular(isMobile ? 16 : 24),
        boxShadow: [
          BoxShadow(
            color: _darkGreen.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 4,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: _accentGreen,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            'Infinity Booking System',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Seamless service booking at your fingertips',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isMobile ? 12 : 14,
              color: Colors.white.withOpacity(0.9),
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 24),

          // Links Row - Responsive
          isMobile
              ? Column(
                  children: [
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          // Navigate to How It Works tab (contains privacy)
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Learn More',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _accentGreen,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          // Already in Contact tab
                        },
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Contact Us',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: _accentGreen,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          // Navigate to How It Works tab (contains privacy)
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Learn More',
                            style: TextStyle(
                              color: _accentGreen,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _accentGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 16),
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          // Already in Contact tab
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Contact Us',
                            style: TextStyle(
                              color: _accentGreen,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

          const SizedBox(height: 20),
          Divider(
            color: Colors.white.withOpacity(0.2),
            height: 1,
          ),
          const SizedBox(height: 20),

          // Contact Info
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.email_rounded,
                    color: _accentGreen,
                    size: isMobile ? 14 : 16,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'support@infinitybooking.com',
                      style: TextStyle(
                        color: _accentGreen,
                        fontSize: isMobile ? 11 : 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isMobile ? 6 : 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.phone_rounded,
                    color: _accentGreen,
                    size: isMobile ? 14 : 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '+251 979 108 969',
                    style: TextStyle(
                      color: _accentGreen,
                      fontSize: isMobile ? 11 : 12,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: isMobile ? 16 : 24),
          Text(
            '© 2026 Infinity Booking System. All rights reserved.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _accentGreen.withOpacity(0.7),
              fontSize: isMobile ? 10 : 11,
            ),
          ),

          SizedBox(height: isMobile ? 12 : 16),
          // Social Icons in Footer
          Wrap(
            spacing: isMobile ? 12 : 16,
            runSpacing: isMobile ? 12 : 0,
            alignment: WrapAlignment.center,
            children: [
              _buildFooterSocialIcon(Icons.facebook_rounded, isMobile),
              _buildFooterSocialIcon(Icons.camera_alt_rounded, isMobile),
              _buildFooterSocialIcon(Icons.chat_bubble_rounded, isMobile),
              _buildFooterSocialIcon(Icons.linked_camera_rounded, isMobile),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterSocialIcon(IconData icon, bool isMobile) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          // Handle social media click
        },
        child: Container(
          padding: EdgeInsets.all(isMobile ? 6 : 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: _accentGreen,
            size: isMobile ? 16 : 18,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 768;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _slideAnimation.value),
            child: child,
          ),
        );
      },
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: isMobile ? 10 : 20),

              // Hero Section
              Container(
                padding: EdgeInsets.all(isMobile ? 20 : 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [_primaryGreen, _lightGreen],
                  ),
                  borderRadius: BorderRadius.circular(isMobile ? 16 : 24),
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
                        Icons.contact_support_rounded,
                        color: Colors.white,
                        size: isMobile ? 24 : 32,
                      ),
                    ),
                    SizedBox(width: isMobile ? 16 : 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Contact & Support',
                            style: TextStyle(
                              fontSize: isMobile ? 20 : 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: isMobile ? 2 : 4),
                          Text(
                            'We\'re here to help! Reach out anytime.',
                            style: TextStyle(
                              fontSize: isMobile ? 12 : 14,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: isMobile ? 24 : 40),

              // Quick Contact Methods
              Text(
                'Quick Contact Options',
                style: TextStyle(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: isMobile ? 2 : 4),
              Text(
                'Choose your preferred way to connect with us',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: isMobile ? 16 : 24),

              ..._contactMethods
                  .map((method) => _buildContactMethodCard(method, isMobile)),

              SizedBox(height: isMobile ? 24 : 40),

              // Success Message
              if (_showSuccess)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: EdgeInsets.all(isMobile ? 12 : 16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: _lightGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _lightGreen),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_rounded,
                          color: _lightGreen, size: isMobile ? 20 : 24),
                      SizedBox(width: isMobile ? 8 : 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Message Sent Successfully!',
                              style: TextStyle(
                                color: _darkGreen,
                                fontWeight: FontWeight.w600,
                                fontSize: isMobile ? 13 : 14,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'We\'ll get back to you within 24 hours.',
                              style: TextStyle(
                                color: _darkGreen.withOpacity(0.7),
                                fontSize: isMobile ? 11 : 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _showSuccess = false),
                        icon: Icon(Icons.close,
                            color: _darkGreen, size: isMobile ? 16 : 18),
                      ),
                    ],
                  ),
                ),

              // Contact Form - FIXED FOR MOBILE
              Container(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(isMobile ? 16 : 24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Send us a Message',
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: isMobile ? 2 : 4),
                    Text(
                      'Fill out the form below and we\'ll respond promptly',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: isMobile ? 16 : 24),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Responsive layout for Name and Phone
                          isMobile
                              ? Column(
                                  children: [
                                    TextFormField(
                                      controller: _nameController,
                                      decoration: InputDecoration(
                                        labelText: 'Your Name',
                                        prefixIcon: Icon(Icons.person_rounded,
                                            size: isMobile ? 20 : 24),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Colors.grey[300]!),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[50],
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: isMobile ? 14 : 16,
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return 'Please enter your name';
                                        }
                                        return null;
                                      },
                                    ),
                                    SizedBox(height: 16),
                                    TextFormField(
                                      controller: _phoneController,
                                      decoration: InputDecoration(
                                        labelText: 'Phone Number',
                                        prefixIcon: Icon(Icons.phone_rounded,
                                            size: isMobile ? 20 : 24),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                              color: Colors.grey[300]!),
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[50],
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: isMobile ? 14 : 16,
                                        ),
                                      ),
                                      keyboardType: TextInputType.phone,
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _nameController,
                                        decoration: InputDecoration(
                                          labelText: 'Your Name',
                                          prefixIcon:
                                              Icon(Icons.person_rounded),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                                color: Colors.grey[300]!),
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey[50],
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your name';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 16),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _phoneController,
                                        decoration: InputDecoration(
                                          labelText: 'Phone Number',
                                          prefixIcon: Icon(Icons.phone_rounded),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            borderSide: BorderSide(
                                                color: Colors.grey[300]!),
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey[50],
                                        ),
                                        keyboardType: TextInputType.phone,
                                      ),
                                    ),
                                  ],
                                ),
                          SizedBox(height: isMobile ? 16 : 16),

                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Email Address',
                              prefixIcon: Icon(Icons.email_rounded,
                                  size: isMobile ? 20 : 24),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: isMobile ? 14 : 16,
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: isMobile ? 16 : 16),

                          TextFormField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              labelText: 'Your Message',
                              alignLabelWithHint: true,
                              prefixIcon: Icon(Icons.message_rounded,
                                  size: isMobile ? 20 : 24),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide:
                                    BorderSide(color: Colors.grey[300]!),
                              ),
                              filled: true,
                              fillColor: Colors.grey[50],
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: isMobile ? 14 : 20,
                              ),
                            ),
                            maxLines: isMobile ? 4 : 5,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your message';
                              }
                              if (value.length < 10) {
                                return 'Message is too short';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: isMobile ? 20 : 24),

                          SizedBox(
                            width: double.infinity,
                            height: isMobile ? 52 : 56,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _primaryGreen,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 5,
                                shadowColor: _primaryGreen.withOpacity(0.3),
                              ),
                              child: _isSubmitting
                                  ? SizedBox(
                                      width: isMobile ? 20 : 24,
                                      height: isMobile ? 20 : 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(
                                            Colors.white),
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.send_rounded,
                                            size: isMobile ? 18 : 20),
                                        SizedBox(width: isMobile ? 6 : 8),
                                        Text(
                                          'Send Message',
                                          style: TextStyle(
                                            fontSize: isMobile ? 15 : 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: isMobile ? 24 : 40),

              // Social Media Section
              Text(
                'Connect With Us',
                style: TextStyle(
                  fontSize: isMobile ? 18 : 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: isMobile ? 2 : 4),
              Text(
                'Follow us for updates and announcements',
                style: TextStyle(
                  fontSize: isMobile ? 12 : 14,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: isMobile ? 16 : 24),

              Wrap(
                spacing: isMobile ? 12 : 16,
                runSpacing: isMobile ? 16 : 16,
                alignment: WrapAlignment.center,
                children: _socialLinks
                    .map((social) => _buildSocialButton(social, isMobile))
                    .toList(),
              ),

              SizedBox(height: isMobile ? 24 : 40),

              // FAQ Section
              Container(
                padding: EdgeInsets.all(isMobile ? 16 : 24),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(isMobile ? 16 : 24),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Frequently Asked Questions',
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: isMobile ? 2 : 4),
                    Text(
                      'Quick answers to common questions',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: isMobile ? 16 : 24),
                    ..._faqItems.map((faq) => _buildFAQItem(faq, isMobile)),
                    SizedBox(height: isMobile ? 16 : 20),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          // Navigate to full FAQ
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'View All FAQs',
                              style: TextStyle(
                                color: _primaryGreen,
                                fontWeight: FontWeight.w600,
                                fontSize: isMobile ? 13 : 14,
                              ),
                            ),
                            SizedBox(width: isMobile ? 6 : 8),
                            Icon(Icons.arrow_forward_rounded,
                                color: _primaryGreen, size: isMobile ? 14 : 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Footer Section
              SizedBox(height: isMobile ? 24 : 40),
              _buildFooterSection(isMobile),

              SizedBox(height: isMobile ? 40 : 60),
            ],
          ),
        ),
      ),
    );
  }
}
