import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'setting_screen_backend.dart';
import '../services/gmail_connection_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GmailConnectionService _gmailService = GmailConnectionService();

  final List<Map<String, String>> _languages = [
    {'name': 'English', 'script': 'English'},
    {'name': 'Sinhala', 'script': 'සිංහල'},
    {'name': 'Tamil', 'script': 'தமிழ்'},
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final isDarkMode = settings.isDarkMode;
        return Scaffold(
          backgroundColor: isDarkMode ? const Color(0xFF111827) : const Color(0xFFF9FAFB),
          extendBody: true,
          appBar: _buildAppBar(settings),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(settings),
                const SizedBox(height: 28),
                _buildAppearanceSection(settings),
                const SizedBox(height: 20),
                _buildLanguageSection(settings),
                const SizedBox(height: 20),
                _buildAutoBillSection(settings),
                const SizedBox(height: 20),
                _buildNotificationsSection(settings),
                const SizedBox(height: 120), // Bottom padding
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNavigationBar(settings),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(SettingsProvider settings) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Text(
        settings.t('Settings'),
        style: TextStyle(
          color: settings.isDarkMode ? Colors.white : const Color(0xFF111827),
          fontWeight: FontWeight.w400,
          fontSize: 20,
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: settings.isDarkMode ? Colors.white : Colors.black),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Future<void> _handleEmailBillsToggle(bool val, SettingsProvider settings) async {
    if (val) {
      // Enabling
      try {
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please log in first')),
          );
          return;
        }

        await _gmailService.connectGmail(userId);
        await settings.setEmailBills(true);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gmail connected successfully!')),
        );
      } catch (e) {
        debugPrint('Gmail connection failed: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to connect Gmail. Please try again.')),
        );
      }
    } else {
      // Disabling (could optionally disconnect from Google here too)
      await settings.setEmailBills(false);
    }
  }

  Widget _buildHeader(SettingsProvider settings) {
    final isDark = settings.isDarkMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          settings.t('Settings'),
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF111827),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          settings.t('Manage your app preferences'),
          style: TextStyle(
            fontSize: 14,
            color: isDark ? const Color(0xFF9CA3AF) : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildAppearanceSection(SettingsProvider settings) {
    final isDark = settings.isDarkMode;
    return _buildCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 8),
            child: _buildSectionTitle(settings.t('Appearance'), null, isDark),
          ),
          ListTile(
            leading: Icon(Icons.wb_sunny_outlined, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563)),
            title: Text(settings.t('Dark Mode'), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: isDark ? Colors.white : const Color(0xFF1F2937))),
            subtitle: Text(isDark ? settings.t('Enabled') : settings.t('Disabled'), style: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280), fontSize: 13)),
            trailing: CupertinoSwitch(
              value: settings.isDarkMode,
              onChanged: (val) => settings.setDarkMode(val),
              activeColor: const Color(0xFF22C55E),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildLanguageSection(SettingsProvider settings) {
    final isDark = settings.isDarkMode;
    return _buildCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 8),
            child: _buildSectionTitle(settings.t('Language'), Icons.language, isDark),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: _languages.map((lang) {
                final isSelected = settings.language == lang['name'];
                return GestureDetector(
                  onTap: () => settings.setLanguage(lang['name']!),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected ? (isDark ? const Color(0xFF042F2E) : const Color(0xFFF0FDF4)) : (isDark ? const Color(0xFF1F2937) : Colors.white),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? const Color(0xFF22C55E) : (isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
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
                                settings.t(lang['name']!),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isDark ? Colors.white : const Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(lang['script']!, style: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280), fontSize: 13)),
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

  Widget _buildAutoBillSection(SettingsProvider settings) {
    final isDark = settings.isDarkMode;
    return _buildCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 8),
            child: _buildSectionTitle(settings.t('Auto Bill Detection'), null, isDark),
          ),
          _buildSwitchTile(
            isDark: isDark,
            icon: Icons.email_outlined,
            title: settings.t('Email Bills'),
            subtitle: settings.t('Auto-detect bills from Gmail'),
            value: settings.emailBills,
            onChanged: (val) => _handleEmailBillsToggle(val, settings),
          ),
          Divider(height: 1, color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6), indent: 16, endIndent: 16),
          _buildSwitchTile(
            isDark: isDark,
            icon: Icons.chat_bubble_outline,
            title: settings.t('SMS Bills'),
            subtitle: settings.t('Auto-detect bills from messages'),
            value: settings.smsBills,
            onChanged: (val) => settings.setSmsBills(val),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection(SettingsProvider settings) {
    final isDark = settings.isDarkMode;
    return _buildCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 8),
            child: _buildSectionTitle(settings.t('Notifications'), Icons.notifications_none, isDark),
          ),
          _buildSwitchTile(
            isDark: isDark,
            title: settings.t('Budget Alerts'),
            subtitle: settings.t('Get notified when approaching budget limits'),
            value: settings.budgetAlerts,
            onChanged: (val) => settings.setBudgetAlerts(val),
          ),
          Divider(height: 1, color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6), indent: 16, endIndent: 16),
          _buildSwitchTile(
            isDark: isDark,
            title: settings.t('Weekly Summary'),
            subtitle: settings.t('Receive weekly spending summaries'),
            value: settings.weeklySummary,
            onChanged: (val) => settings.setWeeklySummary(val),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData? icon, bool isDark) {
    if (icon != null) {
      return Row(
        children: [
          Icon(icon, color: isDark ? Colors.white : const Color(0xFF111827), size: 18),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : const Color(0xFF111827),
              letterSpacing: 0.3,
            ),
          ),
        ],
      );
    }
    return Text(
      title,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: isDark ? Colors.white : const Color(0xFF111827),
        letterSpacing: 0.3,
      ),
    );
  }

  Widget _buildCard({required Widget child, required bool isDark}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6), width: 1.5),
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
    IconData? icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return ListTile(
      leading: icon != null ? Icon(icon, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF374151)) : null,
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: isDark ? Colors.white : const Color(0xFF1F2937))),
      subtitle: Text(subtitle, style: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280), fontSize: 13), maxLines: 2),
      trailing: CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF22C55E),
      ),
    );
  }

  Widget _buildBottomNavigationBar(SettingsProvider settings) {
    final isDark = settings.isDarkMode;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937).withOpacity(0.95) : Colors.white.withOpacity(0.95),
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
                  _buildNavItem(Icons.account_balance_wallet_outlined, settings.t('Home'), false, isDark),
                  _buildNavItem(Icons.qr_code_scanner, settings.t('Scan'), false, isDark),
                  const SizedBox(width: 48), // Space for floating button
                  _buildNavItem(Icons.calendar_month_outlined, settings.t('Events'), false, isDark),
                  _buildNavItem(Icons.smart_toy_outlined, settings.t('AI'), false, isDark),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive, bool isDark) {
    return GestureDetector(
      onTap: () {},
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: isActive ? const Color(0xFF22C55E) : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)), size: 22), // Reduced icon size
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: isActive ? FontWeight.bold : FontWeight.w500, color: isActive ? const Color(0xFF22C55E) : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)))),
        ],
      ),
    );
  }
}