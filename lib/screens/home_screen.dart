import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/measurement.dart';
import '../widgets/gear_knob.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _systolic = 120;
  int _diastolic = 80;
  int _pulse = 70;
  List<Measurement> _measurements = [];
  bool _saving = false;

  static const Color _bgColor = Color(0xFFF4F7FF);
  static const Color _textPrimary = Color(0xFF2C4A6E);
  static const Color _textSecondary = Color(0xFF7A9BB5);
  static const Color _gearSystolic = Color(0xFFFFADB8);
  static const Color _gearDiastolic = Color(0xFF9BBFE8);
  static const Color _gearPulse = Color(0xFF99D6B5);
  static const Color _buttonColor = Color(0xFF6B9DC2);
  static const Color _divider = Color(0xFFE4EDF7);

  @override
  void initState() {
    super.initState();
    _loadMeasurements();
  }

  Future<void> _loadMeasurements() async {
    final data = await DatabaseHelper.instance.getAllMeasurements();
    setState(() => _measurements = data);
  }

  Future<void> _addMeasurement() async {
    setState(() => _saving = true);
    final now = DateTime.now();
    final m = Measurement(
      systolic: _systolic,
      diastolic: _diastolic,
      pulse: _pulse,
      datetime: _formatDateTime(now),
    );
    await DatabaseHelper.instance.insertMeasurement(m);
    await _loadMeasurements();
    setState(() {
      _saving = false;
      _systolic = 120;
      _diastolic = 80;
      _pulse = 70;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Measurement saved'),
          backgroundColor: _buttonColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _deleteMeasurement(Measurement m) async {
    if (m.id != null) {
      await DatabaseHelper.instance.deleteMeasurement(m.id!);
      await _loadMeasurements();
    }
  }

  String _formatDateTime(DateTime dt) {
    String p(int n) => n.toString().padLeft(2, '0');
    return '${dt.year}-${p(dt.month)}-${p(dt.day)} ${p(dt.hour)}:${p(dt.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 36, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      'Blood Pressure',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: _textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Track your measurements',
                      style: TextStyle(fontSize: 13, color: _textSecondary),
                    ),
                    const SizedBox(height: 32),

                    // Knobs card
                    Container(
                      padding: const EdgeInsets.fromLTRB(8, 28, 8, 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: _buttonColor.withValues(alpha: 0.10),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          GearKnob(
                            label: 'SYSTOLIC',
                            unit: 'mmHg',
                            value: _systolic,
                            min: 60,
                            max: 250,
                            gearColor: _gearSystolic,
                            onChanged: (v) => setState(() => _systolic = v),
                          ),
                          Container(
                            width: 1,
                            height: 110,
                            color: _divider,
                          ),
                          GearKnob(
                            label: 'DIASTOLIC',
                            unit: 'mmHg',
                            value: _diastolic,
                            min: 40,
                            max: 150,
                            gearColor: _gearDiastolic,
                            onChanged: (v) => setState(() => _diastolic = v),
                          ),
                          Container(
                            width: 1,
                            height: 110,
                            color: _divider,
                          ),
                          GearKnob(
                            label: 'PULSE',
                            unit: 'bpm',
                            value: _pulse,
                            min: 30,
                            max: 200,
                            gearColor: _gearPulse,
                            onChanged: (v) => setState(() => _pulse = v),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Drag knobs left or right to adjust',
                      style: TextStyle(fontSize: 11, color: _textSecondary),
                    ),
                    const SizedBox(height: 24),

                    // Add button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _addMeasurement,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _buttonColor,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              _buttonColor.withValues(alpha: 0.5),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: _saving
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Add',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // History header
                    if (_measurements.isNotEmpty)
                      Row(
                        children: [
                          const Text(
                            'History',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                              color: _textPrimary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${_measurements.length} records',
                            style: const TextStyle(
                              fontSize: 12,
                              color: _textSecondary,
                            ),
                          ),
                        ],
                      ),
                    if (_measurements.isNotEmpty) const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            // Empty state
            if (_measurements.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.favorite_border_rounded,
                        size: 52,
                        color: _textSecondary.withValues(alpha: 0.35),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'No measurements yet',
                        style: TextStyle(color: _textSecondary, fontSize: 15),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Add your first reading above',
                        style: TextStyle(color: _textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final m = _measurements[index];
                    final isLast = index == _measurements.length - 1;
                    return Padding(
                      padding: EdgeInsets.fromLTRB(24, 0, 24, isLast ? 32 : 10),
                      child: Dismissible(
                        key: ValueKey(m.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 22),
                          decoration: BoxDecoration(
                            color: Colors.red.shade300,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.white,
                          ),
                        ),
                        onDismissed: (_) => _deleteMeasurement(m),
                        child: _MeasurementCard(measurement: m),
                      ),
                    );
                  },
                  childCount: _measurements.length,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MeasurementCard extends StatelessWidget {
  final Measurement measurement;

  const _MeasurementCard({required this.measurement});

  Color _statusColor() {
    final sys = measurement.systolic;
    final dia = measurement.diastolic;
    if (sys < 120 && dia < 80) return const Color(0xFF99D6B5); // Normal
    if (sys < 130 && dia < 80) return const Color(0xFFFFD699); // Elevated
    if (sys < 140 || dia < 90) return const Color(0xFFFFB899); // Stage 1
    return const Color(0xFFFFADB8); // Stage 2+
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B9DC2).withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: _statusColor(),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  measurement.datetime,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7A9BB5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${measurement.systolic} / ${measurement.diastolic}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C4A6E),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'mmHg',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF7A9BB5),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      '${measurement.pulse}',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C4A6E),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'bpm',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF7A9BB5),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: Color(0xFFCADCEE),
          ),
        ],
      ),
    );
  }
}
