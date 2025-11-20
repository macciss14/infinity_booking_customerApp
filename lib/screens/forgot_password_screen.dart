// lib/screens/forgot_password_screen.dart

import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Forgot Password'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Forgot Password?',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              SizedBox(height: 20),
              Text(
                'This feature is coming soon. Please try again later.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
              ),
              SizedBox(height: 30),
              // Disabled button or a button that shows a message
              ElevatedButton(
                onPressed: () {
                  // Show a snackbar or dialog indicating the feature is not ready
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('This feature is coming soon!')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: Text(
                  'Send Reset Link',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              SizedBox(height: 15),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Go back to previous screen (e.g., Login)
                },
                child: Text('Back to Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
