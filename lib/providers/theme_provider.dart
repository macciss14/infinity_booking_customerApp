// lib/providers/theme_provider.dart - COMPLETE VERSION
import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  bool _isDarkMode = false;
  Color _primaryColor = const Color(0xFF2E7D32);
  int _selectedThemeIndex = 0;

  final List<Map<String, dynamic>> _themes = [
    {
      'id': 0,
      'name': 'Forest Green',
      'color': const Color(0xFF2E7D32),
      'darkColor': const Color(0xFF1B5E20),
      'lightColor': const Color(0xFF4CAF50),
    },
    {
      'id': 1,
      'name': 'Ocean Blue',
      'color': const Color(0xFF2196F3),
      'darkColor': const Color(0xFF0D47A1),
      'lightColor': const Color(0xFF64B5F6),
    },
    {
      'id': 2,
      'name': 'Royal Purple',
      'color': const Color(0xFF7B1FA2),
      'darkColor': const Color(0xFF4A148C),
      'lightColor': const Color(0xFFBA68C8),
    },
    {
      'id': 3,
      'name': 'Sunset Orange',
      'color': const Color(0xFFFF5722),
      'darkColor': const Color(0xFFD84315),
      'lightColor': const Color(0xFFFF8A65),
    },
    {
      'id': 4,
      'name': 'Deep Pink',
      'color': const Color(0xFFE91E63),
      'darkColor': const Color(0xFFAD1457),
      'lightColor': const Color(0xFFF48FB1),
    },
    {
      'id': 5,
      'name': 'Emerald',
      'color': const Color(0xFF00C853),
      'darkColor': const Color(0xFF00A740),
      'lightColor': const Color(0xFF69F0AE),
    },
    {
      'id': 6,
      'name': 'Midnight Blue',
      'color': const Color(0xFF303F9F),
      'darkColor': const Color(0xFF1A237E),
      'lightColor': const Color(0xFF7986CB),
    },
  ];

  bool get isDarkMode => _isDarkMode;
  Color get primaryColor => _primaryColor;
  int get selectedThemeIndex => _selectedThemeIndex;
  List<Map<String, dynamic>> get themes => _themes;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  void setPrimaryColor(Color color) {
    _primaryColor = color;
    notifyListeners();
  }

  void setThemeByIndex(int index) {
    if (index >= 0 && index < _themes.length) {
      _selectedThemeIndex = index;
      _primaryColor = _themes[index]['color'];
      notifyListeners();
    }
  }

  Color get darkColor {
    return _themes[_selectedThemeIndex]['darkColor'];
  }

  Color get lightColor {
    return _themes[_selectedThemeIndex]['lightColor'];
  }

  String get currentThemeName {
    return _themes[_selectedThemeIndex]['name'];
  }

  Color get textColor {
    return _isDarkMode ? Colors.white : Colors.black;
  }

  Color get backgroundColor {
    return _isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8FDF8);
  }

  Color get surfaceColor {
    return _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
  }

  Color get borderColor {
    return _isDarkMode ? const Color(0xFF333333) : const Color(0xFFE5E5EA);
  }

  Color get secondaryTextColor {
    return _isDarkMode ? const Color(0xFFB0B0B0) : const Color(0xFF666666);
  }
}