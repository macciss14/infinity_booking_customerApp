import 'package:flutter/material.dart';
import 'package:mobile_app/utils/constants.dart';

class HowItWorksContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How It Works',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Constants.primaryColor,
            ),
          ),
          SizedBox(height: 20),
          _buildStep(
            number: 1,
            title: 'Create an Account',
            description: 'Sign up for free and create your profile',
            icon: Icons.person_add,
          ),
          _buildStep(
            number: 2,
            title: 'Browse Services',
            description: 'Explore various service categories and providers',
            icon: Icons.search,
          ),
          _buildStep(
            number: 3,
            title: 'Book a Service',
            description: 'Select your preferred service and time slot',
            icon: Icons.calendar_today,
          ),
          _buildStep(
            number: 4,
            title: 'Make Payment',
            description: 'Pay securely through our platform',
            icon: Icons.payment,
          ),
          _buildStep(
            number: 5,
            title: 'Enjoy the Service',
            description: 'Relax while our professionals serve you',
            icon: Icons.emoji_events,
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required int number,
    required String title,
    required String description,
    required IconData icon,
  }) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Constants.primaryColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  number.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            SizedBox(width: 16),
            Icon(icon, color: Constants.primaryColor, size: 24),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(description, style: TextStyle(color: Colors.grey[600])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
