import 'package:flutter/material.dart';
import '../screens/drawer_screens/weekly_planner_screen.dart';
import '../screens/drawer_screens/statistics_screen.dart';
import '../screens/drawer_screens/savings_goals_screen.dart';
import '../screens/drawer_screens/subscription_manager_screen.dart';
import '../screens/drawer_screens/debt_tracker_screen.dart';
import '../screens/drawer_screens/voice_expense_screen.dart';
import '../screens/drawer_screens/financial_health_screen.dart';

class VelloDrawer extends StatelessWidget {
  const VelloDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF9FAFB),
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: const BoxDecoration(
                color: Color(0xFF004D40),
              ),
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
            _menuItem(context, Icons.calendar_month_outlined, 'Weekly Planner', 'AI-powered budget planning', const WeeklyPlannerScreen()),
            _menuItem(context, Icons.bar_chart_outlined, 'Statistics', 'View spending analytics', const StatisticsScreen()),
            _menuItem(context, Icons.flag_outlined, 'Savings Goals', 'Set and track savings goals', const SavingsGoalsScreen()),
            _menuItem(context, Icons.subscriptions_outlined, 'Subscription Manager', 'Manage and cancel subscriptions', const SubscriptionManagerScreen()),
            _menuItem(context, Icons.money_off_outlined, 'Debt Tracker', 'Track and manage debt', const DebtTrackerScreen()),
            _menuItem(context, Icons.mic_none_outlined, 'Voice Expense', 'Add expenses using voice', const VoiceExpenseScreen()),
            _menuItem(context, Icons.health_and_safety_outlined, 'Financial Health', 'Access your financial health', const FinancialHealthScreen()),
            const Divider(height: 32, thickness: 1, color: Color(0xFFE5E7EB)),
            _menuItem(context, Icons.settings_outlined, 'Settings', 'App preferences and notifications', null),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(BuildContext context, IconData icon, String title, String subtitle, Widget? destination) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFEAF9F3),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF0AA36C).withOpacity(0.3)),
        ),
        child: Icon(icon, color: const Color(0xFF0AA36C), size: 22),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: Color(0xFF1F2937))),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
      onTap: () {
        Navigator.pop(context);
        if (destination != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => destination));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('$title coming soon!')),
          );
        }
      },
    );
  }
}
