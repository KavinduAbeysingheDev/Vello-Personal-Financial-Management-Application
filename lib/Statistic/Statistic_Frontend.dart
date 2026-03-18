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
  final Color _gradLeft = const Color(0xFF0D9488);
  final Color _gradRight = const Color(0xFF10B981);
  final Color _pageBg = const Color(0xFFF9FAFB);
  final Color _darkText = const Color(0xFF111827);
  final Color _greyText = const Color(0xFF6B7280);
  
  String _selectedPeriod = "Monthly";
  int _touchedPieIndex = -1;

  @override
  Widget build(BuildContext context) {
    final slices = _service.getSlices(_selectedPeriod);
    final bars = _service.getBars(_selectedPeriod);

    return Scaffold(
      backgroundColor: _pageBg,
      body: CustomScrollView(
        slivers: [
          _buildSliverHeader(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPeriodToggle(),
                  const SizedBox(height: 30),
                  _buildSectionTitle("Spending by Category"),
                  const SizedBox(height: 20),
                  _buildPieCard(slices),
                  const SizedBox(height: 30),
                  _buildSectionTitle("Budget vs Actual Spending"),
                  const SizedBox(height: 20),
                  _buildBarCard(bars),
                  const SizedBox(height: 80),
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
      expandedHeight: 100,
      pinned: true,
      backgroundColor: _gradLeft,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        title: const Text(
          "Statistics",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [_gradLeft, _gradRight],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      actions: [
        IconButton(onPressed: () {}, icon: const Icon(Icons.menu, color: Colors.white)),
        const SizedBox(width: 8),
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
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.black.withOpacity(0.05)),
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
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? _gradLeft : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : _greyText,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1F2937)),
        ),
        const SizedBox(width: 8),
        const Icon(Icons.auto_awesome, color: Color(0xFF10B981), size: 14),
      ],
    );
  }

  Widget _buildPieCard(List<StatisticSlice> slices) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: SizedBox(
        height: 280,
        child: _PieWithOutsideLabels(
          slices: slices,
          touchedIndex: _touchedPieIndex,
          onTouch: (i) => setState(() => _touchedPieIndex = i),
        ),
      ),
    );
  }

  Widget _buildBarCard(List<StatisticBar> bars) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 220,
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
                      getTitlesWidget: (v, m) {
                        int i = v.toInt();
                        if (i >= 0 && i < bars.length) {
                          return Padding(padding: const EdgeInsets.only(top: 10), child: Text(bars[i].label, style: TextStyle(color: _greyText, fontSize: 10)));
                        }
                        return const SizedBox();
                      },
                      reservedSize: 32,
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 200,
                      getTitlesWidget: (v, m) => Text(v.toInt().toString(), style: TextStyle(color: _greyText, fontSize: 10)),
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (v) => FlLine(color: Colors.black.withOpacity(0.03), strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: bars.asMap().entries.map((entry) {
                  int idx = entry.key;
                  var bar = entry.value;
                  return BarChartGroupData(
                    x: idx,
                    barsSpace: 4,
                    barRods: [
                      BarChartRodData(
                        toY: bar.budget,
                        color: _gradLeft.withOpacity(0.15),
                        width: 14,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                      BarChartRodData(
                        toY: bar.spent,
                        color: _gradLeft,
                        width: 14,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendItem(_gradLeft.withOpacity(0.15), "Budget"),
              const SizedBox(width: 25),
              _legendItem(_gradLeft, "Spent"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(color: _greyText, fontSize: 12)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CUSTOM PIE CHART WITH L-SHAPED OUTSIDE LABELS (Exactly as in Figma)
// ─────────────────────────────────────────────────────────────────────────────

class _PieWithOutsideLabels extends StatelessWidget {
  final List<StatisticSlice> slices;
  final int touchedIndex;
  final ValueChanged<int> onTouch;

  const _PieWithOutsideLabels({required this.slices, required this.touchedIndex, required this.onTouch});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final size = min(constraints.maxWidth, constraints.maxHeight);
        return CustomPaint(
          painter: _LabelPainter(slices: slices, touchedIndex: touchedIndex),
          child: Center(
            child: GestureDetector(
              onTapUp: (details) {
                final cx = size / 2;
                final cy = size / 2;
                final tap = details.localPosition;
                double angle = atan2(tap.dy - cy, tap.dx - cx);
                double deg = angle * 180 / pi + 90;
                if (deg < 0) deg += 360;
                double cumulative = 0;
                for (int i = 0; i < slices.length; i++) {
                  cumulative += slices[i].percentage / 100 * 360;
                  if (deg <= cumulative) {
                    onTouch(i);
                    return;
                  }
                }
              },
              child: SizedBox(
                width: size * 0.55,
                height: size * 0.55,
                child: PieChart(
                  PieChartData(
                    startDegreeOffset: -90,
                    sectionsSpace: 2,
                    centerSpaceRadius: 0,
                    pieTouchData: PieTouchData(enabled: false),
                    sections: slices.asMap().entries.map((entry) {
                      int i = entry.key;
                      final isTouched = i == touchedIndex;
                      return PieChartSectionData(
                        color: entry.value.color,
                        value: entry.value.percentage,
                        title: '',
                        showTitle: false,
                        radius: isTouched ? 85 : 80,
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LabelPainter extends CustomPainter {
  final List<StatisticSlice> slices;
  final int touchedIndex;

  const _LabelPainter({required this.slices, required this.touchedIndex});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final double pieRadius = size.width * 0.55 / 2 * (80 / 100);

    double startAngle = -pi / 2;

    for (int i = 0; i < slices.length; i++) {
      final slice = slices[i];
      final sweep = slice.percentage / 100 * 2 * pi;
      final mid = startAngle + sweep / 2;

      final p1x = cx + (pieRadius + 8) * cos(mid);
      final p1y = cy + (pieRadius + 8) * sin(mid);

      final p2x = cx + (pieRadius + 32) * cos(mid);
      final p2y = cy + (pieRadius + 32) * sin(mid);

      final isRight = cos(mid) >= 0;
      final p3x = p2x + (isRight ? 25 : -25);
      final p3y = p2y;

      final paint = Paint()
        ..color = slice.color
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;

      canvas.drawPath(Path()..moveTo(p1x, p1y)..lineTo(p2x, p2y)..lineTo(p3x, p3y), paint);

      final label = '${slice.name} ${slice.percentage.toInt()}%';
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: slice.color),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final tx = isRight ? p3x + 5 : p3x - tp.width - 5;
      final ty = p3y - tp.height / 2;
      tp.paint(canvas, Offset(tx, ty));

      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(_LabelPainter old) => old.touchedIndex != touchedIndex || old.slices != slices;
}
