// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/route_helper.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'screens/landing/landing_page.dart';
import 'screens/main/main_screen.dart';
import 'utils/constants.dart';
import 'providers/notification_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Create NotificationProvider with NotificationService dependency
        ChangeNotifierProvider(
          create: (context) => NotificationProvider(
            NotificationService(),
          ),
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.scaffoldBackground,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            titleTextStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            elevation: 1,
            shadowColor: AppColors.shadowMedium,
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            secondary: AppColors.secondary,
          ),
          // Add bottom navigation bar theme for MainScreen
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: Colors.grey,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
          ),
        ),
        initialRoute: RouteHelper.initial,
        onGenerateRoute: RouteHelper.generateRoute,
        debugShowCheckedModeBanner: false,
        home: const AppStartupScreen(),
      ),
    );
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
        // Show loading screen
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        
        // Show error screen if there's an error
        if (snapshot.hasError) {
          return ErrorScreen(error: snapshot.error.toString());
        }
        
        // Determine which screen to show based on auth status
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
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App logo/icon
            Icon(
              Icons.calendar_today,
              size: 80,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            
            // App name
            Text(
              AppStrings.appName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            
            // App tagline (optional)
            Text(
              'Book Services Anytime',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 40),
            
            // Loading indicator
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 20),
            
            // Loading text
            Text(
              'Loading...',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
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
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Error icon
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 20),
              
              // Error title
              const Text(
                'Oops! Something went wrong',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              
              // Error message
              Text(
                error,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 30),
              
              // Retry button
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AppStartupScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              
              // Alternative: Go to landing page
              TextButton(
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
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}