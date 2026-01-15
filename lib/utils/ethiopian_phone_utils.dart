// lib/utils/ethiopian_phone_utils.dart
class EthiopianPhoneUtils {
  static bool isValidEthiopianPhone(String phone) {
    String cleanPhone = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // Check various valid formats
    if (cleanPhone.length == 9 && RegExp(r'^[79]\d{8}$').hasMatch(cleanPhone)) {
      return true;
    }
    if (cleanPhone.length == 10 && cleanPhone.startsWith('0') && 
        RegExp(r'^0[79]\d{8}$').hasMatch(cleanPhone)) {
      return true;
    }
    if (cleanPhone.length == 12 && cleanPhone.startsWith('251') && 
        RegExp(r'^251[79]\d{8}$').hasMatch(cleanPhone)) {
      return true;
    }
    if (cleanPhone.length == 13 && cleanPhone.startsWith('+251') && 
        RegExp(r'^\+251[79]\d{8}$').hasMatch(cleanPhone)) {
      return true;
    }
    
    return false;
  }

  static String formatForBackend(String phoneNumber) {
    String formatted = phoneNumber.trim().replaceAll(RegExp(r'[^\d]'), '');
    
    if (formatted.startsWith('251')) {
      return '0${formatted.substring(3)}';
    } else if (!formatted.startsWith('0') && formatted.length == 9) {
      return '0$formatted';
    }
    
    return formatted.length == 10 && formatted.startsWith('0') 
        ? formatted 
        : phoneNumber;
  }

  static String getFormattedDisplay(String phone) {
    if (phone.startsWith('0') && phone.length == 10) {
      return '+251 ${phone.substring(1, 4)} ${phone.substring(4, 7)} ${phone.substring(7)}';
    }
    return phone;
  }
}