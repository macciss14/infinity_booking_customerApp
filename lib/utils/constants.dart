// lib/utils/constants.dart
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
  // NEW: OTP Registration Endpoints
  static const String requestOtpEndpoint =
      'infinity-booking/auth/register/request-otp';
  static const String verifyOtpAndRegisterEndpoint =
      'infinity-booking/auth/register/customer/verify-otp';

  // Existing auth endpoints
  static const String registerEndpoint =
      'infinity-booking/auth/register/customer';
  static const String loginEndpoint = 'infinity-booking/auth/login';
  static const String logoutEndpoint = 'infinity-booking/auth/logout';
  static const String changePasswordEndpoint =
      'infinity-booking/users/change-password';
  static const String forgotPasswordEndpoint =
      'infinity-booking/auth/forgot-password';
  static const String resetPasswordEndpoint =
      'infinity-booking/auth/reset-password';

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
  static const String providersListEndpoint = 'infinity-booking/providers';
  static const String providerServicesEndpoint =
      'infinity-booking/providers/{id}/services';

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
  static const String similarServicesEndpoint =
      'infinity-booking/services/{serviceId}/similar';

  // ==================== BOOKING ENDPOINTS ====================
  static const String createBookingEndpoint = 'infinity-booking/bookings';
  static const String getAllBookingsEndpoint = 'infinity-booking/bookings';
  static const String bookingDetailEndpoint = 'infinity-booking/bookings/{id}';
  static const String bookingsByCustomerEndpoint =
      'infinity-booking/bookings/customer/{customerId}';
  static const String bookingsByProviderEndpoint =
      'infinity-booking/bookings/provider/{providerId}';
  static const String bookingsByServiceEndpoint =
      'infinity-booking/bookings/service/{serviceId}';
  static const String customerBookingStatsEndpoint =
      'infinity-booking/bookings/stats/customer/{customerId}';
  static const String myBookingsEndpoint =
      'infinity-booking/bookings/my-bookings'; // ✅ ADDED

  // Booking actions
  static const String cancelBookingEndpoint =
      'infinity-booking/bookings/{id}/cancel';
  static const String updateBookingStatusEndpoint =
      'infinity-booking/bookings/{id}/status';
  static const String rescheduleBookingEndpoint =
      'infinity-booking/bookings/{id}/reschedule';
  static const String checkSlotAvailabilityEndpoint =
      'infinity-booking/bookings/check-availability';
  static const String completeBookingEndpoint =
      'infinity-booking/bookings/{id}/complete';
  static const String rateBookingEndpoint =
      'infinity-booking/bookings/{id}/rate';

  // ==================== REVIEW ENDPOINTS ====================
  static const String createReviewEndpoint = 'infinity-booking/reviews';
  static const String getAllReviewsEndpoint = 'infinity-booking/reviews';
  static const String serviceReviewsEndpoint =
      'infinity-booking/reviews/service/{serviceId}';
  static const String providerReviewsEndpoint =
      'infinity-booking/reviews/provider/{providerId}';
  static const String userReviewsEndpoint =
      'infinity-booking/reviews/my-reviews';
  static const String reviewDetailEndpoint = 'infinity-booking/reviews/{id}';
  static const String updateReviewEndpoint = 'infinity-booking/reviews/{id}';
  static const String deleteReviewEndpoint = 'infinity-booking/reviews/{id}';
  static const String reportReviewEndpoint =
      'infinity-booking/reviews/{id}/report';
  static const String serviceReviewStatsEndpoint =
      'infinity-booking/reviews/service/{serviceId}/stats';
  static const String providerReviewStatsEndpoint =
      'infinity-booking/reviews/provider/{providerId}/stats';
  static const String canReviewServiceEndpoint =
      'infinity-booking/reviews/can-review/{serviceId}';
  static const String canReviewBookingEndpoint =
      'infinity-booking/reviews/can-review-booking/{bookingId}';
  static const String reviewHelpfulEndpoint =
      'infinity-booking/reviews/{id}/helpful';

  // ==================== NOTIFICATION ENDPOINTS ====================
  static const String createNotificationEndpoint =
      'infinity-booking/notifications';
  static const String getAllNotificationsEndpoint =
      'infinity-booking/notifications';
  static const String sendNotificationEndpoint =
      'infinity-booking/notifications/send';
  static const String userNotificationsEndpoint =
      'infinity-booking/notifications/my-notifications';
  static const String unreadNotificationsCountEndpoint =
      'infinity-booking/notifications/unread-count';
  static const String notificationDetailEndpoint =
      'infinity-booking/notifications/{id}';
  static const String updateNotificationEndpoint =
      'infinity-booking/notifications/{id}';
  static const String deleteNotificationEndpoint =
      'infinity-booking/notifications/{id}';
  static const String markNotificationReadEndpoint =
      'infinity-booking/notifications/{id}/read';
  static const String markNotificationUnreadEndpoint =
      'infinity-booking/notifications/{id}/unread';
  static const String bulkUpdateNotificationsEndpoint =
      'infinity-booking/notifications/bulk/update';
  static const String markAllNotificationsReadEndpoint =
      'infinity-booking/notifications/all/read';

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
  static const String recentSearchesKey = 'recent_searches';
  static const String favoriteServicesKey = 'favorite_services';

  // NEW: OTP Storage Keys
  static const String otpRequestIdKey = 'otp_request_id';
  static const String otpPhoneKey = 'otp_phone';
  static const String otpExpiryKey = 'otp_expiry';

  // ==================== VALIDATION ====================
  static const int minPasswordLength = 8;
  static const int maxNameLength = 100;
  static const int maxEmailLength = 254;
  static const int maxPhoneLength = 20;
  static const int maxAddressLength = 500;
  static const int maxServiceDescription = 1000;
  static const int maxReviewLength = 1000;
  static const int maxNotesLength = 500;

  // NEW: OTP Validation
  static const int otpLength = 6;
  static const Duration otpExpiryDuration = Duration(minutes: 10);

  // ==================== DESIGN ====================
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double smallPadding = 8.0;
  static const double mediumPadding = 12.0;
  static const double largePadding = 24.0;
  static const double appBarHeight = 56.0;
  static const double bottomNavBarHeight = 70.0;
  static const double iconSize = 24.0;
  static const double smallIconSize = 20.0;
  static const double largeIconSize = 32.0;

  // Card dimensions
  static const double cardElevation = 2.0;
  static const double cardBorderRadius = 16.0;
  static const double cardPadding = 12.0;

  // Button dimensions
  static const double buttonHeight = 48.0;
  static const double buttonBorderRadius = 12.0;
  static const double smallButtonHeight = 36.0;

  // Image dimensions
  static const double avatarSize = 40.0;
  static const double serviceImageHeight = 120.0;
  static const double categoryImageSize = 48.0;

  // ==================== TIMEOUTS ====================
  static const Duration apiTimeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration refreshIndicatorTimeout = Duration(seconds: 2);

  // NEW: OTP Timeout
  static const Duration otpResendCooldown = Duration(seconds: 60);

  // ==================== PAGINATION ====================
  static const int defaultPageSize = 20;
  static const int servicesPageSize = 12;
  static const int reviewsPageSize = 10;
  static const int bookingsPageSize = 20;
  static const int notificationsPageSize = 20;
  static const int categoriesPageSize = 50;
  static const int searchResultsPageSize = 15;

  // ==================== ROUTE NAMES ====================
  static const String routeHome = '/';
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeOtpVerification = '/otp-verification';
  static const String routeServiceList = '/services';
  static const String routeServiceDetail = '/services/:id';
  static const String routeBookings = '/bookings';
  static const String routeBookingDetail = '/bookings/:id';
  static const String routeBookingConfirmation = '/booking-confirmation';
  static const String routePaymentMethod = '/payment-method';
  static const String routeProfile = '/profile';
  static const String routeEditProfile = '/edit-profile';
  static const String routeNotifications = '/notifications';
  static const String routeSearch = '/search';
  static const String routeReviews = '/reviews';
  static const String routeWriteReview = '/write-review';
  static const String routeSettings = '/settings';
  static const String routeLanding = '/landing';
  static const String routeAbout = '/about';
  static const String routeContact = '/contact';
  static const String routeHowItWorks = '/how-it-works';

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
    if (subcategoryId != null)
      result = result.replaceAll('{subcategoryId}', subcategoryId);
    if (categoryId != null)
      result = result.replaceAll('{categoryId}', categoryId);
    if (reference != null) result = result.replaceAll('{reference}', reference);
    if (pid != null) result = result.replaceAll('{pid}', pid);
    if (customerId != null)
      result = result.replaceAll('{customerId}', customerId);
    if (providerId != null)
      result = result.replaceAll('{providerId}', providerId);
    if (bookingId != null) result = result.replaceAll('{bookingId}', bookingId);

    return result;
  }

  static String buildUrl(String endpoint) {
    // Remove any leading slash if present
    if (endpoint.startsWith('/')) {
      endpoint = endpoint.substring(1);
    }

    // If endpoint already has full path, return as is
    if (endpoint.startsWith('http')) {
      return endpoint;
    }

    // Otherwise build complete URL
    if (apiBaseUrl.endsWith('/') && endpoint.startsWith('/')) {
      return '$apiBaseUrl${endpoint.substring(1)}';
    } else if (!apiBaseUrl.endsWith('/') && !endpoint.startsWith('/')) {
      return '$apiBaseUrl/$endpoint';
    } else {
      return '$apiBaseUrl$endpoint';
    }
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

  // Format currency
  static String formatCurrency(double amount, {String currency = 'ETB'}) {
    return '${amount.toStringAsFixed(2)} $currency';
  }

  // Format date
  static String formatDate(DateTime date, {bool includeTime = false}) {
    if (includeTime) {
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  // Format time
  static String formatTime(TimeOfDay time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
  }

  // Calculate duration in hours and minutes
  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    if (remainingMinutes == 0) {
      return '$hours hr';
    }
    return '$hours hr $remainingMinutes min';
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
  static const String loginWithPhone = 'Login with phone';
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
  static const String search = 'Search';
  static const String filter = 'Filter';
  static const String sort = 'Sort';
  static const String apply = 'Apply';
  static const String clear = 'Clear';
  static const String select = 'Select';
  static const String optional = 'Optional';

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
  static const String welcomeBack = 'Welcome Back';
  static const String rememberMe = 'Remember me';
  static const String signUp = 'Sign Up';
  static const String orContinueWith = 'Or continue with';
  static const String useDifferentNumber = 'Use different number';

  // NEW: OTP Registration
  static const String enterPhoneNumber = 'Enter Phone Number';
  static const String enterOtp = 'Enter OTP';
  static const String otpSentToPhone = 'OTP sent to your phone via Telegram';
  static const String otpSent = 'OTP Sent';
  static const String verifyOtp = 'Verify OTP';
  static const String resendOtp = 'Resend OTP';
  static const String sendingOtp = 'Sending OTP...';
  static const String verifyingOtp = 'Verifying OTP...';
  static const String otpVerificationSuccess = 'OTP verified successfully!';
  static const String phoneNumberRequired = 'Phone number is required';
  static const String invalidPhoneNumber = 'Please enter a valid phone number';
  static const String otpRequired = 'OTP is required';
  static const String invalidOtp = 'OTP must be 6 digits';
  static const String resendIn = 'Resend in';
  static const String seconds = 'seconds';
  static const String otpInstruction =
      'Enter the 6-digit code sent to your phone';

  // Navigation
  static const String home = 'Home';
  static const String bookings = 'Bookings';
  static const String services = 'Services';
  static const String categories = 'Categories';
  static const String profile = 'Profile';
  static const String payments = 'Payments';
  static const String notifications = 'Notifications';
  static const String settings = 'Settings';
  static const String myAccount = 'My Account';
  static const String help = 'Help';
  static const String about = 'About';
  static const String contact = 'Contact Us';
  static const String privacy = 'Privacy Policy';
  static const String terms = 'Terms of Service';

  // Home Screen
  static const String helloUser = 'Hello, {name}! 👋';
  static const String homeSubtitle = 'Book your favorite services with ease';
  static const String quickActions = 'Quick Actions';
  static const String browseServices = 'Browse Services';
  static const String myBookings = 'My Bookings';
  static const String specialOffers = 'Special Offers';
  static const String popularCategories = 'Popular Categories';
  static const String featuredServices = 'Featured Services';
  static const String recentBookings = 'Recent Bookings';
  static const String viewAllCategories = 'View All Categories';
  static const String viewAllServices = 'View All Services';
  static const String viewAllBookings = 'View All Bookings';

  // Service
  static const String serviceDetails = 'Service Details';
  static const String bookNow = 'Book Now';
  static const String viewDetails = 'View Details';
  static const String browseServicesTitle = 'Browse Services';
  static const String featuredServicesTitle = 'Featured Services';
  static const String popularServicesTitle = 'Popular Services';
  static const String allServicesTitle = 'All Services';
  static const String serviceProvider = 'Service Provider';
  static const String serviceType = 'Service Type';
  static const String location = 'Location';
  static const String availability = 'Availability';
  static const String price = 'Price';
  static const String duration = 'Duration';
  static const String rating = 'Rating';
  static const String reviews = 'Reviews';
  static const String writeReview = 'Write Review';
  static const String serviceUnavailable = 'Service Unavailable';
  static const String selectService = 'Select Service';
  static const String serviceIncludes = 'What\'s Included';
  static const String serviceRequirements = 'Requirements';
  static const String serviceNotes = 'Additional Notes';

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
  static const String bookingId = 'Booking ID';
  static const String bookingHistory = 'Booking History';
  static const String noBookings = 'No bookings yet';
  static const String bookYourFirstService = 'Book your first service!';

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
  static const String amountDue = 'Amount Due';
  static const String paymentOptions = 'Payment Options';

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
  static const String inProgress = 'In Progress';
  static const String scheduled = 'Scheduled';

  // Notifications
  static const String notificationsTitle = 'Notifications';
  static const String unreadNotifications = 'Unread Notifications';
  static const String markAllAsRead = 'Mark All as Read';
  static const String noNotifications = 'No Notifications';
  static const String notification = 'Notification';
  static const String newNotification = 'New Notification';
  static const String notificationPreferences = 'Notification Preferences';
  static const String enableNotifications = 'Enable Notifications';

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
  static const String reviewTitle = 'Title (Optional)';
  static const String reviewContent = 'Share your experience';
  static const String noReviews = 'No reviews yet';
  static const String beFirstToReview = 'Be the first to review!';

  // Profile
  static const String editProfile = 'Edit Profile';
  static const String personalInformation = 'Personal Information';
  static const String accountSettings = 'Account Settings';
  static const String changePassword = 'Change Password';
  static const String logout = 'Logout';
  static const String memberSince = 'Member Since';
  static const String totalBookings = 'Total Bookings';
  static const String favoriteServices = 'Favorite Services';
  static const String accountInfo = 'Account Information';

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
  static const String serviceRequired = 'Please select a service';
  static const String providerRequired = 'Please select a provider';
  static const String notesTooLong = 'Notes cannot exceed 500 characters';

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
  static const String cancelConfirmation = 'Are you sure you want to cancel?';
  static const String discardChanges = 'Discard Changes?';

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
  static const String unknownError = 'An unknown error occurred.';
  static const String connectionFailed =
      'Connection failed. Please check your network.';

  // NEW: OTP Error Messages
  static const String otpSendingFailed =
      'Failed to send OTP. Please try again.';
  static const String otpVerificationFailed = 'Invalid OTP. Please try again.';
  static const String otpExpired = 'OTP has expired. Please request a new one.';
  static const String otpLimitExceeded =
      'Too many attempts. Please try again later.';

  // Success Messages
  static const String loginSuccess = 'Login successful!';
  static const String registerSuccess = 'Registration successful!';
  static const String profileUpdateSuccess = 'Profile updated successfully!';
  static const String bookingSuccess = 'Booking created successfully!';
  static const String paymentSuccess = 'Payment successful!';
  static const String reviewSuccess = 'Review submitted successfully!';
  static const String notificationMarkedRead = 'Notification marked as read!';
  static const String allNotificationsRead =
      'All notifications marked as read!';
  static const String passwordChangedSuccess = 'Password changed successfully!';
  static const String settingsSaved = 'Settings saved successfully!';

  // NEW: OTP Success Messages
  static const String otpSentSuccess =
      'OTP sent successfully! Please check your Telegram.';
  static const String registrationComplete =
      'Registration completed successfully!';

  // Placeholders
  static const String searchPlaceholder = 'Search services...';
  static const String notesPlaceholder =
      'Add any special instructions or notes...';
  static const String reviewPlaceholder = 'Write your review here...';
  static const String searchNotificationsPlaceholder =
      'Search notifications...';
  static const String namePlaceholder = 'Enter your full name';
  static const String emailPlaceholder = 'Enter your email';
  static const String phonePlaceholder = 'Enter your phone number';
  static const String addressPlaceholder = 'Enter your address';
  static const String passwordPlaceholder = 'Enter your password';
  static const String confirmPasswordPlaceholder = 'Confirm your password';

  // NEW: OTP Placeholders
  static const String otpPlaceholder = 'Enter 6-digit OTP';

  // Empty States
  static const String emptyServices = 'No services available';
  static const String emptyCategories = 'No categories available';
  static const String emptyBookings = 'No bookings yet';
  static const String emptyNotifications = 'No notifications';
  static const String emptyReviews = 'No reviews yet';
  static const String emptySearchResults = 'No results found';

  // Actions
  static const String refresh = 'Refresh';
  static const String addToFavorites = 'Add to Favorites';
  static const String removeFromFavorites = 'Remove from Favorites';
  static const String share = 'Share';
  static const String call = 'Call';
  static const String message = 'Message';
  static const String navigate = 'Navigate';
  static const String addPhoto = 'Add Photo';
  static const String changePhoto = 'Change Photo';
}

class AppColors {
  // ✅ UPDATED: Primary Brand Colors - Forest Green Theme
  static const Color primary = Color(0xFF228B22); // Forest Green
  static const Color primaryLight = Color(0xFFE8F5E9); // Light Green Background
  static const Color primaryDark = Color(0xFF1B5E20); // Dark Forest Green
  static const Color secondary = Color(0xFF20B2AA); // LightSeaGreen (unchanged)
  static const Color secondaryLight = Color(0xFF48D1CC); // Medium Turquoise
  static const Color accent = Color(0xFFFF6B6B); // Coral Red (unchanged)
  static const Color accentLight = Color(0xFFFFE5E5); // Light Coral

  // ✅ UPDATED: Button Colors
  static const Color buttonPrimary = Color(0xFF228B22); // Forest Green
  static const Color buttonSecondary = Color(0xFF20B2AA); // LightSeaGreen
  static const Color buttonTertiary = Color(0xFF6C757D); // Gray
  static const Color buttonSuccess = Color(0xFF28A745); // Success Green
  static const Color buttonWarning = Color(0xFFFFC107); // Warning Yellow
  static const Color buttonDanger = Color(0xFFDC3545); // Danger Red
  static const Color buttonDisabled = Color(0xFFE9ECEF); // Disabled Gray

  // ✅ UPDATED: Button variants - light backgrounds
  static const Color buttonPrimaryLight = Color(0xFFE8F5E9);
  static const Color buttonSecondaryLight = Color(0xFFE0F7FA);
  static const Color buttonTertiaryLight = Color(0xFFF8F9FA);
  static const Color buttonSuccessLight = Color(0xFFD4EDDA);
  static const Color buttonWarningLight = Color(0xFFFFF3CD);
  static const Color buttonDangerLight = Color(0xFFF8D7DA);

  // ✅ UPDATED: Button text colors (some may need updating)
  static const Color buttonTextOnPrimary = Colors.white;
  static const Color buttonTextOnSecondary = Colors.white;
  static const Color buttonTextOnTertiary = Color(0xFF212529);
  static const Color buttonTextOnSuccess = Colors.white;
  static const Color buttonTextOnWarning = Color(0xFF212529);
  static const Color buttonTextOnDanger = Colors.white;
  static const Color buttonTextOnLight = Color(0xFF228B22); // Updated to Forest Green

  // ✅ UPDATED: OTP Colors
  static const Color otpField = Color(0xFFF8F9FA);
  static const Color otpFieldBorder = Color(0xFFE9ECEF);
  static const Color otpFieldFocused = Color(0xFFE8F5E9);
  static const Color otpFieldError = Color(0xFFF8D7DA);
  static const Color otpText = Color(0xFF212529);
  static const Color resendText = Color(0xFF6C757D);
  static const Color resendActive = Color(0xFF228B22); // Forest Green
  static const Color resendDisabled = Color(0xFFADB5BD);

  // Neutral Colors (unchanged)
  static const Color black = Color(0xFF000000);
  static const Color white = Colors.white;
  static const Color grey50 = Color(0xFFF8F9FA);
  static const Color grey100 = Color(0xFFF1F3F5);
  static const Color grey200 = Color(0xFFE9ECEF);
  static const Color grey300 = Color(0xFFDEE2E6);
  static const Color grey400 = Color(0xFFCED4DA);
  static const Color grey500 = Color(0xFFADB5BD);
  static const Color grey600 = Color(0xFF6C757D);
  static const Color grey700 = Color(0xFF495057);
  static const Color grey800 = Color(0xFF343A40);
  static const Color grey900 = Color(0xFF212529);

  // ✅ UPDATED: Backgrounds
  static const Color scaffoldBackground = Color(0xFFF8F9FA);
  static const Color cardBackground = Colors.white;
  static const Color dialogBackground = Colors.white;
  static const Color bottomSheetBackground = Colors.white;
  static const Color appBarBackground = Color(0xFF228B22); // Forest Green

  // Text Colors
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);
  static const Color textTertiary = Color(0xFFADB5BD);
  static const Color textDisabled = Color(0xFFCED4DA);
  static const Color textOnPrimary = Colors.white;
  static const Color textOnSecondary = Colors.white;
  static const Color textOnDark = Colors.white;
  static const Color textLink = Color(0xFF228B22); // Forest Green

  // Status Colors (unchanged)
  static const Color success = Color(0xFF28A745);
  static const Color successLight = Color(0xFFD4EDDA);
  static const Color successDark = Color(0xFF155724);
  static const Color warning = Color(0xFFFFC107);
  static const Color warningLight = Color(0xFFFFF3CD);
  static const Color warningDark = Color(0xFF856404);
  static const Color error = Color(0xFFDC3545);
  static const Color errorLight = Color(0xFFF8D7DA);
  static const Color errorDark = Color(0xFF721C24);
  static const Color info = Color(0xFF17A2B8);
  static const Color infoLight = Color(0xFFD1ECF1);
  static const Color infoDark = Color(0xFF0C5460);

  // ✅ UPDATED: Notification Colors
  static const Color notificationUnread = Color(0xFFE8F5E9);
  static const Color notificationRead = Colors.white;
  static const Color notificationImportant = Color(0xFFFFF3CD);
  static const Color notificationSuccess = Color(0xFFD4EDDA);
  static const Color notificationWarning = Color(0xFFFFF3CD);
  static const Color notificationError = Color(0xFFF8D7DA);

  // Review & Rating Colors (unchanged)
  static const Color starFilled = Color(0xFFFFC107);
  static const Color starEmpty = Color(0xFFE0E0E0);
  static const Color ratingBackground = Color(0xFFF8F9FA);

  // Border & Divider Colors (unchanged)
  static const Color borderColor = Color(0xFFE9ECEF);
  static const Color borderLight = Color(0xFFF1F3F5);
  static const Color borderDark = Color(0xFFDEE2E6);
  static const Color dividerColor = Color(0xFFE9ECEF);

  // ✅ UPDATED: Shadow Colors
  static const Color shadowLight = Color(0x0A000000);
  static const Color shadowMedium = Color(0x1A000000);
  static const Color shadowDark = Color(0x33000000);
  static const Color shadowPrimary = Color(0x1A228B22); // Forest Green

  // ✅ UPDATED: Bottom Navigation Bar
  static const Color bottomNavBackground = Colors.white;
  static const Color bottomNavSelected = Color(0xFF228B22); // Forest Green
  static const Color bottomNavUnselected = Color(0xFF6C757D);

  // ✅ UPDATED: Form Fields
  static const Color formFieldBackground = Colors.white;
  static const Color formFieldBorder = Color(0xFFE9ECEF);
  static const Color formFieldFocusedBorder = Color(0xFF228B22); // Forest Green
  static const Color formFieldErrorBorder = Color(0xFFDC3545);
  static const Color formFieldLabel = Color(0xFF6C757D);
  static const Color formFieldHint = Color(0xFFADB5BD);

  // ✅ UPDATED: Chip Colors
  static const Color chipBackground = Color(0xFFE9ECEF);
  static const Color chipSelectedBackground = Color(0xFF228B22); // Forest Green
  static const Color chipText = Color(0xFF6C757D);
  static const Color chipSelectedText = Colors.white;

  // ✅ UPDATED: Progress Indicators
  static const Color progressIndicator = Color(0xFF228B22); // Forest Green
  static const Color progressTrack = Color(0xFFE9ECEF);

  // ✅ UPDATED: Avatar Colors
  static const List<Color> avatarColors = [
    Color(0xFF228B22), // Forest Green (updated)
    Color(0xFF20B2AA), // LightSeaGreen
    Color(0xFF28A745), // Green
    Color(0xFFFFC107), // Yellow
    Color(0xFFDC3545), // Red
    Color(0xFF6C757D), // Gray
  ];
  
  // ✅ NEW: Gradient Colors for Navigation
  static const List<Color> homeGradient = [Color(0xFF228B22), Color(0xFF32CD32)];
  static const List<Color> servicesGradient = [Color(0xFF20B2AA), Color(0xFF3CB371)];
  static const List<Color> bookingsGradient = [Color(0xFFDAA520), Color(0xFFCD853F)];
  static const List<Color> profileGradient = [Color(0xFF6A5ACD), Color(0xFF9370DB)];
}

class AppTextStyles {
  // Headings
  static const TextStyle h1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle h2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle h3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle h4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle h5 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle h6 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // Body Text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  // Caption & Helper Text
  static const TextStyle captionLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle captionMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle captionSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.normal,
    color: AppColors.textTertiary,
    height: 1.4,
  );

  // Button Text
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.buttonTextOnPrimary,
    letterSpacing: 0.5,
  );

  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.buttonTextOnPrimary,
    letterSpacing: 0.5,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.buttonTextOnPrimary,
    letterSpacing: 0.5,
  );

  // App Bar
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
    letterSpacing: 0.15,
  );

  // Bottom Navigation
  static const TextStyle bottomNavSelected = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: AppColors.bottomNavSelected,
    letterSpacing: 0.2,
  );

  static const TextStyle bottomNavUnselected = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.bottomNavUnselected,
    letterSpacing: 0.2,
  );

  // Form Fields
  static const TextStyle formLabel = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.formFieldLabel,
    height: 1.4,
  );

  static const TextStyle formHint = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.formFieldHint,
    height: 1.4,
  );

  static const TextStyle formError = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.error,
    height: 1.4,
  );

  static const TextStyle formInput = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  // NEW: OTP Text Styles
  static const TextStyle otpTitle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle otpDescription = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static const TextStyle otpInput = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 2,
  );

  static const TextStyle otpResend = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.resendText,
    height: 1.4,
  );

  static const TextStyle otpTimer = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.resendActive,
    height: 1.4,
  );

  static const TextStyle otpError = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.error,
    height: 1.4,
  );

  // Price & Amount
  static const TextStyle priceLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.secondary,
    height: 1.2,
  );

  static const TextStyle priceMedium = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.secondary,
    height: 1.3,
  );

  static const TextStyle priceSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.secondary,
    height: 1.3,
  );

  // Rating
  static const TextStyle ratingLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.starFilled,
    height: 1.3,
  );

  static const TextStyle ratingMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.starFilled,
    height: 1.3,
  );

  static const TextStyle ratingSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.starFilled,
    height: 1.3,
  );

  // Status
  static const TextStyle status = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  // Notifications
  static const TextStyle notificationTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle notificationBody = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle notificationTime = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.normal,
    color: AppColors.textTertiary,
    height: 1.4,
  );

  static const TextStyle notificationBadge = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );

  // Reviews
  static const TextStyle reviewTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle reviewBody = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle reviewAuthor = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static const TextStyle reviewDate = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.normal,
    color: AppColors.textTertiary,
    height: 1.4,
  );

  // Chip & Tag
  static const TextStyle chip = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.chipText,
    height: 1.4,
  );

  static const TextStyle chipSelected = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.chipSelectedText,
    height: 1.4,
  );

  // Link
  static const TextStyle link = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textLink,
    decoration: TextDecoration.underline,
    height: 1.5,
  );

  // Welcome/User Greeting
  static const TextStyle welcome = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
    height: 1.5,
  );
}

