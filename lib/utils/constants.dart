// lib/utils/constants.dart - COMPLETE UPDATED VERSION
import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'Infinity Booking';
  static const String appVersion = '1.0.0';

  // API Configuration — ✅ CORRECTED
  static const String baseUrl =
      'https://infinity-booking-backend1.onrender.com';
  static const String apiBaseUrl = '$baseUrl/'; // ✅ Trailing slash

  // ==================== AUTH ENDPOINTS ====================
  static const String registerEndpoint =
      'infinity-booking/auth/register/customer';
  static const String loginEndpoint = 'infinity-booking/auth/login';
  static const String logoutEndpoint = 'infinity-booking/auth/logout';
  static const String changePasswordEndpoint =
      'infinity-booking/users/change-password';

  // ==================== USER ENDPOINTS ====================
  static const String profileEndpoint = 'infinity-booking/users/profile';
  static const String updateProfileEndpoint = 'infinity-booking/users/';
  static const String uploadPhotoEndpoint =
      'infinity-booking/users/profile-photo/upload';
  static const String currentUserEndpoint = 'infinity-booking/users/current';

  // ==================== PROVIDER ENDPOINTS ====================
  static const String providerEndpoint = 'infinity-booking/providers/{id}';
  static const String providerByPidEndpoint =
      'infinity-booking/users/providers/by-pid/{pid}';

  // ==================== CATEGORY & SUBCATEGORY ENDPOINTS ====================
  static const String categoriesEndpoint = 'infinity-booking/categories';
  static const String categoryDetailEndpoint =
      'infinity-booking/categories/{id}';
  static const String subcategoriesEndpoint =
      'infinity-booking/categories/{id}/subcategories';
  static const String subcategoryDetailEndpoint =
      'infinity-booking/subcategories/{id}';

  // ==================== SERVICE ENDPOINTS ====================
  static const String servicesEndpoint = 'infinity-booking/services';
  static const String servicesByCategoryEndpoint =
      'infinity-booking/services/category/{id}';
  static const String servicesBySubcategoryEndpoint =
      'infinity-booking/services/subcategory/{subcategoryId}';
  static const String serviceDetailEndpoint = 'infinity-booking/services/{id}';
  static const String featuredServicesEndpoint =
      'infinity-booking/services/featured';
  static const String popularServicesEndpoint =
      'infinity-booking/services/popular';
  static const String searchServicesEndpoint =
      'infinity-booking/services/search';
  static const String serviceSlotsEndpoint =
      'infinity-booking/services/{serviceId}/slots';

  // ==================== BOOKING ENDPOINTS ====================
  // ✅ COMPLETE BOOKING ENDPOINTS FROM YOUR API DOC
  static const String createBookingEndpoint = 'infinity-booking/bookings';
  static const String getAllBookingsEndpoint = 'infinity-booking/bookings';
  static const String bookingDetailEndpoint = 'infinity-booking/bookings/{id}';
  static const String bookingsByCustomerEndpoint = 'infinity-booking/bookings/customer/{customerId}';
  static const String bookingsByProviderEndpoint = 'infinity-booking/bookings/provider/{providerId}';
  static const String bookingsByServiceEndpoint = 'infinity-booking/bookings/service/{serviceId}';
  static const String customerBookingStatsEndpoint = 'infinity-booking/bookings/stats/customer/{customerId}';
  
  // Booking actions
  static const String cancelBookingEndpoint = 'infinity-booking/bookings/{id}/cancel';
  static const String updateBookingStatusEndpoint = 'infinity-booking/bookings/{id}/status';
  static const String rescheduleBookingEndpoint = 'infinity-booking/bookings/{id}/reschedule';
  static const String checkSlotAvailabilityEndpoint = 'infinity-booking/bookings/check-availability';
  static const String completeBookingEndpoint = 'infinity-booking/bookings/{id}/complete';
  static const String rateBookingEndpoint = 'infinity-booking/bookings/{id}/rate';

  // ==================== REVIEW ENDPOINTS ====================
  // ✅ COMPLETE REVIEW ENDPOINTS FROM YOUR API DOC
  static const String createReviewEndpoint = 'infinity-booking/reviews';
  static const String getAllReviewsEndpoint = 'infinity-booking/reviews';
  static const String serviceReviewsEndpoint = 'infinity-booking/reviews/service/{serviceId}';
  static const String providerReviewsEndpoint = 'infinity-booking/reviews/provider/{providerId}';
  static const String userReviewsEndpoint = 'infinity-booking/reviews/my-reviews';
  static const String reviewDetailEndpoint = 'infinity-booking/reviews/{id}';
  static const String updateReviewEndpoint = 'infinity-booking/reviews/{id}';
  static const String deleteReviewEndpoint = 'infinity-booking/reviews/{id}';
  static const String reportReviewEndpoint = 'infinity-booking/reviews/{id}/report';
  static const String serviceReviewStatsEndpoint = 'infinity-booking/reviews/service/{serviceId}/stats';
  static const String providerReviewStatsEndpoint = 'infinity-booking/reviews/provider/{providerId}/stats';
  static const String canReviewServiceEndpoint = 'infinity-booking/reviews/can-review/{serviceId}';
  static const String canReviewBookingEndpoint = 'infinity-booking/reviews/can-review-booking/{bookingId}';
  static const String reviewHelpfulEndpoint = 'infinity-booking/reviews/{id}/helpful';

  // ==================== NOTIFICATION ENDPOINTS ====================
  // ✅ COMPLETE NOTIFICATION ENDPOINTS FROM YOUR API DOC
  static const String createNotificationEndpoint = 'infinity-booking/notifications';
  static const String getAllNotificationsEndpoint = 'infinity-booking/notifications';
  static const String sendNotificationEndpoint = 'infinity-booking/notifications/send';
  static const String userNotificationsEndpoint = 'infinity-booking/notifications/my-notifications';
  static const String unreadNotificationsCountEndpoint = 'infinity-booking/notifications/unread-count';
  static const String notificationDetailEndpoint = 'infinity-booking/notifications/{id}';
  static const String updateNotificationEndpoint = 'infinity-booking/notifications/{id}';
  static const String deleteNotificationEndpoint = 'infinity-booking/notifications/{id}';
  static const String markNotificationReadEndpoint = 'infinity-booking/notifications/{id}/read';
  static const String markNotificationUnreadEndpoint = 'infinity-booking/notifications/{id}/unread';
  static const String bulkUpdateNotificationsEndpoint = 'infinity-booking/notifications/bulk/update';
  static const String markAllNotificationsReadEndpoint = 'infinity-booking/notifications/all/read';

  // ==================== PAYMENT ENDPOINTS ====================
  static const String processPaymentEndpoint =
      'infinity-booking/payments/process';
  static const String verifyPaymentEndpoint =
      'infinity-booking/payments/verify/{reference}';
  static const String paymentMethodsEndpoint =
      'infinity-booking/payments/methods';
  static const String paymentHistoryEndpoint =
      'infinity-booking/payments/history';

  // ==================== STORAGE KEYS ====================
  static const String tokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String firstLaunchKey = 'first_launch';
  static const String refreshTokenKey = 'refresh_token';
  static const String themeModeKey = 'theme_mode';
  static const String languageKey = 'app_language';

  // ==================== VALIDATION ====================
  static const int minPasswordLength = 8;
  static const int maxNameLength = 100;
  static const int maxEmailLength = 254;
  static const int maxPhoneLength = 20;
  static const int maxAddressLength = 500;

  // ==================== DESIGN ====================
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double smallPadding = 8.0;
  static const double mediumPadding = 12.0;
  static const double largePadding = 24.0;
  static const double appBarHeight = 56.0;
  static const double bottomNavBarHeight = 70.0;

  // ==================== TIMEOUTS ====================
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ==================== PAGINATION ====================
  static const int defaultPageSize = 20;
  static const int servicesPageSize = 12;
  static const int reviewsPageSize = 10;
  static const int bookingsPageSize = 20;
  static const int notificationsPageSize = 20;

  // ==================== HELPER METHODS ====================
  static String replacePathParams(String endpoint,
      {String? id,
      String? serviceId,
      String? subcategoryId,
      String? categoryId,
      String? reference,
      String? pid,
      String? customerId,
      String? providerId,
      String? bookingId}) {
    var result = endpoint;
    
    if (id != null) result = result.replaceAll('{id}', id);
    if (serviceId != null) result = result.replaceAll('{serviceId}', serviceId);
    if (subcategoryId != null) {
      result = result.replaceAll('{subcategoryId}', subcategoryId);
    }
    if (categoryId != null) {
      result = result.replaceAll('{categoryId}', categoryId);
    }
    if (reference != null) result = result.replaceAll('{reference}', reference);
    if (pid != null) result = result.replaceAll('{pid}', pid);
    if (customerId != null) result = result.replaceAll('{customerId}', customerId);
    if (providerId != null) result = result.replaceAll('{providerId}', providerId);
    if (bookingId != null) result = result.replaceAll('{bookingId}', bookingId);
    
    return result;
  }

  static String buildUrl(String endpoint) {
    if (endpoint.startsWith('/')) {
      endpoint = endpoint.substring(1);
    }
    return '$baseUrl/$endpoint';
  }

  static String endpointWithQuery(
      String baseEndpoint, Map<String, dynamic>? queryParams) {
    if (queryParams == null || queryParams.isEmpty) {
      return baseEndpoint;
    }
    final queryString = queryParams.entries
        .where((entry) => entry.value != null)
        .map((entry) =>
            '${entry.key}=${Uri.encodeComponent(entry.value.toString())}')
        .join('&');
    return '$baseEndpoint?$queryString';
  }
}

