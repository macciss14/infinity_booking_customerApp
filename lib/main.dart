import 'package:flutter/material.dart';
import 'screens/landing/landing_page.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/main/home_screen.dart';
import 'screens/main/profile_screen.dart';
import 'screens/profile/edit_profile_screen.dart';
import 'services/auth_service.dart';
import 'utils/constants.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Constants.appName,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Constants.primaryColor),
        useMaterial3: true,
      ),
      home: AuthWrapper(),
      routes: {
        '/': (context) => LandingPage(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/profile': (context) => ProfileScreen(),
        '/edit-profile': (context) => EditProfileScreen(),
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      print('🔐 AuthWrapper - Checking authentication status...');
      final isLoggedIn = await AuthService.isLoggedIn();
      print('🔐 AuthWrapper - User logged in: $isLoggedIn');

      setState(() {
        _isCheckingAuth = false;
      });
    } catch (e) {
      print('💥 AuthWrapper - Error checking auth: $e');
      setState(() {
        _isCheckingAuth = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Loading...', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      );
    }

    return FutureBuilder<bool>(
      future: AuthService.isLoggedIn(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        } else {
          bool isLoggedIn = snapshot.data ?? false;
          print('🔐 AuthWrapper - Final decision - Logged in: $isLoggedIn');

          if (isLoggedIn) {
            return HomeScreen();
          } else {
            return LandingPage();
          }
        }
      },
    );
  }
}
