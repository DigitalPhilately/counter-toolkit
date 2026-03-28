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
    final stampColor = colorFromHex(item.stamp.colourHex);
    final tile = SizedBox(
      width: compact ? 112 : 124,
      height: compact ? 168 : 186,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Row(
                children: [
                  Expanded(
                    flex: 67,
                    child: _StampFace(
                      item: item,
                      color: stampColor,
                      compact: compact,
                    ),
                  ),
                  Expanded(
                    flex: 33,
                    child: _BarcodeStrip(
                      seed: item.stamp.label,
                      color: darken(stampColor, 0.18),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (item.count > 1)
            Positioned(
              top: -10,
              right: -8,
              child: _CountBadge(count: item.count),
            ),
          if (item.isPicked)
            Positioned(
              bottom: 10,
              right: 10,
              child: Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFF0F5B57),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 18,
                  color: Colors.white,
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
        borderRadius: BorderRadius.circular(26),
        onTap: onTap,
        child: tile,
      ),
    );
  }
}

class _StampFace extends StatelessWidget {
  const _StampFace({
    required this.item,
    required this.color,
    required this.compact,
  });

  final StampLineItem item;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final faceColor = lighten(color, 0.04);

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            lighten(faceColor, 0.08),
            faceColor,
            darken(faceColor, 0.08),
          ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(compact ? 10 : 12),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _CameoPainter(
                  color: Colors.white.withValues(alpha: 0.18),
                  shadowColor: Colors.black.withValues(alpha: 0.08),
                ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  stampTypeLabel(item.stamp.type),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.stamp.colourName,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.w700,
                      fontSize: compact ? 10 : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.stamp.label,
                    style:
                        (compact
                                ? Theme.of(context).textTheme.titleMedium
                                : Theme.of(context).textTheme.titleLarge)
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              height: 0.95,
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

class _BarcodeStrip extends StatelessWidget {
  const _BarcodeStrip({required this.seed, required this.color});

  final String seed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color, darken(color, 0.12)],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2A29),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Text(
        'x$count',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _PseudoBarcodePainter extends CustomPainter {
  const _PseudoBarcodePainter({required this.seed});

  final String seed;

  @override
  void paint(Canvas canvas, Size size) {
    final cellsAcross = 5;
    final cellsDown = 18;
    final cellWidth = size.width / cellsAcross;
    final cellHeight = size.height / cellsDown;
    final seedValue = seed.codeUnits.fold<int>(
      17,
      (sum, value) => sum * 31 + value,
    );
    var state = seedValue;

    for (var y = 0; y < cellsDown; y++) {
      for (var x = 0; x < cellsAcross; x++) {
        state = (state * 1103515245 + 12345) & 0x7fffffff;
        final isDark = state % 7 > 2;
        final paint = Paint()
          ..color = isDark
              ? Colors.white.withValues(alpha: 0.85)
              : Colors.white.withValues(alpha: 0.18);
        final inset = (state % 3).toDouble() * 0.5;
        final rect = RRect.fromRectAndRadius(
          Rect.fromLTWH(
            x * cellWidth + inset,
            y * cellHeight + inset,
            math.max(2, cellWidth - (inset * 2)),
            math.max(3, cellHeight - (inset * 2)),
          ),
          const Radius.circular(2),
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

class _CameoPainter extends CustomPainter {
  const _CameoPainter({required this.color, required this.shadowColor});

  final Color color;
  final Color shadowColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.52, size.height * 0.42);
    final shoulderPath = Path()
      ..moveTo(size.width * 0.12, size.height * 0.88)
      ..quadraticBezierTo(
        size.width * 0.32,
        size.height * 0.68,
        size.width * 0.54,
        size.height * 0.72,
      )
      ..quadraticBezierTo(
        size.width * 0.84,
        size.height * 0.78,
        size.width * 0.92,
        size.height * 0.98,
      )
      ..lineTo(size.width * 0.08, size.height * 0.98)
      ..close();

    canvas.drawShadow(shoulderPath, shadowColor, 8, true);
    canvas.drawPath(shoulderPath, Paint()..color = color);

    canvas.drawOval(
      Rect.fromCenter(
        center: center,
        width: size.width * 0.38,
        height: size.height * 0.34,
      ),
      Paint()..color = color,
    );

    final profilePath = Path()
      ..moveTo(size.width * 0.55, size.height * 0.22)
      ..quadraticBezierTo(
        size.width * 0.67,
        size.height * 0.26,
        size.width * 0.69,
        size.height * 0.39,
      )
      ..quadraticBezierTo(
        size.width * 0.62,
        size.height * 0.43,
        size.width * 0.63,
        size.height * 0.49,
      )
      ..quadraticBezierTo(
        size.width * 0.55,
        size.height * 0.52,
        size.width * 0.57,
        size.height * 0.59,
      )
      ..quadraticBezierTo(
        size.width * 0.51,
        size.height * 0.59,
        size.width * 0.47,
        size.height * 0.54,
      );

    canvas.drawPath(
      profilePath,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.32)
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _CameoPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.shadowColor != shadowColor;
  }
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
