// lib/main.dart (COMPLETE UPDATED VERSION)
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/route_helper.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'screens/landing/landing_page.dart';
import 'screens/main/main_screen.dart';
import 'utils/constants.dart';
import 'utils/theme_utils.dart'; // Add this import
import 'providers/notification_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/language_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(
          create: (context) => NotificationProvider(
            NotificationService(),
          ),
        ),
      ],
      child: Consumer2<ThemeProvider, LanguageProvider>(
        builder: (context, themeProvider, languageProvider, child) {
          return MaterialApp(
            title: AppStrings.appName,
            theme: _buildLightTheme(themeProvider),
            darkTheme: _buildDarkTheme(themeProvider),
            themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            locale: _getLocale(languageProvider.currentLanguage),
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('am', 'ET'),
              Locale('ti', 'ER'),
            ],
            initialRoute: RouteHelper.initial,
            onGenerateRoute: RouteHelper.generateRoute,
            debugShowCheckedModeBanner: false,
            home: const AppStartupScreen(),
          );
        },
      ),
    );
  }

  ThemeData _buildLightTheme(ThemeProvider themeProvider) {
    return ThemeData.light().copyWith(
      useMaterial3: true,
      scaffoldBackgroundColor: themeProvider.backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: themeProvider.primaryColor,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        elevation: 1,
        shadowColor: themeProvider.isDarkMode 
            ? Colors.black.withOpacity(0.5) 
            : const Color(0xFFE0E0E0),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: themeProvider.primaryColor,
        primary: themeProvider.primaryColor,
        secondary: themeProvider.lightColor,
        brightness: Brightness.light,
        background: themeProvider.backgroundColor,
        surface: themeProvider.surfaceColor,
        onSurface: themeProvider.textColor,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: themeProvider.surfaceColor,
        selectedItemColor: themeProvider.primaryColor,
        unselectedItemColor: themeProvider.secondaryTextColor,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: themeProvider.primaryColor,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardTheme(
        color: themeProvider.surfaceColor,
        elevation: 2,
        shadowColor: themeProvider.isDarkMode 
            ? Colors.black 
            : Colors.grey[300],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: themeProvider.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: themeProvider.primaryColor,
          side: BorderSide(color: themeProvider.primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: themeProvider.primaryColor,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: themeProvider.isDarkMode 
            ? const Color(0xFF2D2D2D) 
            : Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: themeProvider.primaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: themeProvider.borderColor),
        ),
        labelStyle: TextStyle(color: themeProvider.secondaryTextColor),
        hintStyle: TextStyle(color: themeProvider.secondaryTextColor),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: themeProvider.textColor,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: themeProvider.textColor,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: themeProvider.textColor,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: themeProvider.textColor,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: themeProvider.textColor,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: themeProvider.textColor,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: themeProvider.textColor,
        ),
        titleSmall: TextStyle(
          color: themeProvider.textColor,
        ),
        bodyLarge: TextStyle(
          color: themeProvider.textColor,
        ),
        bodyMedium: TextStyle(
          color: themeProvider.textColor,
        ),
        bodySmall: TextStyle(
          color: themeProvider.secondaryTextColor,
        ),
        labelLarge: TextStyle(
          color: themeProvider.textColor,
        ),
        labelMedium: TextStyle(
          color: themeProvider.secondaryTextColor,
        ),
        labelSmall: TextStyle(
          color: themeProvider.secondaryTextColor,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: themeProvider.borderColor,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: themeProvider.surfaceColor,
        selectedColor: themeProvider.primaryColor.withOpacity(0.2),
        checkmarkColor: themeProvider.primaryColor,
        labelStyle: TextStyle(color: themeProvider.textColor),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
        brightness: themeProvider.isDarkMode ? Brightness.dark : Brightness.light,
      ),
      iconTheme: IconThemeData(
        color: themeProvider.textColor,
      ),
      tabBarTheme: TabBarTheme(
        labelColor: themeProvider.primaryColor,
        unselectedLabelColor: themeProvider.secondaryTextColor,
        indicator: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: themeProvider.primaryColor,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  ThemeData _buildDarkTheme(ThemeProvider themeProvider) {
    return ThemeData.dark().copyWith(
      useMaterial3: true,
      scaffoldBackgroundColor: themeProvider.backgroundColor,
      appBarTheme: AppBarTheme(
        backgroundColor: themeProvider.primaryColor,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.5),
      ),
      colorScheme: ColorScheme.fromSeed(
        seedColor: themeProvider.primaryColor,
        primary: themeProvider.primaryColor,
        secondary: themeProvider.lightColor,
        brightness: Brightness.dark,
        background: themeProvider.backgroundColor,
        surface: themeProvider.surfaceColor,
        onSurface: Colors.white,
        surfaceVariant: const Color(0xFF2D2D2D),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: themeProvider.surfaceColor,
        selectedItemColor: themeProvider.primaryColor,
        unselectedItemColor: themeProvider.secondaryTextColor,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: themeProvider.primaryColor,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardTheme(
        color: themeProvider.surfaceColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: themeProvider.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: themeProvider.primaryColor,
          side: BorderSide(color: themeProvider.primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: themeProvider.primaryColor,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF2D2D2D),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: themeProvider.primaryColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        labelStyle: TextStyle(color: themeProvider.secondaryTextColor),
        hintStyle: TextStyle(color: themeProvider.secondaryTextColor),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      textTheme: TextTheme(
        displayLarge: TextStyle(
          color: themeProvider.textColor,
          fontWeight: FontWeight.bold,
        ),
        displayMedium: TextStyle(
          color: themeProvider.textColor,
          fontWeight: FontWeight.bold,
        ),
        displaySmall: TextStyle(
          color: themeProvider.textColor,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: themeProvider.textColor,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: themeProvider.textColor,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: themeProvider.textColor,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: themeProvider.textColor,
        ),
        titleSmall: TextStyle(
          color: themeProvider.textColor,
        ),
        bodyLarge: TextStyle(
          color: themeProvider.textColor,
        ),
        bodyMedium: TextStyle(
          color: themeProvider.textColor,
        ),
        bodySmall: TextStyle(
          color: themeProvider.secondaryTextColor,
        ),
        labelLarge: TextStyle(
          color: themeProvider.textColor,
        ),
        labelMedium: TextStyle(
          color: themeProvider.secondaryTextColor,
        ),
        labelSmall: TextStyle(
          color: themeProvider.secondaryTextColor,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: themeProvider.borderColor,
        thickness: 1,
        space: 1,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: themeProvider.surfaceColor,
        selectedColor: themeProvider.primaryColor.withOpacity(0.2),
        checkmarkColor: themeProvider.primaryColor,
        labelStyle: TextStyle(color: themeProvider.textColor),
        secondaryLabelStyle: const TextStyle(color: Colors.white),
        brightness: Brightness.dark,
      ),
      iconTheme: IconThemeData(
        color: themeProvider.textColor,
      ),
      tabBarTheme: TabBarTheme(
        labelColor: themeProvider.primaryColor,
        unselectedLabelColor: themeProvider.secondaryTextColor,
        indicator: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: themeProvider.primaryColor,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Locale? _getLocale(String languageCode) {
    switch (languageCode) {
      case 'en':
        return const Locale('en', 'US');
      case 'am':
        return const Locale('am', 'ET');
      case 'ti':
        return const Locale('ti', 'ER');
      default:
        return const Locale('en', 'US');
    }
  }
}

class AppStartupScreen extends StatefulWidget {
  const AppStartupScreen({super.key});

  @override
  State<AppStartupScreen> createState() => _AppStartupScreenState();
}

class _AppStartupScreenState extends State<AppStartupScreen> {
  late Future<bool> _checkAuthStatus;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus = _checkAuthentication();
  }

  Future<bool> _checkAuthentication() async {
    try {
      final authService = AuthService();
      return await authService.isLoggedIn();
    } catch (error) {
      debugPrint('Error checking auth status: $error');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkAuthStatus,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        
        if (snapshot.hasError) {
          return ErrorScreen(error: snapshot.error.toString());
        }
        
        final isLoggedIn = snapshot.data ?? false;
        return isLoggedIn ? const MainScreen() : const LandingPage();
      },
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    
    return Scaffold(
      backgroundColor: themeProvider.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                Icons.calendar_today_rounded,
                size: 60,
                color: themeProvider.primaryColor,
              ),
            ),
            const SizedBox(height: 30),
            
            Text(
              AppStrings.appName,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),
            
            Text(
              'Book Services Anytime',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 50),
            
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.white.withOpacity(0.8),
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            Text(
              'Loading...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  final String error;
  
  const ErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: themeProvider.backgroundColor,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode 
                      ? Colors.orange.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 60,
                  color: themeProvider.isDarkMode ? Colors.orange : Colors.red,
                ),
              ),
              const SizedBox(height: 30),
              
              Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: themeProvider.textColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: themeProvider.secondaryTextColor,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 40),
              
              ThemeUtils.themedElevatedButton(
                context: context,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AppStartupScreen(),
                    ),
                  );
                },
                child: const Text(
                  'Retry',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              
              const SizedBox(height: 15),
              
              ThemeUtils.themedTextButton(
                context: context,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LandingPage(),
                    ),
                  );
                },
                child: const Text(
                  'Go to Home Page',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}