import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('About Cashlet'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // App Logo
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.account_balance_wallet,
                  size: 50,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ),

          // App Name and Version
          Center(
            child: Text(
              'Cashlet',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Version 1.0.0',
              style: theme.textTheme.titleMedium,
            ),
          ),

          const SizedBox(height: 32),

          // App Description
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Cashlet is a personal finance and task management app designed to help you track your expenses and stay organized in your daily life.',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Features',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  _buildFeatureItem('Track daily expenses and income'),
                  _buildFeatureItem(
                      'Categorize transactions for better insights'),
                  _buildFeatureItem('Manage tasks and get timely reminders'),
                  _buildFeatureItem('View reports and spending patterns'),
                  _buildFeatureItem('Dark mode support'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Privacy and Terms
          ListTile(
            leading: Icon(Icons.privacy_tip, color: theme.colorScheme.primary),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Open privacy policy page or link
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.description, color: theme.colorScheme.primary),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Open terms of service page or link
            },
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.mail, color: theme.colorScheme.primary),
            title: const Text('Contact Support'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // Open contact page or email client
            },
          ),

          const SizedBox(height: 32),

          // Made with love
          const Center(
            child: Text(
              'Made with ❤️ for better financial management',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•  ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
