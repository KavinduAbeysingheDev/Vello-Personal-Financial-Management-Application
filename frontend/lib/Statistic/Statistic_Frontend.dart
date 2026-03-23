import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'Statistic_backend.dart';
import '../widgets/vello_top_bar.dart';
import '../services/app_provider.dart';
import 'package:provider/provider.dart';
import '../screens/setting_screen_backend.dart';

class StatisticScreen extends StatefulWidget {
  const StatisticScreen({super.key});

  @override
  State<StatisticScreen> createState() => _StatisticScreenState();
}

class _StatisticScreenState extends State<StatisticScreen>
    with SingleTickerProviderStateMixin {
  final StatisticService _service =
      StatisticService(); // This is a singleton now
  final Color _gradLeft = const Color(0xFF0D9488);
  final Color _gradRight = const Color(0xFF10B981);

  String _selectedPeriod = "Monthly";
  int _touchedPieIndex = -1;

  @override
  void initState() {
    super.initState();
    // LISTEN TO BACKEND UPDATES (from Home Page etc.)
    _service.addListener(_onDataUpdated);
  }

  @override
  void dispose() {
    _service.removeListener(_onDataUpdated);
    super.dispose();
  }

  void _onDataUpdated() {
    if (mounted) setState(() {}); // Refresh UI when background data changes
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context);
    final settings = Provider.of<SettingsProvider>(context);
    final isDark = settings.isDarkMode;

    // These now fetch from the SHARED SINGLETON using real data
    final slices = _service.getSlices(provider.transactions, _selectedPeriod);
    final bars = _service.getBars(provider.transactions, provider.budgets, _selectedPeriod);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPeriodToggle(settings),
                const SizedBox(height: 35),
                _buildSectionTitle(settings.t("Spending by Category"), isDark),
                const SizedBox(height: 15),
                _buildPieCard(slices, settings),
                const SizedBox(height: 40),
                _buildSectionTitle(settings.t("Budget vs Actual Spending"), isDark),
                const SizedBox(height: 15),
                _buildBarCard(bars, settings),
                const SizedBox(
                  height: 140,
                ), // Extra space for floating bottom bar
              ],
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildPeriodToggle(SettingsProvider settings) {
    final isDark = settings.isDarkMode;
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [_buildToggleButton("Weekly", settings), _buildToggleButton("Monthly", settings)],
      ),
    );
  }

  Widget _buildToggleButton(String key, SettingsProvider settings) {
    bool isSelected = _selectedPeriod == key;
    final isDark = settings.isDarkMode;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? _gradLeft : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              settings.t(key),
              style: TextStyle(
                color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.grey[600]),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1F2937),
          ),
        ),
        const Icon(Icons.auto_awesome, color: Color(0xFF10B981), size: 18),
      ],
    );
  }

  Widget _buildPieCard(List<StatisticSlice> slices, SettingsProvider settings) {
    final isDark = settings.isDarkMode;
    double total = slices.fold(
      0,
      (sum, item) => sum + item.amount,
    ); // Real amount from backend now

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.03),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 240,
                child: PieChart(
                  PieChartData(
                    startDegreeOffset: -90,
                    sectionsSpace: 4,
                    centerSpaceRadius: 65,
                    pieTouchData: PieTouchData(
                      touchCallback: (event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            _touchedPieIndex = -1;
                            return;
                          }
                          _touchedPieIndex = pieTouchResponse
                              .touchedSection!
                              .touchedSectionIndex;
                        });
                      },
                    ),
                    sections: slices.asMap().entries.map((entry) {
                      int i = entry.key;
                      final isTouched = i == _touchedPieIndex;
                      return PieChartSectionData(
                        color: entry.value.color,
                        value: entry.value.percentage,
                        title: '',
                        showTitle: false,
                        radius: isTouched ? 35 : 30,
                      );
                    }).toList(),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    settings.t("Total Spent"),
                    style: TextStyle(
                      color: isDark ? Colors.white70 : Colors.grey[400],
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "\$${total.toInt()}",
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1F2937),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 35),
          Column(
            children: slices.asMap().entries.map((entry) {
              final slice = entry.value;
              final isLast = entry.key == slices.length - 1;
              return Container(
                margin: EdgeInsets.only(bottom: isLast ? 0 : 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF111827) : const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: slice.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Text(
                        settings.t(slice.name),
                        style: TextStyle(
                          color: isDark ? Colors.white : const Color(0xFF1F2937),
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      "${slice.percentage.toInt()}%",
                      style: TextStyle(
                        color: isDark ? Colors.white70 : Colors.grey[500],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      "\$${slice.amount.toInt()}",
                      style: TextStyle(
                        color: isDark ? Colors.white : const Color(0xFF1F2937),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBarCard(List<StatisticBar> bars, SettingsProvider settings) {
    final isDark = settings.isDarkMode;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 40, 10, 30),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F2937) : Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 450,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceEvenly,
                maxY: 2500, // Matching monthly budget
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (_) => isDark ? const Color(0xFF374151) : Colors.white,
                    tooltipPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    tooltipMargin: 12,
                    tooltipRoundedRadius: 15,
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      final val = rod.toY.toInt();
                      final isSpent = rodIndex == 1;
                      return BarTooltipItem(
                        "${isSpent ? settings.t('Spent') : settings.t('Budget')}\n\$${val}",
                        TextStyle(
                          color: isSpent ? _gradLeft : (isDark ? Colors.white70 : Colors.grey[600]),
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      );
                    },
                  ),
                ),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, m) {
                        int i = v.toInt();
                        if (i >= 0 && i < bars.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 18),
                            child: Text(
                              settings.t(bars[i].label),
                              style: TextStyle(
                                color: isDark ? Colors.white70 : const Color(0xFF1F2937),
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                        return const SizedBox();
                      },
                      reservedSize: 60,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 45,
                      interval: 500,
                      getTitlesWidget: (v, m) => Text(
                        v.toInt().toString(),
                        style: TextStyle(
                          color: isDark ? Colors.grey[500] : Colors.grey[600],
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) => FlLine(
                    color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.04),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                barGroups: bars.asMap().entries.map((entry) {
                  int idx = entry.key;
                  var bar = entry.value;
                  return BarChartGroupData(
                    x: idx,
                    barsSpace: 12,
                    barRods: [
                      BarChartRodData(
                        toY: bar.budget,
                        color: _gradLeft.withOpacity(0.12),
                        width: 48,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      BarChartRodData(
                        toY: bar.spent,
                        gradient: LinearGradient(
                          colors: [_gradLeft, _gradRight],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                        width: 48,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 35),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendItem(_gradLeft.withOpacity(0.12), settings.t("Budget"), isDark),
              const SizedBox(width: 45),
              _legendItem(_gradLeft, settings.t("Actual Spent"), isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label, bool isDark) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1F2937),
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