class AppStrings {
  // Common
  static const String appName = 'Infinity Booking';
  static const String welcome = 'Welcome';
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String tryAgain = 'Try Again';
  static const String retry = 'Retry';
  static const String cancel = 'Cancel';
  static const String confirm = 'Confirm';
  static const String save = 'Save';
  static const String edit = 'Edit';
  static const String delete = 'Delete';
  static const String back = 'Back';
  static const String next = 'Next';
  static const String submit = 'Submit';
  static const String skip = 'Skip';
  static const String done = 'Done';
  static const String close = 'Close';
  static const String viewAll = 'View All';
  static const String seeMore = 'See More';
  static const String noData = 'No data available';
  static const String noResults = 'No results found';
  static const String somethingWentWrong = 'Something went wrong';

  // Auth
  static const String login = 'Login';
  static const String register = 'Register';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String fullName = 'Full Name';
  static const String phone = 'Phone Number';
  static const String address = 'Address';
  static const String forgotPassword = 'Forgot Password?';
  static const String resetPassword = 'Reset Password';
  static const String dontHaveAccount = "Don't have an account?";
  static const String alreadyHaveAccount = "Already have an account?";
  static const String createAccount = 'Create Account';
  static const String signIn = 'Sign In';
  static const String signOut = 'Sign Out';
  static const String continueAsGuest = 'Continue as Guest';

