import 'package:flutter/material.dart';
import '../../config/route_helper.dart';
import 'home_content.dart';
import 'how_it_works_content.dart';
import 'about_content.dart';
import 'contact_content.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeContent(),
    HowItWorksContent(),
    AboutContent(),
    ContactContent(),
  ];

  final List<String> _appBarTitles = const [
    'Infinity Booking',
    'How It Works',
    'About Us',
    'Contact Us',
  ];

  void _navigateToLogin() {
    RouteHelper.pushNamed(context, RouteHelper.login);
  }

  void _navigateToRegister() {
    RouteHelper.pushNamed(context, RouteHelper.register);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_appBarTitles[_currentIndex]),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                TextButton(
                  onPressed: _navigateToLogin,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Login'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _navigateToRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                  ),
                  child: const Text('Register'),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ✅ FIXED: Make content scrollable
          Expanded(
            child: SingleChildScrollView(
              child: _pages[_currentIndex],
            ),
          ),
          // Footer with Terms & Privacy - fixed at bottom
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade300)),
              color: Colors.grey[50],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    RouteHelper.pushNamed(
                        context, RouteHelper.termsOfServiceContent);
                  },
                  child: const Text(
                    'Terms of Service',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
                Container(
                  width: 1,
                  height: 12,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    RouteHelper.pushNamed(
                        context, RouteHelper.privacyPolicyContent);
                  },
                  child: const Text(
                    'Privacy Policy',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.help),
            label: 'How It Works',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'About',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_mail),
            label: 'Contact',
          ),
        ],
      ),
    );
  }
}
