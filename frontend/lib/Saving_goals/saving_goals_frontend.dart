// savings_goals_screen.dart
// Place this file in lib/screens/savings_goals_screen.dart (or same folder as main.dart)
// Then update the import in main.dart to match your project structure.

import 'package:flutter/material.dart';
import 'saving_goals_backend.dart';
import '../screens/setting_screen_backend.dart';
import 'package:provider/provider.dart';

class SavingsGoalsScreen extends StatefulWidget {
  const SavingsGoalsScreen({super.key});

  @override
  State<SavingsGoalsScreen> createState() => _SavingsGoalsScreenState();
}

class _SavingsGoalsScreenState extends State<SavingsGoalsScreen> {
  @override
  void initState() {
    super.initState();
    // Load saved goals from SharedPreferences when screen opens
    SavingsGoalService().loadGoals();
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final service = SavingsGoalService();
        final goals = service.goals;
        final isDark = settings.isDarkMode;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bill Detected REMOVED
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        settings.t('Savings Goals'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : const Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.auto_awesome,
                        color: Color(0xFF10B981),
                        size: 15,
                      ),
                    ],
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showNewGoalModal(context),
                    icon: const Icon(Icons.add, size: 14),
                    label: Text(
                      settings.t('New Goal'),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF047857),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Total Progress Card (Live Data)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7B1FA2), Color(0xFF9C27B0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9C27B0).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      settings.t('Total Progress'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${service.totalSaved.toInt()}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${settings.t('of')} \$${service.totalTarget.toInt()}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: service.overallProgress,
                        backgroundColor: Colors.white24,
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${(service.overallProgress * 100).toStringAsFixed(1)}% ${settings.t('Complete')}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Goal Cards from Service
              ...goals.map(
                (goal) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _buildGoalCard(context: context, goal: goal, settings: settings),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ));
      },
    );
  }

  Widget _buildGoalCard({
    required BuildContext context,
    required SavingsGoal goal,
    required SettingsProvider settings,
  }) {
    final isDark = settings.isDarkMode;
    final progress = goal.progress;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              goal.icon is IconData
                  ? Icon(goal.icon as IconData, color: goal.iconColor, size: 28)
                  : Text(
                      goal.icon.toString(),
                      style: const TextStyle(fontSize: 28),
                    ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      settings.t(goal.title),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: goal.priorityColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            settings.t(goal.priority.substring(0, 1).toUpperCase() + goal.priority.substring(1)),
                            style: TextStyle(
                              color: goal.priorityTextColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (goal.subtitle.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF374151) : const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              settings.t(goal.subtitle),
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? Colors.white70 : const Color(0xFF4B5563),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                settings.t('Saved'),
                style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF6B7280), fontSize: 13),
              ),
              Text(
                '\$${goal.saved.toInt()}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
              valueColor: AlwaysStoppedAnimation(goal.progressColor),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                settings.t('Target'),
                style: TextStyle(color: isDark ? Colors.white70 : const Color(0xFF6B7280), fontSize: 13),
              ),
              Text(
                '\$${goal.target.toInt()}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: isDark ? Colors.white : const Color(0xFF111827),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          InkWell(
            onTap: () => _showAddFundsModal(context, goal.id, goal.title),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? const Color(0xFF065F46) : const Color(0xFFD1FAE5)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.trending_up,
                    color: Color(0xFF059669),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${settings.t('Add to Goal')} (\$${goal.remaining.toInt()}.00 ${settings.t('remaining')})',
                    style: const TextStyle(
                      color: Color(0xFF059669),
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showNewGoalModal(BuildContext context) {
    String selectedPriority = 'Medium';
    DateTime? selectedDate;
    String selectedEmoji = '🎯';
    final nameController = TextEditingController();
    final targetController = TextEditingController();
    final startController = TextEditingController();

    final List<String> availableEmojis = [
      '🎯',
      '💰',
      '🏝️',
      '🚗',
      '🏠',
      '💻',
      '💸',
      '✈️',
      '🎓',
      '🏥',
    ];

    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final isDark = settings.isDarkMode;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            backgroundColor: isDark ? const Color(0xFF1F2937) : const Color(0xFFF1F8F6),
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 24,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 380),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            settings.t('Create New Goal'),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : const Color(0xFF111827),
                              letterSpacing: -0.5,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.close,
                              size: 20,
                              color: Color(0xFF9CA3AF),
                            ),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Goal Name
                      _modalLabel(settings.t('Goal Name'), isDark),
                      _modalTextField(
                        context: context,
                        controller: nameController,
                        hint: settings.t('e.g., Summer Trip'),
                      ),
                      const SizedBox(height: 14),

                      // Emoji Selector (Interactive)
                      _modalLabel(settings.t('Goal Icon (Emoji)'), isDark),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: availableEmojis.map((emoji) {
                            final isSelected = selectedEmoji == emoji;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => selectedEmoji = emoji),
                              child: Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(0xFF00695C)
                                      : (isDark ? const Color(0xFF111827) : Colors.white),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF00695C)
                                        : (isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
                                  ),
                                ),
                                child: Text(
                                  emoji,
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _modalLabel(settings.t('Target'), isDark),
                                _modalTextField(
                                  context: context,
                                  controller: targetController,
                                  hint: '\$0.00',
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _modalLabel(settings.t('Starting'), isDark),
                                _modalTextField(
                                  context: context,
                                  controller: startController,
                                  hint: '\$0.00',
                                  keyboardType: TextInputType.number,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Deadline (Interactive)
                      _modalLabel(settings.t('Target Date'), isDark),
                      InkWell(
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                            builder: (context, child) {
                              return Theme(
                                data: isDark ? ThemeData.dark() : ThemeData.light(),
                                child: child!,
                              );
                            },
                          );
                          if (date != null) {
                            setState(() => selectedDate = date);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF111827) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                selectedDate == null
                                    ? settings.t('Choose Date')
                                    : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                                style: TextStyle(
                                  color: selectedDate == null
                                      ? const Color(0xFF9CA3AF)
                                      : (isDark ? Colors.white : const Color(0xFF111827)),
                                  fontSize: 13,
                                ),
                              ),
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                                color: Color(0xFF9CA3AF),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Priority (Interactive Dropdown)
                      _modalLabel(settings.t('Priority Level'), isDark),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF111827) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            dropdownColor: isDark ? const Color(0xFF1F2937) : Colors.white,
                            value: selectedPriority,
                            isExpanded: true,
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              size: 20,
                              color: Color(0xFF9CA3AF),
                            ),
                            style: TextStyle(
                              color: isDark ? Colors.white : const Color(0xFF111827),
                              fontSize: 13,
                            ),
                            onChanged: (val) {
                              setState(() => selectedPriority = val!);
                            },
                            items: ['Low', 'Medium', 'High'].map((String p) {
                              return DropdownMenuItem<String>(
                                value: p,
                                child: Text(settings.t(p)),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Create Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Logic to add goal to backend
                            final newGoal = SavingsGoal(
                              id: DateTime.now().toString(),
                              title: nameController.text.isEmpty
                                  ? 'New Goal'
                                  : nameController.text,
                              target:
                                  double.tryParse(targetController.text) ?? 0,
                              saved: double.tryParse(startController.text) ?? 0,
                              icon: selectedEmoji,
                              iconColor: Colors.blue, // Default color
                              priority: selectedPriority.toLowerCase(),
                              priorityColor: selectedPriority == 'High'
                                  ? const Color(0xFFFEE2E2)
                                  : (selectedPriority == 'Medium'
                                        ? const Color(0xFFFEF3C7)
                                        : const Color(0xFFD1FAE5)),
                              priorityTextColor: selectedPriority == 'High'
                                  ? const Color(0xFFEF4444)
                                  : (selectedPriority == 'Medium'
                                        ? const Color(0xFFF59E0B)
                                        : const Color(0xFF10B981)),
                              progressColor: selectedPriority == 'High'
                                  ? const Color(0xFFEF4444)
                                  : const Color(0xFF3B82F6),
                              // subtitle will be calculated based on date, or default
                              subtitle: selectedDate != null
                                  ? '${selectedDate!.difference(DateTime.now()).inDays} ${settings.t('days left')}'
                                  : settings.t('No deadline'),
                            );
                            SavingsGoalService().addGoal(newGoal);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00695C),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            settings.t('Create Goal'),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _modalLabel(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isDark ? Colors.white70 : const Color(0xFF374151),
        ),
      ),
    );
  }

  Widget _modalTextField({
    required BuildContext context,
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final isDark = Provider.of<SettingsProvider>(context, listen: false).isDarkMode;
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: 13, color: isDark ? Colors.white : const Color(0xFF111827)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: isDark ? Colors.grey[500] : const Color(0xFF9CA3AF), fontSize: 13),
        filled: true,
        fillColor: isDark ? const Color(0xFF111827) : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00695C), width: 1.5),
        ),
      ),
    );
  }

  void _showAddFundsModal(
    BuildContext context,
    String goalId,
    String goalTitle,
  ) {
    final amountController = TextEditingController();

    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final isDark = settings.isDarkMode;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: isDark ? const Color(0xFF1F2937) : Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 340),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${settings.t('Add to')} ${settings.t(goalTitle)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : const Color(0xFF111827),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          size: 20,
                          color: Color(0xFF9CA3AF),
                        ),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    settings.t('Contribute to your savings goal.'),
                    style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : const Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    settings.t('Amount to Add'),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white70 : const Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: amountController,
                    keyboardType: TextInputType.number,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: '0.00',
                      prefixText: '\$ ',
                      prefixStyle: TextStyle(fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
                      filled: true,
                      fillColor: isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF00695C),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final amount =
                            double.tryParse(amountController.text) ?? 0;
                        if (amount > 0) {
                          SavingsGoalService().addFunds(goalId, amount);
                        }
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00695C),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Add Amount',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
