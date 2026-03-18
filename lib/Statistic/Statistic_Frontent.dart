// lib/Statistic/Statistic_Frontent.dart
// Statistics page – matches Vello Figma design exactly.

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'Statistic_backend.dart';

// ─────────────────────────────────────────────
// Colours (taken from Figma screenshots)
// ─────────────────────────────────────────────
const Color _gradLeft = Color(0xFF0D9488); // teal-600
const Color _gradRight = Color(0xFF10B981); // emerald-500
const Color _pageBg = Color(0xFFF0F2F5); // light-grey page bg
const Color _cardBg = Colors.white;
const Color _darkText = Color(0xFF111827); // near-black
const Color _greyText = Color(0xFF6B7280); // secondary text
const Color _purple = Color(0xFF6366F1); // FAB colour

// Bar chart bar colours (now defined in StatisticService)

// ─────────────────────────────────────────────
// Static data
// ─────────────────────────────────────────────
// Data will be fetched from StatisticService

// ─────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────
class StatisticScreen extends StatefulWidget {
  const StatisticScreen({super.key});

  @override
  State<StatisticScreen> createState() => _StatisticScreenState();
}

class _StatisticScreenState extends State<StatisticScreen>
    with SingleTickerProviderStateMixin {
  final StatisticService _service = StatisticService();
  List<StatisticSlice> _slices = [];
  List<StatisticBar> _bars = [];
  int _touched = -1; // pie slice index currently highlighted

  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _slices = _service.getSlices();
    _bars = _service.getBars();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  // ── scaffold ─────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      appBar: _appBar(),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _pageTitle(),
              const SizedBox(height: 18),
              _pieCard(),
              const SizedBox(height: 14),
              _barCard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _bottomNav(),
    );
  }

  // ── App Bar ───────────────────────────────────
  PreferredSizeWidget _appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_gradLeft, _gradRight],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      ),
      // Golden square logo icon — matches Figma exactly
      leading: Padding(
        padding: const EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0A4F44),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: Icon(Icons.bolt, color: Color(0xFFFFD700), size: 20),
          ),
        ),
      ),
      title: const Text(
        'Vello',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.menu, color: Colors.white, size: 22),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(
            Icons.settings_outlined,
            color: Colors.white,
            size: 22,
          ),
          onPressed: () {},
          padding: const EdgeInsets.only(right: 6),
        ),
      ],
    );
  }

  // ── "Statistics ✦" page title ─────────────────
  Widget _pageTitle() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Statistics',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: _darkText,
          ),
        ),
        const SizedBox(width: 6),
        const Icon(Icons.auto_awesome, color: _gradRight, size: 15),
      ],
    );
  }

  // ────────────────────────────────────────────────────────
  //  CARD 1 – Spending by Category (Pie chart)
  // ────────────────────────────────────────────────────────
  Widget _pieCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeading('Spending by Category'),
          const SizedBox(height: 16),
          // Pie chart with outside labels drawn by CustomPainter
          SizedBox(
            height: 270,
            child: _PieWithOutsideLabels(
              slices: _slices,
              touchedIndex: _touched,
              onTouch: (i) => setState(() => _touched = i),
            ),
          ),
        ],
      ),
    );
  }

  // ────────────────────────────────────────────────────────
  //  CARD 2 – Budget vs Actual Spending (Bar chart)
  // ────────────────────────────────────────────────────────
  Widget _barCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _cardHeading('Budget vs Actual Spending'),
          const SizedBox(height: 16),
          SizedBox(
            height: 230,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 600,

                // Touch tooltip
                barTouchData: BarTouchData(
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipItem: (group, gi, rod, ri) {
                      final bar = _bars[gi];
                      final isLeft = ri == 0; // left bar = Budget
                      final name = isLeft ? 'Budget' : 'Spent';
                      final val = isLeft ? bar.budget : bar.spent;
                      return BarTooltipItem(
                        '$name\n\$${val.toInt()}',
                        const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),

                // Axis labels
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= _bars.length)
                          return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            _bars[i].label,
                            style: const TextStyle(
                              fontSize: 10,
                              color: _greyText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 150,
                      reservedSize: 34,
                      getTitlesWidget: (v, _) => Text(
                        v.toInt().toString(),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF9CA3AF),
                        ),
                      ),
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),

                // Grid
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 150,
                  getDrawingHorizontalLine: (_) =>
                      const FlLine(color: Color(0xFFE5E7EB), strokeWidth: 1),
                ),

                borderData: FlBorderData(show: false),

                // Bar groups — Budget on LEFT, Spent on RIGHT (matches Figma)
                barGroups: List.generate(_bars.length, (i) {
                  final b = _bars[i];
                  return BarChartGroupData(
                    x: i,
                    barsSpace: 4,
                    barRods: [
                      // ① Budget bar (pale mint) — LEFT
                      BarChartRodData(
                        toY: b.budget,
                        color: StatisticService.colorBudget,
                        width: 16,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(5),
                        ),
                      ),
                      // ② Spent bar (dark green) — RIGHT
                      BarChartRodData(
                        toY: b.spent,
                        color: StatisticService.colorSpent,
                        width: 16,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(5),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Legend — centred below the chart (matches Figma)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendSquare(StatisticService.colorBudget, 'Budget'),
              const SizedBox(width: 20),
              _legendSquare(StatisticService.colorSpent, 'Spent'),
            ],
          ),
        ],
      ),
    );
  }

  // ── Shared helpers ────────────────────────────
  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _cardHeading(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: _darkText,
      ),
    );
  }

  Widget _legendSquare(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 11,
          height: 11,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: _greyText,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ── Bottom navigation bar ────────────────────
  Widget _bottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.07),
            blurRadius: 14,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navIcon(Icons.account_balance_wallet_outlined, 'Home'),
              _navIcon(Icons.camera_alt_outlined, 'Scan'),
              // Centre purple add button
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: _purple,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _purple.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.add, color: Colors.white, size: 28),
                ),
              ),
              _navIcon(Icons.calendar_today_outlined, 'Events'),
              _navIcon(Icons.smart_toy_outlined, 'AI'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navIcon(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 22, color: const Color(0xFF9CA3AF)),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Color(0xFF9CA3AF)),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────