class AppSpacing {
  // Spacing scale
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;

  // Screen padding
  static const EdgeInsets screenPadding =
      EdgeInsets.all(AppConstants.defaultPadding);
  static const EdgeInsets screenHorizontalPadding =
      EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding);
  static const EdgeInsets screenVerticalPadding =
      EdgeInsets.symmetric(vertical: AppConstants.defaultPadding);

  // Card padding
  static const EdgeInsets cardPadding =
      EdgeInsets.all(AppConstants.cardPadding);
  static const EdgeInsets cardHorizontalPadding =
      EdgeInsets.symmetric(horizontal: AppConstants.cardPadding);
  static const EdgeInsets cardVerticalPadding =
      EdgeInsets.symmetric(vertical: AppConstants.cardPadding);

  // Button padding
  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: AppConstants.largePadding,
    vertical: AppConstants.mediumPadding,
  );

  static const EdgeInsets buttonSmallPadding = EdgeInsets.symmetric(
    horizontal: AppConstants.mediumPadding,
    vertical: AppConstants.smallPadding,
  );

  // List item padding
  static const EdgeInsets listItemPadding = EdgeInsets.symmetric(
    vertical: AppConstants.smallPadding,
    horizontal: AppConstants.defaultPadding,
  );

  // Form field padding
  static const EdgeInsets formFieldPadding = EdgeInsets.symmetric(
    vertical: AppConstants.smallPadding,
    horizontal: AppConstants.mediumPadding,
  );

  // App bar padding
  static const EdgeInsets appBarPadding = EdgeInsets.symmetric(
    horizontal: AppConstants.defaultPadding,
    vertical: AppConstants.smallPadding,
  );

  // Bottom navigation padding
  static const EdgeInsets bottomNavPadding = EdgeInsets.symmetric(
    horizontal: AppConstants.smallPadding,
    vertical: AppConstants.smallPadding,
  );

  // Dialog padding
  static const EdgeInsets dialogPadding =
      EdgeInsets.all(AppConstants.largePadding);
  static const EdgeInsets dialogContentPadding =
      EdgeInsets.symmetric(vertical: AppConstants.defaultPadding);

  // Chip padding
  static const EdgeInsets chipPadding = EdgeInsets.symmetric(
    horizontal: AppConstants.smallPadding,
    vertical: AppSpacing.xs,
  );

  // NEW: OTP Spacing
  static const EdgeInsets otpScreenPadding =
      EdgeInsets.all(AppConstants.largePadding);
  static const EdgeInsets otpInputPadding = EdgeInsets.symmetric(
    horizontal: AppSpacing.xxl,
    vertical: AppSpacing.xl,
  );
  static const EdgeInsets otpFieldPadding = EdgeInsets.symmetric(
    vertical: AppConstants.mediumPadding,
    horizontal: AppConstants.defaultPadding,
  );

  // Section spacing
  static const EdgeInsets sectionPadding =
      EdgeInsets.symmetric(vertical: AppSpacing.xl);
  static const EdgeInsets sectionContentPadding =
      EdgeInsets.only(bottom: AppSpacing.lg);
}

