import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vello_app/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vello_app/main.dart';

import '../services/gmail_connection_service.dart';
import '../widgets/vello_drawer.dart';
import '../widgets/vello_top_bar.dart';
import 'add_transaction_page.dart';
import 'setting_screen_backend.dart';
import '../services/reminder_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final GmailConnectionService _gmailService = GmailConnectionService();

  final List<Map<String, String>> _languages = const [
    {'code': 'en', 'script': 'English'},
    {'code': 'si', 'script': 'සිංහල'},
    {'code': 'ta', 'script': 'தமிழ்'},
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final l10n = AppLocalizations.of(context)!;
        final isDarkMode = settings.isDarkMode;
        final bottomSpacing = MediaQuery.of(context).padding.bottom + 180;

        return Scaffold(
          backgroundColor:
              isDarkMode ? const Color(0xFF111827) : const Color(0xFFF9FAFB),
          extendBody: true,
          appBar: const VelloTopBar(),
          endDrawer: const VelloDrawer(),
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            padding: EdgeInsets.fromLTRB(20, 24, 20, bottomSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(settings, l10n),
                const SizedBox(height: 28),
                _buildAppearanceSection(settings, l10n),
                const SizedBox(height: 20),
                _buildLanguageSection(settings, l10n),
                const SizedBox(height: 20),
                _buildAutoBillSection(settings, l10n),
                const SizedBox(height: 20),
                _buildNotificationsSection(settings, l10n),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNavigationBar(settings, l10n),
        );
      },
    );
  }

  Future<void> _handleEmailBillsToggle(
    bool val,
    SettingsProvider settings,
    AppLocalizations l10n,
  ) async {
    if (val) {
      try {
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.pleaseLogInFirst)),
          );
          return;
        }

        await _gmailService.connectGmail(userId);
        await settings.setEmailBills(true);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.gmailConnectedSuccessfully)),
        );
      } catch (e) {
        debugPrint('Gmail connection failed: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.failedToConnectGmailPleaseTryAgain)),
        );
      }
    } else {
      await settings.setEmailBills(false);
    }
  }

  Widget _buildHeader(SettingsProvider settings, AppLocalizations l10n) {
    final isDark = settings.isDarkMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.settings,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF111827),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.settingsManagePreferences,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? const Color(0xFF9CA3AF) : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildAppearanceSection(
    SettingsProvider settings,
    AppLocalizations l10n,
  ) {
    final isDark = settings.isDarkMode;
    return _buildCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              top: 16,
              right: 16,
              bottom: 8,
            ),
            child: _buildSectionTitle(l10n.appearance, null, isDark),
          ),
          ListTile(
            leading: Icon(
              Icons.wb_sunny_outlined,
              color:
                  isDark ? const Color(0xFF9CA3AF) : const Color(0xFF4B5563),
            ),
            title: Text(
              l10n.darkMode,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: isDark ? Colors.white : const Color(0xFF1F2937),
              ),
            ),
            subtitle: Text(
              isDark ? l10n.enabled : l10n.disabled,
              style: TextStyle(
                color:
                    isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
                fontSize: 13,
              ),
            ),
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

  Widget _buildLanguageSection(SettingsProvider settings, AppLocalizations l10n) {
    final isDark = settings.isDarkMode;
    return _buildCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              top: 16,
              right: 16,
              bottom: 8,
            ),
            child: _buildSectionTitle(l10n.language, Icons.language, isDark),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: _languages.map((lang) {
                final code = lang['code']!;
                final isSelected = settings.localeCode == code;
                return GestureDetector(
                  onTap: () => settings.setLocaleCode(code),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark
                              ? const Color(0xFF042F2E)
                              : const Color(0xFFF0FDF4))
                          : (isDark ? const Color(0xFF1F2937) : Colors.white),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF22C55E)
                            : (isDark
                                ? const Color(0xFF374151)
                                : const Color(0xFFE5E7EB)),
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
                                _localizedLanguageName(code, l10n),
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color:
                                      isDark ? Colors.white : const Color(0xFF1F2937),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                lang['script']!,
                                style: TextStyle(
                                  color: isDark
                                      ? const Color(0xFF9CA3AF)
                                      : const Color(0xFF6B7280),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: Color(0xFF22C55E),
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
        ],
      ),
    );
  }

  String _localizedLanguageName(String code, AppLocalizations l10n) {
    switch (code) {
      case 'si':
        return l10n.sinhala;
      case 'ta':
        return l10n.tamil;
      default:
        return l10n.english;
    }
  }

  Widget _buildAutoBillSection(SettingsProvider settings, AppLocalizations l10n) {
    final isDark = settings.isDarkMode;
    return _buildCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              top: 16,
              right: 16,
              bottom: 8,
            ),
            child: _buildSectionTitle(l10n.autoBillDetection, null, isDark),
          ),
          _buildSwitchTile(
            isDark: isDark,
            icon: Icons.email_outlined,
            title: l10n.emailBills,
            subtitle: l10n.autoDetectBillsFromGmail,
            value: settings.emailBills,
            onChanged: (val) => _handleEmailBillsToggle(val, settings, l10n),
          ),
          Divider(
            height: 1,
            color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
            indent: 16,
            endIndent: 16,
          ),
          _buildSwitchTile(
            isDark: isDark,
            icon: Icons.chat_bubble_outline,
            title: l10n.smsBills,
            subtitle: l10n.autoDetectBillsFromMessages,
            value: settings.smsBills,
            onChanged: (val) => settings.setSmsBills(val),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildNotificationsSection(
    SettingsProvider settings,
    AppLocalizations l10n,
  ) {
    final isDark = settings.isDarkMode;
    return _buildCard(
      isDark: isDark,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              top: 16,
              right: 16,
              bottom: 8,
            ),
            child: _buildSectionTitle(l10n.notifications, Icons.notifications_none, isDark),
          ),
          _buildSwitchTile(
            isDark: isDark,
            title: l10n.reminder,
            subtitle: l10n.receiveReminderNotifications,
            value: settings.reminder,
            onChanged: (val) async {
              final enabled = await ReminderService.instance.setReminderEnabled(val);
              await settings.setReminder(enabled);
            },
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
        border: Border.all(
          color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
          width: 1.5,
        ),
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
      leading: icon != null
          ? Icon(
              icon,
              color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF374151),
            )
          : null,
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 15,
          color: isDark ? Colors.white : const Color(0xFF1F2937),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280),
          fontSize: 13,
        ),
        maxLines: 2,
      ),
      trailing: CupertinoSwitch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF22C55E),
      ),
    );
  }

  Widget _buildBottomNavigationBar(
    SettingsProvider settings,
    AppLocalizations l10n,
  ) {
    final isDark = settings.isDarkMode;
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1F2937).withOpacity(0.95)
            : Colors.white.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
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
                  _buildNavItem(
                    icon: Icons.account_balance_wallet_outlined,
                    label: l10n.home,
                    isActive: false,
                    isDark: isDark,
                    onTap: () => _onBottomNavTap(0),
                  ),
                  _buildNavItem(
                    icon: Icons.qr_code_scanner,
                    label: l10n.scan,
                    isActive: false,
                    isDark: isDark,
                    onTap: () => _onBottomNavTap(1),
                  ),
                  _buildCenterAddButton(),
                  _buildNavItem(
                    icon: Icons.calendar_month_outlined,
                    label: l10n.event,
                    isActive: false,
                    isDark: isDark,
                    onTap: () => _onBottomNavTap(2),
                  ),
                  _buildNavItem(
                    icon: Icons.smart_toy_outlined,
                    label: l10n.ai,
                    isActive: false,
                    isDark: isDark,
                    onTap: () => _onBottomNavTap(3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _onBottomNavTap(int index) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => MainScreen(initialIndex: index)),
      (route) => false,
    );
  }

  Widget _buildCenterAddButton() {
    return GestureDetector(
      key: const Key('settings-nav-add'),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
        );
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: const Color(0xFF059669),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF059669).withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isActive
                ? const Color(0xFF22C55E)
                : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)),
            size: 22,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              color: isActive
                  ? const Color(0xFF22C55E)
                  : (isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280)),
            ),
          ),
        ],
      ),
    );
  }
}

