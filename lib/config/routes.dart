import 'package:flutter/material.dart';
import '../screens/landing/landing_page.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/main/home_screen.dart';
import '../screens/main/profile_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/service/service_list_screen.dart';
import '../screens/service/service_detail_screen.dart';
import '../screens/booking/booking_screen.dart';
import '../screens/booking/booking_confirmation_screen.dart';
import '../screens/main/bookings_screen.dart';
import '../models/service_model.dart';
import '../models/booking_model.dart';

class AppRoutes {
  static const String landing = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String services = '/services';
  static const String serviceDetail = '/service-detail';
  static const String booking = '/booking';
  static const String bookingConfirmation = '/booking-confirmation';
  static const String bookings = '/bookings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case landing:
        return MaterialPageRoute(builder: (_) => LandingPage());
      case login:
        return MaterialPageRoute(builder: (_) => LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => RegisterScreen());
      case home:
        return MaterialPageRoute(builder: (_) => HomeScreen());
      case profile:
        return MaterialPageRoute(builder: (_) => ProfileScreen());
      case editProfile:
        return MaterialPageRoute(builder: (_) => EditProfileScreen());
      case services:
        return MaterialPageRoute(builder: (_) => ServiceListScreen());
      case serviceDetail:
        final service = settings.arguments as Service?;
        if (service != null) {
          return MaterialPageRoute(
            builder: (_) => ServiceDetailScreen(service: service),
          );
        } else {
          return _errorRoute('Service details require a service object');
        }
      case booking:
        final service = settings.arguments as Service?;
        if (service != null) {
          return MaterialPageRoute(
            builder: (_) => BookingScreen(service: service),
          );
        } else {
          return _errorRoute('Booking requires a service object');
        }
      case bookingConfirmation:
        final booking = settings.arguments as Booking?;
        if (booking != null) {
          return MaterialPageRoute(
            builder: (_) => BookingConfirmationScreen(booking: booking),
          );
        } else {
          return _errorRoute('Booking confirmation requires a booking object');
        }
      case bookings:
        return MaterialPageRoute(builder: (_) => BookingsScreen());
      default:
        return _errorRoute('No route defined for ${settings.name}');
    }
  }

  static MaterialPageRoute _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: Text('Error')),
        body: Center(
          child: Text(message),
        ),
      ),
    );
  }
}
