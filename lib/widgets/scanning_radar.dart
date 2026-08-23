import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/cyber_theme.dart';

class ScanningRadar extends StatefulWidget {
  final String stage;

  const ScanningRadar({super.key, required this.stage});

  @override
  State<ScanningRadar> createState() => _ScanningRadarState();
}

class _ScanningRadarState extends State<ScanningRadar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 160,
            height: 160,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: _RadarPainter(progress: _controller.value),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'THREAT ANALYSIS IN PROGRESS',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: CyberTheme.cyan,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: CyberTheme.navyMid,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: CyberTheme.cardBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: CyberTheme.cyan,
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    widget.stage.isNotEmpty ? widget.stage : 'Gathering Network Telemetry...',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: CyberTheme.grayLt,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  final double progress;

  _RadarPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width / 2;

    // Outer circle
    final circlePaint = Paint()
      ..color = CyberTheme.cyan.withOpacity(0.15)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (int i = 1; i <= 3; i++) {
      canvas.drawCircle(center, maxRadius * (i / 3), circlePaint);
    }

    // Crosshairs
    final linePaint = Paint()
      ..color = CyberTheme.cyan.withOpacity(0.2)
      ..strokeWidth = 1;

    canvas.drawLine(Offset(0, center.dy), Offset(size.width, center.dy), linePaint);
    canvas.drawLine(Offset(center.dx, 0), Offset(center.dx, size.height), linePaint);

    // Rotating Sweep
    final sweepAngle = progress * 2 * pi;
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        colors: [
          CyberTheme.cyan.withOpacity(0.0),
          CyberTheme.cyan.withOpacity(0.4),
        ],
        stops: const [0.8, 1.0],
        transform: GradientRotation(sweepAngle - 0.5),
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, maxRadius, sweepPaint);

    // Center glowing blip
    final blipPaint = Paint()
      ..color = CyberTheme.cyan
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 4, blipPaint);
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