  // Navigation
  static const String home = 'Home';
  static const String bookings = 'Bookings';
  static const String services = 'Services';
  static const String categories = 'Categories';
  static const String profile = 'Profile';
  static const String payments = 'Payments';
  static const String notifications = 'Notifications';
  static const String settings = 'Settings';

  // Service
  static const String serviceDetails = 'Service Details';
  static const String bookNow = 'Book Now';
  static const String viewDetails = 'View Details';
  static const String browseServices = 'Browse Services';
  static const String featuredServices = 'Featured Services';
  static const String popularServices = 'Popular Services';
  static const String allServices = 'All Services';
  static const String serviceProvider = 'Service Provider';
  static const String serviceType = 'Service Type';
  static const String location = 'Location';
  static const String availability = 'Availability';
  static const String price = 'Price';
  static const String duration = 'Duration';
  static const String rating = 'Rating';
  static const String reviews = 'Reviews';
  static const String writeReview = 'Write Review';

  // Booking
  static const String createBooking = 'Create Booking';
  static const String selectTimeSlot = 'Select Time Slot';
  static const String selectedSlot = 'Selected Slot';
  static const String bookingDate = 'Booking Date';
  static const String bookingTime = 'Booking Time';
  static const String bookingNotes = 'Booking Notes';
  static const String totalAmount = 'Total Amount';
  static const String bookingSummary = 'Booking Summary';
  static const String confirmBooking = 'Confirm Booking';
  static const String bookingConfirmed = 'Booking Confirmed';
  static const String bookingFailed = 'Booking Failed';
  static const String upcomingBookings = 'Upcoming Bookings';
  static const String pastBookings = 'Past Bookings';
  static const String pendingBookings = 'Pending Bookings';
  static const String cancelledBookings = 'Cancelled Bookings';
  static const String rescheduleBooking = 'Reschedule Booking';
  static const String cancelBooking = 'Cancel Booking';

