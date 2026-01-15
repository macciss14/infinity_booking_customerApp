// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';
import '../../config/route_helper.dart';
import '../../utils/validators.dart';
import '../../utils/telegram_helper.dart'; // Add this import
import 'package:flutter/services.dart';
import 'dart:async';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phonenumberController = TextEditingController();
  final _passwordController = TextEditingController();

  // State variables
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Password reset flow - USING STATE MACHINE APPROACH
  String _resetFlowState = 'login'; // 'login', 'forgot', 'otp', 'newPassword'
  bool _isResettingPassword = false;
  bool _isVerifyingOTP = false;

  // OTP controllers
  final List<TextEditingController> _otpControllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _otpFocusNodes =
      List.generate(6, (index) => FocusNode());

  // Password controllers
  final _newPasswordController = TextEditingController();
  final _confirmNewPasswordController = TextEditingController();
  bool _obscureNewPassword = true;
  bool _obscureConfirmNewPassword = true;

  // Timer
  int _resendTimer = 60;
  bool _canResendOTP = false;
  Timer? _timer;

  // Reset data
  String? _resetRequestId;
  String? _resetPhoneNumber;

  // Colors
  final Color _primaryGreen = const Color(0xFF2E7D32);
  final Color _lightGreen = const Color(0xFF4CAF50);
  final Color _darkGreen = const Color(0xFF1B5E20);
  final Color _accentGreen = const Color(0xFF81C784);
  final Color _background = const Color(0xFFF8FDF8);
  final Color _errorRed = const Color(0xFFF44336);
  final Color _successGreen = const Color(0xFF4CAF50);
  final Color _textLight = const Color(0xFF666666);
  final Color _textDark = const Color(0xFF333333);

  @override
  void initState() {
    super.initState();
    // Clear OTP fields when starting
    _clearOTPFields();
  }

  @override
  void dispose() {
    _phonenumberController.dispose();
    _passwordController.dispose();
    _newPasswordController.dispose();
    _confirmNewPasswordController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  // ─── LOGIN ──────────────────────────────────────────────
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String phonenumber = _phonenumberController.text.trim();

      // Validate phone number
      final phoneError = Validators.validatePhone(phonenumber);
      if (phoneError != null) {
        throw Exception(phoneError);
      }

      print('📱 [LoginScreen] Logging in with: $phonenumber');

      final authService = AuthService();
      await authService.login(phonenumber, _passwordController.text);

      if (mounted) {
        _showSuccessSnackbar('Login successful!');
        RouteHelper.pushNamedAndRemoveUntil(context, AppConstants.routeHome);
      }
    } catch (e) {
      if (mounted) {
        _handleLoginError(e);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _handleLoginError(dynamic error) {
    String errorMessage = error.toString();

    if (errorMessage.startsWith('Exception: ')) {
      errorMessage = errorMessage.substring(11);
    }

    if (errorMessage.contains('Invalid phone number or password') ||
        errorMessage.contains('invalid credentials') ||
        errorMessage.contains('incorrect password') ||
        errorMessage.contains('invalid phonenumber')) {
      errorMessage = 'Invalid phone number or password';
      _passwordController.clear();
    } else if (errorMessage.contains('user not found') ||
        errorMessage.contains('no account')) {
      errorMessage = 'No account found. Please register first.';
    } else if (errorMessage.contains('network') ||
        errorMessage.contains('connection') ||
        errorMessage.contains('SocketException')) {
      errorMessage = 'Network error. Please check your internet connection.';
    } else if (errorMessage.contains('bad request')) {
      errorMessage = 'Invalid phone number format.';
    } else if (errorMessage.contains('unauthorized') ||
        errorMessage.contains('token')) {
      errorMessage = 'Session expired. Please login again.';
    } else if (errorMessage.contains('server')) {
      errorMessage = 'Server error. Please try again later.';
    } else if (errorMessage.contains('timeout')) {
      errorMessage = 'Request timeout. Please try again.';
    }

    _showErrorSnackbar(errorMessage);
  }

  // ─── PASSWORD RESET FLOW ──────────────────────────────

  // Step 1: Start forgot password
  void _startForgotPassword() {
    setState(() {
      _resetFlowState = 'forgot';
      _clearOTPFields();
    });
  }

  // Step 2: Request password reset OTP
  Future<void> _requestPasswordReset() async {
    final phoneNumber = _phonenumberController.text.trim();

    final phoneError = Validators.validatePhone(phoneNumber);
    if (phoneError != null) {
      _showErrorSnackbar(phoneError);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = AuthService();
      final response = await authService.requestPasswordResetOtp(phoneNumber);

      if (response.success) {
        // Get the requestId from response
        _resetRequestId = response.data?['requestId'];
        _resetPhoneNumber = phoneNumber;

        print('📝 [LoginScreen] Reset requestId: $_resetRequestId');

        // Immediately open Telegram bot after OTP is sent
        await _openTelegramBot();

        if (_resetRequestId != null) {
          setState(() {
            _resetFlowState = 'otp';
            _startResendTimer();
          });

          _showSuccessSnackbar('OTP sent! Opening Telegram bot...');

          // Auto-focus on first OTP field
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_otpFocusNodes.isNotEmpty) {
              FocusScope.of(context).requestFocus(_otpFocusNodes[0]);
            }
          });
        } else {
          _showErrorSnackbar(
              'Failed to start reset session. Please try again.');
        }
      } else {
        _showErrorSnackbar(response.message);
      }
    } catch (e) {
      _showErrorSnackbar('Failed to request password reset: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Open Telegram bot
  Future<void> _openTelegramBot() async {
    try {
      await TelegramHelper.openBotChat();
      _showInfoSnackbar('Opening InfinityBookingBot...');
    } catch (e) {
      print('❌ Error opening Telegram: $e');
      // Don't show error to user, just log it
    }
  }

  // Step 3: Verify OTP
  Future<void> _verifyOTP() async {
    String otp = '';
    for (var controller in _otpControllers) {
      otp += controller.text;
    }

    if (otp.length != 6) {
      _showErrorSnackbar('Please enter a valid 6-digit OTP');
      return;
    }

    setState(() => _isVerifyingOTP = true);

    try {
      // For demo purposes, we'll simulate OTP verification
      // In production, you would call an API to verify the OTP
      await Future.delayed(const Duration(milliseconds: 500));

      // OTP verified successfully
      setState(() {
        _resetFlowState = 'newPassword';
        _isVerifyingOTP = false;
      });

      _showSuccessSnackbar('OTP verified! Now set your new password.');
    } catch (e) {
      _showErrorSnackbar('Failed to verify OTP: ${e.toString()}');
      setState(() => _isVerifyingOTP = false);
    }
  }

  // Step 4: Set new password
  Future<void> _setNewPassword() async {
    if (_newPasswordController.text.length < 6) {
      _showErrorSnackbar('Password must be at least 6 characters');
      return;
    }

    if (_newPasswordController.text != _confirmNewPasswordController.text) {
      _showErrorSnackbar('Passwords do not match');
      return;
    }

    if (_resetRequestId == null || _resetPhoneNumber == null) {
      _showErrorSnackbar('Reset session expired. Please start over.');
      _resetToLogin();
      return;
    }

    setState(() => _isResettingPassword = true);

    try {
      final authService = AuthService();

      // Get OTP from input fields
      String otp = '';
      for (var controller in _otpControllers) {
        otp += controller.text;
      }

      final response = await authService.resetPasswordWithOtp(
        otp: otp,
        newPassword: _newPasswordController.text,
        requestId: _resetRequestId,
        phoneNumber: _resetPhoneNumber,
      );

      if (response.success) {
        _showSuccessSnackbar(
            'Password reset successful! Please login with your new password.');

        // Reset all forms
        _resetAllForms();

        // Go back to login
        _resetToLogin();
      } else {
        _showErrorSnackbar(response.message);
      }
    } catch (e) {
      _showErrorSnackbar('Failed to reset password: ${e.toString()}');
    } finally {
      setState(() => _isResettingPassword = false);
    }
  }

  void _resetAllForms() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _newPasswordController.clear();
    _confirmNewPasswordController.clear();
    _phonenumberController.clear();
    _passwordController.clear();
    _timer?.cancel();
    _resendTimer = 60;
    _canResendOTP = false;
    _resetRequestId = null;
    _resetPhoneNumber = null;
  }

  void _clearOTPFields() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
  }

  void _resetToLogin() {
    setState(() {
      _resetFlowState = 'login';
      _resetAllForms();
      _isResettingPassword = false;
      _isVerifyingOTP = false;
    });
  }

  void _goBack() {
    if (_resetFlowState == 'newPassword') {
      setState(() => _resetFlowState = 'otp');
    } else if (_resetFlowState == 'otp') {
      setState(() => _resetFlowState = 'forgot');
    } else if (_resetFlowState == 'forgot') {
      _resetToLogin();
    } else {
      RouteHelper.pop(context);
    }
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

  // ─── UI HELPERS ──────────────────────────────────────
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

  void _navigateToRegister() {
    RouteHelper.pushNamed(context, AppConstants.routeRegister);
  }

  // ─── UI BUILDERS ─────────────────────────────────────
  Widget _buildHeader() {
    String title;
    String subtitle;
    IconData icon;

    switch (_resetFlowState) {
      case 'forgot':
        title = 'Reset Password';
        subtitle = 'Enter your phone number to receive OTP';
        icon = Icons.lock_reset;
        break;
      case 'otp':
        title = 'Verify OTP';
        subtitle = 'Check InfinityBookingBot on Telegram';
        icon = Icons.telegram;
        break;
      case 'newPassword':
        title = 'Set New Password';
        subtitle = 'Create your new password';
        icon = Icons.password;
        break;
      default:
        title = 'Welcome Back';
        subtitle = 'Login with your phone number';
        icon = Icons.calendar_today;
    }

    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
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
          child: Icon(icon, color: Colors.white, size: 50),
        ),
        const SizedBox(height: 20),
        Text(
          title,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: _darkGreen,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 16,
            color: _textLight,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPhoneNumberField() {
    return TextFormField(
      controller: _phonenumberController,
      decoration: InputDecoration(
        labelText: 'Phone Number',
        hintText: 'Enter valid phone number',
        prefixIcon: Icon(Icons.phone, color: _primaryGreen),
        suffixIcon: Icon(
          Icons.check_circle,
          color: Validators.validatePhone(_phonenumberController.text.trim()) ==
                  null
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
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.next,
      validator: Validators.validatePhone,
      onChanged: (value) => setState(() {}),
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Enter your password',
        prefixIcon: Icon(Icons.lock, color: _primaryGreen),
        suffixIcon: IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility : Icons.visibility_off,
            color: Colors.grey[600],
          ),
          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
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
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      obscureText: _obscurePassword,
      textInputAction: TextInputAction.done,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Password is required';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
      onFieldSubmitted: (_) => _login(),
    );
  }

  Widget _buildNewPasswordFields() {
    return Column(
      children: [
        TextFormField(
          controller: _newPasswordController,
          decoration: InputDecoration(
            labelText: 'New Password',
            hintText: 'Minimum 6 characters',
            prefixIcon: Icon(Icons.lock, color: _primaryGreen),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureNewPassword ? Icons.visibility : Icons.visibility_off,
                color: Colors.grey[600],
              ),
              onPressed: () =>
                  setState(() => _obscureNewPassword = !_obscureNewPassword),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _primaryGreen, width: 2),
            ),
          ),
          obscureText: _obscureNewPassword,
          validator: (value) {
            if (value == null || value.trim().isEmpty)
              return 'New password is required';
            if (value.length < 6) return 'Must be at least 6 characters';
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _confirmNewPasswordController,
          decoration: InputDecoration(
            labelText: 'Confirm New Password',
            hintText: 'Re-enter new password',
            prefixIcon: Icon(Icons.lock, color: _primaryGreen),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmNewPassword
                    ? Icons.visibility
                    : Icons.visibility_off,
                color: Colors.grey[600],
              ),
              onPressed: () => setState(() =>
                  _obscureConfirmNewPassword = !_obscureConfirmNewPassword),
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: _primaryGreen, width: 2),
            ),
          ),
          obscureText: _obscureConfirmNewPassword,
          validator: (value) {
            if (value == null || value.trim().isEmpty)
              return 'Please confirm password';
            if (value != _newPasswordController.text)
              return 'Passwords do not match';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildOTPInput() {
    return Column(
      children: [
        // Telegram instruction card with open button
        Container(
          padding: const EdgeInsets.all(16),
          margin: const EdgeInsets.only(bottom: 16),
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
                'A 6-digit code has been sent to:',
                style: TextStyle(fontSize: 12, color: _textDark),
              ),
              const SizedBox(height: 4),
              Text(
                _resetPhoneNumber ?? _phonenumberController.text.trim(),
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
        ),

        // OTP input fields
        Text(
          'Enter 6-digit OTP from Telegram',
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
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: _primaryGreen, width: 2),
                  ),
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
                      _verifyOTP();
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
          onPressed: _isVerifyingOTP ? null : _verifyOTP,
          style: ElevatedButton.styleFrom(
            backgroundColor: _primaryGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            minimumSize: const Size(double.infinity, 56),
          ),
          child: _isVerifyingOTP
              ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : const Text('Verify OTP',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),

        const SizedBox(height: 16),

        // Resend OTP and Open Telegram buttons
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Didn\'t receive code? ',
                    style: TextStyle(color: _textLight)),
                GestureDetector(
                  onTap: _canResendOTP ? _requestPasswordReset : null,
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
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _openTelegramBot,
              icon: Icon(Icons.open_in_new, size: 16),
              label: Text(
                'Open Telegram Bot Again',
                style: TextStyle(color: _primaryGreen),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildPhoneNumberField(),
          const SizedBox(height: 16),
          _buildPasswordField(),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _startForgotPassword,
              child: Text('Forgot Password?',
                  style: TextStyle(color: _primaryGreen)),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isLoading ? null : _login,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
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
                : const Text('Log In',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Don't have an account? ",
                  style: TextStyle(color: _textLight)),
              TextButton(
                onPressed: _navigateToRegister,
                child: Text('Register',
                    style: TextStyle(
                        color: _primaryGreen, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildForgotPasswordForm() {
    return Column(
      children: [
        _buildPhoneNumberField(),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _isLoading ? null : _requestPasswordReset,
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
              : const Text('Send Reset OTP',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: _resetToLogin,
          child: Text('Back to Login', style: TextStyle(color: _primaryGreen)),
        ),
      ],
    );
  }

  Widget _buildCurrentForm() {
    switch (_resetFlowState) {
      case 'forgot':
        return _buildForgotPasswordForm();
      case 'otp':
        return _buildOTPInput();
      case 'newPassword':
        return Column(
          children: [
            _buildNewPasswordFields(),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isResettingPassword ? null : _setNewPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
                minimumSize: const Size(double.infinity, 56),
              ),
              child: _isResettingPassword
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Reset Password',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _goBack,
              child:
                  Text('Back to OTP', style: TextStyle(color: _primaryGreen)),
            ),
          ],
        );
      default:
        return _buildLoginForm();
    }
  }

  Widget _buildFormatHints() {
    if (_resetFlowState == 'login') {
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
    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      appBar: AppBar(
        title: Text(
          _resetFlowState == 'forgot'
              ? 'Forgot Password'
              : _resetFlowState == 'otp'
                  ? 'Verify OTP'
                  : _resetFlowState == 'newPassword'
                      ? 'Set New Password'
                      : 'Login',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
        backgroundColor: _primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            _buildHeader(),
            const SizedBox(height: 40),
            _buildCurrentForm(),
            const SizedBox(height: 24),
            _buildFormatHints(),
          ],
        ),
      ),
    );
  }
}
