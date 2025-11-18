// lib/screens/profile_screen.dart

import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // Import AuthService
import '../models/user_model.dart'; // Import your User model
import 'edit_profile_screen.dart'; // Import the EditProfileScreen

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _currentUser;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null; // Clear any previous error
    });

    try {
      // Attempt to fetch the profile from the backend first
      final result = await AuthService.fetchUserProfile();

      if (result['success']) {
        // Fetch the updated user data from shared preferences
        final user = await AuthService.getCurrentUser();
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });
      } else {
        // If fetching from backend fails, try getting from local storage
        print('Failed to fetch profile from backend: ${result['message']}');
        _errorMessage = result['message'];

        final localUser = await AuthService.getCurrentUser();
        setState(() {
          _currentUser = localUser;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading profile: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred while loading the profile.';
      });
    }
  }

  // NEW: Function to handle the logout process
  Future<void> _performLogout() async {
    // Call the logout function from AuthService
    await AuthService.logout();

    // Navigate back to the Landing Page or Login Screen after logout
    // This will trigger the main.dart's FutureBuilder to re-evaluate isLoggedIn()
    // and show the LandingPage as the token will be cleared.
    Navigator.pushReplacementNamed(
      context,
      '/',
    ); // Navigates back to the initial route (LandingPage if not logged in)
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Profile')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Profile')),
        body: Center(child: Text('Error loading profile data.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          // Add an Edit button to navigate to EditProfileScreen
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfileScreen()),
              ).then((_) {
                // Optionally, reload profile data after editing
                _loadUserProfile();
              });
            },
          ),
          // Add the Logout button to the AppBar
          IconButton(
            icon: Icon(Icons.logout, color: Colors.red),
            onPressed: _performLogout, // Call the new _performLogout function
          ),
        ],
      ),
      body: SingleChildScrollView(
        // Make the profile content scrollable
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_errorMessage != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    'Warning: $_errorMessage',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              // Header with Avatar, Full Name, and Email
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundImage:
                          _currentUser?.profilePictureUrl !=
                              null // Check if profilePictureUrl is not null
                          ? NetworkImage(_currentUser!.profilePictureUrl!)
                                as ImageProvider // Show from network using the correct field name
                          : AssetImage(
                              'assets/default_avatar.png',
                            ), // Default avatar if null
                      backgroundColor: Colors.grey[300],
                    ),
                    SizedBox(height: 20),
                    Text(
                      _currentUser!.fullName,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _currentUser!.email,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Divider(),
              SizedBox(height: 10),
              // Details List
              _buildDetailItem(
                Icons.person,
                'Full Name',
                _currentUser!.fullName,
              ),
              _buildDetailItem(
                Icons.phone,
                'Phone',
                _currentUser!.phone.isEmpty
                    ? 'Not provided'
                    : _currentUser!.phone,
              ), // Handle empty string
              _buildDetailItem(Icons.home, 'Address', _currentUser!.address),
              // Add more fields if available in your User model
              // _buildDetailItem(Icons.calendar_today, 'Member Since', _currentUser!.registrationDate.toString().split('T')[0]),

              // Add a button to refresh profile data if needed
              SizedBox(height: 20),
              ElevatedButton(
                onPressed:
                    _loadUserProfile, // Refresh button calls the same function
                child: Text('Refresh Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
                Text(value, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
