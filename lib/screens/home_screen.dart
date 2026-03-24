import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../l10n/strings.dart';
import '../models/measurement.dart';
import '../widgets/gear_knob.dart';
import 'history_screen.dart';

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
  int _step = 0; // 0=systolic, 1=diastolic, 2=pulse, 3=all done

  static const Color _bgColor = Color(0xFFF4F7FF);
  static const Color _textPrimary = Color(0xFF2C4A6E);
  static const Color _textSecondary = Color(0xFF7A9BB5);
  static const Color _gearSystolic = Color(0xFFADD8F0);
  static const Color _gearDiastolic = Color(0xFF5B8DB8);
  static const Color _gearPulse = Color(0xFFFF9090);
  static const Color _confirmColor = Color(0xFF99D6B5);
  static const Color _buttonColor = Color(0xFF6B9DC2);

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
      _step = 0;
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.instance.measurementSaved),
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

  Future<void> _openHistory() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HistoryScreen()),
    );
    _loadMeasurements();
  }

  Widget _buildKnob(int knobIndex, {required bool active, VoidCallback? onTap}) {
    final s = AppStrings.instance;
    final labels = [s.systolic.toUpperCase(), s.diastolic.toUpperCase(), s.pulse.toUpperCase()];
    const units = ['mmHg', 'mmHg', 'bpm'];
    const colors = [_gearSystolic, _gearDiastolic, _gearPulse];
    const mins = [60, 40, 30];
    const maxs = [250, 150, 200];
    final values = [_systolic, _diastolic, _pulse];
    final callbacks = [
      (int v) => setState(() => _systolic = v),
      (int v) => setState(() => _diastolic = v),
      (int v) => setState(() => _pulse = v),
    ];
    final knob = Opacity(
      opacity: active ? 1.0 : 0.38,
      child: GearKnob(
        label: labels[knobIndex],
        unit: units[knobIndex],
        value: values[knobIndex],
        min: mins[knobIndex],
        max: maxs[knobIndex],
        gearColor: colors[knobIndex],
        gearSize: active ? 100.0 : 58.0,
        enabled: active,
        onChanged: callbacks[knobIndex],
      ),
    );
    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: knob,
      );
    }
    return knob;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Fixed top section ──────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Header row: history button + title
                  Row(
                    children: [
                      IconButton(
                        onPressed: _openHistory,
                        icon: const Icon(Icons.history_rounded),
                        color: _textPrimary,
                        iconSize: 26,
                        tooltip: AppStrings.instance.historyTooltip,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      Expanded(
                        child: Text(
                          AppStrings.instance.appTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: _textPrimary,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 26), // balance the icon
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    AppStrings.instance.appSubtitle,
                    style: const TextStyle(fontSize: 12, color: _textSecondary),
                  ),
                  const SizedBox(height: 20),

                  // Knobs card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Container(
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
                      child: SizedBox(
                        height: 218,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Left: always the knob "behind" the active one (circular)
                            Expanded(
                              child: Center(
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 280),
                                  child: SizedBox(
                                    key: ValueKey('l$_step'),
                                    child: _buildKnob(
                                      _step >= 3 ? 0 : (_step + 2) % 3,
                                      active: false,
                                      onTap: () {
                                        final idx = _step >= 3 ? 0 : (_step + 2) % 3;
                                        setState(() => _step = idx);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Center: always the active knob
                            Expanded(
                              child: Center(
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 280),
                                  child: SizedBox(
                                    key: ValueKey('c$_step'),
                                    child: _buildKnob(
                                      _step >= 3 ? 1 : _step,
                                      active: _step < 3,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Right: always the knob "ahead" of the active one (circular)
                            Expanded(
                              child: Center(
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 280),
                                  child: SizedBox(
                                    key: ValueKey('r$_step'),
                                    child: _buildKnob(
                                      _step >= 3 ? 2 : (_step + 1) % 3,
                                      active: false,
                                      onTap: () {
                                        final idx = _step >= 3 ? 2 : (_step + 1) % 3;
                                        setState(() => _step = idx);
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    _step >= 3
                        ? AppStrings.instance.allValuesSet
                        : '${[AppStrings.instance.setSystolic, AppStrings.instance.setDiastolic, AppStrings.instance.setPulse][_step]}  ·  ${AppStrings.instance.dragToAdjust}',
                    style: const TextStyle(fontSize: 11, color: _textSecondary),
                  ),
                  const SizedBox(height: 12),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: _step < 3
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
                            child: SizedBox(
                              width: double.infinity,
                              height: 44,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: OutlinedButton(
                                  key: ValueKey(_step),
                                  onPressed: () => setState(() => _step++),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                      color: _confirmColor,
                                      width: 1.5,
                                    ),
                                    foregroundColor: _textPrimary,
                                    backgroundColor: _confirmColor.withValues(alpha: 0.15),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        [
                                          AppStrings.instance.confirmSystolic,
                                          AppStrings.instance.confirmDiastolic,
                                          AppStrings.instance.confirmPulse,
                                        ][_step],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        _step == 2 ? Icons.favorite_rounded : Icons.check_rounded,
                                        size: 17,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),

                  // Add button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: (_saving || _step < 3) ? null : _addMeasurement,
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
                            : Text(
                                AppStrings.instance.add,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // History section header
                  if (_measurements.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Row(
                        children: [
                          Text(
                            AppStrings.instance.recent,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _textPrimary,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${_measurements.length} ${AppStrings.instance.records}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: _textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_measurements.isNotEmpty) const SizedBox(height: 10),
                ],
              ),
            ),

            // ── Scrollable list or empty state (fills remaining space) ──
            Expanded(
              child: _measurements.isEmpty
                  ? _EmptyState()
                  : Stack(
                      children: [
                        ListView.builder(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
                          itemCount: _measurements.length,
                          itemBuilder: (context, index) {
                            final m = _measurements[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
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
                                child: MeasurementCard(measurement: m),
                              ),
                            );
                          },
                        ),
                        // Bottom fade fog
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 80,
                          child: IgnorePointer(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    _bgColor.withValues(alpha: 0),
                                    _bgColor,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.favorite_border_rounded,
            size: 48,
            color: Color(0x597A9BB5),
          ),
          const SizedBox(height: 10),
          Text(
            AppStrings.instance.noMeasurements,
            style: const TextStyle(color: Color(0xFF7A9BB5), fontSize: 14),
          ),
          const SizedBox(height: 2),
          Text(
            AppStrings.instance.addFirstReading,
            style: const TextStyle(color: Color(0xFF7A9BB5), fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class MeasurementCard extends StatelessWidget {
  final Measurement measurement;

  const MeasurementCard({super.key, required this.measurement});

  Color _statusColor() {
    final sys = measurement.systolic;
    final dia = measurement.diastolic;
    if (sys < 120 && dia < 80) return const Color(0xFF99D6B5);
    if (sys < 130 && dia < 80) return const Color(0xFFFFD699);
    if (sys < 140 || dia < 90) return const Color(0xFFFFB899);
    return const Color(0xFFFFADB8);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
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
            height: 48,
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
                    fontSize: 11,
                    color: Color(0xFF7A9BB5),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${measurement.systolic} / ${measurement.diastolic}',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C4A6E),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'mmHg',
                      style: TextStyle(fontSize: 10, color: Color(0xFF7A9BB5)),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${measurement.pulse}',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C4A6E),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'bpm',
                      style: TextStyle(fontSize: 10, color: Color(0xFF7A9BB5)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
