import 'package:flutter/material.dart';
import 'package:mobile_app/utils/constants.dart';
import 'home_content.dart';
import 'about_content.dart';
import 'how_it_works_content.dart';
import 'contact_content.dart';

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int _currentIndex = 0;

  final List<String> _sectionTitles = [
    'Home',
    'About',
    'How It Works',
    'Contact',
  ];

  final List<IconData> _sectionIcons = [
    Icons.home,
    Icons.info,
    Icons.how_to_reg,
    Icons.contact_mail,
  ];

  @override
  Widget build(BuildContext context) {
    final List<Widget> _sectionWidgets = [
      HomeContent(
        onLoginRegisterPressed: () {
          Navigator.pushNamed(context, '/login');
        },
      ),
      AboutContent(),
      HowItWorksContent(),
      ContactContent(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Infinity Booking',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Constants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
              ),
              child: Text(
                'Login / Register',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
      body: _sectionWidgets[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: List.generate(
            _sectionTitles.length,
            (index) => BottomNavigationBarItem(
              icon: Icon(_sectionIcons[index]),
              label: _sectionTitles[index],
            ),
          ),
          selectedItemColor: Constants.primaryColor,
          unselectedItemColor: Colors.grey[600],
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
          showUnselectedLabels: true,
        ),
      ),
    );
  }
}
