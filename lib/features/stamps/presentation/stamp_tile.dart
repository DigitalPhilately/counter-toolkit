import 'dart:math' as math;

import 'package:counter_toolkit/features/stamps/domain/stamp_models.dart';
import 'package:flutter/material.dart';

class StampPickTile extends StatelessWidget {
  const StampPickTile({
    super.key,
    required this.item,
    this.onTap,
    this.compact = false,
  });

  final StampLineItem item;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tile = SizedBox(
      width: compact ? 118 : 142,
      height: compact ? 156 : 188,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          PhysicalShape(
            elevation: compact ? 5 : 8,
            color: const Color(0xFFF9F6F1),
            shadowColor: Colors.black.withValues(alpha: 0.16),
            clipper: const _StampEdgeClipper(),
            child: Padding(
              padding: EdgeInsets.all(compact ? 6 : 7),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F1EA),
                  border: Border.all(
                    color: const Color(0xFFE4DED3),
                    width: 1.1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      flex: 64,
                      child: _StampFace(item: item, compact: compact),
                    ),
                    const _PerforationBridge(),
                    Expanded(
                      flex: 24,
                      child: _BarcodeStrip(seed: item.stamp.label),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (item.count > 1)
            Positioned(
              top: -8,
              right: -4,
              child: _CountBadge(count: item.count),
            ),
          if (item.isPicked)
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.94),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 16,
                  color: Color(0xFF0F5B57),
                ),
              ),
            ),
        ],
      ),
    );

    if (onTap == null) {
      return tile;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: tile,
      ),
    );
  }
}

class _StampFace extends StatelessWidget {
  const _StampFace({required this.item, required this.compact});