  // Payment
  static const String payment = 'Payment';
  static const String paymentMethod = 'Payment Method';
  static const String selectPaymentMethod = 'Select Payment Method';
  static const String payNow = 'Pay Now';
  static const String payLater = 'Pay Later';
  static const String skipPayment = 'Skip Payment';
  static const String paymentPending = 'Payment Pending';
  static const String paymentSuccessful = 'Payment Successful';
  static const String paymentFailed = 'Payment Failed';
  static const String paymentHistory = 'Payment History';
  static const String transactionId = 'Transaction ID';
  static const String paymentReference = 'Payment Reference';

  // Status
  static const String status = 'Status';
  static const String pending = 'Pending';
  static const String confirmed = 'Confirmed';
  static const String completed = 'Completed';
  static const String cancelled = 'Cancelled';
  static const String active = 'Active';
  static const String inactive = 'Inactive';
  static const String available = 'Available';
  static const String unavailable = 'Unavailable';

  // Notifications
  static const String notificationsTitle = 'Notifications';
  static const String unreadNotifications = 'Unread Notifications';
  static const String markAllAsRead = 'Mark All as Read';
  static const String noNotifications = 'No Notifications';
  static const String notification = 'Notification';

  // Reviews
  static const String writeAReview = 'Write a Review';
  static const String yourReview = 'Your Review';
  static const String ratingRequired = 'Rating is required';
  static const String reviewSubmitted = 'Review Submitted';
  static const String editReview = 'Edit Review';
  static const String deleteReview = 'Delete Review';
  static const String reportReview = 'Report Review';
  static const String helpful = 'Helpful';
  static const String notHelpful = 'Not Helpful';

  // Validation Messages
  static const String emailRequired = 'Email is required';
  static const String invalidEmail = 'Please enter a valid email';
  static const String passwordRequired = 'Password is required';
  static const String passwordTooShort =
      'Password must be at least 8 characters';
  static const String nameRequired = 'Full name is required';
  static const String phoneRequired = 'Phone number is required';
  static const String invalidPhone = 'Please enter a valid phone number';
  static const String passwordsDontMatch = 'Passwords do not match';
  static const String addressRequired = 'Address is required';
  static const String dateRequired = 'Please select a date';
  static const String timeRequired = 'Please select a time';
  static const String slotRequired = 'Please select a time slot';
  static const String paymentMethodRequired = 'Please select a payment method';

  // Dialog Messages
  static const String logoutConfirmation = 'Are you sure you want to logout?';
  static const String cancelBookingConfirmation =
      'Are you sure you want to cancel this booking?';
  static const String deleteConfirmation =
      'Are you sure you want to delete this?';
  static const String unsavedChanges =
      'You have unsaved changes. Are you sure you want to leave?';
  static const String deleteReviewConfirmation =
      'Are you sure you want to delete this review?';
  static const String reportReviewConfirmation =
      'Are you sure you want to report this review?';

