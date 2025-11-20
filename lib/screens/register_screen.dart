// lib/screens/register_screen.dart

import 'package:flutter/material.dart';
import '../services/auth_service.dart'; // Import AuthService
import 'login_screen.dart'; // Import the LoginScreen

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isObscurePassword = true;
  bool _isObscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Create a new account',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                SizedBox(height: 30),
                TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    // Add email format validation if needed
                    return null;
                  },
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    // Add phone number format validation if needed
                    return null;
                  },
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    prefixIcon: Icon(Icons.home),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscurePassword = !_isObscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _isObscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 8) {
                      return 'Password must be at least 8 characters long';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscureConfirmPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscureConfirmPassword =
                              !_isObscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _isObscureConfirmPassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _performRegister,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: 80,
                            vertical: 15,
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        child: Text(
                          'Register',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                SizedBox(height: 15),
                // Add a link to Login Screen
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Go back to Login
                  },
                  child: Text('Already have an account? Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _performRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Call the AuthService.register method with the correct field name 'phonenumber'
      final result = await AuthService.register(
        _fullNameController.text,
        _emailController.text,
        _phoneController.text, // Pass phone number as 'phonenumber'
        _addressController.text,
        _passwordController.text,
        _confirmPasswordController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (result['success']) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Registration successful!'),
          ),
        );
        // Navigate back to Login Screen
        Navigator.pop(context); // Close Register Screen, go back to Login
      } else {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Registration failed.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