  final StampLineItem item;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final stampColor = colorFromHex(item.stamp.colourHex);
    final faceTop = lighten(stampColor, 0.1);
    final faceBottom = darken(stampColor, 0.12);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [faceTop, stampColor, faceBottom],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _StampFaceTexturePainter(
                lightColor: Colors.white.withValues(alpha: 0.14),
                shadowColor: Colors.black.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned.fill(
            child: CustomPaint(
              painter: _EngravedCameoPainter(
                baseColor: Colors.white.withValues(alpha: 0.26),
                lineColor: Colors.white.withValues(alpha: 0.22),
                shadowColor: Colors.black.withValues(alpha: 0.12),
              ),
            ),
          ),
          Positioned(
            left: compact ? 7 : 9,
            right: compact ? 6 : 8,
            bottom: compact ? 7 : 9,
            child: FittedBox(
              alignment: Alignment.bottomLeft,
              fit: BoxFit.scaleDown,
              child: Text(
                item.stamp.label,
                maxLines: 1,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.98),
                  fontSize: compact ? 27 : 32,
                  fontWeight: FontWeight.w700,
                  height: 0.95,
                  letterSpacing: -0.6,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                  fontFamilyFallback: const ['Georgia', 'Times New Roman'],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PerforationBridge extends StatelessWidget {
  const _PerforationBridge();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 12,
      child: DecoratedBox(
        decoration: const BoxDecoration(color: Color(0xFFF8F5F0)),
        child: CustomPaint(painter: const _PerforationBridgePainter()),
      ),
    );
  }
}

class _BarcodeStrip extends StatelessWidget {
  const _BarcodeStrip({required this.seed});

  final String seed;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFFFDFBF8),
        border: Border(left: BorderSide(color: Color(0xFFE2DBCF), width: 1)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 8),
        child: CustomPaint(
          painter: _PseudoBarcodePainter(seed: seed),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: const Color(0xFF232E35),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Text(
        'x$count',
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _StampEdgeClipper extends CustomClipper<Path> {
  const _StampEdgeClipper();

  @override
  Path getClip(Size size) => _buildStampEdgePath(size);

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _PseudoBarcodePainter extends CustomPainter {
  const _PseudoBarcodePainter({required this.seed});

  final String seed;

  @override
  void paint(Canvas canvas, Size size) {
    final cellsAcross = 6;
    final cellsDown = 22;
    final cellWidth = size.width / cellsAcross;
    final cellHeight = size.height / cellsDown;
    final seedValue = seed.codeUnits.fold<int>(
      31,
      (sum, value) => (sum * 37) + value,
    );
    var state = seedValue;

    for (var y = 0; y < cellsDown; y++) {
      for (var x = 0; x < cellsAcross; x++) {
        state = (state * 1103515245 + 12345) & 0x7fffffff;
        final isDark = state % 10 >= 3;
        final paint = Paint()
          ..color = isDark ? const Color(0xFF283241) : const Color(0xFFE9E3D9);
        final inset = (state % 2).toDouble() * 0.4;
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            (x * cellWidth) + inset,
            (y * cellHeight) + inset,
            math.max(2.2, cellWidth - (inset * 2)),
            math.max(2.6, cellHeight - (inset * 2)),
          ),
          const Radius.circular(1.4),
        );
        canvas.drawRRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PseudoBarcodePainter oldDelegate) {
    return oldDelegate.seed != seed;
  }
}

class _PerforationBridgePainter extends CustomPainter {
  const _PerforationBridgePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final guidePaint = Paint()..color = const Color(0xFFE9E2D6);
    canvas.drawRect(
      Rect.fromLTWH(size.width - 1, 0, 1, size.height),
      guidePaint,
    );

    final punchPaint = Paint()..color = const Color(0xFFD3CCC1);
    final highlightPaint = Paint()..color = Colors.white.withValues(alpha: 0.7);
    final count = math.max(8, (size.height / 11).floor());
    final spacing = size.height / (count + 1);

    for (var index = 1; index <= count; index++) {
      final center = Offset(size.width * 0.42, spacing * index);
      canvas.drawCircle(center, 1.9, punchPaint);
      canvas.drawCircle(center.translate(-0.35, -0.35), 0.8, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StampFaceTexturePainter extends CustomPainter {
  const _StampFaceTexturePainter({
    required this.lightColor,
    required this.shadowColor,
  });

  final Color lightColor;
  final Color shadowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final lightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [lightColor, Colors.transparent],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, lightPaint);

    final texturePaint = Paint()
      ..color = shadowColor
      ..strokeWidth = 0.7
      ..style = PaintingStyle.stroke;

    final diagonalGap = size.width / 8;
    for (
      double offset = -size.height;
      offset < size.width;
      offset += diagonalGap
    ) {
      final start = Offset(offset, 0);
      final end = Offset(offset + size.height, size.height);
      canvas.drawLine(start, end, texturePaint);
    }

    final vignettePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.35, -0.2),
        radius: 1.05,
        colors: [
          Colors.transparent,
          shadowColor.withValues(alpha: 0.06),
          shadowColor.withValues(alpha: 0.18),
        ],
        stops: const [0.0, 0.62, 1.0],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, vignettePaint);
  }

  @override
  bool shouldRepaint(covariant _StampFaceTexturePainter oldDelegate) {
    return oldDelegate.lightColor != lightColor ||
        oldDelegate.shadowColor != shadowColor;
  }
}

class _EngravedCameoPainter extends CustomPainter {
  const _EngravedCameoPainter({
    required this.baseColor,
    required this.lineColor,
    required this.shadowColor,
  });

  final Color baseColor;
  final Color lineColor;
  final Color shadowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final shoulderPath = Path()
      ..moveTo(size.width * 0.1, size.height * 0.93)
      ..quadraticBezierTo(
        size.width * 0.36,
        size.height * 0.72,
        size.width * 0.56,
        size.height * 0.76,
      )
      ..quadraticBezierTo(
        size.width * 0.82,
        size.height * 0.79,
        size.width * 0.98,
        size.height * 0.94,
      )
      ..lineTo(size.width * 0.1, size.height * 0.98)
      ..close();

    canvas.drawPath(
      shoulderPath.shift(const Offset(1.5, 2)),
      Paint()..color = shadowColor.withValues(alpha: 0.16),
    );
    canvas.drawPath(shoulderPath, Paint()..color = baseColor);

    final headRect = Rect.fromLTWH(
      size.width * 0.22,
      size.height * 0.13,
      size.width * 0.45,
      size.height * 0.52,
    );
    canvas.drawOval(
      headRect.shift(const Offset(1.4, 1.8)),
      Paint()..color = shadowColor.withValues(alpha: 0.14),
    );
    canvas.drawOval(headRect, Paint()..color = baseColor);

    final silhouettePath = Path()
      ..moveTo(size.width * 0.55, size.height * 0.18)
      ..quadraticBezierTo(
        size.width * 0.69,
        size.height * 0.2,
        size.width * 0.73,
        size.height * 0.34,
      )
      ..quadraticBezierTo(
        size.width * 0.7,
        size.height * 0.38,
        size.width * 0.64,
        size.height * 0.41,
      )
      ..quadraticBezierTo(
        size.width * 0.68,
        size.height * 0.45,
        size.width * 0.61,
        size.height * 0.51,
      )
      ..quadraticBezierTo(
        size.width * 0.56,
        size.height * 0.56,
        size.width * 0.56,
        size.height * 0.66,
      )
      ..quadraticBezierTo(
        size.width * 0.47,
        size.height * 0.66,
        size.width * 0.4,
        size.height * 0.61,
      );

    canvas.drawPath(
      silhouettePath,
      Paint()
        ..color = lineColor.withValues(alpha: 0.95)
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    final hairPaint = Paint()
      ..color = lineColor.withValues(alpha: 0.7)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    for (double step = 0.18; step <= 0.48; step += 0.05) {
      final hair = Path()
        ..moveTo(size.width * 0.28, size.height * step)
        ..quadraticBezierTo(
          size.width * 0.47,
          size.height * (step - 0.05),
          size.width * 0.59,
          size.height * (step + 0.02),
        );
      canvas.drawPath(hair, hairPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _EngravedCameoPainter oldDelegate) {
    return oldDelegate.baseColor != baseColor ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.shadowColor != shadowColor;
  }
}

Path _buildStampEdgePath(Size size) {
  const notchRadius = 3.6;
  const cornerRadius = 7.0;
  const inset = 0.8;

  final basePath = Path()
    ..addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(
          inset,
          inset,
          size.width - (inset * 2),
          size.height - (inset * 2),
        ),
        const Radius.circular(cornerRadius),
      ),
    );

  final holesPath = Path();
  final topCount = math.max(8, ((size.width - (cornerRadius * 2)) / 9).floor());
  final sideCount = math.max(
    10,
    ((size.height - (cornerRadius * 2)) / 9).floor(),
  );

  for (var index = 0; index < topCount; index++) {
    final t = (index + 0.5) / topCount;
    final x = lerpDouble(cornerRadius + 1, size.width - cornerRadius - 1, t);
    holesPath.addOval(
      Rect.fromCircle(center: Offset(x, inset), radius: notchRadius),
    );
    holesPath.addOval(
      Rect.fromCircle(
        center: Offset(x, size.height - inset),
        radius: notchRadius,
      ),
    );
  }

  for (var index = 0; index < sideCount; index++) {
    final t = (index + 0.5) / sideCount;
    final y = lerpDouble(cornerRadius + 1, size.height - cornerRadius - 1, t);
    holesPath.addOval(
      Rect.fromCircle(center: Offset(inset, y), radius: notchRadius),
    );
    holesPath.addOval(
      Rect.fromCircle(
        center: Offset(size.width - inset, y),
        radius: notchRadius,
      ),
    );
  }

  return Path.combine(PathOperation.difference, basePath, holesPath);
}

double lerpDouble(double start, double end, double t) {
  return start + ((end - start) * t);
}

Color colorFromHex(String hex) {
  final cleaned = hex.replaceFirst('#', '');
  final value = int.parse(cleaned, radix: 16);
  return Color(0xFF000000 | value);
}

Color darken(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
  return hsl.withLightness(lightness).toColor();
}

Color lighten(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
  return hsl.withLightness(lightness).toColor();
}
