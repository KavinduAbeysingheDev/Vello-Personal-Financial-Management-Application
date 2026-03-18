import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'Statistic_backend.dart';

class StatisticScreen extends StatefulWidget {
  const StatisticScreen({super.key});

  @override
  State<StatisticScreen> createState() => _StatisticScreenState();
}

class _StatisticScreenState extends State<StatisticScreen> with SingleTickerProviderStateMixin {
  final StatisticService _service = StatisticService();
  final Color _tealPrimary = const Color(0xFF0D9488);
  final Color _emeraldPrimary = const Color(0xFF10B981);
  final Color _bgGray = const Color(0xFFF9FAFB);
  
  String _selectedPeriod = "Monthly";
  int _touchedPieIndex = -1;

  @override
  Widget build(BuildContext context) {
    final slices = _service.getSlices(_selectedPeriod);
    final bars = _service.getBars(_selectedPeriod);

    return Scaffold(
      backgroundColor: _bgGray,
      body: CustomScrollView(
        slivers: [
          _buildSliverHeader(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPeriodToggle(),
                  const SizedBox(height: 25),
                  _buildSectionTitle("Spending by Category"),
                  const SizedBox(height: 20),
                  _buildPieChartCard(slices),
                  const SizedBox(height: 25),
                  _buildSectionTitle("Budget vs Actual Spending"),
                  const SizedBox(height: 20),
                  _buildBarChartCard(bars),
                  const SizedBox(height: 100), // Space for bottom nav
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverHeader() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: _tealPrimary,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        title: const Text(
          "Statistics",
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_tealPrimary, _emeraldPrimary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert, color: Colors.white)),
      ],
    );
  }

  Widget _buildPeriodToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          _buildToggleButton("Weekly"),
          _buildToggleButton("Monthly"),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String title) {
    bool isSelected = _selectedPeriod == title;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = title),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? _tealPrimary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)),
        ),
        const Icon(Icons.auto_awesome, color: Color(0xFF10B981), size: 18),
      ],
    );
  }

  Widget _buildPieChartCard(List<StatisticSlice> slices) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    setState(() {
                      if (!event.isInterestedForInteractions ||
                          pieTouchResponse == null ||
                          pieTouchResponse.touchedSection == null) {
                        _touchedPieIndex = -1;
                        return;
                      }
                      _touchedPieIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                    });
                  },
                ),
                borderData: FlBorderData(show: false),
                sectionsSpace: 4,
                centerSpaceRadius: 60,
                sections: slices.asMap().entries.map((entry) {
                  int idx = entry.key;
                  var slice = entry.value;
                  final isTouched = idx == _touchedPieIndex;
                  final fontSize = isTouched ? 16.0 : 12.0;
                  final radius = isTouched ? 90.0 : 80.0;
                  final widgetSize = isTouched ? 65.0 : 55.0;

                  return PieChartSectionData(
                    color: slice.color,
                    value: slice.percentage,
                    title: '${slice.percentage.toInt()}%',
                    radius: radius,
                    titleStyle: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 30),
          _buildLegend(slices),
        ],
      ),
    );
  }

  Widget _buildLegend(List<StatisticSlice> slices) {
    return Wrap(
      spacing: 15,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: slices.map((slice) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: slice.color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              slice.name,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildBarChartCard(List<StatisticBar> bars) {
    return Container(
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 15, offset: const Offset(0, 5)),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 250,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 600,
                barTouchData: BarTouchData(enabled: true),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < bars.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(bars[index].label, style: const TextStyle(color: Colors.grey, fontSize: 10)),
                          );
                        }
                        return const SizedBox();
                      },
                      reservedSize: 32,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        if (value % 200 == 0) {
                          return Text(value.toInt().toString(), style: const TextStyle(color: Colors.grey, fontSize: 10));
                        }
                        return const SizedBox();
                      },
                      reservedSize: 28,
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.1), strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: bars.asMap().entries.map((entry) {
                  int idx = entry.key;
                  var bar = entry.value;
                  return BarChartGroupData(
                    x: idx,
                    barRods: [
                      BarChartRodData(
                        toY: bar.budget,
                        color: _tealPrimary.withOpacity(0.2),
                        width: 15,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      BarChartRodData(
                        toY: bar.spent,
                        color: _tealPrimary,
                        width: 15,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                    barsSpace: 4,
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(_tealPrimary.withOpacity(0.2), "Budget"),
              const SizedBox(width: 20),
              _buildLegendItem(_tealPrimary, "Spent"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3)),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}