class AppDurations {
  // Animation durations
  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration verySlow = Duration(milliseconds: 800);

  // Transition durations
  static const Duration pageTransition = Duration(milliseconds: 300);
  static const Duration dialogTransition = Duration(milliseconds: 250);
  static const Duration bottomSheetTransition = Duration(milliseconds: 300);
  static const Duration fabTransition = Duration(milliseconds: 200);

  // UI feedback durations
  static const Duration toastDuration = Duration(seconds: 3);
  static const Duration snackbarDuration = Duration(seconds: 4);
  static const Duration tooltipDuration = Duration(milliseconds: 1500);
  static const Duration rippleDuration = Duration(milliseconds: 400);

  // Refresh durations
  static const Duration refreshIndicatorTimeout = Duration(seconds: 2);
  static const Duration pullToRefreshDelay = Duration(milliseconds: 500);
  static const Duration notificationRefresh = Duration(minutes: 5);
  static const Duration cacheRefresh = Duration(minutes: 10);

  // NEW: OTP Timer
  static const Duration otpTimerInterval = Duration(seconds: 1);
  static const Duration otpResendDelay = Duration(seconds: 1);

  // Loading states
  static const Duration shimmerDuration = Duration(milliseconds: 1500);
  static const Duration skeletonDelay = Duration(milliseconds: 800);
  static const Duration progressIndicatorDelay = Duration(milliseconds: 300);

