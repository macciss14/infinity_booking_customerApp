import 'package:flutter/material.dart';

class AboutContent extends StatelessWidget {
  const AboutContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'About Infinity Booking',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),

          // Mission Section
          _buildSection(
            title: 'Our Mission',
            content:
                'To revolutionize the way people book and manage services by providing a seamless, intuitive, and reliable platform that connects customers with trusted service providers.',
            icon: Icons.flag,
          ),
          const SizedBox(height: 24),

          // Vision Section
          _buildSection(
            title: 'Our Vision',
            content:
                'To become the leading service booking platform globally, making service discovery and appointment management effortless for everyone.',
            icon: Icons.visibility,
          ),
          const SizedBox(height: 24),

          // What We Solve Section
          _buildSection(
            title: 'What We Solve',
            content:
                'Infinity Booking addresses the challenges of finding reliable service providers, managing appointments, and ensuring quality service delivery. We bridge the gap between customers and professional service providers.',
            icon: Icons.build,
          ),
          const SizedBox(height: 24),

          // Why We Exist Section
          _buildSection(
            title: 'Why Infinity Booking Exists',
            content:
                'We believe that booking services should be as simple as online shopping. Our platform eliminates the hassle of phone calls, waiting times, and uncertainty by providing instant booking, real-time updates, and verified service providers.',
            icon: Icons.question_answer,
          ),
          const SizedBox(height: 32),

          // Team Values
          const Text(
            'Our Values',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          _buildValueItem(
            context,
            title: 'Customer First',
            description: 'We prioritize customer satisfaction above all else',
          ),
          _buildValueItem(
            context,
            title: 'Innovation',
            description:
                'We continuously improve our platform with new features',
          ),
          _buildValueItem(
            context,
            title: 'Reliability',
            description: 'We ensure consistent and dependable service',
          ),
          _buildValueItem(
            context,
            title: 'Transparency',
            description: 'We maintain clear communication and honest pricing',
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: Colors.blue,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildValueItem(
    BuildContext context, {
    required String title,
    required String description,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.blue,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
