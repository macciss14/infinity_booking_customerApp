// lib/main.dart

import 'package:flutter/material.dart';
import 'screens/landing_page.dart'; // Import the landing page
import 'screens/login_screen.dart'; // Import LoginScreen
import 'screens/register_screen.dart'; // Import RegisterScreen
import 'screens/home_screen.dart'; // Import HomeScreen
import 'screens/services_screen.dart'; // Import other screens
import 'screens/bookings_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/payments_screen.dart';
import 'services/auth_service.dart'; // Import AuthService
import 'utils/constants.dart'; // Import your constants

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Infinity Booking Customer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Constants.primaryColor),
        useMaterial3: true,
      ),
      // Use a FutureBuilder to check login status and set the initial screen
      home: FutureBuilder<bool>(
        future: AuthService.isLoggedIn(), // Check if user is logged in
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Show a loading indicator while checking
            return Scaffold(body: Center(child: CircularProgressIndicator()));
          } else {
            // Navigate based on login status
            bool isLoggedIn = snapshot.data ?? false;
            return isLoggedIn ? HomeScreen() : LandingPage(); // Show Home if logged in, LandingPage otherwise
          }
        },
      ),
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/services': (context) => ServicesScreen(),
        '/bookings': (context) => BookingsScreen(),
        '/profile': (context) => ProfileScreen(),
        '/payments': (context) => PaymentsScreen(),
        // Add other routes as needed later
      },
    );
  }
}