  // Debounce durations
  static const Duration searchDebounce = Duration(milliseconds: 500);
  static const Duration scrollDebounce = Duration(milliseconds: 100);
  static const Duration buttonDebounce = Duration(milliseconds: 300);
}

// Helper for API responses
class ApiResponse {
  final bool success;
  final dynamic data;
  final String? message;
  final int? statusCode;
  final Map<String, dynamic>? meta;

  ApiResponse({
    required this.success,
    this.data,
    this.message,
    this.statusCode,
    this.meta,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] ?? false,
      data: json['data'],
      message: json['message'],
      statusCode: json['statusCode'],
      meta: json['meta'],
    );
  }

  Map<String, dynamic> toJson() => {
        'success': success,
        'data': data,
        'message': message,
        'statusCode': statusCode,
        'meta': meta,
      };
}

// NEW: OTP Response Model
class OtpResponse {
  final String requestId;
  final String phone;
  final DateTime expiresAt;
  final String? message;

  OtpResponse({
    required this.requestId,
    required this.phone,
    required this.expiresAt,
    this.message,
  });

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
      requestId: json['requestId'] ?? json['data']['requestId'],
      phone: json['phone'] ?? json['data']['phone'],
      expiresAt: DateTime.parse(json['expiresAt'] ?? json['data']['expiresAt']),
      message: json['message'] ?? json['data']['message'],
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toJson() => {
        'requestId': requestId,
        'phone': phone,
        'expiresAt': expiresAt.toIso8601String(),
        'message': message,
      };
}

