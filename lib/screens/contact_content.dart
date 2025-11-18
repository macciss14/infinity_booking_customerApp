// lib/screens/contact_content.dart

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart'; // Import for launching URLs
import '../utils/constants.dart'; // Import your constants

class ContactContent extends StatelessWidget {
  const ContactContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact Us',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Constants.forestGreen,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'We\'d love to hear from you! Reach out for support, inquiries, or feedback.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            SizedBox(height: 30),
            // Contact Options
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildContactOption(
                  Icons.email,
                  'Email Us',
                  'info@infinitybooking.com',
                ),
                _buildContactOption(Icons.phone, 'Call Us', '+251 979 108 969'),
              ],
            ),
            SizedBox(height: 30),
            // Contact Form Placeholder (Optional - Basic layout)
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Constants.secondaryColor, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Send us a Message',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Constants.secondaryColor,
                    ),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Your Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      labelText: 'Your Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Your Message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      // Handle form submission (requires backend integration)
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Thank you for your message! (Form submission not implemented yet)',
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.primaryColor,
                      padding: EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                    ),
                    child: Text(
                      'Send Message',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            // Social Media Links (Text placeholders for now)
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
                    'Follow Us',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Constants.accentColor,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Example text placeholders for social media
                      TextButton(
                        onPressed: () async {
                          final Uri url = Uri.parse(
                            'https://www.facebook.com/hayelomhailay',
                          ); // Replace with actual URL
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Could not launch Facebook URL'),
                              ),
                            );
                          }
                        },
                        child: Text(
                          'Facebook',
                          style: TextStyle(color: Constants.primaryColor),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final Uri url = Uri.parse(
                            'https://www.twitter.com/@Hayelom1419',
                          ); // Replace with actual URL
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Could not launch Twitter URL'),
                              ),
                            );
                          }
                        },
                        child: Text(
                          'Twitter',
                          style: TextStyle(color: Constants.primaryColor),
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final Uri url = Uri.parse(
                            'https://www.linkedin.com/company/hayelomhailay',
                          ); // Replace with actual URL
                          if (await canLaunchUrl(url)) {
                            await launchUrl(url);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Could not launch LinkedIn URL'),
                              ),
                            );
                          }
                        },
                        child: Text(
                          'LinkedIn',
                          style: TextStyle(color: Constants.primaryColor),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget for Contact Options
  Widget _buildContactOption(IconData icon, String title, String value) {
    return Container(
      width: 150, // Fixed width
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: Constants.primaryColor),
          SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          SizedBox(height: 5),
          Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
