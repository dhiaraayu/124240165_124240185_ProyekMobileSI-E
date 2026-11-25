import 'package:flutter/material.dart';
import '../theme.dart';

/// Latar visual onboarding: mencoba memuat foto dari [assets] (berurutan),
/// dan jika tidak ada satu pun, memakai ilustrasi bawaan bergaya motorsport.
class OnboardingBackdrop extends StatelessWidget {
  final List<String> assets;
  final int variant;

  const OnboardingBackdrop({
    super.key,
    this.assets = const [],
    this.variant = 0,
  });

  Widget _fallback() => CustomPaint(
        painter: _BackdropPainter(variant),
        size: Size.infinite,
      );

  Widget _image(int i) {
    if (i >= assets.length) return _fallback();
    return Image.asset(
      assets[i],
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (context, error, stackTrace) => _image(i + 1),
    );
  }

  @override
  Widget build(BuildContext context) => SizedBox.expand(child: _image(0));
}

class _BackdropPainter extends CustomPainter {
  final int variant;

  _BackdropPainter(this.variant);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final w = size.width;
    final h = size.height;

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2A0D0C), AppTheme.darkBg, Color(0xFF0B0B10)],
          stops: [0.0, 0.55, 1.0],
        ).createShader(rect),
    );

    if (variant == 0) {
      // Garis balap diagonal
      for (int i = 0; i < 6; i++) {
        final x = w * (0.1 + i * 0.17);
        final path = Path()
          ..moveTo(x, 0)
          ..lineTo(x + w * 0.10, 0)
          ..lineTo(x - w * 0.35 + w * 0.10, h * 0.7)
          ..lineTo(x - w * 0.35, h * 0.7)
          ..close();
        canvas.drawPath(
          path,
          Paint()
            ..color = AppTheme.f1Red.withOpacity(i.isEven ? 0.20 : 0.07),
        );
      }
    } else if (variant == 1) {
      // Siluet lintasan jalan raya (Marina Bay style)
      final track = Path()
        ..moveTo(w * 0.12, h * 0.30)
        ..cubicTo(w * 0.30, h * 0.10, w * 0.55, h * 0.12, w * 0.62, h * 0.24)
        ..cubicTo(w * 0.70, h * 0.36, w * 0.92, h * 0.26, w * 0.88, h * 0.42)
        ..cubicTo(w * 0.84, h * 0.58, w * 0.58, h * 0.50, w * 0.46, h * 0.52)
        ..cubicTo(w * 0.30, h * 0.55, w * 0.34, h * 0.40, w * 0.12, h * 0.30)
        ..close();
      canvas.drawPath(
        track,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 14
          ..color = AppTheme.f1Red.withOpacity(0.55)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
      );
      canvas.drawPath(
        track,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4
          ..strokeJoin = StrokeJoin.round
          ..color = AppTheme.f1Red,
      );
      canvas.drawPath(
        track,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = Colors.white.withOpacity(0.5),
      );
    } else {
      // Grid titik halus
      final dot = Paint()..color = Colors.white.withOpacity(0.06);
      for (double x = 16; x < w; x += 24) {
        for (double y = 16; y < h; y += 24) {
          canvas.drawCircle(Offset(x, y), 1.2, dot);
        }
      }
      canvas.drawCircle(
        Offset(w * 0.5, h * 0.3),
        w * 0.55,
        Paint()
          ..shader = RadialGradient(
            colors: [
              AppTheme.f1Red.withOpacity(0.28),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(center: Offset(w * 0.5, h * 0.3), radius: w * 0.55),
          ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BackdropPainter old) => old.variant != variant;
}
