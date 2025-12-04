// lib/config/route_helper.dart
import 'package:flutter/material.dart';

// Auth Screens
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';

// Landing Screens
import '../screens/landing/landing_page.dart';
import '../screens/landing/home_content.dart';
import '../screens/landing/about_content.dart';
import '../screens/landing/contact_content.dart';
import '../screens/landing/how_it_works_content.dart';
import '../screens/landing/terms_of_service_content.dart';
import '../screens/landing/privacy_policy_content.dart';

// Main App Screens
import '../screens/main/main_screen.dart';
import '../screens/main/home_screen.dart';
// ❌ Remove: import '../screens/main/services_tab_screen.dart';
import '../screens/main/bookings_screen.dart';
import '../screens/main/payments_screen.dart';
import '../screens/main/profile_screen.dart';

// Service Screens
// ❌ Remove category/subcategory screens — handled inline in ServiceListScreen
import '../screens/service/service_list_screen.dart';
import '../screens/service/service_detail_screen.dart';

// Booking Screens
import '../screens/booking/booking_screen.dart';
import '../screens/booking/booking_confirmation_screen.dart';

// Profile Screens
import '../screens/profile/edit_profile_screen.dart';

class RouteHelper {
  static const String initial = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';

  // Landing info pages
  static const String homeContent = '/home-content';
  static const String aboutContent = '/about-content';
  static const String contactContent = '/contact-content';
  static const String howItWorksContent = '/how-it-works-content';
  static const String termsOfServiceContent = '/terms-of-service';
  static const String privacyPolicyContent = '/privacy-policy';

  // ✅ Service navigation: only service list & detail
  static const String serviceList = '/service-list';
  static const String serviceDetail = '/service-detail';

  // Booking flow
  static const String booking = '/booking';
  static const String bookingConfirmation = '/booking-confirmation';

  // Profile
  static const String editProfile = '/edit-profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case initial:
        return MaterialPageRoute(builder: (_) => const LandingPage());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());

      case main:
        return MaterialPageRoute(builder: (_) => const MainScreen());

      case homeContent:
        return MaterialPageRoute(builder: (_) => const HomeContent());

      case aboutContent:
        return MaterialPageRoute(builder: (_) => const AboutContent());

      case contactContent:
        return MaterialPageRoute(builder: (_) => const ContactContent());

      case howItWorksContent:
        return MaterialPageRoute(builder: (_) => const HowItWorksContent());

      case termsOfServiceContent:
        return MaterialPageRoute(builder: (_) => const TermsOfServiceContent());

      case privacyPolicyContent:
        return MaterialPageRoute(builder: (_) => const PrivacyPolicyContent());

      // ✅ Unified service marketplace — no args needed
      case serviceList:
        return MaterialPageRoute(builder: (_) => const ServiceListScreen());

      case serviceDetail:
        if (args is String) {
          return MaterialPageRoute(
              builder: (_) => ServiceDetailScreen(serviceId: args));
        }
        return _errorRoute('Service ID required');

      case booking:
        if (args is String) {
          return MaterialPageRoute(
              builder: (_) => BookingScreen(serviceId: args));
        }
        return _errorRoute('Service ID required for booking');

      case bookingConfirmation:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => BookingConfirmationScreen(bookingData: args),
          );
        } else if (args is String) {
          return MaterialPageRoute(
            builder: (_) => BookingConfirmationScreen(
              bookingData: {'serviceId': args},
            ),
          );
        }
        return _errorRoute('Booking confirmation data required');

      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());

      default:
        return _errorRoute('Route not found');
    }
  }

  static MaterialPageRoute _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods for navigation
  static void pushNamed(BuildContext context, String routeName,
      {Object? arguments}) {
    Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  static void pushReplacementNamed(BuildContext context, String routeName,
      {Object? arguments}) {
    Navigator.pushReplacementNamed(context, routeName, arguments: arguments);
  }

  static void pushAndRemoveUntil(BuildContext context, String routeName,
      {Object? arguments}) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  static void pop(BuildContext context) {
    Navigator.pop(context);
  }

  static Future<T?> push<T>(BuildContext context, Widget widget) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(builder: (_) => widget),
    );
  }
}
