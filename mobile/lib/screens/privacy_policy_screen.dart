import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Text(
            'TraceOff Privacy Policy',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(
            'TraceOff is built with a strict privacy-first design. We do not collect, store, '
            'or sell your personal data. Our system is designed to avoid keeping logs of your '
            'usage beyond what is absolutely necessary for short-term abuse prevention and rate limiting.',
          ),
          SizedBox(height: 12),
          Text(
            'Key principles:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
              '• Input URLs are processed transiently in memory and never stored on our servers.'),
          Text(
              '• We do not persist raw IP addresses, request metadata, or identifiers in long-term logs.'),
          Text(
              '• No account, email, or personal profile is required to use the service.'),
          Text(
              '• No third-party trackers, analytics SDKs, or ad libraries are embedded in the app.'),
          SizedBox(height: 12),
          Text(
            'Data we may process briefly:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
              '• Input URLs you provide for cleaning (kept in memory only during processing).'),
          Text(
              '• Minimal telemetry such as aggregate request counters for abuse prevention.'),
          SizedBox(height: 12),
          Text(
            'On-device storage:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
              '• Local history, preferences, and settings are stored securely on your device only.'),
          Text(
              '• You have full control to clear your history and data at any time.'),
          SizedBox(height: 12),
          Text(
            'Transparency & Open Source:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'The TraceOff source code is fully open and can be inspected or built on your own machine. '
            'You may run the cleaning logic locally by choosing "Run Remote" mode, or directly review '
            'how requests are handled in our GitHub repository: https://github.com/aimuhire/TraceOff',
          ),
          SizedBox(height: 12),
          Text(
            'Contact',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'For questions, feedback, or concerns about this policy, please open an issue on our GitHub repository.',
          ),
        ],
      ),
    );
  }
}
