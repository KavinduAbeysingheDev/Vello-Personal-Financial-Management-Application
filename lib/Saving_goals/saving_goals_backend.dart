import 'package:flutter/material.dart';

class SavingsGoal {
  final String id;
  final String title;
  final String priority;
  final double saved;
  final double target;
  final dynamic icon; // Can be IconData or String (emoji)
  final Color iconColor;
  final Color priorityColor;
  final Color priorityTextColor;
  final String subtitle;
  final Color progressColor;
  final bool isOverdue;

  SavingsGoal({
    required this.id,
    required this.title,
    required this.priority,
    required this.saved,
    required this.target,
    required this.icon,
    this.iconColor = const Color(0xFF3B82F6),
    this.priorityColor = const Color(0xFFFEE2E2),
    this.priorityTextColor = const Color(0xFFEF4444),
    this.subtitle = '',
    this.progressColor = const Color(0xFF10B981),
    this.isOverdue = false,
  });

  double get remaining => target - saved > 0 ? target - saved : 0;
  double get progress => target > 0 ? saved / target : 0;
}

class SavingsGoalService extends ChangeNotifier {
  // Static Instance for easy access without provider
  static final SavingsGoalService _instance = SavingsGoalService._internal();
  factory SavingsGoalService() => _instance;
  SavingsGoalService._internal();

  final List<SavingsGoal> _goals = [
    SavingsGoal(
      id: '1',
      icon: Icons.shield,
      iconColor: const Color(0xFF3B82F6),
      title: 'Emergency Fund',
      priority: 'high',
      priorityColor: const Color(0xFFFEE2E2),
      priorityTextColor: const Color(0xFFEF4444),
      subtitle: '79 days left',
      saved: 6500.00,
      target: 10000.00,
      progressColor: const Color(0xFF3B82F6),
    ),
    SavingsGoal(
      id: '2',
      icon: Icons.flight,
      iconColor: const Color(0xFF6B7280),
      title: 'Vacation to Japan',
      priority: 'medium',
      priorityColor: const Color(0xFFFEF3C7),
      priorityTextColor: const Color(0xFFF59E0B),
      subtitle: 'Overdue',
      saved: 2100.00,
      target: 5000.00,
      progressColor: const Color(0xFF9CA3AF),
      isOverdue: true,
    ),
    SavingsGoal(
      id: '3',
      icon: Icons.laptop_mac,
      iconColor: const Color(0xFF3B82F6),
      title: 'New Laptop',
      priority: 'low',
      priorityColor: const Color(0xFFD1FAE5),
      priorityTextColor: const Color(0xFF10B981),
      subtitle: 'Overdue',
      saved: 1450.00,
      target: 2000.00,
      progressColor: const Color(0xFF3B82F6),
      isOverdue: true,
    ),
  ];

  List<SavingsGoal> get goals => List.unmodifiable(_goals);

  double get totalSaved => _goals.fold(0.0, (sum, goal) => sum + goal.saved);
  double get totalTarget => _goals.fold(0.0, (sum, goal) => sum + goal.target);
  double get overallProgress => totalTarget > 0 ? totalSaved / totalTarget : 0;

  void addGoal(SavingsGoal goal) {
    _goals.insert(0, goal);
    notifyListeners();
  }

  void addFunds(String id, double amount) {
    final index = _goals.indexWhere((g) => g.id == id);
    if (index != -1) {
      final goal = _goals[index];
      _goals[index] = SavingsGoal(
        id: goal.id,
        title: goal.title,
        priority: goal.priority,
        saved: goal.saved + amount,
        target: goal.target,
        icon: goal.icon,
        iconColor: goal.iconColor,
        priorityColor: goal.priorityColor,
        priorityTextColor: goal.priorityTextColor,
        subtitle: goal.subtitle,
        progressColor: goal.progressColor,
        isOverdue: goal.isOverdue,
      );
      notifyListeners();
    }
  }
}
