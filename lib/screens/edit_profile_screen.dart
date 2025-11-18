// lib/screens/edit_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import 'dart:convert'; // Import jsonEncode/Decode
import '../services/auth_service.dart'; // Import AuthService
import '../models/user_model.dart'; // Import your User model
import 'package:image_picker/image_picker.dart'; // For selecting profile picture
import 'dart:html' as html; // Import for web file handling
import 'dart:typed_data'; // Import for Uint8List

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey =
      GlobalKey<
        FormState
      >(); // We might keep this for password change section if needed, but not for profile fields
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emailController = TextEditingController(); // Email is read-only
  final _passwordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();

  bool _isObscureCurrentPassword = true;
  bool _isObscureNewPassword = true;
  bool _isObscureConfirmNewPassword = true;
  bool _isLoading = false;

  // Use html.File for web compatibility
  html.File? _selectedImageFile; // For profile picture
  Uint8List? _selectedImageBytes; // Store the bytes for preview as Uint8List

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
      final user = await AuthService.getCurrentUser();
      if (user != null) {
        setState(() {
          _currentUser = user;
          _fullNameController.text = user.fullName;
          _emailController.text = user.email;
          _phoneController.text = user.phone;
          _addressController.text = user.address;
        });
      }
    } catch (e) {
      print('Error loading user profile: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Convert the picked file to html.File and bytes for web compatibility
      final bytes = await pickedFile.readAsBytes();
      final fileName = pickedFile.name;
      setState(() {
        _selectedImageFile = html.File([bytes], fileName); // Create html.File
        _selectedImageBytes = Uint8List.fromList(
          bytes,
        ); // Store bytes as Uint8List for preview
      });
      // Upload the selected image
      await _uploadImage(_selectedImageFile!);
    }
  }

  Future<void> _uploadImage(html.File imageFile) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Convert the html.File to List<int> for the API call
      final reader = html.FileReader();
      reader.onLoadEnd.listen((event) {
        final bytes = reader.result as List<int>;
        final fileName = imageFile.name;
        // Call the API to upload the image
        _uploadImageBytes(bytes, fileName);
      });
      reader.onError.listen((event) {
        print('Error reading file: $event');
        setState(() {
          _isLoading = false;
        });
      });
      reader.readAsArrayBuffer(imageFile);
    } catch (e) {
      print('Error preparing image for upload: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _uploadImageBytes(List<int> imageBytes, String fileName) async {
    try {
      final result = await AuthService.uploadProfilePhoto(imageBytes, fileName);

      if (result['success']) {
        // The profile data should have been updated in the service
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Profile photo uploaded successfully!',
            ),
          ),
        );
        // Reload the profile to reflect changes
        await _loadUserProfile();
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              result['message'] ?? 'Failed to upload profile photo.',
            ),
          ),
        );
      }
    } catch (e) {
      print('Error uploading profile photo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while uploading the profile photo.'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    // DO NOT use _formKey.currentState!.validate() here for profile fields.
    // We will handle validation for changed fields only within this function.

    if (_currentUser != null) {
      // Check _currentUser is not null
      setState(() {
        _isLoading = true;
      });

      try {
        // Build a map of only the fields that have been changed
        Map<String, dynamic> partialUpdateData = {};

        // Compare controller values with original user data and add to partialUpdateData if different
        if (_fullNameController.text != _currentUser?.fullName) {
          // Optional: Add minimal validation here if needed (e.g., check for minimum length)
          partialUpdateData['fullname'] = _fullNameController.text;
        }
        if (_phoneController.text != _currentUser?.phone) {
          // Optional: Add minimal validation here if needed (e.g., check for format)
          partialUpdateData['phoneNumber'] =
              _phoneController.text; // Use the correct key expected by backend
        }
        if (_addressController.text != _currentUser?.address) {
          // Optional: Add minimal validation here if needed (e.g., check for minimum length)
          partialUpdateData['address'] = _addressController
              .text; // Use the correct key expected by backend
        }

        // Only proceed if there are actual changes to save
        if (partialUpdateData.isNotEmpty) {
          // Add the user's id to the partialUpdateData
          partialUpdateData['id'] = _currentUser!.id;

          // Call the API to update the profile with only the changed fields
          final result = await AuthService.updateProfile(partialUpdateData);

          if (result['success']) {
            // Update local cache using shared_preferences directly here
            final prefs =
                await SharedPreferences.getInstance(); // Import required
            // Fetch the updated user data again from the service to ensure consistency
            final updatedUserResult = await AuthService.fetchUserProfile();
            if (updatedUserResult['success']) {
              final updatedUser = updatedUserResult['user'] as User?;
              if (updatedUser != null) {
                await prefs.setString(
                  'user_data',
                  jsonEncode(updatedUser.toJson()),
                ); // Import required
              }
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Profile updated successfully!')),
            );

            // Navigate back to Profile Screen
            Navigator.pop(context); // Close Edit Profile Screen
          } else {
            // Show error message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['message'] ?? 'Failed to update profile.'),
              ),
            );
          }
        } else {
          // No changes were made
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('No changes to save.')));
          // Optionally, navigate back without saving
          Navigator.pop(context); // Close Edit Profile Screen
        }
      } catch (e) {
        print('Error updating profile: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred while updating the profile.'),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      // Handle case where user data is not loaded
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User data not available. Cannot update profile.'),
        ),
      );
    }
  }

  Future<void> _changePassword() async {
    // Use form validation only for the password change section
    if (_passwordController.text.isEmpty ||
        _newPasswordController.text.isEmpty ||
        _confirmNewPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all password fields.')),
      );
      return;
    }

    if (_newPasswordController.text != _confirmNewPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('New passwords do not match.')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Call the API to change the password
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
          ),
        );

        // Clear password fields
        _passwordController.clear();
        _newPasswordController.clear();
        _confirmNewPasswordController.clear();
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to change password.'),
          ),
        );
      }
    } catch (e) {
      print('Error changing password: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while changing the password.'),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Edit Profile')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Edit Profile')),
        body: Center(child: Text('Error loading profile data.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key:
              _formKey, // Keep the key if needed elsewhere, but don't use its validate method for profile fields here
          child: ListView(
            children: [
              // Profile Picture Section
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage:
                          _selectedImageBytes !=
                              null // Check for selected bytes first
                          ? MemoryImage(
                              _selectedImageBytes!,
                            ) // Use Uint8List for preview
                          : _currentUser?.profilePictureUrl != null
                          ? NetworkImage(_currentUser!.profilePictureUrl!)
                                as ImageProvider // Then from network
                          : AssetImage(
                              'assets/default_avatar.png',
                            ), // Default avatar
                      backgroundColor: Colors.grey[300],
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            width: 2,
                            color: Theme.of(context).cardColor,
                          ),
                          color: Theme.of(context).primaryColor,
                        ),
                        child: IconButton(
                          icon: Icon(Icons.edit, color: Colors.white, size: 20),
                          onPressed: _pickImage, // Trigger image picker
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Full Name Field - NO VALIDATOR
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(labelText: 'Full Name'),
                // NO VALIDATOR: Fields are optional
              ),
              SizedBox(height: 15),
              // Email Field (Read-Only)
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  suffixIcon: Icon(
                    Icons.lock,
                  ), // Add lock icon to indicate read-only
                ),
                enabled: false, // Make it read-only
              ),
              SizedBox(height: 15),
              // Phone Number Field - NO VALIDATOR
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Phone Number'),
                // NO VALIDATOR: Fields are optional
              ),
              SizedBox(height: 15),
              // Address Field - NO VALIDATOR
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
                // NO VALIDATOR: Fields are optional
              ),
              SizedBox(height: 20),
              // Save Changes Button
              ElevatedButton(
                onPressed: _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: Text(
                  'Save Changes',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 20),
              // Change Password Section
              Divider(),
              SizedBox(height: 10),
              Text(
                'Change Password',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Current Password',
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your current password';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _newPasswordController,
                decoration: InputDecoration(
                  labelText: 'New Password',
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
                  if (value == null || value.isEmpty) {
                    return 'Please enter your new password';
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters long';
                  }
                  return null;
                },
              ),
              SizedBox(height: 15),
              TextFormField(
                controller: _confirmNewPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirm New Password',
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
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your new password';
                  }
                  if (value != _newPasswordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _changePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(
                    context,
                  ).secondaryHeaderColor, // Use secondary color for change password button
                ),
                child: Text(
                  'Change Password',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              // NOTE: Logout button is now in the HomeScreen Drawer
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
