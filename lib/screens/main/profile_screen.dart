import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../services/auth_service.dart';
import '../../services/image_picker_service.dart';
import '../../models/user_model.dart';
import '../profile/edit_profile_screen.dart';
import '../../utils/constants.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _currentUser;
  bool _isLoading = true;
  bool _isUploading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('🔄 ProfileScreen - Loading user profile...');
      final result = await AuthService.getProfileWithFallback();

      if (result['success']) {
        setState(() {
          _currentUser = result['user'];
          _isLoading = false;
        });
        print('✅ ProfileScreen - Profile loaded successfully');
        _debugUserInfo();
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = result['message'];
        });
        print('❌ ProfileScreen - Failed to load profile: $_errorMessage');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error: $e';
      });
      print('💥 ProfileScreen - Error loading profile: $e');
    }
  }

  void _debugUserInfo() {
    if (_currentUser != null) {
      print('🔍 DEBUG USER INFO:');
      print('   👤 Name: ${_currentUser!.fullName}');
      print('   📧 Email: ${_currentUser!.email}');
      print('   🆔 ID: ${_currentUser!.id}');
      print('   📸 Profile Photo: ${_currentUser!.profilePhoto}');
      print('   📞 Phone: "${_currentUser!.phone}"');
      print('   🏠 Address: "${_currentUser!.address}"');

      final hasPhoto = _currentUser!.profilePhoto != null &&
          _currentUser!.profilePhoto!.isNotEmpty;
      print('   ✅ Has Profile Photo: $hasPhoto');

      if (hasPhoto) {
        print('   🔗 Photo URL: ${_currentUser!.profilePhoto}');
        print('   🌐 Full Photo URL: ${_currentUser!.getProfilePhotoUrl()}');
      }
    }
  }

  Future<void> _uploadProfilePhoto() async {
    try {
      print('📸 ProfileScreen - Starting photo upload process...');

      Uint8List? imageBytes;

      if (kIsWeb) {
        print('🌐 Web platform detected, using web image picker...');
        imageBytes = await ImagePickerService.pickImageWeb();
      } else {
        print('📱 Mobile platform detected, using standard image picker...');
        imageBytes = await ImagePickerService.pickImageAsBytes();
      }

      if (imageBytes != null && imageBytes.isNotEmpty) {
        setState(() {
          _isUploading = true;
        });

        final fileName =
            'profile_${_currentUser!.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';

        print('🚀 Uploading to server...');
        print('   📁 File: $fileName');
        print('   📊 Size: ${imageBytes.length} bytes');
        print('   👤 User ID: ${_currentUser!.id}');

        final result = await AuthService.uploadProfilePhoto(
          imageBytes,
          fileName,
        );

        print('📸 Upload result: ${result['success']}');
        print('📸 Upload message: ${result['message']}');

        if (result['success']) {
          print('✅ Photo uploaded successfully!');

          // Update the user data immediately
          if (result['user'] != null) {
            print('   👤 Updated user received');
            setState(() {
              _currentUser = result['user'];
            });
          } else {
            print('   🔄 No user in response, reloading profile...');
            await _loadUserProfile();
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('✅ Profile photo updated successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          print('❌ Photo upload failed: ${result['message']}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ ${result['message']}'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        print('❌ No image selected or image bytes are empty');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ No image selected or image is invalid'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('💥 ProfileScreen - Error in photo upload: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('💥 Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Widget _buildProfileAvatar() {
    if (_currentUser == null) {
      return _buildDefaultAvatar();
    }

    final hasProfilePhoto = _currentUser!.profilePhoto != null &&
        _currentUser!.profilePhoto!.isNotEmpty;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Profile Avatar Container
        Container(
          width: 120,
          height: 120,
          child: Stack(
            children: [
              if (_isUploading)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Uploading...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (hasProfilePhoto)
                CircleAvatar(
                  radius: 60,
                  backgroundImage:
                      NetworkImage(_currentUser!.getProfilePhotoUrl()!),
                  backgroundColor: Colors.grey[300],
                  onBackgroundImageError: (exception, stackTrace) {
                    print('❌ Error loading profile image: $exception');
                  },
                )
              else
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[300],
                  child: Icon(Icons.person, size: 50, color: Colors.grey[600]),
                ),
            ],
          ),
        ),

        // Camera Button positioned on the photo
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Constants.primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.camera_alt, color: Colors.white, size: 20),
              onPressed: _isUploading ? null : _uploadProfilePhoto,
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultAvatar() {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.grey[300],
          child: Icon(Icons.person, size: 50, color: Colors.grey[600]),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Constants.primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: Icon(Icons.camera_alt, color: Colors.white, size: 20),
              onPressed: _isUploading ? null : _uploadProfilePhoto,
              padding: EdgeInsets.zero,
            ),
          ),
        ),
      ],
    );
  }

  void _showEditDialog(String field, String currentValue) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${_capitalize(field)}'),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter your $field',
            border: OutlineInputBorder(),
          ),
          maxLines: field == 'address' ? 3 : 1,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                await _updateField(field, controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateField(String field, String value) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final updateData = {field == 'phone' ? 'phonenumber' : field: value};

      final result = await AuthService.updateProfile(updateData);

      if (result['success']) {
        await _loadUserProfile(); // Reload to get updated data
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_capitalize(field)} updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to update $field'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating $field: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }

  Widget _buildInfoCard(IconData icon, String title, String value,
      {VoidCallback? onTap}) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, color: Constants.primaryColor),
        title: Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        subtitle: Text(
          value,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        trailing: onTap != null
            ? Icon(Icons.edit, size: 18, color: Colors.grey)
            : null,
        onTap: onTap,
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await AuthService.logout();
              Navigator.pushReplacementNamed(context, '/');
            },
            child: Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
          backgroundColor: Constants.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Profile'),
          backgroundColor: Constants.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.orange),
              SizedBox(height: 20),
              Text('Failed to load profile'),
              SizedBox(height: 10),
              Text(
                _errorMessage ?? 'Unknown error',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _loadUserProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Constants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfileScreen()),
              ).then((_) => _loadUserProfile());
            },
          ),
          IconButton(icon: Icon(Icons.refresh), onPressed: _loadUserProfile),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Photo Section
            _buildProfileAvatar(),

            SizedBox(height: 20),

            Text(
              _currentUser!.fullName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Constants.primaryColor,
              ),
            ),
            SizedBox(height: 5),
            Text(
              _currentUser!.email,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),

            SizedBox(height: 30),

            // Profile Info Cards
            _buildInfoCard(Icons.person, 'Full Name', _currentUser!.fullName),
            _buildInfoCard(Icons.email, 'Email', _currentUser!.email),
            _buildInfoCard(
              Icons.phone,
              'Phone',
              _currentUser!.phone.isEmpty
                  ? 'Not provided'
                  : _currentUser!.phone,
              onTap: () => _showEditDialog('phone', _currentUser!.phone),
            ),
            _buildInfoCard(
              Icons.home,
              'Address',
              _currentUser!.address.isEmpty
                  ? 'Not provided'
                  : _currentUser!.address,
              onTap: () => _showEditDialog('address', _currentUser!.address),
            ),

            SizedBox(height: 30),

            // Action Buttons
            ElevatedButton.icon(
              onPressed: _showLogoutDialog,
              icon: Icon(Icons.logout),
              label: Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
