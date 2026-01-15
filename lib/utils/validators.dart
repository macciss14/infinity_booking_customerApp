// lib/utils/validators.dart
class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
      caseSensitive: false,
    );

    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }

    return null;
  }

  static bool isValidEmail(String email) {
    if (email.trim().isEmpty) {
      return true;
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
      caseSensitive: false,
    );

    return emailRegex.hasMatch(email);
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Full name is required';
    }

    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }

    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Clean the phone number for validation
    final cleanPhone = value.replaceAll(RegExp(r'[^\d]'), '');
    
    // Check length
    if (cleanPhone.length < 9 || cleanPhone.length > 12) {
      return 'Phone number must be 9-12 digits\n'
             'Accepted formats:\n'
             '• 9XXXXXXXX or 7XXXXXXXX (9 digits)\n'
             '• 09XXXXXXXX or 07XXXXXXXX (10 digits)\n'
             '• +2519XXXXXXXX or +2517XXXXXXXX (13 characters)';
    }
    
    final firstDigit = cleanPhone.isNotEmpty ? cleanPhone[0] : '';
    
    // 9-digit format: 9XXXXXXXX or 7XXXXXXXX
    if (cleanPhone.length == 9) {
      if (firstDigit != '9' && firstDigit != '7') {
        return 'Phone number must start with 9 or 7 for 9-digit format';
      }
      return null;
    }
    
    // 10-digit format: 09XXXXXXXX or 07XXXXXXXX
    if (cleanPhone.length == 10) {
      if (!cleanPhone.startsWith('09') && !cleanPhone.startsWith('07')) {
        return 'Phone number must start with 09 or 07 for 10-digit format';
      }
      return null;
    }
    
    // 12-digit format: 2519XXXXXXXX or 2517XXXXXXXX
    if (cleanPhone.length == 12) {
      if (!cleanPhone.startsWith('251') || (cleanPhone[3] != '9' && cleanPhone[3] != '7')) {
        return 'Phone number must be in format 2519XXXXXXXX or 2517XXXXXXXX';
      }
      return null;
    }
    
    // 11-digit format (likely 0XXXXXXXXXX)
    if (cleanPhone.length == 11) {
      if (!cleanPhone.startsWith('09') && !cleanPhone.startsWith('07')) {
        return 'Phone number must start with 09 or 07 for 11-digit format';
      }
      final last9 = cleanPhone.substring(2);
      if (last9.length != 9 || (last9[0] != '9' && last9[0] != '7')) {
        return 'Invalid phone number format';
      }
      return null;
    }
    
    return 'Invalid phone number format';
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your password';
    }

    if (value != password) {
      return 'Passwords do not match';
    }

    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    return null;
  }

  static String? validateNotEmpty(String? value, String errorMessage) {
    if (value == null || value.isEmpty) {
      return errorMessage;
    }

    return null;
  }

  static String? validateAddress(String? value) {
    return null;
  }

  // Helper to check if phone is valid Ethiopian mobile
  static bool isValidEthiopianPhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanPhone.length < 9 || cleanPhone.length > 12) {
      return false;
    }
    
    final firstDigit = cleanPhone.isNotEmpty ? cleanPhone[0] : '';
    
    // 9-digit format
    if (cleanPhone.length == 9) {
      return firstDigit == '9' || firstDigit == '7';
    }
    
    // 10-digit format
    if (cleanPhone.length == 10) {
      return cleanPhone.startsWith('09') || cleanPhone.startsWith('07');
    }
    
    // 12-digit format
    if (cleanPhone.length == 12) {
      return cleanPhone.startsWith('251') && (cleanPhone[3] == '9' || cleanPhone[3] == '7');
    }
    
    // 11-digit format
    if (cleanPhone.length == 11) {
      if (cleanPhone.startsWith('09') || cleanPhone.startsWith('07')) {
        final last9 = cleanPhone.substring(2);
        return last9.length == 9 && (last9[0] == '9' || last9[0] == '7');
      }
    }
    
    return false;
  }

  // Format phone for display
  static String formatPhoneForDisplay(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    if (cleanPhone.length == 9) {
      return '0$cleanPhone';
    } else if (cleanPhone.length == 10 && (cleanPhone.startsWith('09') || cleanPhone.startsWith('07'))) {
      return cleanPhone;
    } else if (cleanPhone.length == 12 && cleanPhone.startsWith('251')) {
      return '0${cleanPhone.substring(3)}';
    } else if (cleanPhone.length == 11 && (cleanPhone.startsWith('09') || cleanPhone.startsWith('07'))) {
      return cleanPhone;
    }
    
    return phone;
  }
}