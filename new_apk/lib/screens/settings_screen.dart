import 'package:flutter/material.dart';

import '../widgets/settings_button.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store Settings & Integrations'),
        backgroundColor: const Color(0xFF0A0A0D),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSettingsGroup('BUSINESS PROFILE', [
            const SettingsButton(
              icon: Icons.store,
              iconColor: Color(0xFFFFD700),
              title: 'Store Details',
              subtitle: 'VyaparBeast Retail Outlet #01',
              onTap: _noop,
            ),
            const SettingsButton(
              icon: Icons.camera_alt_outlined,
              iconColor: Colors.pinkAccent,
              title: 'Instagram Page Linking',
              subtitle: '@vyaparbeast.official',
              onTap: _noop,
            ),
          ]),
          const SizedBox(height: 16),
          _buildSettingsGroup('COMMUNICATION & APIS', [
            const SettingsButton(
              icon: Icons.message,
              iconColor: Color(0xFF25D366),
              title: 'WhatsApp Integration',
              subtitle: 'Native Deep Linking Enabled',
              trailing: Switch(value: true, onChanged: null),
            ),
            const SettingsButton(
              icon: Icons.auto_awesome,
              iconColor: Colors.amber,
              title: 'AI Copywriting Engine',
              subtitle: 'Groq / HuggingFace Connected',
              onTap: _noop,
            ),
          ]),
          const SizedBox(height: 16),
          _buildSettingsGroup('SYSTEM LOGOUT', [
            const SettingsButton(
              icon: Icons.logout,
              iconColor: Colors.redAccent,
              title: 'Logout Session',
              titleStyle: TextStyle(color: Colors.redAccent),
              trailing: SizedBox.shrink(),
              onTap: _noop,
            ),
          ]),
        ],
      ),
    );
  }

  static void _noop() {}

  Widget _buildSettingsGroup(String title, List<Widget> tiles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFFFD700),
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF141419),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF2B2B36)),
          ),
          child: Column(children: tiles),
        ),
      ],
    );
  }
}
