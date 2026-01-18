// lib/config/route_helper.dart - FIXED VERSION
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
import '../screens/service/write_review_screen.dart';

// Booking Screens
import '../screens/booking/booking_screen.dart';
import '../screens/booking/booking_confirmation_screen.dart';
import '../screens/booking/payment_method_screen.dart';
import '../screens/booking/skip_payment_confirmation_screen.dart';

// Profile Screens
import '../screens/profile/edit_profile_screen.dart';

// Notifications Screen
import '../screens/notifications/notifications_screen.dart';

// Search Screen
import '../screens/search/search_screen.dart';

// Settings Screens
import '../screens/settings/settings_screen.dart';
import '../screens/settings/help_support_screen.dart';
import '../screens/settings/faq_screen.dart';
import '../screens/settings/privacy_policy_screen.dart';

// Models
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

  // Legal Pages
  static const String termsAndPrivacy = '/terms-and-privacy';

  // Original separate pages (optional)
  static const String termsOfServiceContent = '/terms-of-service';
  static const String privacyPolicyContent = '/privacy-policy';

  // Settings Routes
  static const String settings = '/settings';
  static const String helpAndSupport = '/help-support';
  static const String faq = '/faq';
  static const String privacyPolicy = '/privacy-policy';

  // Main app sections
  static const String home = '/home';
  static const String bookings = '/bookings';
  static const String payments = '/payments';
  static const String profile = '/profile';

  // Service navigation
  static const String serviceList = '/service-list';
  static const String serviceDetail = '/service-detail';
  static const String reviews = '/reviews';
  static const String writeReview = '/write-review';

  // Booking flow
  static const String booking = '/booking';
  static const String paymentMethod = '/payment-method';
  static const String skipPayment = '/skip-payment';
  static const String bookingConfirmation = '/booking-confirmation';

  // Profile
  static const String editProfile = '/edit-profile';

  // Notifications route
  static const String notifications = '/notifications';

  // Search route
  static const String search = '/search';

  // Route generator
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    // Get the route name from settings
    final routeName = settings.name;

    // Use if-else instead of switch to avoid constant pattern error
    if (routeName == initial) {
      return MaterialPageRoute(builder: (_) => const LandingPage());
    } else if (routeName == login) {
      return MaterialPageRoute(builder: (_) => const LoginScreen());
    } else if (routeName == register) {
      return MaterialPageRoute(builder: (_) => const RegisterScreen());
    } else if (routeName == main) {
      return MaterialPageRoute(builder: (_) => const MainScreen());
    } else if (routeName == home) {
      return MaterialPageRoute(builder: (_) => const HomeScreen());
    } else if (routeName == bookings) {
      return MaterialPageRoute(builder: (_) => const BookingsScreen());
    } else if (routeName == payments) {
      return MaterialPageRoute(builder: (_) => const PaymentsScreen());
    } else if (routeName == profile) {
      return MaterialPageRoute(builder: (_) => const ProfileScreen());
    } else if (routeName == settings) {
      return MaterialPageRoute(builder: (_) => const SettingsScreen());
    } else if (routeName == helpAndSupport) {
      return MaterialPageRoute(builder: (_) => const HelpSupportScreen());
    } else if (routeName == faq) {
      return MaterialPageRoute(builder: (_) => const FAQScreen());
    } else if (routeName == privacyPolicy) {
      return MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen());
    } else if (routeName == homeContent) {
      return MaterialPageRoute(builder: (_) => const HomeContent());
    } else if (routeName == aboutContent) {
      return MaterialPageRoute(builder: (_) => const AboutContent());
    } else if (routeName == contactContent) {
      return MaterialPageRoute(builder: (_) => const ContactContent());
    } else if (routeName == howItWorksContent) {
      return MaterialPageRoute(builder: (_) => const HowItWorksContent());
    } else if (routeName == search) {
      return MaterialPageRoute(builder: (_) => const SearchScreen());
    } else if (routeName == serviceList) {
      if (args is String) {
        return MaterialPageRoute(
          builder: (_) => ServiceListScreen(categoryId: args),
        );
      } else if (args is Map<String, dynamic>) {
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
        return MaterialPageRoute(builder: (_) => const ServiceListScreen());
      }
    } else if (routeName == serviceDetail) {
      if (args is String) {
        return MaterialPageRoute(
          builder: (_) => ServiceDetailScreen(serviceId: args),
        );
      } else if (args is Map<String, dynamic>) {
        return MaterialPageRoute(
          builder: (_) => ServiceDetailScreen(
            serviceId: args['serviceId'] as String,
            service: args['service'] as ServiceModel?,
          ),
        );
      } else if (args is ServiceModel) {
        return MaterialPageRoute(
          builder: (_) => ServiceDetailScreen(
            serviceId: args.id,
            service: args,
          ),
        );
      }
      return _errorRoute('Service ID required for service detail');
    } else if (routeName == reviews) {
      if (args is String) {
        return MaterialPageRoute(
          builder: (_) => ReviewsScreen(serviceId: args),
        );
      } else if (args is Map<String, dynamic>) {
        return MaterialPageRoute(
          builder: (_) => ReviewsScreen(
            serviceId: args['serviceId'] as String,
            serviceName: args['serviceName'] as String?,
          ),
        );
      }
      return _errorRoute('Service ID required for reviews');
    } else if (routeName == writeReview) {
      if (args is Map<String, dynamic>) {
        return MaterialPageRoute(
          builder: (_) => WriteReviewScreen(
            serviceId: args['serviceId'] as String,
            serviceName: args['serviceName'] as String?,
            bookingId: args['bookingId'] as String?,
          ),
        );
      }
      return _errorRoute('Service ID required for writing review');
    } else if (routeName == booking) {
      if (args is String) {
        return MaterialPageRoute(
          builder: (_) => BookingScreen(serviceId: args),
        );
      } else if (args is Map<String, dynamic>) {
        final serviceId = args['serviceId'] as String?;
        final providerId = args['providerId'] as String?;
        final service = args['service'] as ServiceModel?;

        if (serviceId == null) {
          return _errorRoute('Service ID is required for booking');
        }

        return MaterialPageRoute(
          builder: (_) => BookingScreen(
            serviceId: serviceId,
            providerId: providerId,
          ),
        );
      } else if (args is ServiceModel) {
        return MaterialPageRoute(
          builder: (_) => BookingScreen(serviceId: args.id),
        );
      }
      return _errorRoute('Service ID required for booking');
    } else if (routeName == paymentMethod) {
      if (args is Map<String, dynamic>) {
        try {
          String serviceId = '';
          String providerId = '';
          Map<String, dynamic> bookingData = {};

          if (args['service'] is ServiceModel) {
            serviceId = (args['service'] as ServiceModel).id;
          } else if (args['serviceId'] != null) {
            serviceId = args['serviceId'].toString();
          } else if (args['service'] is Map<String, dynamic>) {
            final serviceMap = args['service'] as Map<String, dynamic>;
            serviceId = serviceMap['id']?.toString() ?? 
                       serviceMap['serviceId']?.toString() ?? 
                       serviceMap['_id']?.toString() ?? '';
          }

          providerId = args['providerId']?.toString() ?? '';

          bookingData = {
            'totalAmount': args['totalAmount'] as double? ?? 0.0,
            'bookingDate': args['bookingDate']?.toString() ?? '',
            'notes': args['notes']?.toString(),
            'startTime': args['selectedSlot']?['startTime']?.toString() ??
                       args['startTime']?.toString() ?? '',
            'endTime': args['selectedSlot']?['endTime']?.toString() ??
                     args['endTime']?.toString() ?? '',
          };

          if (serviceId.isEmpty) {
            return _errorRoute('Service ID is required');
          }
          if (providerId.isEmpty) {
            return _errorRoute('Provider ID is required');
          }

          debugPrint('Creating PaymentMethodScreen with Service ID: $serviceId, Provider ID: $providerId');

          return MaterialPageRoute(
            builder: (_) => PaymentMethodScreen(
              bookingData: bookingData,
              serviceId: serviceId,
              providerId: providerId,
            ),
          );
        } catch (e) {
          debugPrint('Error creating PaymentMethodScreen: $e');
          return _errorRoute('Error creating payment screen: $e');
        }
      }
      return _errorRoute('Payment method screen requires booking data');
    } else if (routeName == skipPayment) {
      try {
        if (args is Map<String, dynamic>) {
          String serviceId = '';
          String providerId = '';
          Map<String, dynamic> bookingData = {};

          if (args['service'] is ServiceModel) {
            serviceId = (args['service'] as ServiceModel).id;
          } else if (args['serviceId'] != null) {
            serviceId = args['serviceId'].toString();
          }

          providerId = args['providerId']?.toString() ?? '';

          bookingData = {
            'totalAmount': args['totalAmount'] as double? ?? 0.0,
            'bookingDate': args['bookingDate']?.toString() ?? '',
            'notes': args['notes']?.toString(),
            'startTime': args['selectedSlot']?['startTime']?.toString() ?? '',
            'endTime': args['selectedSlot']?['endTime']?.toString() ?? '',
          };

          return MaterialPageRoute(
            builder: (_) => PaymentMethodScreen(
              bookingData: bookingData,
              serviceId: serviceId,
              providerId: providerId,
            ),
          );
        }
      } catch (e) {
        debugPrint('SkipPayment screen not found or error: $e');
        return _errorRoute('Skip payment feature not available');
      }
      return _errorRoute('Skip payment requires booking data');
    } else if (routeName == bookingConfirmation) {
      if (args is Map<String, dynamic>) {
        final booking = args['booking'];
        BookingModel bookingModel;

        if (booking is BookingModel) {
          bookingModel = booking;
        } else if (booking is Map<String, dynamic>) {
          try {
            bookingModel = BookingModel.fromJson(booking);
          } catch (e) {
            return _errorRoute('Invalid booking data format');
          }
        } else {
          return _errorRoute('Booking data required');
        }

        return MaterialPageRoute(
          builder: (_) => BookingConfirmationScreen(
            booking: bookingModel,
            paymentResult: args['paymentResult'] as Map<String, dynamic>?,
            skipPayment: args['skipPayment'] as bool? ?? false,
          ),
        );
      }
      return _errorRoute('Booking confirmation data required');
    } else if (routeName == editProfile) {
      return MaterialPageRoute(builder: (_) => const EditProfileScreen());
    } else if (routeName == notifications) {
      return MaterialPageRoute(builder: (_) => const NotificationsScreen());
    } else if (routeName == termsAndPrivacy) {
      return MaterialPageRoute(builder: (_) => const LandingPage());
    } else if (routeName == termsOfServiceContent) {
      return MaterialPageRoute(builder: (_) => const LandingPage());
    } else if (routeName == privacyPolicyContent) {
      return MaterialPageRoute(builder: (_) => const LandingPage());
    } else {
      return _errorRoute('Route not found: $routeName');
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

  // Settings Navigation Helpers
  static void goToSettings(BuildContext context) {
    pushNamed(context, settings);
  }

  static void goToHelpSupport(BuildContext context) {
    pushNamed(context, helpAndSupport);
  }

  static void goToFAQ(BuildContext context) {
    pushNamed(context, faq);
  }

  static void goToPrivacyPolicy(BuildContext context) {
    pushNamed(context, privacyPolicy);
  }

  /// Navigate to service detail
  static void goToServiceDetail(BuildContext context, String serviceId) {
    pushNamed(context, serviceDetail, arguments: serviceId);
  }

  /// Navigate to service detail with ServiceModel
  static void goToServiceDetailWithModel(
      BuildContext context, ServiceModel service) {
    pushNamed(context, serviceDetail, arguments: service);
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

  /// Navigate to search screen
  static void goToSearch(BuildContext context) {
    pushNamed(context, search);
  }

  /// Navigate to booking flow with provider ID
  static void goToBookingWithProvider({
    required BuildContext context,
    required String serviceId,
    required String providerId,
    ServiceModel? service,
  }) {
    debugPrint('Navigating to booking with provider ID: $providerId');

    pushNamed(
      context,
      booking,
      arguments: {
        'serviceId': serviceId,
        'providerId': providerId,
        if (service != null) 'service': service,
      },
    );
  }

  /// Navigate to booking flow (legacy)
  static void goToBooking(BuildContext context, String serviceId) {
    pushNamed(context, booking, arguments: serviceId);
  }

  /// Navigate to booking flow with ServiceModel
  static void goToBookingWithModel(BuildContext context, ServiceModel service) {
    pushNamed(context, booking, arguments: service);
  }

  /// Navigate to payment method selection
  static void goToPaymentMethod(
    BuildContext context, {
    required ServiceModel service,
    required Map<String, dynamic> selectedSlot,
    required double totalAmount,
    required String bookingDate,
    String? notes,
    String? providerId,
    String? providerName,
  }) {
    debugPrint('Navigating to payment method with Service ID: ${service.id}');

    pushNamed(
      context,
      paymentMethod,
      arguments: {
        'service': service,
        'serviceId': service.id,
        'providerId': providerId,
        'selectedSlot': selectedSlot,
        'totalAmount': totalAmount,
        'bookingDate': bookingDate,
        'notes': notes,
        'providerName': providerName,
      },
    );
  }

  /// Navigate to skip payment
  static void goToSkipPayment(
    BuildContext context, {
    required ServiceModel service,
    required Map<String, dynamic> selectedSlot,
    required double totalAmount,
    required String bookingDate,
    String? notes,
    String? providerId,
    String? providerName,
  }) {
    debugPrint('Navigating to skip payment with Service ID: ${service.id}');

    pushNamed(
      context,
      skipPayment,
      arguments: {
        'service': service,
        'serviceId': service.id,
        'providerId': providerId,
        'selectedSlot': selectedSlot,
        'totalAmount': totalAmount,
        'bookingDate': bookingDate,
        'notes': notes,
        'providerName': providerName,
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

  /// Navigate to write review screen
  static void goToWriteReview(
    BuildContext context, {
    required String serviceId,
    String? serviceName,
    String? bookingId,
  }) {
    pushNamed(
      context,
      writeReview,
      arguments: {
        'serviceId': serviceId,
        'serviceName': serviceName,
        'bookingId': bookingId,
      },
    );
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

  /// Navigate to notifications screen
  static void goToNotifications(BuildContext context) {
    pushNamed(context, notifications);
  }

  /// Navigate to pending payments screen
  static void goToPendingPayments(BuildContext context) {
    pushNamed(context, payments);
  }

  /// Navigate with data preservation
  static void goToScreenWithData(
    BuildContext context,
    String routeName,
    Map<String, dynamic> data,
  ) {
    pushNamed(context, routeName, arguments: data);
  }

  /// Clear navigation stack and go to screen
  static void clearStackAndGo(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    pushNamedAndRemoveUntil(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// Show loading dialog
  static void showLoadingDialog(BuildContext context,
      {String message = 'Loading...'}) {
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
    VoidCallback? onPressed,
    bool autoDismiss = true,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[400]),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: onPressed ??
                () {
                  if (autoDismiss) Navigator.pop(context);
                },
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
        title: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green),
            const SizedBox(width: 8),
            Text(title),
          ],
        ),
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
    Color confirmColor = Colors.red,
    Color cancelColor = Colors.grey,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(foregroundColor: cancelColor),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Show booking confirmation dialog
  static Future<bool> showBookingConfirmationDialog(
    BuildContext context, {
    required String serviceName,
    required String providerName,
    required String date,
    required String time,
    required double amount,
  }) async {
    return await showConfirmDialog(
      context,
      title: 'Confirm Booking',
      message: 'Confirm booking for:\n\n'
          '• Service: $serviceName\n'
          '• Provider: $providerName\n'
          '• Date: $date\n'
          '• Time: $time\n'
          '• Amount: ${amount.toStringAsFixed(2)} ETB\n\n'
          'Proceed with booking?',
      confirmText: 'Book Now',
      cancelText: 'Cancel',
      confirmColor: Colors.green,
    );
  }

  /// Show payment confirmation dialog
  static Future<bool> showPaymentConfirmationDialog(
    BuildContext context, {
    required String paymentMethod,
    required double amount,
  }) async {
    return await showConfirmDialog(
      context,
      title: 'Confirm Payment',
      message: 'Confirm payment of ${amount.toStringAsFixed(2)} ETB '
          'via $paymentMethod?\n\n'
          'This action cannot be undone.',
      confirmText: 'Pay Now',
      cancelText: 'Cancel',
      confirmColor: Colors.green,
    );
  }

  /// Show logout confirmation dialog
  static Future<bool> showLogoutConfirmationDialog(BuildContext context) async {
    return await showConfirmDialog(
      context,
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmText: 'Logout',
      cancelText: 'Cancel',
    );
  }

  /// Show session expired dialog
  static void showSessionExpiredDialog(
    BuildContext context, {
    VoidCallback? onLoginPressed,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Session Expired'),
        content: const Text('Your session has expired. Please login again.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onLoginPressed?.call();
              goToLogin(context);
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  /// Show notification permission dialog
  static Future<bool> showNotificationPermissionDialog(
    BuildContext context,
  ) async {
    return await showConfirmDialog(
      context,
      title: 'Enable Notifications',
      message: 'Allow Infinity Booking to send you notifications about '
          'your bookings, reminders, and promotions?',
      confirmText: 'Allow',
      cancelText: 'Not Now',
      confirmColor: Colors.green,
    );
  }

  /// Show notification settings dialog
  static void showNotificationSettingsDialog(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notification Settings'),
        content: const Text(
            'Manage your notification preferences in device settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Open device notification settings
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Show mark all notifications read dialog
  static Future<bool> showMarkAllReadDialog(
    BuildContext context,
  ) async {
    return await showConfirmDialog(
      context,
      title: 'Mark All as Read',
      message: 'Are you sure you want to mark all notifications as read?',
      confirmText: 'Mark All',
      cancelText: 'Cancel',
      confirmColor: Colors.blue,
    );
  }
}