// Pagination helper
class Pagination {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int perPage;
  final bool hasNext;
  final bool hasPrev;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.perPage,
    required this.hasNext,
    required this.hasPrev,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'] ?? 1,
      totalPages: json['total_pages'] ?? 1,
      totalItems: json['total_items'] ?? 0,
      perPage: json['per_page'] ?? AppConstants.defaultPageSize,
      hasNext: json['has_next'] ?? false,
      hasPrev: json['has_prev'] ?? false,
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
  static const String scheduled = 'scheduled';

  static String getDisplayName(String status) {
    switch (status) {
      case pending:
        return AppStrings.pending;
      case confirmed:
        return AppStrings.confirmed;
      case inProgress:
        return AppStrings.inProgress;
      case completed:
        return AppStrings.completed;
      case cancelled:
        return AppStrings.cancelled;
      case pendingPayment:
        return AppStrings.paymentPending;
      case scheduled:
        return AppStrings.scheduled;
      default:
        return status;
    }
  }

  static Color getColor(String status) {
    switch (status) {
      case pending:
        return AppColors.warning;
      case confirmed:
      case scheduled:
        return AppColors.info;
      case inProgress:
        return AppColors.primary; // Now Forest Green
      case completed:
        return AppColors.success;
      case cancelled:
        return AppColors.error;
      case pendingPayment:
        return AppColors.warning;
      default:
        return AppColors.grey600;
    }
  }

