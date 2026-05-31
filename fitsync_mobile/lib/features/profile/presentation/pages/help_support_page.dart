import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  static const _faqs = [
    (
      'How do I book a training session?',
      'Go to the Home tab, browse available trainings, and tap on any training card. On the training detail page, tap "Book Now" to select your date, time, and reservation type.',
    ),
    (
      'Can I cancel a reservation?',
      'Yes. Go to the Bookings tab, find your reservation, and tap the cancel button. Please note that cancellations may be subject to our cancellation policy.',
    ),
    (
      'What payment methods are supported?',
      'We support PayPal and cash payment. You can choose your preferred method during the booking confirmation step.',
    ),
    (
      'How do I leave a review?',
      'Open a training\'s detail page and tap "View Reviews". From there, tap the review icon in the top right corner to leave your rating and comment.',
    ),
    (
      'What are additional services?',
      'Additional services are optional add-ons you can include with your booking, such as equipment rental, nutrition consultation, or personal coaching extras.',
    ),
    (
      'How do I change my password?',
      'Go to the Profile tab and tap "Change Password". You\'ll need to enter your current password and then set a new one.',
    ),
    (
      'Why am I not receiving notifications?',
      'Make sure you\'ve granted notification permissions to the FitSync app in your device settings. You can also check your notification history in the Profile tab.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1923),
      appBar: AppBar(
        backgroundColor: const Color(0xFF152030),
        foregroundColor: Colors.white,
        title: const Text('Help & Support'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _ContactCard(),
          const SizedBox(height: 24),
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ...(_faqs.map((faq) => _FaqTile(question: faq.$1, answer: faq.$2))),
          const SizedBox(height: 24),
          _AppInfoCard(),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E2A3A), Color(0xFF152030)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8622A).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8622A).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.support_agent, color: Color(0xFFE8622A), size: 24),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Contact Support',
                      style: TextStyle(
                          color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('We\'re here to help',
                      style: TextStyle(color: Colors.white60, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ContactRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: 'support@fitsync.app',
          ),
          const SizedBox(height: 10),
          _ContactRow(
            icon: Icons.access_time,
            label: 'Hours',
            value: 'Mon – Fri, 9:00 AM – 6:00 PM',
          ),
          const SizedBox(height: 10),
          _ContactRow(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: '+1 (800) 348-7962',
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ContactRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF4A90D9), size: 18),
        const SizedBox(width: 10),
        Text('$label: ', style: TextStyle(color: Colors.grey[400], fontSize: 13)),
        Expanded(
          child: Text(value,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }
}

class _FaqTile extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A3A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        iconColor: const Color(0xFFE8622A),
        collapsedIconColor: Colors.white38,
        title: Text(
          question,
          style: const TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
        ),
        children: [
          Text(
            answer,
            style: TextStyle(color: Colors.grey[400], fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class _AppInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A3A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8622A).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.fitness_center, color: Color(0xFFE8622A), size: 22),
              ),
              const SizedBox(width: 10),
              const Text('FitSync',
                  style: TextStyle(
                      color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          Text('Version 1.0.0',
              style: TextStyle(color: Colors.grey[500], fontSize: 13)),
          const SizedBox(height: 4),
          Text('© 2025 FitSync. All rights reserved.',
              style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        ],
      ),
    );
  }
}
