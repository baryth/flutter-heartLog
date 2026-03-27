import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../l10n/strings.dart';
import '../models/measurement.dart';

enum _Period { week, month, year, all }

class MetricsScreen extends StatefulWidget {
  const MetricsScreen({super.key});

  @override
  State<MetricsScreen> createState() => _MetricsScreenState();
}

class _MetricsScreenState extends State<MetricsScreen> {
  List<Measurement> _all = [];
  _Period _period = _Period.month;

  static const _bg = Color(0xFFF4F7FF);
  static const _primary = Color(0xFF2C4A6E);
  static const _secondary = Color(0xFF7A9BB5);
  static const _systolicColor = Color(0xFFADD8F0);
  static const _diastolicColor = Color(0xFF5B8DB8);
  static const _pulseColor = Color(0xFFFF9090);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await DatabaseHelper.instance.getAllMeasurements();
    setState(() => _all = data.reversed.toList()); // ASC for chart
  }

  List<Measurement> get _filtered {
    final now = DateTime.now();
    DateTime? cutoff;
    switch (_period) {
      case _Period.week:
        cutoff = now.subtract(const Duration(days: 7));
      case _Period.month:
        cutoff = now.subtract(const Duration(days: 30));
      case _Period.year:
        cutoff = now.subtract(const Duration(days: 365));
      case _Period.all:
        cutoff = null;
    }
    if (cutoff == null) return _all;
    return _all.where((m) => _parseDate(m.datetime).isAfter(cutoff!)).toList();
  }

  DateTime _parseDate(String s) => DateTime.parse(s.replaceFirst(' ', 'T'));

  @override
  Widget build(BuildContext context) {
    final data = _filtered;
    final s = AppStrings.instance;
    final periodLabels = [s.periodWeek, s.periodMonth, s.periodYear, s.periodAll];

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 24, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: _primary,
                    iconSize: 22,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Expanded(
                    child: Text(
                      s.metricsTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _primary,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 22),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Period tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6B9DC2).withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: _Period.values.map((p) {
                    final selected = p == _period;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _period = p),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            color: selected ? _primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Text(
                            periodLabels[p.index],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: selected ? Colors.white : _secondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: data.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.bar_chart_rounded,
                            size: 48,
                            color: Color(0x597A9BB5),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            s.noData,
                            style: const TextStyle(
                              fontSize: 14,
                              color: _secondary,
                            ),
                          ),
                        ],
                      ),
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                      child: Column(
                        children: [
                          // Chart card
                          Container(
                            padding: const EdgeInsets.fromLTRB(8, 20, 16, 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6B9DC2).withValues(alpha: 0.08),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: SizedBox(
                              height: 260,
                              child: LineChart(_buildChart(data)),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Legend
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _LegendDot(color: _systolicColor, label: s.systolic),
                              const SizedBox(width: 20),
                              _LegendDot(color: _diastolicColor, label: s.diastolic),
                              const SizedBox(width: 20),
                              _LegendDot(color: _pulseColor, label: s.pulse),
                            ],
                          ),
                          const SizedBox(height: 18),

                          // Averages card
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 16,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6B9DC2).withValues(alpha: 0.08),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  s.average,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: _secondary,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    _AvgStat(
                                      label: s.systolic,
                                      value: data.map((m) => m.systolic).reduce((a, b) => a + b) / data.length,
                                      unit: 'mmHg',
                                      color: _systolicColor,
                                    ),
                                    Container(
                                      width: 1,
                                      height: 50,
                                      color: const Color(0xFFE4EDF7),
                                    ),
                                    _AvgStat(
                                      label: s.diastolic,
                                      value: data.map((m) => m.diastolic).reduce((a, b) => a + b) / data.length,
                                      unit: 'mmHg',
                                      color: _diastolicColor,
                                    ),
                                    Container(
                                      width: 1,
                                      height: 50,
                                      color: const Color(0xFFE4EDF7),
                                    ),
                                    _AvgStat(
                                      label: s.pulse,
                                      value: data.map((m) => m.pulse).reduce((a, b) => a + b) / data.length,
                                      unit: 'bpm',
                                      color: _pulseColor,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartData _buildChart(List<Measurement> data) {
    final systolicSpots = <FlSpot>[];
    final diastolicSpots = <FlSpot>[];
    final pulseSpots = <FlSpot>[];

    for (int i = 0; i < data.length; i++) {
      final x = i.toDouble();
      systolicSpots.add(FlSpot(x, data[i].systolic.toDouble()));
      diastolicSpots.add(FlSpot(x, data[i].diastolic.toDouble()));
      pulseSpots.add(FlSpot(x, data[i].pulse.toDouble()));
    }

    final allVals = data
        .expand((m) => [m.systolic, m.diastolic, m.pulse])
        .map((v) => v.toDouble())
        .toList();
    final minY = (allVals.reduce(min) - 15).clamp(0.0, double.infinity);
    final maxY = allVals.reduce(max) + 15;
    final interval = max(1.0, (data.length / 5).ceilToDouble());

    return LineChartData(
      minY: minY,
      maxY: maxY,
      clipData: const FlClipData.all(),
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 20,
        getDrawingHorizontalLine: (_) => const FlLine(
          color: Color(0xFFE4EDF7),
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 36,
            interval: 20,
            getTitlesWidget: (val, _) => Text(
              val.toInt().toString(),
              style: const TextStyle(fontSize: 10, color: Color(0xFF7A9BB5)),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 26,
            interval: interval,
            getTitlesWidget: (val, _) {
              final idx = val.round();
              if (idx < 0 || idx >= data.length) return const SizedBox.shrink();
              final d = _parseDate(data[idx].datetime);
              final label =
                  (_period == _Period.year || _period == _Period.all)
                      ? '${d.month.toString().padLeft(2, '0')}/${(d.year % 100).toString().padLeft(2, '0')}'
                      : '${d.day}/${d.month}';
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  label,
                  style: const TextStyle(fontSize: 9, color: Color(0xFF7A9BB5)),
                ),
              );
            },
          ),
        ),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        _buildLine(systolicSpots, _systolicColor, data.length),
        _buildLine(diastolicSpots, _diastolicColor, data.length),
        _buildLine(pulseSpots, _pulseColor, data.length),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => Colors.white,
          tooltipRoundedRadius: 10,
          tooltipBorder: const BorderSide(color: Color(0xFFE4EDF7)),
          getTooltipItems: (spots) {
            final colors = [_systolicColor, _diastolicColor, _pulseColor];
            return spots.asMap().entries.map((e) {
              return LineTooltipItem(
                e.value.y.toInt().toString(),
                TextStyle(
                  color: colors[e.key % colors.length],
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  LineChartBarData _buildLine(List<FlSpot> spots, Color color, int count) =>
      LineChartBarData(
        spots: spots,
        isCurved: true,
        curveSmoothness: 0.35,
        color: color,
        barWidth: 2.5,
        dotData: FlDotData(
          show: count <= 15,
          getDotPainter: (_, _, _, _) => FlDotCirclePainter(
            radius: 3,
            color: color,
            strokeWidth: 0,
          ),
        ),
        belowBarData: BarAreaData(
          show: true,
          color: color.withValues(alpha: 0.07),
        ),
      );
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF7A9BB5)),
        ),
      ],
    );
  }
}

class _AvgStat extends StatelessWidget {
  final String label;
  final double value;
  final String unit;
  final Color color;

  const _AvgStat({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: Color(0xFF7A9BB5)),
        ),
        const SizedBox(height: 6),
        Text(
          value.round().toString(),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
            height: 1,
          ),
        ),
        Text(
          unit,
          style: const TextStyle(fontSize: 10, color: Color(0xFF7A9BB5)),
        ),
      ],
    );
  }
}