  // Error Messages
  static const String networkError =
      'Network error. Please check your internet connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String timeoutError = 'Request timeout. Please try again.';
  static const String unauthorizedError = 'Unauthorized. Please login again.';
  static const String forbiddenError = 'Access forbidden.';
  static const String notFoundError = 'Resource not found.';
  static const String conflictError = 'Conflict detected.';
  static const String badRequestError =
      'Invalid request. Please check your input.';

  // Success Messages
  static const String loginSuccess = 'Login successful!';
  static const String registerSuccess = 'Registration successful!';
  static const String profileUpdateSuccess = 'Profile updated successfully!';
  static const String bookingSuccess = 'Booking created successfully!';
  static const String paymentSuccess = 'Payment successful!';
  static const String reviewSuccess = 'Review submitted successfully!';
  static const String notificationMarkedRead = 'Notification marked as read!';
  static const String allNotificationsRead = 'All notifications marked as read!';

  // Placeholders
  static const String searchPlaceholder = 'Search services...';
  static const String notesPlaceholder =
      'Add any special instructions or notes...';
  static const String reviewPlaceholder = 'Write your review here...';
  static const String searchNotificationsPlaceholder = 'Search notifications...';
}

class AppColors {
  // Primary Brand Colors
  static const Color primary = Color(0xFF4169E1); // Royal Blue
  static const Color primaryLight = Color(0xFF1E90FF); // Dodger Blue
  static const Color primaryDark = Color(0xFF003366); // Dark Blue
  static const Color secondary = Color(0xFF20B2AA); // LightSeaGreen
  static const Color secondaryLight = Color(0xFF48D1CC); // Medium Turquoise
  static const Color accent = Color(0xFFFF6B6B); // Coral Red

  // Neutral Colors
  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color grey = Color(0xFF9E9E9E);
  static const Color greyLight = Color(0xFFE0E0E0);
  static const Color greyDark = Color(0xFF616161);

  // Backgrounds
  static const Color scaffoldBackground = Color(0xFFF8F9FA);
  static const Color cardBackground = Colors.white;
  static const Color searchBackground = Color(0xFFF5F5F5);
  static const Color chipBackground = Colors.white;
  static const Color dialogBackground = Colors.white;

  // Text Colors
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textDisabled = Color(0xFFADB5BD);
  static const Color textOnPrimary = Colors.white;
  static const Color textOnSecondary = Colors.white;

  // Status Colors
  static const Color success = Color(0xFF28A745);
  static const Color successLight = Color(0xFFD4EDDA);
  static const Color warning = Color(0xFFFFC107);
  static const Color warningLight = Color(0xFFFFF3CD);
  static const Color error = Color(0xFFDC3545);
  static const Color errorLight = Color(0xFFF8D7DA);
  static const Color info = Color(0xFF17A2B8);
  static const Color infoLight = Color(0xFFD1ECF1);

  // Notification Colors
  static const Color notificationUnread = Color(0xFFE3F2FD);
  static const Color notificationRead = Colors.white;
  static const Color notificationImportant = Color(0xFFFFF3CD);

  // Review Colors
  static const Color starFilled = Color(0xFFFFC107);
  static const Color starEmpty = Color(0xFFE0E0E0);

  // Border Colors
  static const Color borderColor = Color(0xFFCED4DA);
  static const Color borderLight = Color(0xFFE9ECEF);
  static const Color borderDark = Color(0xFF6C757D);

  // Shadow Colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowMedium = Color(0x33000000);
  static const Color shadowDark = Color(0x4D000000);
}

class AppTextStyles {
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );

  static const TextStyle pageTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyText = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle captionText = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle priceText = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.secondary,
  );

  static const TextStyle ratingText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: Colors.amber,
  );

  static const TextStyle statusText = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle notificationTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle notificationBody = TextStyle(
    fontSize: 13,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle notificationTime = TextStyle(
    fontSize: 11,
    color: AppColors.textDisabled,
  );

  static const TextStyle reviewText = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle reviewAuthor = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle reviewDate = TextStyle(
    fontSize: 11,
    color: AppColors.textDisabled,
  );
}

