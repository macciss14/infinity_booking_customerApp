// lib/screens/main/profile_screen.dart
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load profile: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (showRefreshIndicator && mounted) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => RouteHelper.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => RouteHelper.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        RouteHelper.showLoadingDialog(context, message: 'Logging out...');
        await _authService.logout();
        RouteHelper.hideLoadingDialog(context);

        // FIXED: Use pushNamedAndRemoveUntil instead of pushAndRemoveUntil
        RouteHelper.pushNamedAndRemoveUntil(context, RouteHelper.login);
      } catch (e) {
        RouteHelper.hideLoadingDialog(context);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Logout failed: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _navigateToEditProfile() {
    RouteHelper.pushNamed(context, RouteHelper.editProfile);
  }

  void _navigateToHelpSupport() {
    RouteHelper.pushNamed(context, RouteHelper.contactContent);
  }

  void _navigateToPrivacyPolicy() {
    RouteHelper.pushNamed(context, RouteHelper.privacyPolicyContent);
  }

  void _navigateToTermsOfService() {
    RouteHelper.pushNamed(context, RouteHelper.termsOfServiceContent);
  }

  void _navigateToAbout() {
    RouteHelper.pushNamed(context, RouteHelper.aboutContent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadUserData(showRefreshIndicator: true),
            tooltip: 'Refresh Profile',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadUserData(showRefreshIndicator: true),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _isRefreshing
                  ? _buildProfileLoading()
                  : FutureBuilder<UserModel?>(
                      future: _userFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return _buildProfileLoading();
                        } else if (snapshot.hasError) {
                          return _buildProfileError('Failed to load profile');
                        } else if (snapshot.hasData && snapshot.data != null) {
                          final user = snapshot.data!;
                          return _buildProfileHeader(user);
                        } else {
                          return _buildProfileError('User data not found');
                        }
                      },
                    ),
              const SizedBox(height: 24),
              _buildMenuSection(),
              const SizedBox(height: 24),
              // Logout Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: _getProfileImage(user.profilephoto),
                  child: _getProfileImage(user.profilephoto) == null
                      ? const Icon(Icons.person, size: 60, color: Colors.grey)
                      : null,
                ),
                GestureDetector(
                  onTap: _navigateToEditProfile,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              user.fullname,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              user.email,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            if (user.phonenumber.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    user.phonenumber,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (user.address != null && user.address!.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      user.address!,
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            ...[
            const SizedBox(height: 8),
            Text(
              'Member since ${_formatDate(user.createdAt!)}',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _navigateToEditProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Edit Profile',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: Column(
        children: [
          _buildMenuTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: _navigateToHelpSupport,
          ),
          _buildDivider(),
          _buildMenuTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: _navigateToPrivacyPolicy,
          ),
          _buildDivider(),
          _buildMenuTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: _navigateToTermsOfService,
          ),
          _buildDivider(),
          _buildMenuTile(
            icon: Icons.info_outline,
            title: 'About',
            onTap: _navigateToAbout,
          ),
          _buildDivider(),
          _buildMenuTile(
            icon: Icons.settings_outlined,
            title: 'Settings',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Settings coming soon!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildProfileLoading() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.grey[200],
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Loading profile...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileError(String message) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => setState(() {
                _loadUserData();
              }),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Theme.of(context).primaryColor),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 16),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey[600],
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: Colors.grey[300],
      ),
    );
  }

  ImageProvider? _getProfileImage(String? profilePhotoUrl) {
    if (profilePhotoUrl == null || profilePhotoUrl.isEmpty) {
      return null;
    }

    try {
      if (profilePhotoUrl.startsWith('http')) {
        return NetworkImage(profilePhotoUrl);
      }

      String completeUrl = profilePhotoUrl;
      if (!profilePhotoUrl.startsWith('/')) {
        completeUrl = '/$profilePhotoUrl';
      }
      completeUrl = '${AppConstants.baseUrl}$completeUrl';

      return NetworkImage(completeUrl);
    } catch (e) {
      print('Error loading profile image: $e');
      return null;
    }
  }

  String _formatDate(DateTime date) {
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${monthNames[date.month - 1]} ${date.year}';
  }
}
