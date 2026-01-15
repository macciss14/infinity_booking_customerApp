// lib/screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../../services/auth_service.dart';
import '../../utils/validators.dart';
import '../../config/route_helper.dart';
import '../../utils/constants.dart';
import '../../utils/telegram_helper.dart'; // Add this import

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Color Scheme
  final Color _primaryGreen = const Color(0xFF2E7D32);
  final Color _lightGreen = const Color(0xFF4CAF50);
  final Color _darkGreen = const Color(0xFF1B5E20);
  final Color _accentGreen = const Color(0xFF81C784);
  final Color _background = const Color(0xFFF8FDF8);
  final Color _errorRed = const Color(0xFFF44336);
  final Color _successGreen = const Color(0xFF4CAF50);
  final Color _textLight = const Color(0xFF666666);
  final Color _textDark = const Color(0xFF333333);

  // Controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // OTP Controllers
  final List<TextEditingController> _otpControllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
      List.generate(6, (index) => FocusNode());

  // State variables
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isOTPVerification = false;
  bool _termsAccepted = false;
  int _resendTimer = 60;
  bool _canResendOTP = false;
  Timer? _timer;

  // Registration data
  Map<String, dynamic> _registrationData = {};
  String? _otpRequestId;

  // Form keys
  final _registerFormKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _clearOTPFields();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  // Step 1: Validate form and immediately go to OTP screen
  Future<void> _validateAndProceedToOTP() async {
    if (!_registerFormKey.currentState!.validate()) return;

    if (!_termsAccepted) {
      _showErrorSnackbar('Please accept the terms and conditions');
      return;
    }

    // Validate passwords match
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password != confirmPassword) {
      _showErrorSnackbar('Passwords do not match');
      return;
    }

    if (password.length < 8) {
      _showErrorSnackbar('Password must be at least 8 characters');
      return;
    }

    setState(() => _isLoading = true);

    try {
      String phoneNumber = _phoneController.text.trim();
      String email = _emailController.text.trim();
      String address = _addressController.text.trim();

      // Validate email format if provided
      if (email.isNotEmpty && !Validators.isValidEmail(email)) {
        throw Exception('Please enter a valid email address or leave it empty');
      }

      // Save registration data with email and address (even if empty)
      _registrationData = {
        'fullname': _fullNameController.text.trim(),
        'email': email,
        'address': address,
        'phone': phoneNumber,
        'password': password,
        'confirmPassword': confirmPassword,
      };

      print('📱 [RegisterScreen] Requesting OTP for: $phoneNumber');
      print('📧 [RegisterScreen] Email: ${email.isEmpty ? "(empty)" : email}');
      print(
          '📍 [RegisterScreen] Address: ${address.isEmpty ? "(empty)" : address}');

      // Request OTP
      final authService = AuthService();
      final otpResponse = await authService.requestOtp(phoneNumber);

      if (otpResponse.success) {
        print('✅ [RegisterScreen] OTP request successful');

        // Save requestId if available
        if (otpResponse.data?['data']?['requestId'] != null) {
          _otpRequestId = otpResponse.data!['data']!['requestId'];
          print('📝 [RegisterScreen] OTP requestId: $_otpRequestId');
        }

        // Open Telegram bot immediately
        await _openTelegramBot();

        // Show OTP screen
        if (mounted) {
          setState(() {
            _isLoading = false;
            _isOTPVerification = true;
            _startResendTimer();
          });

          _showSuccessSnackbar('OTP sent! Check your Telegram messages.');

          // Auto-focus on first OTP field
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_otpFocusNodes.isNotEmpty) {
              FocusScope.of(context).requestFocus(_otpFocusNodes[0]);
            }
          });
        }
      } else {
        throw Exception(otpResponse.message ?? 'Failed to send OTP');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackbar('Error: ${e.toString()}');
      }
    }
  }

  // Open Telegram bot
  Future<void> _openTelegramBot() async {
    try {
      await TelegramHelper.openBotChat();
      _showInfoSnackbar('Opening Infinity Booking Bot...');
    } catch (e) {
      print('❌ Error opening Telegram: $e');
      // Don't show error here, just log it
    }
  }

  // Step 2: Verify OTP and complete registration
  Future<void> _verifyOTPAndCompleteRegistration() async {
    String otp = '';
    for (var controller in _otpControllers) {
      otp += controller.text;
    }

    if (otp.length != 6) {
      _showErrorSnackbar('Please enter a valid 6-digit OTP');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = AuthService();

      print('🔐 [RegisterScreen] Verifying OTP and registering...');
      print('📱 Phone: ${_registrationData['phone']}');
      print('🔑 OTP: $otp');
      print('📧 Email: ${_registrationData['email']}');
      print('📍 Address: ${_registrationData['address']}');

      // Get requestId from storage if not already saved
      String requestId = _otpRequestId ?? '';
      if (requestId.isEmpty) {
        final otpData = await authService.getOtpRequestData();
        requestId = otpData?['requestId'] ?? _registrationData['phone'];
      }

      // Verify OTP and register with email and address (even if empty)
      final otpResponse = await authService.verifyOtpAndRegister(
        otp: otp,
        requestId: requestId,
        phone: _registrationData['phone'],
        fullname: _registrationData['fullname'],
        email: _registrationData['email'],
        address: _registrationData['address'],
        password: _registrationData['password'],
        confirmPassword: _registrationData['confirmPassword'],
      );

      if (otpResponse.success) {
        print('✅ [RegisterScreen] Registration successful!');

        // Auto-login with the registered credentials
        try {
          print('🔑 [RegisterScreen] Attempting auto-login...');
          await authService.login(
            _registrationData['phone'],
            _registrationData['password'],
          );

          print('✅ [RegisterScreen] Auto-login successful');

          if (mounted) {
            _showSuccessSnackbar('Registration successful! Welcome!');
            RouteHelper.pushNamedAndRemoveUntil(
                context, AppConstants.routeHome);
          }
        } catch (loginError) {
          print('🔴 [RegisterScreen] Auto-login failed: $loginError');
          // Go to login screen if auto-login fails
          if (mounted) {
            _showSuccessSnackbar('Account created! Please login');
            RouteHelper.pushNamedAndRemoveUntil(context, RouteHelper.login);
          }
        }
      } else {
        // Show detailed error message
        final errorMessage =
            otpResponse.data?['message'] ?? otpResponse.message;
        throw Exception(errorMessage ?? 'OTP verification failed');
      }
    } catch (e) {
      _handleRegistrationError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleRegistrationError(String error) {
    String errorMessage = error;
    if (errorMessage.startsWith('Exception: ')) {
      errorMessage = errorMessage.substring(11);
    }

    if (errorMessage.toLowerCase().contains('invalid otp') ||
        errorMessage.toLowerCase().contains('incorrect')) {
      errorMessage = 'Invalid OTP. Please check and try again.';
      // Clear OTP fields on invalid OTP
      for (var controller in _otpControllers) {
        controller.clear();
      }
      // Focus on first OTP field
      if (_otpFocusNodes.isNotEmpty) {
        FocusScope.of(context).requestFocus(_otpFocusNodes[0]);
      }
    } else if (errorMessage.toLowerCase().contains('otp expired')) {
      errorMessage = 'OTP has expired. Please request a new one.';
    } else if (errorMessage.toLowerCase().contains('phone already')) {
      errorMessage = 'Phone number already registered. Please login instead.';
      setState(() => _isOTPVerification = false);
    } else if (errorMessage.toLowerCase().contains('network')) {
      errorMessage = 'Network error. Please check your connection.';
    } else if (errorMessage.toLowerCase().contains('user already')) {
      errorMessage = 'Account already exists. Please try logging in instead.';
      setState(() => _isOTPVerification = false);
    } else if (errorMessage.toLowerCase().contains('email')) {
      errorMessage = 'Please enter a valid email address or leave it empty';
    } else if (errorMessage.toLowerCase().contains('address')) {
      errorMessage = 'Please enter a valid address or leave it empty';
    }

    _showErrorSnackbar(errorMessage);
  }

  void _showSuccessSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _errorRed,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showInfoSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _accentGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _startResendTimer() {
    setState(() => _resendTimer = 60);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
      } else {
        timer.cancel();
        setState(() => _canResendOTP = true);
      }
    });
  }

  Future<void> _resendOTP() async {
    if (!_canResendOTP) return;

    setState(() => _isLoading = true);

    try {
      String phoneNumber = _registrationData['phone'];
      print('🔄 [RegisterScreen] Resending OTP to: $phoneNumber');

      final authService = AuthService();
      final response = await authService.requestOtp(phoneNumber);

      if (response.success) {
        // Re-open Telegram bot
        await _openTelegramBot();

        _showSuccessSnackbar('OTP resent successfully! Check Telegram.');
        setState(() {
          _canResendOTP = false;
          _startResendTimer();
        });
      } else {
        _showErrorSnackbar('Failed to resend OTP: ${response.message}');
      }
    } catch (e) {
      _showErrorSnackbar('Failed to resend OTP: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _clearOTPFields() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 20, bottom: 30),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_primaryGreen, _lightGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: _primaryGreen.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              _isOTPVerification
                  ? Icons.telegram
                  : Icons.person_add_alt_1_rounded,
              color: Colors.white,
              size: 40,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _isOTPVerification ? 'Verify Phone' : 'Create Account',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: _darkGreen,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isOTPVerification
                ? 'Check Telegram for your OTP code'
                : 'Fill in your details to get started',
            style: TextStyle(
              fontSize: 16,
              color: _textLight,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOTPInstructionCard() {
    String displayPhone = _registrationData['phone'] ?? '';

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: _accentGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _accentGreen.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.telegram, color: _primaryGreen, size: 20),
              const SizedBox(width: 8),
              Text(
                'Telegram OTP',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _darkGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'A 6-digit code has been sent via Telegram to:',
            style: TextStyle(
              fontSize: 12,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            displayPhone,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _darkGreen,
            ),
          ),
          const SizedBox(height: 12),
          // Open Telegram button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _openTelegramBot,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGreen.withOpacity(0.9),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              icon: Icon(Icons.telegram, size: 20),
              label: const Text('Open InfinityBookingBot'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOTPInput() {
    return Column(
      children: [
        _buildOTPInstructionCard(),

        // OTP Input Fields
        Text(
          'Enter 6-digit code from Telegram',
          style: TextStyle(
            fontSize: 14,
            color: _textDark,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (index) {
            return Container(
              width: 50,
              height: 50,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              child: TextFormField(
                controller: _otpControllers[index],
                focusNode: _otpFocusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: _darkGreen,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _primaryGreen, width: 2),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _errorRed, width: 2),
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (value) {
                  if (value.isNotEmpty && index < 5) {
                    FocusScope.of(context)
                        .requestFocus(_otpFocusNodes[index + 1]);
                  }
                  if (value.isEmpty && index > 0) {
                    FocusScope.of(context)
                        .requestFocus(_otpFocusNodes[index - 1]);
                  }

                  // Auto-verify when all fields are filled
                  if (index == 5 && value.isNotEmpty) {
                    String otp = '';
                    for (var controller in _otpControllers) {
                      otp += controller.text;
                    }
                    if (otp.length == 6) {
                      _verifyOTPAndCompleteRegistration();
                    }
                  }
                },
              ),
            );
          }),
        ),
        const SizedBox(height: 24),

        // Verify OTP Button
        ElevatedButton(
          onPressed: _isLoading ? null : _verifyOTPAndCompleteRegistration,
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            minimumSize: const Size(double.infinity, 56),
          ),
          child: _isLoading
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Verify OTP & Register',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),

        const SizedBox(height: 16),

        // Resend OTP Section
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Didn\'t receive the code? ',
                  style: TextStyle(color: _textLight),
                ),
                GestureDetector(
                  onTap: _canResendOTP ? _resendOTP : null,
                  child: Text(
                    _canResendOTP ? 'Resend Code' : 'Resend in $_resendTimer',
                    style: TextStyle(
                      color: _canResendOTP ? _primaryGreen : _textLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _openTelegramBot,
              icon: Icon(Icons.open_in_new, size: 16),
              label: Text(
                'Open Telegram Bot',
                style: TextStyle(color: _primaryGreen),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Edit Phone Number
        TextButton(
          onPressed: () {
            setState(() {
              _isOTPVerification = false;
              for (var controller in _otpControllers) {
                controller.clear();
              }
            });
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.edit, size: 16, color: _primaryGreen),
              const SizedBox(width: 6),
              Text(
                'Edit phone number',
                style: TextStyle(color: _primaryGreen),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationForm() {
    return Form(
      key: _registerFormKey,
      child: Column(
        children: [
          _buildFullNameField(),
          const SizedBox(height: 16),
          _buildEmailField(),
          const SizedBox(height: 16),
          _buildPhoneField(),
          const SizedBox(height: 16),
          _buildAddressField(),
          const SizedBox(height: 16),
          _buildPasswordField(true),
          const SizedBox(height: 16),
          _buildPasswordField(false),
          const SizedBox(height: 20),
          _buildTermsCheckbox(),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildFullNameField() {
    return TextFormField(
      controller: _fullNameController,
      decoration: InputDecoration(
        labelText: 'Full Name *',
        hintText: 'Enter your full name',
        prefixIcon: Icon(Icons.person, color: _primaryGreen),
        suffixIcon: Icon(
          Icons.check_circle,
          color: Validators.validateName(_fullNameController.text) == null
              ? _lightGreen
              : Colors.grey[300],
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _errorRed, width: 2),
        ),
      ),
      keyboardType: TextInputType.name,
      textInputAction: TextInputAction.next,
      validator: Validators.validateName,
      onChanged: (value) => setState(() {}),
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'you@example.com ',
        prefixIcon: Icon(Icons.email, color: _primaryGreen),
        suffixIcon: Icon(
          Icons.check_circle,
          color: Validators.validateEmail(_emailController.text) == null
              ? _lightGreen
              : Colors.grey[300],
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _errorRed, width: 2),
        ),
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: Validators.validateEmail,
      onChanged: (value) => setState(() {}),
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      controller: _phoneController,
      decoration: InputDecoration(
        labelText: 'Phone Number *',
        hintText: '9XXXXXXXX, 09XXXXXXXX, or +2519XXXXXXXX',
        prefixIcon: Icon(Icons.phone, color: _primaryGreen),
        suffixIcon: Icon(
          Icons.check_circle,
          color: Validators.validatePhone(_phoneController.text) == null
              ? _lightGreen
              : Colors.grey[300],
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _errorRed, width: 2),
        ),
        helperText: 'Accepted formats: 9XXXXXXXX, 09XXXXXXXX, +2519XXXXXXXX',
        helperStyle: TextStyle(fontSize: 12, color: _textLight),
      ),
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      validator: Validators.validatePhone,
      onChanged: (value) => setState(() {}),
    );
  }

  Widget _buildAddressField() {
    return TextFormField(
      controller: _addressController,
      decoration: InputDecoration(
        labelText: 'Address',
        hintText: 'Enter your address (Optional)',
        prefixIcon: Icon(Icons.location_on, color: _primaryGreen),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _errorRed, width: 2),
        ),
      ),
      keyboardType: TextInputType.streetAddress,
      textInputAction: TextInputAction.next,
      maxLines: 2,
    );
  }

  Widget _buildPasswordField(bool isPassword) {
    return TextFormField(
      controller: isPassword ? _passwordController : _confirmPasswordController,
      decoration: InputDecoration(
        labelText: isPassword ? 'Password *' : 'Confirm Password *',
        hintText: isPassword ? 'Minimum 8 characters' : 'Re-enter password',
        prefixIcon: Icon(Icons.lock, color: _primaryGreen),
        suffixIcon: IconButton(
          icon: Icon(
            isPassword
                ? (_obscurePassword ? Icons.visibility : Icons.visibility_off)
                : (_obscureConfirmPassword
                    ? Icons.visibility
                    : Icons.visibility_off),
            color: _textLight,
          ),
          onPressed: () {
            setState(() {
              if (isPassword) {
                _obscurePassword = !_obscurePassword;
              } else {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              }
            });
          },
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _primaryGreen, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: _errorRed, width: 2),
        ),
      ),
      obscureText: isPassword ? _obscurePassword : _obscureConfirmPassword,
      textInputAction: isPassword ? TextInputAction.next : TextInputAction.done,
      validator: isPassword
          ? Validators.validatePassword
          : (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
      onChanged: (value) => setState(() {}),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _termsAccepted,
          onChanged: (value) => setState(() => _termsAccepted = value!),
          activeColor: _primaryGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _termsAccepted = !_termsAccepted),
            child: RichText(
              text: TextSpan(
                text: 'I agree to the ',
                style: TextStyle(
                  fontSize: 14,
                  color: _textDark,
                ),
                children: [
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: _primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: _primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return ElevatedButton(
      onPressed: _isLoading
          ? null
          : () {
              if (_isOTPVerification) {
                _verifyOTPAndCompleteRegistration();
              } else {
                _validateAndProceedToOTP();
              }
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 18),
        shadowColor: _primaryGreen.withOpacity(0.3),
        minimumSize: const Size(double.infinity, 56),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_isLoading) ...[
            const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Text(
            _isOTPVerification
                ? (_isLoading ? 'Verifying...' : 'Verify & Register')
                : (_isLoading ? 'Processing OTP...' : 'register'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (!_isLoading && !_isOTPVerification) ...[
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, size: 20),
          ],
        ],
      ),
    );
  }

  Widget _buildFormatHints() {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: _accentGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _accentGreen.withOpacity(0.3)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: Text(_isOTPVerification ? 'Verify OTP' : 'Register'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_isOTPVerification) {
              setState(() {
                _isOTPVerification = false;
                for (var controller in _otpControllers) {
                  controller.clear();
                }
              });
            } else {
              RouteHelper.pop(context);
            }
          },
        ),
        backgroundColor: _primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (child, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.0, 0.1),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOut,
                    )),
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: _isOTPVerification
                    ? _buildOTPInput()
                    : _buildRegistrationForm(),
              ),
              const SizedBox(height: 24),
              _buildRegisterButton(),
              if (!_isOTPVerification) ...[
                const SizedBox(height: 32),
                _buildLoginLink(),
                const SizedBox(height: 20),
                // Format hints
                _buildFormatHints(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Already have an account? ',
          style: TextStyle(color: _textLight),
        ),
        GestureDetector(
          onTap: () =>
              RouteHelper.pushNamedAndRemoveUntil(context, RouteHelper.login),
          child: Text(
            'Sign In',
            style: TextStyle(
              color: _primaryGreen,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
