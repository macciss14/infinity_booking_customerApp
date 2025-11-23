import 'package:flutter/material.dart';
import 'package:mobile_app/utils/constants.dart';

class ContactContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Us',
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
                children: [
                  _buildContactInfo(
                    Icons.email,
                    'Email',
                    'info@infinitybooking.com',
                  ),
                  SizedBox(height: 16),
                  _buildContactInfo(Icons.phone, 'Phone', '+251 (979) 108-969'),
                  SizedBox(height: 16),
                  _buildContactInfo(
                    Icons.location_on,
                    'Address',
                    'MIT , Aynalem-mekelle, tigray',
                  ),
                  SizedBox(height: 24),
                  Text(
                    'We\'re here to help! Reach out to us with any questions or concerns.',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(IconData icon, String title, String info) {
    return Row(
      children: [
        Icon(icon, color: Constants.primaryColor, size: 24),
        SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(info, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ],
    );
  }
}
