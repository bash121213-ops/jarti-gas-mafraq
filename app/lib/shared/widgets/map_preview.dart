import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// A lightweight, API-free map illustration for the prototype.
///
/// Replacing it with a real map SDK (e.g. `flutter_map` + OSM tiles) is a
/// separate step; the real coordinates come from the order address.
class MapPreview extends StatelessWidget {
  const MapPreview({
    super.key,
    this.height = 120,
    this.showDriver = false,
    this.borderRadius = 20,
    this.overlay,
  });

  final double height;
  final bool showDriver;
  final double borderRadius;
  final Widget? overlay;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: SizedBox(
        height: height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            const CustomPaint(painter: _MapPainter()),
            Align(
              alignment: const Alignment(-0.62, 0.6),
              child: _Marker(
                color: Colors.white,
                borderColor: AppColors.mint,
                icon: Icons.home_rounded,
                iconColor: AppColors.mint,
              ),
            ),
            if (showDriver)
              const Align(
                alignment: Alignment(0.42, -0.42),
                child: _Marker(
                  color: AppColors.apricot,
                  borderColor: Colors.white,
                  icon: Icons.local_shipping_rounded,
                  iconColor: Colors.white,
                  size: 36,
                ),
              ),
            ?overlay,
          ],
        ),
      ),
    );
  }
}

class _Marker extends StatelessWidget {
  const _Marker({
    required this.color,
    required this.borderColor,
    required this.icon,
    required this.iconColor,
    this.size = 30,
  });

  final Color color;
  final Color borderColor;
  final IconData icon;
  final Color iconColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, size: size * 0.48, color: iconColor),
    );
  }
}

class _MapPainter extends CustomPainter {
  const _MapPainter();

  static const List<Rect> _blocks = [
    Rect.fromLTWH(0.03, 0.08, 0.2, 0.24),
    Rect.fromLTWH(0.31, 0.03, 0.16, 0.2),
    Rect.fromLTWH(0.56, 0.09, 0.15, 0.23),
    Rect.fromLTWH(0.79, 0.05, 0.18, 0.28),
    Rect.fromLTWH(0.04, 0.44, 0.15, 0.26),
    Rect.fromLTWH(0.26, 0.4, 0.2, 0.19),
    Rect.fromLTWH(0.52, 0.47, 0.2, 0.22),
    Rect.fromLTWH(0.79, 0.42, 0.17, 0.3),
    Rect.fromLTWH(0.08, 0.76, 0.18, 0.22),
    Rect.fromLTWH(0.34, 0.72, 0.16, 0.26),
    Rect.fromLTWH(0.6, 0.76, 0.17, 0.2),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = const Color(0xFFEEF2EC),
    );

    final blockPaint = Paint()..color = const Color(0xFFE1E8DB);
    for (final block in _blocks) {
      final rect = Rect.fromLTWH(
        block.left * size.width,
        block.top * size.height,
        block.width * size.width,
        block.height * size.height,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        blockPaint,
      );
    }

    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = size.height * 0.085
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(-10, size.height * 0.32),
      Offset(size.width + 10, size.height * 0.27),
      roadPaint,
    );
    canvas.drawLine(
      Offset(-10, size.height * 0.66),
      Offset(size.width + 10, size.height * 0.7),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.24, -10),
      Offset(size.width * 0.19, size.height + 10),
      roadPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.72, -10),
      Offset(size.width * 0.76, size.height + 10),
      roadPaint,
    );

    final routePaint = Paint()
      ..color = AppColors.apricot
      ..strokeWidth = 3.4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(size.width * 0.16, size.height * 0.72)
      ..cubicTo(
        size.width * 0.34,
        size.height * 0.62,
        size.width * 0.48,
        size.height * 0.4,
        size.width * 0.62,
        size.height * 0.3,
      );
    _drawDashed(canvas, path, routePaint);
  }

  void _drawDashed(Canvas canvas, Path path, Paint paint) {
    const dash = 7.0;
    const gap = 6.0;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance = end + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) => false;
}
