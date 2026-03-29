import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../all transactions/alltransactions_frontend.dart';
import '../screens/drawer_screens/savings_goals_screen.dart';
import '../screens/drawer_screens/statistics_screen.dart';
import '../screens/setting_screen_backend.dart';

class VelloDrawer extends StatelessWidget {
  const VelloDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = settings.isDarkMode;
    final bg = isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB);
    final tileBg = isDark ? const Color(0xFF1F2937) : const Color(0xFFEAF9F3);
    final tileBorder =
        isDark ? const Color(0xFF374151) : const Color(0xFF0AA36C).withOpacity(0.3);
    final titleColor = isDark ? Colors.white : const Color(0xFF1F2937);
    final subtitleColor = isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    return Drawer(
      backgroundColor: bg,
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: const BoxDecoration(color: Color(0xFF004D40)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6.0),
                      child: Image.asset(
                        'assets/images/vello_logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Vello Menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _menuItem(
              context,
              icon: Icons.list_alt,
              title: settings.t('All Transactions'),
              subtitle: 'Transaction history',
              destination: const AllTransactionsScreen(),
              tileBg: tileBg,
              tileBorder: tileBorder,
              titleColor: titleColor,
              subtitleColor: subtitleColor,
            ),
            _menuItem(
              context,
              icon: Icons.flag_outlined,
              title: settings.t('Savings Goals'),
              subtitle: 'Track your goals',
              destination: const SavingsGoalsScreen(),
              tileBg: tileBg,
              tileBorder: tileBorder,
              titleColor: titleColor,
              subtitleColor: subtitleColor,
            ),
            _menuItem(
              context,
              icon: Icons.bar_chart_outlined,
              title: settings.t('Statistics'),
              subtitle: 'See spending trends',
              destination: const StatisticsScreen(),
              tileBg: tileBg,
              tileBorder: tileBorder,
              titleColor: titleColor,
              subtitleColor: subtitleColor,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget destination,
    required Color tileBg,
    required Color tileBorder,
    required Color titleColor,
    required Color subtitleColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: tileBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: tileBorder),
        ),
        child: Icon(icon, color: const Color(0xFF0AA36C), size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: titleColor,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: subtitleColor),
      ),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(context, MaterialPageRoute(builder: (_) => destination));
      },
    );
  }
}
