import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../l10n/strings.dart';
import '../models/measurement.dart';
import 'home_screen.dart' show MeasurementCard;

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Measurement> _measurements = [];

  static const Color _bgColor = Color(0xFFF4F7FF);
  static const Color _textPrimary = Color(0xFF2C4A6E);
  static const Color _textSecondary = Color(0xFF7A9BB5);
  static const Color _buttonColor = Color(0xFF6B9DC2);

  @override
  void initState() {
    super.initState();
    _loadMeasurements();
  }

  void _showDonateModal() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.volunteer_activism_rounded,
                size: 48, color: Color(0xFFFF9090)),
            const SizedBox(height: 16),
            Text(
              AppStrings.instance.donateMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: _textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                style: TextButton.styleFrom(
                  foregroundColor: _textSecondary,
                ),
                child: Text(AppStrings.instance.donateDismiss),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadMeasurements() async {
    final data = await DatabaseHelper.instance.getAllMeasurements();
    setState(() => _measurements = data);
  }

  Future<void> _deleteMeasurement(Measurement m) async {
    if (m.id != null) {
      await DatabaseHelper.instance.deleteMeasurement(m.id!);
      await _loadMeasurements();
    }
  }

  Future<void> _showEditDialog(Measurement m) async {
    int systolic = m.systolic;
    int diastolic = m.diastolic;
    int pulse = m.pulse;

    await showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Text(
            AppStrings.instance.editMeasurement,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                m.datetime,
                style: const TextStyle(fontSize: 12, color: _textSecondary),
              ),
              const SizedBox(height: 20),
              _ValueAdjuster(
                label: AppStrings.instance.systolic,
                unit: 'mmHg',
                value: systolic,
                min: 60,
                max: 250,
                onChanged: (v) => setDialogState(() => systolic = v),
              ),
              const SizedBox(height: 12),
              _ValueAdjuster(
                label: AppStrings.instance.diastolic,
                unit: 'mmHg',
                value: diastolic,
                min: 40,
                max: 150,
                onChanged: (v) => setDialogState(() => diastolic = v),
              ),
              const SizedBox(height: 12),
              _ValueAdjuster(
                label: AppStrings.instance.pulse,
                unit: 'bpm',
                value: pulse,
                min: 30,
                max: 200,
                onChanged: (v) => setDialogState(() => pulse = v),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFD0E0EE)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      AppStrings.instance.cancel,
                      style: const TextStyle(color: _textSecondary),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final updated = Measurement(
                        id: m.id,
                        systolic: systolic,
                        diastolic: diastolic,
                        pulse: pulse,
                        datetime: m.datetime,
                      );
                      await DatabaseHelper.instance.updateMeasurement(updated);
                      if (ctx.mounted) Navigator.pop(ctx);
                      await _loadMeasurements();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _buttonColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      AppStrings.instance.save,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 24, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: _textPrimary,
                    iconSize: 22,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  Expanded(
                    child: Text(
                      AppStrings.instance.historyTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _showDonateModal,
                    icon: const Icon(Icons.volunteer_activism_rounded),
                    color: _textSecondary,
                    iconSize: 22,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppStrings.instance.swipeHint,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: Color(0xFF7A9BB5)),
            ),
            const SizedBox(height: 14),

            // List
            Expanded(
              child: _measurements.isEmpty
                  ? Center(
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
                            style: const TextStyle(
                              color: Color(0xFF7A9BB5),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
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
                            child: GestureDetector(
                              onTap: () => _showEditDialog(m),
                              child: Stack(
                                children: [
                                  MeasurementCard(measurement: m),
                                  Positioned(
                                    right: 14,
                                    top: 0,
                                    bottom: 0,
                                    child: Center(
                                      child: Icon(
                                        Icons.edit_rounded,
                                        size: 16,
                                        color: _textSecondary.withValues(
                                          alpha: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ValueAdjuster extends StatelessWidget {
  final String label;
  final String unit;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _ValueAdjuster({
    required this.label,
    required this.unit,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  static const Color _textPrimary = Color(0xFF2C4A6E);
  static const Color _textSecondary = Color(0xFF7A9BB5);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: _textSecondary),
          ),
        ),
        const Spacer(),
        _AdjustButton(
          icon: Icons.remove_rounded,
          enabled: value > min,
          onTap: () => onChanged(value - 1),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 46,
          child: Column(
            children: [
              Text(
                '$value',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: _textPrimary,
                ),
              ),
              Text(
                unit,
                style: const TextStyle(fontSize: 9, color: _textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _AdjustButton(
          icon: Icons.add_rounded,
          enabled: value < max,
          onTap: () => onChanged(value + 1),
        ),
      ],
    );
  }
}

class _AdjustButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _AdjustButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled
              ? const Color(0xFFEBF3FF)
              : const Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: enabled
              ? const Color(0xFF6B9DC2)
              : const Color(0xFFCCCCCC),
        ),
      ),
    );
  }
}
