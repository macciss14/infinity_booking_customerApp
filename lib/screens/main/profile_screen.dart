import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  // Color Scheme
  final Color _primaryColor = const Color(0xFF2E7D32);
  final Color _lightPrimary = const Color(0xFF4CAF50);
  final Color _darkPrimary = const Color(0xFF1B5E20);
  final Color _accentColor = const Color(0xFF81C784);
  final Color _backgroundColor = const Color(0xFFF8FDF8);
  final Color _surfaceColor = Colors.white;
  final Color _errorColor = const Color(0xFFD32F2F);
  final Color _warningColor = const Color(0xFFFF9800);
  final Color _infoColor = const Color(0xFF2196F3);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData({bool showRefreshIndicator = false}) async {
    if (showRefreshIndicator) {
      setState(() {
        _isRefreshing = true;
      });
    }

    try {
      final user = await _authService.fetchUserProfile();
      setState(() {
        _userFuture = Future.value(user);
      });
    } catch (e) {
      final cachedUser = await _authService.getCurrentUser();
      setState(() {
        _userFuture = Future.value(cachedUser);
      });

      if (cachedUser == null && mounted) {
        _showErrorSnackbar('Failed to load profile: ${e.toString()}');
      }
    } finally {
      if (showRefreshIndicator && mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
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

  Widget _buildProfileHeader(UserModel user) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_primaryColor, _darkPrimary],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Profile Picture
            GestureDetector(
              onTap: _navigateToEditProfile,
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: _getProfileImage(user.profilephoto),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: _primaryColor, width: 2),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: _primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // User Info
            Text(
              user.fullname,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),

            Text(
              user.email,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.9),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Quick Info Row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildInfoItem(
                    icon: Icons.phone_rounded,
                    value: user.phonenumber.isNotEmpty ? user.phonenumber : 'Add phone',
                    onTap: () => _navigateToEditProfile(),
                  ),
                  Container(
                    width: 1,
                    height: 30,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  _buildInfoItem(
                    icon: Icons.calendar_today_rounded,
                    value: _formatDate(user.createdAt!),
                  ),
                  if (user.address != null && user.address!.isNotEmpty) ...[
                    Container(
                      width: 1,
                      height: 30,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    _buildInfoItem(
                      icon: Icons.location_on_rounded,
                      value: 'Address',
                      onTap: () => _navigateToEditProfile(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
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
            color: Colors.white,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    Color? iconColor,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (iconColor ?? _primaryColor).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: iconColor ?? _primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
        trailing: trailing ?? const Icon(Icons.chevron_right_rounded),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: _errorColor.withOpacity(0.2)),
      ),
      color: _errorColor.withOpacity(0.05),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _errorColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.logout_rounded,
            color: _errorColor,
            size: 20,
          ),
        ),
        title: Text(
          'Sign Out',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: _errorColor,
          ),
        ),
        subtitle: const Text(
          'Logout from your account',
          style: TextStyle(fontSize: 13),
        ),
        trailing: Icon(Icons.chevron_right_rounded, color: _errorColor),
        onTap: _logout,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileError(String message) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
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
              color: Colors.grey[700],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _loadUserData(showRefreshIndicator: true),
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
        color: _accentColor,
        child: const Icon(
          Icons.person,
          size: 40,
          color: Colors.white,
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
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: _accentColor,
            child: const Icon(
              Icons.person,
              size: 40,
              color: Colors.white,
            ),
          );
        },
      );
    } catch (e) {
      return Container(
        color: _accentColor,
        child: const Icon(
          Icons.person,
          size: 40,
          color: Colors.white,
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
      return '${difference.inDays} days';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()} months';
    } else {
      return '${(difference.inDays / 365).floor()} years';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      body: RefreshIndicator(
        onRefresh: () => _loadUserData(showRefreshIndicator: true),
        color: _primaryColor,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: const Text('My Profile'),
              backgroundColor: _surfaceColor,
              foregroundColor: _darkPrimary,
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
                  onPressed: () => _loadUserData(showRefreshIndicator: true),
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
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
                  const SizedBox(height: 24),

                  // Edit Profile Button
                  ElevatedButton.icon(
                    onPressed: _navigateToEditProfile,
                    icon: const Icon(Icons.edit_rounded, size: 20),
                    label: const Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _surfaceColor,
                      foregroundColor: _primaryColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: _primaryColor, width: 1.5),
                      ),
                      minimumSize: const Size(double.infinity, 50),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Settings Section
                  const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  _buildSettingCard(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    subtitle: 'Manage your notifications',
                    iconColor: _infoColor,
                    onTap: () {
                      RouteHelper.pushNamed(context, RouteHelper.notifications);
                    },
                  ),
                  
                  _buildSettingCard(
                    icon: Icons.help_outline_rounded,
                    title: 'Help & Support',
                    subtitle: 'Get help and contact support',
                    iconColor: _warningColor,
                    onTap: () {
                      _navigateToPage(RouteHelper.contactContent);
                    },
                  ),
                  
                  _buildSettingCard(
                    icon: Icons.info_outline_rounded,
                    title: 'About Us',
                    subtitle: 'Learn more about Infinity Booking',
                    iconColor: _primaryColor,
                    onTap: () {
                      _navigateToPage(RouteHelper.aboutContent);
                    },
                  ),
                  
                  _buildSettingCard(
                    icon: Icons.shield_outlined,
                    title: 'Terms & Privacy',
                    subtitle: 'View terms and privacy policy',
                    onTap: () {
                      _navigateToPage(RouteHelper.termsAndPrivacy);
                    },
                  ),
                  
                  _buildSettingCard(
                    icon: Icons.history_outlined,
                    title: 'Booking History',
                    subtitle: 'View all your past bookings',
                    onTap: () {
                      RouteHelper.pushNamed(context, RouteHelper.bookings);
                    },
                  ),

                  const SizedBox(height: 24),

                  // Logout Button
                  _buildLogoutButton(),
                  const SizedBox(height: 32),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}