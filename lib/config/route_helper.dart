// lib/config/route_helper.dart - UPDATED WITH FIXES
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
import '../screens/main/bookings_screen.dart';
import '../screens/main/payments_screen.dart';
import '../screens/main/profile_screen.dart';

// Service Screens
import '../screens/service/service_list_screen.dart';
import '../screens/service/service_detail_screen.dart';
import '../screens/service/reviews_screen.dart';

// Booking Screens
import '../screens/booking/booking_screen.dart';
import '../screens/booking/booking_confirmation_screen.dart';
import '../screens/booking/payment_method_screen.dart';
import '../screens/booking/skip_payment_confirmation_screen.dart';

// Profile Screens
import '../screens/profile/edit_profile_screen.dart';

// Models (ADD THESE IMPORTS)
import '../models/booking_model.dart';
import '../models/service_model.dart';

class RouteHelper {
  // Initial/landing routes
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

  // Main app sections
  static const String home = '/home';
  static const String bookings = '/bookings';
  static const String payments = '/payments';
  static const String profile = '/profile';

  // Service navigation
  static const String serviceList = '/service-list';
  static const String serviceDetail = '/service-detail';
  static const String reviews = '/reviews';

  // Booking flow
  static const String booking = '/booking';
  static const String paymentMethod = '/payment-method';
  static const String skipPayment = '/skip-payment';
  static const String bookingConfirmation = '/booking-confirmation';

  // Profile
  static const String editProfile = '/edit-profile';

  // Route generator
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

      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case bookings:
        return MaterialPageRoute(builder: (_) => const BookingsScreen());

      case payments:
        return MaterialPageRoute(builder: (_) => const PaymentsScreen());

