// lib/screens/about_content.dart

import 'package:flutter/material.dart';
import '../utils/constants.dart'; // Import your constants

// Make sure the class name is exactly AboutContent
class AboutContent extends StatelessWidget {
  const AboutContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        // Allow scrolling if content overflows
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About Infinity-Booking',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Constants.forestGreen,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'We connect you with trusted professionals across Ethiopia, ensuring accessible, efficient, and reliable service delivery.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            SizedBox(height: 30),
            // Mission Statement
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Constants.primaryColor, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Our Mission',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Constants.primaryColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'To transform the Ethiopian service marketplace by creating a unified, trustworthy, and scalable platform for customers and providers.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Problem Statement from Proposal
            Text(
              'Why Infinity-Booking?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Constants.secondaryColor,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Finding reliable service providers in Ethiopia can be challenging. Fragmented markets, lack of trust, and inefficient processes often lead to frustration for both customers and providers.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            SizedBox(height: 15),
            // List of Problems
            ...[
              '• Difficulty finding trusted providers across multiple domains.',
              '• Time-consuming and inefficient service delivery.',
              '• Lack of reviews and verified profiles reduces user confidence.',
              '• Providers lack tools to optimize schedules and offerings.',
            ].map(
              (problem) => Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.close, color: Colors.red, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        problem,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            // Solution Statement
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Constants.accentColor, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Our Solution',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Constants.accentColor,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Infinity-Booking provides a centralized, user-friendly platform that connects customers with verified providers, streamlines bookings and payments, and builds trust through reviews and ratings.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Objectives from Proposal
            Text(
              'Our Objectives',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Constants.secondaryColor,
              ),
            ),
            SizedBox(height: 10),
            ...[
              '• Connect consumers with service providers across any category.',
              '• Enhance trust through verified profiles, ratings, and reviews.',
              '• Streamline booking, payment and communication for efficiency.',
              '• Empower providers with tools to manage offerings, track earnings, and engage with users.',
              '• Maintain extensibility, supporting infinite service categories as the platform grows.',
            ].map(
              (objective) => Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check, color: Colors.green, size: 18),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        objective,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
