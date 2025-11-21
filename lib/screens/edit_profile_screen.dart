import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

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

  User? _currentUser;

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
      final user = await AuthService.getCurrentUser();
      if (user != null) {
        setState(() {
          _currentUser = user;
          _fullNameController.text = user.fullName;
          _emailController.text = user.email;
          _phoneController.text = user.phone;
          _addressController.text = user.address;
        });
        print('📥 EditProfileScreen - Loaded user data:');
        print('   - Full Name: ${user.fullName}');
        print('   - Email: ${user.email}');
        print('   - Phone: "${user.phone}"');
        print('   - Address: "${user.address}"');
        print('   - User ID: ${user.id}');
      } else {
        print('❌ EditProfileScreen - No user data found');
      }
    } catch (e) {
      print('💥 EditProfileScreen - Error loading user profile: $e');
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

          // Only proceed if there are changes
          if (updateData.isNotEmpty) {
            print('🚀 Sending profile update with data: $updateData');
            print('🔑 User ID: ${_currentUser!.id}');

            final result = await AuthService.updateProfile(updateData);

            if (result['success']) {
              print('✅ Profile update successful');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Profile updated successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.pop(context);
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
            }
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

  // TEMPORARY: Simple avatar without profile photo
  Widget _buildProfileAvatar() {
    return CircleAvatar(
      radius: 60,
      backgroundColor: Colors.grey[300],
      child: Icon(Icons.person, size: 50, color: Colors.grey[600]),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
              // Profile Picture Section (Simplified)
              Center(
                child: Column(
                  children: [
                    _buildProfileAvatar(),
                    SizedBox(height: 10),
                    Text(
                      'Profile photo',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
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
