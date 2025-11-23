import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mobile_app/services/auth_service.dart';
import 'package:mobile_app/utils/constants.dart';
import '../../services/image_picker_service.dart';
import '../../models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();

  bool _isObscureCurrentPassword = true;
  bool _isObscureNewPassword = true;
  bool _isObscureConfirmNewPassword = true;
  bool _isLoading = false;
  bool _isUploading = false;

  User? _currentUser;
  Uint8List? _selectedImageBytes;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      print('🔄 EditProfileScreen - Starting profile load...');
      final result = await AuthService.getProfileWithFallback();
      if (result['success'] && result['user'] != null) {
        setState(() {
          _currentUser = result['user'];
          _fullNameController.text = _currentUser!.fullName;
          _emailController.text = _currentUser!.email;
          _phoneController.text = _currentUser!.phone;
          _addressController.text = _currentUser!.address;
        });
        print('📥 EditProfileScreen - Loaded user data:');
        print('   - Full Name: ${_currentUser!.fullName}');
        print('   - Email: ${_currentUser!.email}');
        print('   - Phone: "${_currentUser!.phone}"');
        print('   - Address: "${_currentUser!.address}"');
        print('   - User ID: ${_currentUser!.id}');
        print(
          '   - Profile Photo: ${_currentUser!.profilePhoto != null && _currentUser!.profilePhoto!.isNotEmpty ? "Set" : "Not set"}',
        );
      } else {
        print('❌ EditProfileScreen - No user data found: ${result['message']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to load profile'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('💥 EditProfileScreen - Error loading user profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading profile: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      if (_currentUser != null) {
        setState(() {
          _isLoading = true;
        });

        try {
          Map<String, dynamic> updateData = {};

          // Only include changed fields
          if (_fullNameController.text != _currentUser?.fullName) {
            updateData['fullname'] = _fullNameController.text;
            print('✅ Full name changed: "${_fullNameController.text}"');
          }
          if (_phoneController.text != _currentUser?.phone) {
            updateData['phonenumber'] = _phoneController.text;
            print('✅ Phone changed: "${_phoneController.text}"');
          }
          if (_addressController.text != _currentUser?.address) {
            updateData['address'] = _addressController.text;
            print('✅ Address changed: "${_addressController.text}"');
          }

          // Upload profile photo if a new one was selected
          if (_selectedImageBytes != null) {
            print('📸 Uploading new profile photo...');
            final fileName =
                'profile_${_currentUser!.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';

            final uploadResult = await AuthService.uploadProfilePhoto(
              _selectedImageBytes!,
              fileName,
            );

            if (uploadResult['success']) {
              print('✅ Profile photo uploaded successfully');
              if (uploadResult['user'] != null) {
                setState(() {
                  _currentUser = uploadResult['user'];
                });
              }
            } else {
              print(
                  '❌ Profile photo upload failed: ${uploadResult['message']}');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Profile updated but photo upload failed: ${uploadResult['message']}'),
                  backgroundColor: Colors.orange,
                ),
              );
            }
          }

          // Only proceed with profile update if there are changes
          if (updateData.isNotEmpty || _selectedImageBytes != null) {
            if (updateData.isNotEmpty) {
              print('🚀 Sending profile update with data: $updateData');
              print('🔑 User ID: ${_currentUser!.id}');

              final result = await AuthService.updateProfile(updateData);

              if (result['success']) {
                print('✅ Profile update successful');

                // Update the current user object with the new data
                if (result['user'] != null) {
                  setState(() {
                    _currentUser = result['user'];
                  });
                }
              } else {
                print('❌ Profile update failed: ${result['message']}');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      result['message'] ?? 'Failed to update profile.',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text(_selectedImageBytes != null && updateData.isNotEmpty
                        ? 'Profile and photo updated successfully!'
                        : _selectedImageBytes != null
                            ? 'Profile photo updated successfully!'
                            : 'Profile updated successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else {
            print('ℹ️ No changes detected to save');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('No changes to save.'),
                backgroundColor: Colors.orange,
              ),
            );
            Navigator.pop(context);
          }
        } catch (e) {
          print('💥 Error updating profile: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An error occurred while updating the profile: $e'),
              backgroundColor: Colors.red,
            ),
          );
        } finally {
          setState(() {
            _isLoading = false;
            _selectedImageBytes = null;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User data not available. Cannot update profile.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fix the validation errors.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _changePassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final result = await AuthService.changePassword(
          _passwordController.text,
          _newPasswordController.text,
        );

        if (result['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                result['message'] ?? 'Password changed successfully!',
              ),
              backgroundColor: Colors.green,
            ),
          );
          _passwordController.clear();
          _newPasswordController.clear();
          _confirmNewPasswordController.clear();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Failed to change password.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred while changing the password.'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _uploadProfilePhoto() async {
    try {
      print('📸 EditProfileScreen - Starting photo selection...');

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
          _selectedImageBytes = imageBytes;
          _isUploading = true;
        });

        print('✅ Photo selected, bytes length: ${imageBytes.length}');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Photo selected. Click "Save Changes" to update.'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        print('❌ No image selected or image bytes are empty');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No image selected or image is invalid'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('💥 EditProfileScreen - Error selecting photo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error selecting photo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Widget _buildProfileAvatar() {
    final profilePhotoUrl = _currentUser?.getProfilePhotoUrl();

    return Stack(
      alignment: Alignment.center,
      children: [
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
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                ),

              // Show selected image if available, otherwise show current profile photo
              if (_selectedImageBytes != null)
                CircleAvatar(
                  radius: 60,
                  backgroundImage: MemoryImage(_selectedImageBytes!),
                  backgroundColor: Colors.grey[300],
                )
              else if (profilePhotoUrl != null && profilePhotoUrl.isNotEmpty)
                CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(profilePhotoUrl),
                  backgroundColor: Colors.grey[300],
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
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
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
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Edit Profile'),
          backgroundColor: Constants.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Edit Profile'),
          backgroundColor: Constants.primaryColor,
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.orange),
              SizedBox(height: 16),
              Text(
                'Error loading profile data',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Please try again later'),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _loadUserProfile, child: Text('Retry')),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Constants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Profile Picture Section
              Center(
                child: Column(
                  children: [
                    _buildProfileAvatar(),
                    SizedBox(height: 10),
                    Text(
                      _selectedImageBytes != null
                          ? 'New photo selected'
                          : 'Profile photo',
                      style: TextStyle(
                        color: _selectedImageBytes != null
                            ? Constants.primaryColor
                            : Colors.grey[600],
                        fontSize: 12,
                        fontWeight: _selectedImageBytes != null
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                    if (_selectedImageBytes != null)
                      Text(
                        'Click "Save Changes" to update',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 30),

              // Personal Information Section
              Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
                enabled: false,
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Address',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.home),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),
              SizedBox(height: 30),

              // Save Changes Button
              ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(
                        'Save Changes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              SizedBox(height: 30),

              // Change Password Section
              Divider(),
              SizedBox(height: 10),
              Text(
                'Change Password',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscureCurrentPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscureCurrentPassword = !_isObscureCurrentPassword;
                      });
                    },
                  ),
                ),
                obscureText: _isObscureCurrentPassword,
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscureNewPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscureNewPassword = !_isObscureNewPassword;
                      });
                    },
                  ),
                ),
                obscureText: _isObscureNewPassword,
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              TextFormField(
                controller: _confirmNewPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isObscureConfirmNewPassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isObscureConfirmNewPassword =
                            !_isObscureConfirmNewPassword;
                      });
                    },
                  ),
                ),
                obscureText: _isObscureConfirmNewPassword,
                validator: (value) {
                  if (value != null &&
                      value.isNotEmpty &&
                      value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),

              ElevatedButton(
                onPressed: _isLoading ? null : _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Change Password',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    super.dispose();
  }
}
