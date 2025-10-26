import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  static const routeName = '/profile';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CircleAvatar(
            radius: 36,
            child: Text('U', style: Theme.of(context).textTheme.headlineMedium),
          ),
          const SizedBox(height: 12),
          Center(child: Text('User Name', style: Theme.of(context).textTheme.titleLarge)),
          const SizedBox(height: 24),
          const ListTile(leading: Icon(Icons.email_rounded), title: Text('user@example.com')),
          const ListTile(leading: Icon(Icons.settings_rounded), title: Text('Preferences')),
          const ListTile(leading: Icon(Icons.lock_rounded), title: Text('Security')),
        ],
      ),
    );
  }
}



