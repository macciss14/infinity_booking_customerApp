import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class PrivacyPolicyContent extends StatelessWidget {
  const PrivacyPolicyContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Privacy Policy',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last updated: ${DateTime.now().toString().split(' ')[0]}',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            _buildSection(
              title: '1. Information We Collect',
              content:
                  'We collect personal information you provide directly to us, such as name, email address, phone number, and booking preferences.',
            ),
            _buildSection(
              title: '2. How We Use Your Information',
              content:
                  'We use the information we collect to provide, maintain, and improve our services, process your bookings, and communicate with you.',
            ),
            _buildSection(
              title: '3. Information Sharing',
              content:
                  'We do not sell your personal information. We may share information with service providers to fulfill your bookings and with your consent.',
            ),
            _buildSection(
              title: '4. Data Storage & Protection',
              content:
                  'We implement appropriate security measures to protect your personal information against unauthorized access, alteration, or destruction.',
            ),
            _buildSection(
              title: '5. Your Rights',
              content:
                  'You have the right to access, correct, or delete your personal information. You can manage your preferences in your account settings.',
            ),
            _buildSection(
              title: '6. Cookies & Tracking',
              content:
                  'We use cookies and similar tracking technologies to track activity on our application and hold certain information.',
            ),
            _buildSection(
              title: '7. Third-Party Services',
              content:
                  'Our service may contain links to third-party websites or services that are not operated by us. We have no control over their content.',
            ),
            _buildSection(
              title: '8. Changes to This Policy',
              content:
                  'We may update our Privacy Policy from time to time. We will notify you of any changes by posting the new policy on this page.',
            ),
            const SizedBox(height: 32),
            const Text(
              'Contact Us',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'If you have any questions about this Privacy Policy, please contact us at privacy@infinitybooking.com',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