  static IconData getIcon(String status) {
    switch (status) {
      case pending:
        return Icons.schedule;
      case confirmed:
      case scheduled:
        return Icons.check_circle;
      case inProgress:
        return Icons.timer;
      case completed:
        return Icons.done_all;
      case cancelled:
        return Icons.cancel;
      case pendingPayment:
        return Icons.payment;
      default:
        return Icons.help;
    }
  }

  static bool isActive(String status) {
    return status == pending ||
        status == confirmed ||
        status == inProgress ||
        status == scheduled;
  }

  static bool canCancel(String status) {
    return status == pending || status == confirmed || status == scheduled;
  }

  static bool canReschedule(String status) {
    return status == confirmed || status == scheduled;
  }

  static bool canRate(String status) {
    return status == completed;
  }
}

// Notification types
class NotificationType {
  static const String bookingCreated = 'booking_created';
  static const String bookingConfirmed = 'booking_confirmed';
  static const String bookingCancelled = 'booking_cancelled';
  static const String bookingRescheduled = 'booking_rescheduled';
  static const String bookingInProgress = 'booking_in_progress';
  static const String bookingCompleted = 'booking_completed';
  static const String paymentReceived = 'payment_received';
  static const String paymentPending = 'payment_pending';
  static const String reviewReceived = 'review_received';
  static const String system = 'system';
  static const String promotion = 'promotion';
  static const String reminder = 'reminder';

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
      case bookingInProgress:
        return 'Service Started';
      case bookingCompleted:
        return 'Service Completed';
      case paymentReceived:
        return 'Payment Received';
      case paymentPending:
        return 'Payment Pending';
      case reviewReceived:
        return 'New Review';
      case system:
        return 'System Notification';
      case promotion:
        return 'Promotion';
      case reminder:
        return 'Reminder';
      default:
        return 'Notification';
    }
  }

  static IconData getIcon(String type) {
    switch (type) {
      case bookingCreated:
      case bookingConfirmed:
      case bookingRescheduled:
        return Icons.calendar_today;
      case bookingCancelled:
        return Icons.cancel;
      case bookingInProgress:
        return Icons.timer;
      case bookingCompleted:
        return Icons.done_all;
      case paymentReceived:
      case paymentPending:
        return Icons.payment;
      case reviewReceived:
        return Icons.star;
      case system:
        return Icons.info;
      case promotion:
        return Icons.local_offer;
      case reminder:
        return Icons.notifications;
      default:
        return Icons.notifications;
    }
  }

  static Color getColor(String type) {
    switch (type) {
      case bookingConfirmed:
      case bookingRescheduled:
        return AppColors.info;
      case bookingCreated:
        return AppColors.primary; // Now Forest Green
      case bookingInProgress:
        return AppColors.warning;
      case bookingCompleted:
        return AppColors.success;
      case bookingCancelled:
        return AppColors.error;
      case paymentReceived:
        return AppColors.success;
      case paymentPending:
        return AppColors.warning;
      case reviewReceived:
        return AppColors.starFilled;
      case promotion:
        return AppColors.accent;
      case system:
      case reminder:
      default:
        return AppColors.grey600;
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
  static const String mobileMoney = 'mobile_money';

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
        return 'Credit/Debit Card';
      case mobileMoney:
        return 'Mobile Money';
      default:
        return method;
    }
  }

  static IconData getIcon(String method) {
    switch (method) {
      case cash:
        return Icons.money;
      case telebirr:
      case mobileMoney:
        return Icons.phone_android;
      case chapa:
      case card:
        return Icons.credit_card;
      case bankTransfer:
        return Icons.account_balance;
      default:
        return Icons.payment;
    }
  }

  static bool isOnline(String method) {
    return method != cash;
  }

  static List<String> get allMethods =>
      [cash, telebirr, chapa, bankTransfer, card, mobileMoney];
}

