extension StringExtensions on String {
  String get capitalizeFirst {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }

  String get capitalizeEachWord {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalizeFirst).join(' ');
  }

  String get trimAndLower => trim().toLowerCase();

  bool get isValidEmail {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
      caseSensitive: false,
    );
    return emailRegex.hasMatch(this);
  }

  bool get isValidPhone {
    final phoneRegex = RegExp(r'^[0-9]{10,15}$');
    return phoneRegex.hasMatch(this);
  }

  bool get isStrongPassword {
    if (length < 8) return false;
    return true;
  }

  String get maskEmail {
    if (!contains('@')) return this;
    final parts = split('@');
    if (parts[0].length <= 2) return this;
    return '${parts[0][0]}***${parts[0].substring(parts[0].length - 1)}@${parts[1]}';
  }

  String get maskPhone {
    if (length < 4) return this;
    return '***${substring(length - 4)}';
  }

  String limitLength(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }
}
