import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'setting_screen_backend.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final SettingsProvider _settingsProvider = SettingsProvider();

  final List<Map<String, String>> _languages = [
    {'name': 'English', 'script': 'English'},
    {'name': 'Sinhala', 'script': 'සිංහල'},
    {'name': 'Tamil', 'script': 'தமிழ்'},
  ];

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _settingsProvider,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFF9FAFB),
          extendBody: true,
          appBar: _buildAppBar(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildAppearanceSection(),
                const SizedBox(height: 20),
                _buildLanguageSection(),
                const SizedBox(height: 20),
                _buildAutoBillSection(),
                const SizedBox(height: 20),
                _buildNotificationsSection(),
                const SizedBox(height: 100),
              ],
            ),
          ),
          floatingActionButton: SizedBox(
            height: 64,
            width: 64,
            child: FloatingActionButton(
              onPressed: () {},
              backgroundColor: const Color(0xFF4F46E5),
              shape: const CircleBorder(),
              elevation: 4,
              child: const Icon(Icons.add, color: Colors.white, size: 32),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          bottomNavigationBar: _buildBottomNavigationBar(),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D9488), Color(0xFF22C55E)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.spa, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              const Text(
                'Vello',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {},
            ),
            _buildGlassIconButton(Icons.settings),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassIconButton(IconData icon) {
    return Center(
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Settings',
          style: TextStyle(
            fontSize: 32, // Perfect match for Figma large headers
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Manage your app preferences',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildAppearanceSection() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 8),
            child: _buildSectionTitle('Appearance', null),
          ),
          ListTile(
            leading: const Icon(Icons.wb_sunny_outlined, color: Color(0xFF4B5563)),
            title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF1F2937))),
            subtitle: Text(_settingsProvider.isDarkMode ? 'Enabled' : 'Disabled', style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
            trailing: CupertinoSwitch(
              value: _settingsProvider.isDarkMode,
              onChanged: (val) => _settingsProvider.setDarkMode(val),
              activeColor: const Color(0xFF22C55E),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildLanguageSection() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 8),
            child: _buildSectionTitle('Language', Icons.language),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: _languages.map((lang) {
                final isSelected = _settingsProvider.language == lang['name'];
                return GestureDetector(
                  onTap: () => _settingsProvider.setLanguage(lang['name']!),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFF0FDF4) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF22C55E) : const Color(0xFFE5E7EB),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lang['name']!,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: const Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(lang['script']!, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(color: Color(0xFF22C55E), shape: BoxShape.circle),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAutoBillSection() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 8),
            child: _buildSectionTitle('Auto Bill Detection', null),
          ),
          _buildSwitchTile(
            icon: Icons.email_outlined,
            title: 'Email Bills',
            subtitle: 'Auto-detect bills from Gmail',
            value: _settingsProvider.emailBills,
            onChanged: (val) => _settingsProvider.setEmailBills(val),
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6), indent: 16, endIndent: 16),
          _buildSwitchTile(
            icon: Icons.chat_bubble_outline,
            title: 'SMS Bills',
            subtitle: 'Auto-detect bills from messages',
            value: _settingsProvider.smsBills,
            onChanged: (val) => _settingsProvider.setSmsBills(val),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 8),
            child: _buildSectionTitle('Notifications', Icons.notifications_none),
          ),
          _buildSwitchTile(
            icon: Icons.notifications_none,
            title: 'Budget Alerts',
            subtitle: 'Get notified when approaching budget limits',
            value: _settingsProvider.budgetAlerts,
            onChanged: (val) => _settingsProvider.setBudgetAlerts(val),
          ),
          const Divider(height: 1, color: Color(0xFFF3F4F6), indent: 16, endIndent: 16),
          _buildSwitchTile(
            icon: Icons.analytics_outlined,
            title: 'Weekly Summary',
            subtitle: 'Receive weekly spending summaries',
            value: _settingsProvider.weeklySummary,
            onChanged: (val) => _settingsProvider.setWeeklySummary(val),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData? icon) {
    if (icon != null) {
      return Row(
        children: [
          Icon(icon, color: const Color(0xFF1F2937), size: 20),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
              letterSpacing: 0.3,
            ),
          ),
        ],
      );
    }
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1F2937),
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF4B5563)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: Color(0xFF1F2937))),
      subtitle: Text(subtitle, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13), maxLines: 2),
      trailing: CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF22C55E),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, -5)),
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: BottomAppBar(
            elevation: 0,
            color: Colors.transparent,
            shape: const CircularNotchedRectangle(),
            notchMargin: 10,
            child: SizedBox(
              height: 65,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(Icons.account_balance_wallet_outlined, 'Home', false),
                  _buildNavItem(Icons.qr_code_scanner, 'Scan', false),
                  const SizedBox(width: 48), // Space for floating button
                  _buildNavItem(Icons.calendar_month_outlined, 'Events', false),
                  _buildNavItem(Icons.smart_toy_outlined, 'AI', false),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isActive ? const Color(0xFF22C55E) : const Color(0xFF6B7280), size: 26),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: isActive ? FontWeight.bold : FontWeight.w500, color: isActive ? const Color(0xFF22C55E) : const Color(0xFF6B7280))),
        ],
      ),
    );
  }
}