// Service availability status
class ServiceAvailability {
  static const String available = 'available';
  static const String unavailable = 'unavailable';
  static const String fullyBooked = 'fully_booked';
  static const String comingSoon = 'coming_soon';

  static String getDisplayName(String status) {
    switch (status) {
      case available:
        return AppStrings.available;
      case unavailable:
        return AppStrings.unavailable;
      case fullyBooked:
        return 'Fully Booked';
      case comingSoon:
        return 'Coming Soon';
      default:
        return status;
    }
  }

  static Color getColor(String status) {
    switch (status) {
      case available:
        return AppColors.success;
      case unavailable:
        return AppColors.error;
      case fullyBooked:
        return AppColors.warning;
      case comingSoon:
        return AppColors.info;
      default:
        return AppColors.grey600;
    }
  }

  static bool isBookable(String status) {
    return status == available;
  }
}

// Review rating helper
class ReviewRating {
  static String getDisplayText(double rating) {
    if (rating >= 4.5) return 'Excellent';
    if (rating >= 4.0) return 'Very Good';
    if (rating >= 3.5) return 'Good';
    if (rating >= 3.0) return 'Average';
    if (rating >= 2.0) return 'Below Average';
    return 'Poor';
  }

  static Color getColor(double rating) {
    if (rating >= 4.0) return AppColors.success;
    if (rating >= 3.0) return AppColors.warning;
    return AppColors.error;
  }
}

// Error helper
class AppError {
  final String message;
  final String? code;
  final dynamic data;

  AppError({
    required this.message,
    this.code,
    this.data,
  });

  factory AppError.fromException(dynamic exception) {
    if (exception is String) {
      return AppError(message: exception);
    }

    // Handle Dio errors
    if (exception.toString().contains('DioError')) {
      if (exception.toString().contains('SocketException') ||
          exception.toString().contains('Connection refused')) {
        return AppError(
          message: AppStrings.networkError,
          code: 'NETWORK_ERROR',
        );
      }
      if (exception.toString().contains('Timeout')) {
        return AppError(
          message: AppStrings.timeoutError,
          code: 'TIMEOUT',
        );
      }
    }

    return AppError(message: exception.toString());
  }

  @override
  String toString() => message;
}