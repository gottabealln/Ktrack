import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/entry.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/floating_blobs.dart';
import '../widgets/gradient_card.dart';

class GraphsScreen extends StatefulWidget {
  final StorageService storage;
  const GraphsScreen({super.key, required this.storage});

  @override
  State<GraphsScreen> createState() => _GraphsScreenState();
}

class _GraphsScreenState extends State<GraphsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  List<Entry> _entries = [];
  String _viewMode = 'week';

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();
    _load();
  }

  Future<void> _load() async {
    final e = await widget.storage.getEntries();
    setState(() => _entries = e);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<Entry> get _filtered {
    final now = DateTime.now();
    if (_viewMode == 'week') {
      final weekAgo = now.subtract(const Duration(days: 7));
      return _entries.where((e) => e.date.isAfter(weekAgo)).toList();
    } else {
      final monthAgo = now.subtract(const Duration(days: 30));
      return _entries.where((e) => e.date.isAfter(monthAgo)).toList();
    }
  }

  Map<String, int> _symptomCounts() {
    final map = <String, int>{};
    for (final e in _filtered) {
      for (final s in e.symptoms) {
        map[s] = (map[s] ?? 0) + 1;
      }
    }
    return map;
  }

  List<FlSpot> _severitySpots() {
    final now = DateTime.now();
    final days = _viewMode == 'week' ? 7 : 30;
    final spots = <FlSpot>[];
    for (int i = days - 1; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: i));
      final dayEntries = _filtered
          .where((e) =>
      e.date.year == day.year &&
          e.date.month == day.month &&
          e.date.day == day.day)
          .toList();
      final avg = dayEntries.isEmpty
          ? 0.0
          : dayEntries.map((e) => e.severity).reduce((a, b) => a + b) /
          dayEntries.length;
      spots.add(FlSpot((days - 1 - i).toDouble(), avg));
    }
    return spots;
  }

  List<FlSpot> _frequencySpots() {
    final now = DateTime.now();
    final days = _viewMode == 'week' ? 7 : 30;
    final spots = <FlSpot>[];
    for (int i = days - 1; i >= 0; i--) {
      final day = DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: i));
      final count = _filtered
          .where((e) =>
      e.date.year == day.year &&
          e.date.month == day.month &&
          e.date.day == day.day)
          .length;
      spots.add(FlSpot((days - 1 - i).toDouble(), count.toDouble()));
    }
    return spots;
  }

  String _trend() {
    final spots = _severitySpots();
    if (spots.length < 4) return 'NOT ENOUGH DATA';
    final half = spots.length ~/ 2;
    final firstAvg =
    spots.take(half).where((s) => s.y > 0).map((s) => s.y).toList();
    final secondAvg =
    spots.skip(half).where((s) => s.y > 0).map((s) => s.y).toList();
    if (firstAvg.isEmpty || secondAvg.isEmpty) return 'NOT ENOUGH DATA';
    final f = firstAvg.reduce((a, b) => a + b) / firstAvg.length;
    final s = secondAvg.reduce((a, b) => a + b) / secondAvg.length;
    if (s < f - 0.3) return 'IMPROVING';
    if (s > f + 0.3) return 'NEEDS ATTENTION';
    return 'STABLE';
  }

  Gradient _trendGradient(String t) {
    switch (t) {
      case 'IMPROVING':
        return AppGradients.calm;
      case 'NEEDS ATTENTION':
        return AppGradients.danger;
      case 'STABLE':
        return AppGradients.warm;
      default:
        return AppGradients.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final counts = _symptomCounts();
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final trend = _trend();
    final totalEntries = _filtered.length;

    return FloatingBlobs(
      child: FadeTransition(
        opacity: _fade,
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                ShaderMask(
                  shaderCallback: (rect) => const LinearGradient(
                    colors: [
                      AppColors.g2,
                      AppColors.g5,
                      AppColors.g3,
                    ],
                  ).createShader(rect),
                  child: Text(
                    'Insights',
                    textAlign: TextAlign.center,
                    style: AppText.h1.copyWith(
                      color: Colors.white,
                      fontSize: 30,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'patterns over time',
                  textAlign: TextAlign.center,
                  style: AppText.small,
                ),
                const SizedBox(height: 22),

                // Week / Month toggle
                Row(
                  children: [
                    Expanded(child: _toggle('week', 'This Week')),
                    const SizedBox(width: 10),
                    Expanded(child: _toggle('month', 'This Month')),
                  ],
                ),

                const SizedBox(height: 20),

                // Trend card
                GradientCard(
                  gradient: _trendGradient(trend),
                  child: Column(
                    children: [
                      const Text(
                        'OVERALL TREND',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.6,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        trend,
                        textAlign: TextAlign.center,
                        style: AppText.h2.copyWith(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Total entries: $totalEntries',
                        style: AppText.small
                            .copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Severity line chart
                GradientCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Severity Trend', style: AppText.h3),
                      const SizedBox(height: 4),
                      Text('average per day (1-5)',
                          style: AppText.small),
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 180,
                        child: _severitySpots().every((s) => s.y == 0)
                            ? Center(
                          child: Text('No data yet',
                              style: AppText.small),
                        )
                            : LineChart(
                          LineChartData(
                            minY: 0,
                            maxY: 5,
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              horizontalInterval: 1,
                              getDrawingHorizontalLine: (_) =>
                                  FlLine(
                                    color: Colors.white
                                        .withOpacity(0.06),
                                    strokeWidth: 1,
                                  ),
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 1,
                                  reservedSize: 26,
                                  getTitlesWidget: (v, _) => Text(
                                    v.toInt().toString(),
                                    style: AppText.small
                                        .copyWith(fontSize: 10),
                                  ),
                                ),
                              ),
                              bottomTitles: const AxisTitles(
                                sideTitles: SideTitles(
                                    showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles: SideTitles(
                                    showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles: SideTitles(
                                    showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(
                                color:
                                Colors.white.withOpacity(0.1),
                              ),
                            ),
                            lineBarsData: [
                              LineChartBarData(
                                spots: _severitySpots(),
                                isCurved: true,
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.g5,
                                    AppColors.g2,
                                    AppColors.g3,
                                  ],
                                ),
                                barWidth: 4,
                                isStrokeCapRound: true,
                                dotData: FlDotData(
                                  show: true,
                                  getDotPainter:
                                      (s, p, b, i) =>
                                      FlDotCirclePainter(
                                        radius: 4,
                                        color: Colors.white,
                                        strokeWidth: 2,
                                        strokeColor:
                                        AppColors.g3,
                                      ),
                                ),
                                belowBarData: BarAreaData(
                                  show: true,
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      AppColors.g3
                                          .withOpacity(0.35),
                                      AppColors.g3
                                          .withOpacity(0.0),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Frequency bar chart
                GradientCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Panic Frequency', style: AppText.h3),
                      const SizedBox(height: 4),
                      Text('entries per day', style: AppText.small),
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 180,
                        child: BarChart(
                          BarChartData(
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              getDrawingHorizontalLine: (_) => FlLine(
                                color: Colors.white.withOpacity(0.06),
                                strokeWidth: 1,
                              ),
                            ),
                            titlesData: FlTitlesData(
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 26,
                                  getTitlesWidget: (v, _) => Text(
                                    v.toInt().toString(),
                                    style: AppText.small
                                        .copyWith(fontSize: 10),
                                  ),
                                ),
                              ),
                              bottomTitles: const AxisTitles(
                                sideTitles:
                                SideTitles(showTitles: false),
                              ),
                              topTitles: const AxisTitles(
                                sideTitles:
                                SideTitles(showTitles: false),
                              ),
                              rightTitles: const AxisTitles(
                                sideTitles:
                                SideTitles(showTitles: false),
                              ),
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                              ),
                            ),
                            barGroups: _frequencySpots()
                                .map((s) => BarChartGroupData(
                              x: s.x.toInt(),
                              barRods: [
                                BarChartRodData(
                                  toY: s.y,
                                  gradient: const LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      AppColors.g3,
                                      AppColors.g4,
                                    ],
                                  ),
                                  width: _viewMode == 'week'
                                      ? 18
                                      : 6,
                                  borderRadius:
                                  const BorderRadius.vertical(
                                    top: Radius.circular(6),
                                  ),
                                ),
                              ],
                            ))
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Symptom breakdown
                GradientCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Symptom Breakdown',
                          style: AppText.h3),
                      const SizedBox(height: 16),
                      if (sorted.isEmpty)
                        Text('No symptoms recorded yet',
                            style: AppText.small)
                      else
                        ...sorted.map((e) {
                          final max = sorted.first.value;
                          final ratio = e.value / max;
                          return Padding(
                            padding:
                            const EdgeInsets.only(bottom: 14),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(e.key,
                                          style: AppText.body),
                                    ),
                                    Text('${e.value}x',
                                        style:
                                        AppText.small.copyWith(
                                          color: AppColors.g3,
                                          fontWeight: FontWeight.w700,
                                        )),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                LayoutBuilder(
                                  builder: (ctx, c) => Stack(
                                    children: [
                                      Container(
                                        height: 10,
                                        width: c.maxWidth,
                                        decoration: BoxDecoration(
                                          color: Colors.white
                                              .withOpacity(0.06),
                                          borderRadius:
                                          BorderRadius.circular(6),
                                        ),
                                      ),
                                      TweenAnimationBuilder<double>(
                                        tween: Tween(
                                            begin: 0, end: ratio),
                                        duration: const Duration(
                                            milliseconds: 900),
                                        curve: Curves.easeOutCubic,
                                        builder: (_, v, __) => Container(
                                          height: 10,
                                          width: c.maxWidth * v,
                                          decoration: BoxDecoration(
                                            gradient:
                                            AppGradients.warm,
                                            borderRadius:
                                            BorderRadius.circular(
                                                6),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.g3
                                                    .withOpacity(0.5),
                                                blurRadius: 12,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _toggle(String mode, String label) {
    final active = _viewMode == mode;
    return GestureDetector(
      onTap: () => setState(() => _viewMode = mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: active ? AppGradients.warm : null,
          color: active ? null : Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: active
                ? Colors.transparent
                : Colors.white.withOpacity(0.1),
          ),
          boxShadow: active
              ? [
            BoxShadow(
              color: AppColors.g3.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: AppText.button.copyWith(
              color: active ? Colors.white : AppColors.textDim,
            ),
          ),
        ),
      ),
    );
  }
}