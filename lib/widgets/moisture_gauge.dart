import 'package:flutter/material.dart';
import 'dart:math' as math;

class MoistureGauge extends StatefulWidget {
  final int moisture;
  final int expected;

  const MoistureGauge({
    super.key,
    required this.moisture,
    required this.expected,
  });

  @override
  State<MoistureGauge> createState() => _MoistureGaugeState();
}

class _MoistureGaugeState extends State<MoistureGauge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 1200), vsync: this);
    _animation = Tween<double>(begin: 0, end: widget.moisture / 100)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
    _controller.forward();
  }

  @override
  void didUpdateWidget(MoistureGauge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.moisture != widget.moisture) {
      _animation = Tween<double>(
              begin: oldWidget.moisture / 100, end: widget.moisture / 100)
          .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getMoistureColor(int percent) {
    if (percent < 20) return const Color(0xFFFF6B6B);
    if (percent < widget.expected) return const Color(0xFFFFD93D);
    if (percent > widget.expected + 20) return const Color(0xFF4ECDC4);
    return const Color(0xFF6BCB77);
  }

  String _getStatusLabel(int percent) {
    if (percent < 20) return 'CRITICALLY DRY';
    if (percent < widget.expected) return 'DRY — WATERING';
    if (percent > widget.expected + 20) return 'OVER SATURATED';
    return 'OPTIMAL';
  }

  @override
  Widget build(BuildContext context) {
    final color = _getMoistureColor(widget.moisture);
    final statusLabel = _getStatusLabel(widget.moisture);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E2A3A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Soil Moisture',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: color.withOpacity(0.4)),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: color,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return CustomPaint(
                painter: _GaugePainter(
                  progress: _animation.value,
                  expectedProgress: widget.expected / 100,
                  color: color,
                ),
                child: SizedBox(
                  width: 160,
                  height: 90,
                  child: Align(
                    alignment: const Alignment(0, 0.8),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${widget.moisture}%',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                        Text(
                          'Target: ${widget.expected}%',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          // Linear progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: widget.moisture / 100,
              minHeight: 8,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0%', style: TextStyle(fontSize: 10, color: Colors.white38)),
              Text('100%', style: TextStyle(fontSize: 10, color: Colors.white38)),
            ],
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double progress;
  final double expectedProgress;
  final Color color;

  _GaugePainter({
    required this.progress,
    required this.expectedProgress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2 - 8;
    const startAngle = math.pi;
    const sweepAngle = math.pi;

    // Background arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle, sweepAngle, false,
      Paint()
        ..color = Colors.white.withOpacity(0.08)
        ..strokeWidth = 12
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Expected marker
    final expectedAngle = startAngle + (sweepAngle * expectedProgress);
    final markerPaint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final markerStart = Offset(
      center.dx + (radius - 8) * math.cos(expectedAngle),
      center.dy + (radius - 8) * math.sin(expectedAngle),
    );
    final markerEnd = Offset(
      center.dx + (radius + 8) * math.cos(expectedAngle),
      center.dy + (radius + 8) * math.sin(expectedAngle),
    );
    canvas.drawLine(markerStart, markerEnd, markerPaint);

    // Progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle, sweepAngle * progress, false,
      Paint()
        ..color = color
        ..strokeWidth = 12
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle, sweepAngle * progress, false,
      Paint()
        ..color = color
        ..strokeWidth = 10
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.progress != progress || old.color != color;
}