class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;

  static const EdgeInsets screenPadding =
      EdgeInsets.all(AppConstants.defaultPadding);
  static const EdgeInsets cardPadding =
      EdgeInsets.all(AppConstants.mediumPadding);
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: AppConstants.largePadding,
    vertical: AppConstants.mediumPadding,
  );
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    vertical: AppConstants.smallPadding,
    horizontal: AppConstants.defaultPadding,
  );
}

class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration pageTransition = Duration(milliseconds: 250);
  static const Duration toastDuration = Duration(seconds: 3);
  static const Duration notificationRefresh = Duration(minutes: 5);
}

// Helper for API responses
class ApiResponse {
  final bool success;
  final dynamic data;
  final String? message;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] ?? false,
      data: json['data'],
      message: json['message'],
      statusCode: json['statusCode'],
    );
  }
}

// Booking status helper
class BookingStatus {
  static const String pending = 'pending';
  static const String confirmed = 'confirmed';
  static const String inProgress = 'in_progress';
  static const String completed = 'completed';
  static const String cancelled = 'cancelled';
  static const String pendingPayment = 'pending_payment';

  static String getDisplayName(String status) {
    switch (status) {
      case pending:
        return 'Pending';
      case confirmed:
        return 'Confirmed';
      case inProgress:
        return 'In Progress';
      case completed:
        return 'Completed';
      case cancelled:
        return 'Cancelled';
      case pendingPayment:
        return 'Pending Payment';
      default:
        return 'Unknown';
    }
  }

  static Color getColor(String status) {
    switch (status) {
      case pending:
        return Colors.orange;
      case confirmed:
        return Colors.blue;
      case inProgress:
        return Colors.purple;
      case completed:
        return Colors.green;
      case cancelled:
        return Colors.red;
      case pendingPayment:
        return Colors.orangeAccent;
      default:
        return Colors.grey;
    }
  }
}

// Notification types
class NotificationType {
  static const String bookingCreated = 'booking_created';
  static const String bookingConfirmed = 'booking_confirmed';
  static const String bookingCancelled = 'booking_cancelled';
  static const String bookingRescheduled = 'booking_rescheduled';
  static const String paymentReceived = 'payment_received';
  static const String reviewReceived = 'review_received';
  static const String system = 'system';
  static const String promotion = 'promotion';

  static String getDisplayName(String type) {
    switch (type) {
      case bookingCreated:
        return 'New Booking';
      case bookingConfirmed:
        return 'Booking Confirmed';
      case bookingCancelled:
        return 'Booking Cancelled';
      case bookingRescheduled:
        return 'Booking Rescheduled';
      case paymentReceived:
        return 'Payment Received';
      case reviewReceived:
        return 'New Review';
      case system:
        return 'System Notification';
      case promotion:
        return 'Promotion';
      default:
        return 'Notification';
    }
  }
}

// Payment methods
class PaymentMethods {
  static const String cash = 'cash';
  static const String telebirr = 'telebirr';
  static const String chapa = 'chapa';
  static const String bankTransfer = 'bank_transfer';
  static const String card = 'card';

  static String getDisplayName(String method) {
    switch (method) {
      case cash:
        return 'Cash';
      case telebirr:
        return 'Telebirr';
      case chapa:
        return 'Chapa';
      case bankTransfer:
        return 'Bank Transfer';
      case card:
        return 'Card';
      default:
        return method;
    }
  }

  static IconData getIcon(String method) {
    switch (method) {
      case cash:
        return Icons.money;
      case telebirr:
        return Icons.phone_android;
      case chapa:
        return Icons.credit_card;
      case bankTransfer:
        return Icons.account_balance;
      case card:
        return Icons.credit_card;
      default:
        return Icons.payment;
    }
  }
}