      case profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());

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

      // Service List with filtering
      case serviceList:
        // Handle arguments for filtering
        if (args is String) {
          // Category ID passed as string
          return MaterialPageRoute(
            builder: (_) => ServiceListScreen(categoryId: args),
          );
        } else if (args is Map<String, dynamic>) {
          // Multiple filter parameters
          return MaterialPageRoute(
            builder: (_) => ServiceListScreen(
              categoryId: args['categoryId'] as String?,
              subcategoryId: args['subcategoryId'] as String?,
              searchQuery: args['searchQuery'] as String?,
              categoryName: args['categoryName'] as String?,
              subcategoryName: args['subcategoryName'] as String?,
            ),
          );
        } else {
          // No filters
          return MaterialPageRoute(builder: (_) => const ServiceListScreen());
        }

      // Service Detail
      case serviceDetail:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => ServiceDetailScreen(serviceId: args),
          );
        } else if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => ServiceDetailScreen(
              serviceId: args['serviceId'] as String,
            ),
          );
        }
        return _errorRoute('Service ID required for service detail');

      // Reviews Screen
      case reviews:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => ReviewsScreen(serviceId: args),
          );
        } else if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => ReviewsScreen(
              serviceId: args['serviceId'] as String,
            ),
          );
        }
        return _errorRoute('Service ID required for reviews');

      // Booking Screen
      case booking:
        if (args is String) {
          return MaterialPageRoute(
            builder: (_) => BookingScreen(serviceId: args),
          );
        } else if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => BookingScreen(
              serviceId: args['serviceId'] as String,
            ),
          );
        }
        return _errorRoute('Service ID required for booking');

      // Payment Method Screen
      case paymentMethod:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => PaymentMethodScreen(
              service: args['service'] as ServiceModel, // FIXED: Cast to ServiceModel
              selectedSlot: args['selectedSlot'] as Map<String, dynamic>,
              totalAmount: args['totalAmount'] as double,
              bookingDate: args['bookingDate'] as String,
              notes: args['notes'] as String?,
            ),
          );
        }
        return _errorRoute('Payment method screen requires booking data');

      // Skip Payment Confirmation Screen
      case skipPayment:
        if (args is Map<String, dynamic>) {
          return MaterialPageRoute(
            builder: (_) => SkipPaymentConfirmationScreen(
              service: args['service'] as ServiceModel, // FIXED: Cast to ServiceModel
              selectedSlot: args['selectedSlot'] as Map<String, dynamic>,
              totalAmount: args['totalAmount'] as double,
              bookingDate: args['bookingDate'] as String,
              notes: args['notes'] as String?,
            ),
          );
        }
        return _errorRoute('Skip payment screen requires booking data');

      // Booking Confirmation Screen
      case bookingConfirmation:
        if (args is Map<String, dynamic>) {
          // FIXED: Properly handle arguments
          final booking = args['booking'];
          if (booking is BookingModel) {
            return MaterialPageRoute(
              builder: (_) => BookingConfirmationScreen(
                booking: booking,
                paymentResult: args['paymentResult'] as Map<String, dynamic>?,
                skipPayment: args['skipPayment'] as bool? ?? false,
              ),
            );
          } else if (booking is Map<String, dynamic>) {
            // Convert map to BookingModel
            try {
              final bookingModel = BookingModel.fromJson(booking);
              return MaterialPageRoute(
                builder: (_) => BookingConfirmationScreen(
                  booking: bookingModel,
                  paymentResult: args['paymentResult'] as Map<String, dynamic>?,
                  skipPayment: args['skipPayment'] as bool? ?? false,
                ),
              );
            } catch (e) {
              return _errorRoute('Invalid booking data format');
            }
          }
        }
        return _errorRoute('Booking confirmation data required');

      // Edit Profile
      case editProfile:
        return MaterialPageRoute(builder: (_) => const EditProfileScreen());

      default:
        return _errorRoute('Route not found');
    }
  }

  // Error route
  static MaterialPageRoute _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('Error'),
          backgroundColor: Colors.red,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red[400],
                ),
                const SizedBox(height: 20),
                Text(
                  'Route Error',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    // Navigate back to home
                    // You might want to use a Navigator key or context
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                  ),
                  child: const Text(
                    'Go to Home',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper methods for navigation

  /// Push a named route
  static Future<void> pushNamed(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) async {
    await Navigator.pushNamed(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// Push a named route and replace current
  static Future<void> pushReplacementNamed(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) async {
    await Navigator.pushReplacementNamed(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// Push a named route and remove all previous routes
  static Future<void> pushNamedAndRemoveUntil(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) async {
    await Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Push a named route and remove until a condition
  static Future<void> pushNamedAndRemoveUntilCondition(
    BuildContext context,
    String routeName,
    bool Function(Route<dynamic>) predicate, {
    Object? arguments,
  }) async {
    await Navigator.pushNamedAndRemoveUntil(
      context,
      routeName,
      predicate,
      arguments: arguments,
    );
  }

  /// Go back to previous screen
  static void pop(BuildContext context, [dynamic result]) {
    Navigator.pop(context, result);
  }

  /// Check if can pop
  static bool canPop(BuildContext context) {
    return Navigator.canPop(context);
  }

  /// Pop until a route name
  static void popUntil(BuildContext context, String routeName) {
    Navigator.popUntil(context, ModalRoute.withName(routeName));
  }

  /// Push a custom widget
  static Future<T?> push<T>(BuildContext context, Widget widget) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(builder: (_) => widget),
    );
  }

  /// Push a custom widget and replace
  static Future<T?> pushReplacement<T>(BuildContext context, Widget widget) {
    return Navigator.pushReplacement<T, T>(
      context,
      MaterialPageRoute(builder: (_) => widget),
    );
  }

  /// Push and remove all previous
  static Future<T?> pushAndRemoveAll<T>(BuildContext context, Widget widget) {
    return Navigator.pushAndRemoveUntil<T>(
      context,
      MaterialPageRoute(builder: (_) => widget),
      (route) => false,
    );
  }

  // Navigation shortcuts for common flows

  /// Navigate to service detail
  static void goToServiceDetail(BuildContext context, String serviceId) {
    pushNamed(context, serviceDetail, arguments: serviceId);
  }

  /// Navigate to service list with category filter
  static void goToServiceList(BuildContext context,
      {String? categoryId,
      String? subcategoryId,
      String? searchQuery,
      String? categoryName,
      String? subcategoryName}) {
    pushNamed(
      context,
      serviceList,
      arguments: {
        'categoryId': categoryId,
        'subcategoryId': subcategoryId,
        'searchQuery': searchQuery,
        'categoryName': categoryName,
        'subcategoryName': subcategoryName,
      },
    );
  }

  /// Navigate to booking flow
  static void goToBooking(BuildContext context, String serviceId) {
    pushNamed(context, booking, arguments: serviceId);
  }

  /// Navigate to payment method selection
  static void goToPaymentMethod(
    BuildContext context, {
    required ServiceModel service,
    required Map<String, dynamic> selectedSlot,
    required double totalAmount,
    required String bookingDate,
    String? notes,
  }) {
    pushNamed(
      context,
      paymentMethod,
      arguments: {
        'service': service,
        'selectedSlot': selectedSlot,
        'totalAmount': totalAmount,
        'bookingDate': bookingDate,
        'notes': notes,
      },
    );
  }

  /// Navigate to skip payment confirmation
  static void goToSkipPayment(
    BuildContext context, {
    required ServiceModel service,
    required Map<String, dynamic> selectedSlot,
    required double totalAmount,
    required String bookingDate,
    String? notes,
  }) {
    pushNamed(
      context,
      skipPayment,
      arguments: {
        'service': service,
        'selectedSlot': selectedSlot,
        'totalAmount': totalAmount,
        'bookingDate': bookingDate,
        'notes': notes,
      },
    );
  }

  /// Navigate to booking confirmation
  static void goToBookingConfirmation(
    BuildContext context, {
    required BookingModel booking,
    Map<String, dynamic>? paymentResult,
    bool skipPayment = false,
  }) {
    pushNamed(
      context,
      bookingConfirmation,
      arguments: {
        'booking': booking,
        'paymentResult': paymentResult,
        'skipPayment': skipPayment,
      },
    );
  }

  /// Navigate to reviews
  static void goToReviews(BuildContext context, String serviceId) {
    pushNamed(context, reviews, arguments: serviceId);
  }

  /// Navigate to edit profile
  static void goToEditProfile(BuildContext context) {
    pushNamed(context, editProfile);
  }

  /// Navigate to main app
  static void goToMainApp(BuildContext context) {
    pushReplacementNamed(context, main);
  }

  /// Navigate to login
  static void goToLogin(BuildContext context) {
    pushReplacementNamed(context, login);
  }

  /// Navigate to register
  static void goToRegister(BuildContext context) {
    pushNamed(context, register);
  }

  /// Navigate to home
  static void goToHome(BuildContext context) {
    pushReplacementNamed(context, home);
  }

  /// Navigate to bookings
  static void goToBookings(BuildContext context) {
    pushNamed(context, bookings);
  }

  /// Navigate to payments
  static void goToPayments(BuildContext context) {
    pushNamed(context, payments);
  }

  /// Navigate to profile
  static void goToProfile(BuildContext context) {
    pushNamed(context, profile);
  }

  /// Show loading dialog
  static void showLoadingDialog(BuildContext context, {String message = 'Loading...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  /// Hide loading dialog
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  /// Show error dialog
  static void showErrorDialog(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  /// Show success dialog
  static void showSuccessDialog(
    BuildContext context, {
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: const TextStyle(color: Colors.green)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: onPressed ?? () => Navigator.pop(context),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  /// Show confirmation dialog
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}