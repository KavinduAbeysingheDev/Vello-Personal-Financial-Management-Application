import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────
// SavingsGoal Model
// ─────────────────────────────────────────────────────────────
class SavingsGoal {
  final String id;
  final String title;
  final String priority;
  final double saved;
  final double target;
  final String icon; // Emoji string
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

  // Convert SavingsGoal to JSON Map for saving
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'priority': priority,
    'saved': saved,
    'target': target,
    'icon': icon,
    'iconColor': iconColor.value,
    'priorityColor': priorityColor.value,
    'priorityTextColor': priorityTextColor.value,
    'subtitle': subtitle,
    'progressColor': progressColor.value,
    'isOverdue': isOverdue,
  };

  // Create SavingsGoal from JSON Map for loading
  factory SavingsGoal.fromJson(Map<String, dynamic> json) => SavingsGoal(
    id: json['id'],
    title: json['title'],
    priority: json['priority'],
    saved: (json['saved'] as num).toDouble(),
    target: (json['target'] as num).toDouble(),
    icon: json['icon'],
    iconColor: Color(json['iconColor']),
    priorityColor: Color(json['priorityColor']),
    priorityTextColor: Color(json['priorityTextColor']),
    subtitle: json['subtitle'] ?? '',
    progressColor: Color(json['progressColor']),
    isOverdue: json['isOverdue'] ?? false,
  );
}

// ─────────────────────────────────────────────────────────────
// SavingsGoalService — Singleton + ChangeNotifier + Persistent
// ─────────────────────────────────────────────────────────────
class SavingsGoalService extends ChangeNotifier {
  static final SavingsGoalService _instance = SavingsGoalService._internal();
  factory SavingsGoalService() => _instance;
  SavingsGoalService._internal();

  static const String _storageKey = 'savings_goals';

  final List<SavingsGoal> _goals = [];
  bool _isLoaded = false;

  // ── Default goals (shown first time app opens) ──────────────
  static final List<SavingsGoal> _defaultGoals = [
    SavingsGoal(
      id: 'default_1',
      icon: '🛡️',
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
      id: 'default_2',
      icon: '✈️',
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
      id: 'default_3',
      icon: '💻',
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

  // ── Getters ─────────────────────────────────────────────────
  List<SavingsGoal> get goals => List.unmodifiable(_goals);
  double get totalSaved => _goals.fold(0.0, (sum, g) => sum + g.saved);
  double get totalTarget => _goals.fold(0.0, (sum, g) => sum + g.target);
  double get overallProgress => totalTarget > 0 ? totalSaved / totalTarget : 0;

  // ── Load goals from SharedPreferences ───────────────────────
  Future<void> loadGoals() async {
    if (_isLoaded) return;
    _isLoaded = true;

    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString == null) {
      // First time: load default goals
      _goals.addAll(_defaultGoals);
      await _saveGoals(); // Save defaults to storage
    } else {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      _goals.clear();
      _goals.addAll(jsonList.map((e) => SavingsGoal.fromJson(e)).toList());
    }

    notifyListeners();
  }

  // ── Save all goals to SharedPreferences ─────────────────────
  Future<void> _saveGoals() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(_goals.map((g) => g.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  // ── Add a new goal ──────────────────────────────────────────
  Future<void> addGoal(SavingsGoal goal) async {
    _goals.insert(0, goal);
    await _saveGoals();
    notifyListeners();
  }

  // ── Add funds to an existing goal ───────────────────────────
  Future<void> addFunds(String id, double amount) async {
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
      await _saveGoals();
      notifyListeners();
    }
  }

  // ── Delete a goal ────────────────────────────────────────────
  Future<void> deleteGoal(String id) async {
    _goals.removeWhere((g) => g.id == id);
    await _saveGoals();
    notifyListeners();
  }
}
