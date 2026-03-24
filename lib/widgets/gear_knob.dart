import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class GearKnob extends StatefulWidget {
  final String label;
  final String unit;
  final double gearSize;
  final bool enabled;
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
    this.gearSize = 90.0,
    this.enabled = true,
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
    return IgnorePointer(
      ignoring: !widget.enabled,
      child: GestureDetector(
        onPanStart: _onPanStart,
        onPanUpdate: _onPanUpdate,
        behavior: HitTestBehavior.opaque,
        child: Column(
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
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.gearColor.withValues(alpha: 0.45),
                    blurRadius: widget.gearSize * 0.15,
                    offset: Offset(0, widget.gearSize * 0.055),
                  ),
                ],
              ),
              child: CustomPaint(
                size: Size(widget.gearSize, widget.gearSize),
                painter: _GearPainter(angle: _angle, color: widget.gearColor),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              '${widget.value}',
              style: TextStyle(
                fontSize: (widget.gearSize * 0.38).clamp(16.0, 44.0),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2C4A6E),
                height: 1,
              ),
            ),
            if (widget.unit.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                widget.unit,
                style: TextStyle(
                  fontSize: (widget.gearSize * 0.11).clamp(8.0, 12.0),
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ],
        ),
      ),
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
    final toothHeight = outerRadius * 0.20;
    final toothWidth = outerRadius * 0.14;

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
          Radius.circular(toothWidth * 0.3),
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
        ..strokeWidth = (outerRadius * 0.063).clamp(1.5, 3.0),
    );

    // Spokes
    final spokePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.30)
      ..strokeWidth = (outerRadius * 0.053).clamp(1.0, 2.5)
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
