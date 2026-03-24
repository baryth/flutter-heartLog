import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GearKnob extends StatefulWidget {
  final String label;
  final String unit;
  final int value;
  final int min;
  final int max;
  final Color gearColor;
  final ValueChanged<int> onChanged;

  const GearKnob({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.gearColor,
    required this.onChanged,
    this.unit = '',
  });

  @override
  State<GearKnob> createState() => _GearKnobState();
}

class _GearKnobState extends State<GearKnob> {
  double _angle = 0;
  double _totalDrag = 0;
  int _baseValue = 0;

  // How many pixels of horizontal drag equal one unit of value change
  static const double _pixelsPerStep = 6.0;

  void _onPanStart(DragStartDetails details) {
    _totalDrag = 0;
    _baseValue = widget.value;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    _totalDrag += details.delta.dx;
    final steps = (_totalDrag / _pixelsPerStep).round();
    final newValue = (_baseValue + steps).clamp(widget.min, widget.max);
    if (newValue != widget.value) {
      HapticFeedback.selectionClick();
      widget.onChanged(newValue);
    }
    setState(() {
      _angle += details.delta.dx * 0.025;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onPanStart: _onPanStart,
          onPanUpdate: _onPanUpdate,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.gearColor.withValues(alpha: 0.45),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: CustomPaint(
              size: const Size(90, 90),
              painter: _GearPainter(angle: _angle, color: widget.gearColor),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Text(
          '${widget.value}',
          style: const TextStyle(
            fontSize: 34,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2C4A6E),
            height: 1,
          ),
        ),
        if (widget.unit.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            widget.unit,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.4,
            ),
          ),
        ],
      ],
    );
  }
}

class _GearPainter extends CustomPainter {
  final double angle;
  final Color color;

  const _GearPainter({required this.angle, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final outerRadius = size.width / 2 - 3;
    const numTeeth = 12;
    const toothHeight = 9.0;
    const toothWidth = 6.5;

    final bodyPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    // Teeth
    for (int i = 0; i < numTeeth; i++) {
      canvas.save();
      canvas.rotate(2 * pi * i / numTeeth);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(0, -(outerRadius + toothHeight / 2 - 2)),
            width: toothWidth,
            height: toothHeight,
          ),
          const Radius.circular(2),
        ),
        bodyPaint,
      );
      canvas.restore();
    }

    // Main gear body circle
    canvas.drawCircle(Offset.zero, outerRadius, bodyPaint);

    // Subtle highlight ring on top
    canvas.drawCircle(
      Offset.zero,
      outerRadius - 3,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.20)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );

    // Spokes
    final spokePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.30)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 6; i++) {
      canvas.save();
      canvas.rotate(pi / 3 * i);
      canvas.drawLine(
        Offset(0, -(outerRadius * 0.27)),
        Offset(0, -(outerRadius * 0.70)),
        spokePaint,
      );
      canvas.restore();
    }

    // Center hole
    canvas.drawCircle(
      Offset.zero,
      outerRadius * 0.24,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.80)
        ..style = PaintingStyle.fill,
    );

    // Center dot
    canvas.drawCircle(
      Offset.zero,
      outerRadius * 0.08,
      Paint()
        ..color = color.withValues(alpha: 0.55)
        ..style = PaintingStyle.fill,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(_GearPainter oldDelegate) =>
      oldDelegate.angle != angle || oldDelegate.color != color;
}
