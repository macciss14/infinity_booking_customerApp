import 'package:flutter/material.dart';
import 'package:mobile_app/utils/constants.dart';

class AboutContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About Infinity Booking',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Constants.primaryColor,
            ),
          ),
          SizedBox(height: 20),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: EdgeInsets.all(24),
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
                  SizedBox(height: 12),
                  Text(
                    'At Infinity Booking, we believe in making service booking simple, reliable, and accessible to everyone. Our platform connects customers with trusted service providers, ensuring quality and convenience.',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'What We Offer',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Constants.primaryColor,
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildBulletPoint('Wide range of service categories'),
                  _buildBulletPoint('Verified and rated service providers'),
                  _buildBulletPoint('Easy online booking and payments'),
                  _buildBulletPoint('Real-time booking tracking'),
                  _buildBulletPoint('Customer support 24/7'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Constants.accentColor, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
