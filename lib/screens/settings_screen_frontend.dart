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

  final Map<String, Map<String, String>> _localizedStrings = {
    'Sinhala': {
      'Settings': 'සැකසුම්',
      'Manage your app preferences': 'ඔබගේ යෙදුම් මනාප කළමනාකරණය කරන්න',
      'Appearance': 'පෙනුම',
      'Dark Mode': 'අඳුරු තේමාව (Dark Mode)',
      'Enabled': 'සක්‍රියයි',
      'Disabled': 'අක්‍රියයි',
      'Language': 'භාෂාව',
      'Auto Bill Detection': 'බිල්පත් හඳුනාගැනීම',
      'Email Bills': 'ඊමේල් බිල්පත්',
      'Auto-detect bills from Gmail': 'Gmail මගින් බිල්පත් හඳුනාගන්න',
      'SMS Bills': 'කෙටිපණිවුඩ බිල්පත්',
      'Auto-detect bills from messages': 'SMS මගින් බිල්පත් හඳුනාගන්න',
      'Notifications': 'දැනුම්දීම්',
      'Budget Alerts': 'අයවැය ඇඟවීම්',
      'Get notified when approaching budget limits': 'අයවැය සීමාවන්ට ළඟා වන විට දැනුම් දෙන්න',
      'Weekly Summary': 'සතිපතා සාරාංශය',
      'Receive weekly spending summaries': 'සතිපතා වියදම් සාරාංශ ලබාගන්න',
      'Home': 'මුල් පිටුව',
      'Scan': 'ස්කෑන්',
      'Events': 'සිදුවීම්',
      'AI': 'AI',
    },
    'Tamil': {
      'Settings': 'அமைப்புகள்',
      'Manage your app preferences': 'பயன்பாட்டு விருப்பங்களை நிர்வகிக்கவும்',
      'Appearance': 'தோற்றம்',
      'Dark Mode': 'இருண்ட பயன்முறை',
      'Enabled': 'செயல்படுத்தப்பட்டது',
      'Disabled': 'முடக்கப்பட்டது',
      'Language': 'மொழி',
      'Auto Bill Detection': 'தானியங்கி பில் கண்டறிதல்',
      'Email Bills': 'மின்னஞ்சல் பில்கள்',
      'Auto-detect bills from Gmail': 'Gmail இலிருந்து பில்களைக் கண்டறியவும்',
      'SMS Bills': 'SMS பில்கள்',
      'Auto-detect bills from messages': 'SMS இலிருந்து பில்களைக் கண்டறியவும்',
      'Notifications': 'அறிவிப்புகள்',
      'Budget Alerts': 'பட்ஜெட் எச்சரிக்கைகள்',
      'Get notified when approaching budget limits': 'பட்ஜெட் வரம்புகளை நெருங்கும்போது அறிவிப்பைப் பெறுக',
      'Weekly Summary': 'வாராந்திர சுருக்கம்',
      'Receive weekly spending summaries': 'வாராந்திர செலவு சுருக்கங்களைப் பெறுக',
      'Home': 'முகப்பு',
      'Scan': 'ஸ்கேன்',
      'Events': 'நிகழ்வுகள்',
      'AI': 'AI',
    }
  };

  String t(String key) {
    if (_settingsProvider.language == 'English') return key;
    return _localizedStrings[_settingsProvider.language]?[key] ?? key;
  }

  bool get isDark => _settingsProvider.isDarkMode;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _settingsProvider,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB),
          extendBody: true,
          appBar: _buildAppBar(),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 28),
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
          color: Color(0xFF00966D), // Exact Teal background from screenshot
        ),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF2EAF8D), // Lighter teal box
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.grass, color: Color(0xFFFFD700), size: 16), // Gold icon
              ),
              const SizedBox(width: 10),
              const Text(
                'Vello',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400, // Normal font weight
                  fontSize: 20,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 22),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 22),
              onPressed: () {},
            ),
            const SizedBox(width: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          t('Settings'),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF111827),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          t('Manage your app preferences'),
          style: TextStyle(
            fontSize: 16,
            color: isDark ? const Color(0xFF9CA3AF) : Colors.grey.shade600,
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
            child: _buildSectionTitle(t('Appearance'), null),
          ),
          ListTile(
            leading: Icon(Icons.wb_sunny_outlined, color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563)),
            title: Text(t('Dark Mode'), style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: isDark ? Colors.white : const Color(0xFF1F2937))),
            subtitle: Text(isDark ? t('Enabled') : t('Disabled'), style: TextStyle(color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280), fontSize: 13)),
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
            child: _buildSectionTitle(t('Language'), Icons.language),
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
                                lang['name']!,
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

  Widget _buildAutoBillSection() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 8),
            child: _buildSectionTitle(t('Auto Bill Detection'), null),
          ),
          _buildSwitchTile(
            icon: Icons.email_outlined,
            title: t('Email Bills'),
            subtitle: t('Auto-detect bills from Gmail'),
            value: _settingsProvider.emailBills,
            onChanged: (val) => _settingsProvider.setEmailBills(val),
          ),
          Divider(height: 1, color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6), indent: 16, endIndent: 16),
          _buildSwitchTile(
            icon: Icons.chat_bubble_outline,
            title: t('SMS Bills'),
            subtitle: t('Auto-detect bills from messages'),
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
            child: _buildSectionTitle(t('Notifications'), Icons.notifications_none),
          ),
          _buildSwitchTile(
            title: t('Budget Alerts'),
            subtitle: t('Get notified when approaching budget limits'),
            value: _settingsProvider.budgetAlerts,
            onChanged: (val) => _settingsProvider.setBudgetAlerts(val),
          ),
          Divider(height: 1, color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6), indent: 16, endIndent: 16),
          _buildSwitchTile(
            title: t('Weekly Summary'),
            subtitle: t('Receive weekly spending summaries'),
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

  Widget _buildCard({required Widget child}) {
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

  Widget _buildBottomNavigationBar() {
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
                  _buildNavItem(Icons.account_balance_wallet_outlined, t('Home'), false),
                  _buildNavItem(Icons.qr_code_scanner, t('Scan'), false),
                  const SizedBox(width: 48), // Space for floating button
                  _buildNavItem(Icons.calendar_month_outlined, t('Events'), false),
                  _buildNavItem(Icons.smart_toy_outlined, t('AI'), false),
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
          Icon(icon, color: isActive ? const Color(0xFF22C55E) : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)), size: 26),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, fontWeight: isActive ? FontWeight.bold : FontWeight.w500, color: isActive ? const Color(0xFF22C55E) : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)))),
        ],
      ),
    );
  }
}