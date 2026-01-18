import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';
import '../../config/route_helper.dart';
import '../../utils/constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  late Future<UserModel?> _userFuture;
  bool _isRefreshing = false;

  // Minimal color scheme matching the reference design
  final Color _primaryColor = Colors.black;
  final Color _secondaryColor = const Color(0xFF666666);
  final Color _accentColor = const Color(0xFF007AFF);
  final Color _backgroundColor = Colors.white;
  final Color _surfaceColor = const Color(0xFFF5F5F7);
  final Color _borderColor = const Color(0xFFE5E5EA);
  final Color _errorColor = const Color(0xFFFF3B30);

  @override
  void initState() {
    super.initState();
    _userFuture = _loadUserData();
  }

  Future<UserModel?> _loadUserData({bool showRefreshIndicator = false}) async {
    if (showRefreshIndicator) {
      setState(() {
        _isRefreshing = true;
      });
    }

    try {
      final user = await _authService.fetchUserProfile();
      return user;
    } catch (e) {
      final cachedUser = await _authService.getCurrentUser();
      
      if (cachedUser == null && mounted) {
        _showErrorSnackbar('Failed to load profile: ${e.toString()}');
      }
      
      return cachedUser;
    } finally {
      if (showRefreshIndicator && mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  Future<void> _refreshUserData() async {
    setState(() {
      _userFuture = _loadUserData(showRefreshIndicator: true);
    });
    await _userFuture;
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _errorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _logout() async {
    final confirmed = await _showLogoutConfirmation();
    
    if (confirmed == true && mounted) {
      try {
        _showLoadingDialog('Logging out...');
        await _authService.logout();
        _hideLoadingDialog();
        
        RouteHelper.pushNamedAndRemoveUntil(context, RouteHelper.login);
      } catch (e) {
        _hideLoadingDialog();
        if (mounted) {
          _showErrorSnackbar('Logout failed: $e');
        }
      }
    }
  }

  Future<bool?> _showLogoutConfirmation() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Colors.red),
            SizedBox(width: 12),
            Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: _primaryColor),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(color: _primaryColor),
            const SizedBox(width: 16),
            Expanded(child: Text(message)),
          ],
        ),
      ),
    );
  }

  void _hideLoadingDialog() {
    Navigator.of(context, rootNavigator: true).pop();
  }

  void _navigateToEditProfile() {
    RouteHelper.pushNamed(context, RouteHelper.editProfile);
  }

  void _navigateToPage(String routeName) {
    RouteHelper.pushNamed(context, routeName);
  }

  // UPDATED: Clean minimalist profile header
  Widget _buildProfileHeader(UserModel user) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Profile Image
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: _borderColor, width: 1.5),
                ),
                child: ClipOval(
                  child: _getProfileImage(user.profilephoto),
                ),
              ),
              const SizedBox(width: 20),
              
              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullname,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 14,
                        color: _secondaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // User status badge (like "Professional" in reference)
                    if (user.phonenumber.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: _surfaceColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _borderColor),
                        ),
                        child: Text(
                          'Verified',
                          style: TextStyle(
                            fontSize: 12,
                            color: _secondaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Quick Info - Horizontal layout
          Container(
            decoration: BoxDecoration(
              color: _surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _borderColor),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickInfoItem(
                    icon: Icons.phone_rounded,
                    label: 'Phone',
                    value: user.phonenumber.isNotEmpty ? user.phonenumber : 'Add',
                    onTap: _navigateToEditProfile,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: _borderColor,
                  ),
                  _buildQuickInfoItem(
                    icon: Icons.calendar_today_rounded,
                    label: 'Joined',
                    value: _formatDate(user.createdAt!),
                  ),
                  if (user.address != null && user.address!.isNotEmpty) ...[
                    Container(
                      width: 1,
                      height: 40,
                      color: _borderColor,
                    ),
                    _buildQuickInfoItem(
                      icon: Icons.location_on_rounded,
                      label: 'Location',
                      value: 'View',
                      onTap: _navigateToEditProfile,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoItem({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Icon(
            icon,
            size: 18,
            color: _secondaryColor,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: _secondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // UPDATED: Clean navigation item in sidebar style
  Widget _buildNavigationItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? iconColor,
    VoidCallback? onTap,
    Widget? trailing,
    bool showChevron = true,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: (iconColor ?? _accentColor).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? _accentColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: _secondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                if (showChevron)
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: _secondaryColor.withOpacity(0.5),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // NEW: Section header like in reference image
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _secondaryColor,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildProfileLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: _primaryColor),
          const SizedBox(height: 16),
          Text(
            'Loading profile...',
            style: TextStyle(color: _secondaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileError(String message) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: _errorColor,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: _secondaryColor,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _refreshUserData,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getProfileImage(String? profilePhotoUrl) {
    if (profilePhotoUrl == null || profilePhotoUrl.isEmpty) {
      return Container(
        color: _surfaceColor,
        child: Icon(
          Icons.person,
          size: 36,
          color: _secondaryColor,
        ),
      );
    }

    try {
      String completeUrl = profilePhotoUrl;
      if (!profilePhotoUrl.startsWith('http')) {
        completeUrl = '${AppConstants.baseUrl}/${profilePhotoUrl.startsWith('/') ? profilePhotoUrl.substring(1) : profilePhotoUrl}';
      }
      return Image.network(
        completeUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              color: _primaryColor,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: _surfaceColor,
            child: Icon(
              Icons.person,
              size: 36,
              color: _secondaryColor,
            ),
          );
        },
      );
    } catch (e) {
      return Container(
        color: _surfaceColor,
        child: Icon(
          Icons.person,
          size: 36,
          color: _secondaryColor,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays < 1) {
      return 'Today';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}d';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}m';
    } else {
      return '${(difference.inDays / 365).floor()}y';
    }
  }

  // UPDATED: Logout button in reference style
  Widget _buildLogoutButton() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Material(
        color: _errorColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: _logout,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: _errorColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: _errorColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sign Out',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: _errorColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Logout from your account',
                        style: TextStyle(
                          fontSize: 13,
                          color: _errorColor.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: _errorColor.withOpacity(0.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: RefreshIndicator(
        onRefresh: _refreshUserData,
        color: _primaryColor,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: const Text('Profile'),
              backgroundColor: _backgroundColor,
              foregroundColor: _primaryColor,
              elevation: 0,
              floating: true,
              actions: [
                IconButton(
                  icon: _isRefreshing
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: _primaryColor,
                          ),
                        )
                      : const Icon(Icons.refresh_rounded),
                  onPressed: _refreshUserData,
                ),
              ],
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                // Profile Header
                FutureBuilder<UserModel?>(
                  future: _userFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container(
                        height: 200,
                        child: _buildProfileLoading(),
                      );
                    } else if (snapshot.hasError) {
                      return _buildProfileError('Failed to load profile');
                    } else if (snapshot.hasData && snapshot.data != null) {
                      return _buildProfileHeader(snapshot.data!);
                    } else {
                      return _buildProfileError('User data not found');
                    }
                  },
                ),
                
                // Edit Profile Button
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: OutlinedButton.icon(
                    onPressed: _navigateToEditProfile,
                    icon: const Icon(Icons.edit_rounded, size: 18),
                    label: const Text('Edit Profile'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _primaryColor,
                      side: BorderSide(color: _borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                
                const Divider(height: 24),
                
                // Settings Section
                _buildSectionHeader('Settings'),
                _buildNavigationItem(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  subtitle: 'Manage your notifications',
                  iconColor: const Color(0xFF007AFF),
                  onTap: () {
                    RouteHelper.pushNamed(context, RouteHelper.notifications);
                  },
                ),
                
                _buildNavigationItem(
                  icon: Icons.history_outlined,
                  title: 'Booking History',
                  subtitle: 'View all your past bookings',
                  iconColor: const Color(0xFF34C759),
                  onTap: () {
                    RouteHelper.pushNamed(context, RouteHelper.bookings);
                  },
                ),
                
                const Divider(height: 8),
                
                // Support Section
                _buildSectionHeader('Support'),
                _buildNavigationItem(
                  icon: Icons.help_outline_rounded,
                  title: 'Help & Support',
                  subtitle: 'Get help and contact support',
                  iconColor: const Color(0xFFFF9500),
                  onTap: () {
                    _navigateToPage(RouteHelper.contactContent);
                  },
                ),
                
                _buildNavigationItem(
                  icon: Icons.info_outline_rounded,
                  title: 'About Us',
                  subtitle: 'Learn more about Infinity Booking',
                  iconColor: const Color(0xFF5856D6),
                  onTap: () {
                    _navigateToPage(RouteHelper.aboutContent);
                  },
                ),
                
                _buildNavigationItem(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy & Terms',
                  subtitle: 'View terms and privacy policy',
                  iconColor: const Color(0xFFAF52DE),
                  onTap: () {
                    _navigateToPage(RouteHelper.termsAndPrivacy);
                  },
                ),
                
                const Divider(height: 8),
                
                // Logout Section
                _buildSectionHeader('Account'),
                _buildLogoutButton(),
                
                // App Version (like in reference image)
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 40),
                  child: Center(
                    child: Text(
                      'v1.0.0', // Replace with your actual version
                      style: TextStyle(
                        fontSize: 13,
                        color: _secondaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}