//  Pie chart widget — uses fl_chart for slices,
//  CustomPainter for the outside connector lines + labels
//  (exactly as shown in Figma)
// ─────────────────────────────────────────────────────────────────
class _PieWithOutsideLabels extends StatelessWidget {
  final List<StatisticSlice> slices;
  final int touchedIndex;
  final ValueChanged<int> onTouch;

  const _PieWithOutsideLabels({
    required this.slices,
    required this.touchedIndex,
    required this.onTouch,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final size = min(constraints.maxWidth, constraints.maxHeight);
        return SizedBox(
          width: size,
          height: size,
          child: CustomPaint(
            // Draws the connector lines and text labels outside the pie
            painter: _LabelPainter(slices: slices, touchedIndex: touchedIndex),
            child: Center(
              child: GestureDetector(
                // Allow tapping slices to highlight them
                onTapUp: (details) {
                  final centre = Offset(size / 2, size / 2);
                  final tap = details.localPosition;
                  double angle = atan2(tap.dy - centre.dy, tap.dx - centre.dx);
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
                  // fl_chart PieChart occupies the inner 60% of the square
                  width: size * 0.60,
                  height: size * 0.60,
                  child: PieChart(
                    PieChartData(
                      startDegreeOffset: -90, // start at the top (12 o'clock)
                      sectionsSpace: 2,
                      centerSpaceRadius: 0,
                      pieTouchData: PieTouchData(enabled: false),
                      sections: List.generate(slices.length, (i) {
                        final touched = i == touchedIndex;
                        return PieChartSectionData(
                          color: slices[i].color,
                          value: slices[i].percentage,
                          title: '', // labels are painted outside
                          showTitle: false,
                          radius: touched ? 88 : 80,
                        );
                      }),
                    ),
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

// CustomPainter that draws the connector lines + category labels outside
class _LabelPainter extends CustomPainter {
  final List<StatisticSlice> slices;
  final int touchedIndex;

  const _LabelPainter({required this.slices, required this.touchedIndex});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Radius must match the fl_chart PieChart inner size (60% of canvas).
    // fl_chart radius parameter is relative to the widget size, so:
    //   pieWidgetSize  = size * 0.60
    //   slice radius   = 80 (px inside the pie widget)
    //   actual radius  = 80 / (size * 0.60) * (size * 0.60 / 2)
    //                  = 80 * 0.5 = centre of the widget mapped to canvas
    // Simpler: the pie sits in the centre 60%, so its radius in canvas coords:
    final double pieRadius = size.width * 0.60 / 2 * (80 / 100);
    // ^ 80 is the slice radius, 100 is the "full size unit" for fl_chart

    double startAngle = -pi / 2; // 12 o'clock

    for (int i = 0; i < slices.length; i++) {
      final slice = slices[i];
      final sweep = slice.percentage / 100 * 2 * pi;
      final mid = startAngle + sweep / 2; // midpoint angle of this slice

      // ── Line start point (just outside the pie edge)
      final p1x = cx + (pieRadius + 8) * cos(mid);
      final p1y = cy + (pieRadius + 8) * sin(mid);

      // ── Elbow point (further out diagonally)
      final p2x = cx + (pieRadius + 28) * cos(mid);
      final p2y = cy + (pieRadius + 28) * sin(mid);

      // ── Horizontal end point
      final rightSide = cos(mid) >= 0;
      final p3x = p2x + (rightSide ? 22 : -22);
      final p3y = p2y;

      // Draw the L-shaped connector line in the slice's colour
      final paint = Paint()
        ..color = (slice.color == StatisticService.colorEntertainment)
            ? const Color(0xFF10B981) // use a visible green for pale slice line
            : slice.color
        ..strokeWidth = 1.4
        ..style = PaintingStyle.stroke;

      canvas.drawPath(
        Path()
          ..moveTo(p1x, p1y)
          ..lineTo(p2x, p2y)
          ..lineTo(p3x, p3y),
        paint,
      );

      // Draw the label text: "CategoryName X%"
      final labelText = '${slice.name} ${slice.percentage.toInt()}%';
      final textColor = (slice.color == StatisticService.colorEntertainment)
          ? const Color(0xFF059669) // readable teal-green for pale slice
          : slice.color;

      final tp = TextPainter(
        text: TextSpan(
          text: labelText,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final textX = rightSide ? p3x + 4 : p3x - tp.width - 4;
      final textY = p3y - tp.height / 2;
      tp.paint(canvas, Offset(textX, textY));

      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(_LabelPainter old) =>
      old.touchedIndex != touchedIndex || old.slices != slices;
}
