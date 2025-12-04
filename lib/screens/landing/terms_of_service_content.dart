import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class TermsOfServiceContent extends StatelessWidget {
  const TermsOfServiceContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Terms of Service'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Terms of Service',
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
              title: '1. Acceptance of Terms',
              content:
                  'By accessing and using Infinity Booking, you accept and agree to be bound by the terms and provision of this agreement.',
            ),
            _buildSection(
              title: '2. Use License',
              content:
                  'Permission is granted to temporarily use Infinity Booking for personal, non-commercial transitory viewing only.',
            ),
            _buildSection(
              title: '3. Booking Rules',
              content:
                  'Users must provide accurate information when making bookings. Cancellations must be made within the specified time frame to avoid charges.',
            ),
            _buildSection(
              title: '4. User Responsibilities',
              content:
                  'Users are responsible for maintaining the confidentiality of their account and password and for restricting access to their device.',
            ),
            _buildSection(
              title: '5. Service Modifications',
              content:
                  'Infinity Booking reserves the right to modify or discontinue any service with or without notice at any time.',
            ),
            _buildSection(
              title: '6. Refund Policy',
              content:
                  'Refunds are processed according to our cancellation policy. Service providers are responsible for their own refund policies.',
            ),
            _buildSection(
              title: '7. Limitation of Liability',
              content:
                  'Infinity Booking shall not be liable for any indirect, incidental, special, consequential or punitive damages.',
            ),
            _buildSection(
              title: '8. Governing Law',
              content:
                  'These terms shall be governed and construed in accordance with the laws of the application\'s operating jurisdiction.',
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
              'If you have any questions about these Terms, please contact us at support@infinitybooking.com',
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
