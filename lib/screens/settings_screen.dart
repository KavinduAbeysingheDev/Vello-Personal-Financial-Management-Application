// settings_screen.dart
// Place this file in the same directory as main.dart (or in lib/screens/ and update the import in main.dart)
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
const SettingsScreen({super.key});

@override
State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
bool _darkMode = false;
String _selectedLanguage = 'English';
bool _emailBills = true;
bool _smsBills = true;
bool _budgetAlerts = true;
bool _weeklySummary = true;
bool _biometric = false;
bool _twoFactor = false;

final List<Map<String, String>> _languages = [
  {'name': 'English', 'script': 'English'},
  {'name': 'Sinhala', 'script': 'සිංහල'},
  {'name': 'Tamil', 'script': 'தமிழ்'},
];

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Row(
        children: [
          Icon(Icons.eco, size: 32),
          SizedBox(width: 8),
          Text(
            'Vello',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {}, // Already on Settings screen
        ),
      ],
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Settings (as mentioned in the query)
          const Text(
            'Profile',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30,
                    backgroundColor: Color(0xFF00BFA5),
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ransini Perera',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'ransini@example.com',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Page header (matches screenshots)
          const Text(
            'Settings',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Manage your app preferences',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Appearance Section (matches first screenshot)
          const Text(
            'Appearance',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.wb_sunny_outlined),
              title: const Text('Dark Mode'),
              subtitle: Text(_darkMode ? 'Enabled' : 'Disabled'),
              trailing: Switch(
                value: _darkMode,
                onChanged: (value) => setState(() => _darkMode = value),
                activeColor: const Color(0xFF00BFA5),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Language Section (matches first screenshot exactly - English highlighted with green bg + dot)
          const Text(
            'Language',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: _languages.map((lang) {
                final isSelected = _selectedLanguage == lang['name'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedLanguage = lang['name']!),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFE0F2F1) : null,
                      border: isSelected
                          ? Border.all(color: const Color(0xFF00BFA5), width: 1.5)
                          : null,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lang['name']!,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                              Text(
                                lang['script']!,
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFF00BFA5),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),

          // Auto Bill Detection Section (matches second screenshot)
          const Text(
            'Auto Bill Detection',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.email_outlined),
                  title: const Text('Email Bills'),
                  subtitle: const Text('Auto-detect bills from Gmail'),
                  trailing: Switch(
                    value: _emailBills,
                    onChanged: (val) => setState(() => _emailBills = val),
                    activeColor: const Color(0xFF00BFA5),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.sms_outlined),
                  title: const Text('SMS Bills'),
                  subtitle: const Text('Auto-detect bills from messages'),
                  trailing: Switch(
                    value: _smsBills,
                    onChanged: (val) => setState(() => _smsBills = val),
                    activeColor: const Color(0xFF00BFA5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Notifications Section (matches second screenshot)
          const Text(
            'Notifications',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Budget Alerts'),
                  subtitle: const Text('Get notified when approaching budget limits'),
                  trailing: Switch(
                    value: _budgetAlerts,
                    onChanged: (val) => setState(() => _budgetAlerts = val),
                    activeColor: const Color(0xFF00BFA5),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.summarize_outlined),
                  title: const Text('Weekly Summary'),
                  subtitle: const Text('Receive weekly spending summaries'),
                  trailing: Switch(
                    value: _weeklySummary,
                    onChanged: (val) => setState(() => _weeklySummary = val),
                    activeColor: const Color(0xFF00BFA5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Security Options (as explicitly mentioned in the query)
          const Text(
            'Security',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Change Password'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {},
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.fingerprint),
                  title: const Text('Biometric Authentication'),
                  trailing: Switch(
                    value: _biometric,
                    onChanged: (val) => setState(() => _biometric = val),
                    activeColor: const Color(0xFF00BFA5),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.security),
                  title: const Text('Two-Factor Authentication'),
                  trailing: Switch(
                    value: _twoFactor,
                    onChanged: (val) => setState(() => _twoFactor = val),
                    activeColor: const Color(0xFF00BFA5),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Logout', style: TextStyle(color: Colors.red)),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    ),

    // Bottom navigation (exactly as shown in both screenshots)
    bottomNavigationBar: BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF00BFA5),
      unselectedItemColor: Colors.grey,
      currentIndex: 2, // Add is center (demo)
      onTap: (index) {},
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.camera_alt),
          label: 'Scan',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add, color: Colors.purple, size: 32),
          label: 'Add',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.event),
          label: 'Events',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.smart_toy),
          label: 'AI',
        ),
      ],
    ),
  );
}
}