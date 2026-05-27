import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:kal_rasol_allah/core/theme/colors.dart';
import 'package:kal_rasol_allah/features/qibla/presentation/controller/qibla_controller.dart';

class QiblaCompassWidget extends ConsumerWidget {
  const QiblaCompassWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final finalAngle = ref.watch(
      qiblaControllerProvider.select((s) => s.finalAngle),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 280,
          height: 280,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ---- Outer compass ring ----
              _CompassRing(),

              // ---- Needle ----
              // ✅ استخدام AnimatedRotation أسهل وأكثر استقراراً من TweenAnimationBuilder
              AnimatedRotation(
                turns: finalAngle / 360,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                child: _QiblaNeedle(),
              ),

              // ---- Center dot ----
              Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: AppColors.primaryGreen,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),

        const Gap(24),

        // ---- Distance label ----
        // if (distanceToKaaba != null)
        //   Column(
        //     children: [
        //       Text(
        //         '${distanceToKaaba.toStringAsFixed(0)} كم',
        //         style: const TextStyle(
        //           fontFamily: ArabicFont.cairo,
        //           fontSize: 28,
        //           fontWeight: FontWeight.bold,
        //           color: AppColors.white,
        //         ),
        //       ),
        //       const Text(
        //         'المسافة إلى الكعبة المشرفة',
        //         style: TextStyle(
        //           fontFamily: ArabicFont.cairo,
        //           fontSize: 14,
        //           color: AppColors.mediumGray,
        //         ),
        //       ),
        //     ],
        //   ),
      ],
    );
  }
}

// ---- Compass Ring Widget ----
class _CompassRing extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppColors.primaryGreen.withOpacity(0.6),
          width: 2,
        ),
        gradient: RadialGradient(
          colors: [
            Colors.black.withOpacity(0.5),
            Colors.black.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.25),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: CustomPaint(painter: _CompassTicksPainter()),
    );
  }
}

// ---- Compass Ticks Painter ----
class _CompassTicksPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;
    final paint = Paint()
      ..color = AppColors.primaryGreen.withOpacity(0.5)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 36; i++) {
      final angle = (i * 10) * pi / 180;
      final isMajor = i % 9 == 0;
      final tickLength = isMajor ? 14.0 : 8.0;
      paint.color = isMajor
          ? AppColors.primaryGreen
          : AppColors.primaryGreen.withOpacity(0.4);
      paint.strokeWidth = isMajor ? 2.5 : 1.0;

      final outer = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
      final inner = Offset(
        center.dx + (radius - tickLength) * cos(angle),
        center.dy + (radius - tickLength) * sin(angle),
      );
      canvas.drawLine(inner, outer, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---- Qibla Needle ----
class _QiblaNeedle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40,
      height: 200,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // North (pointing to Qibla) — green
          Expanded(
            child: Container(
              width: 6,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.lightGreen, AppColors.primaryGreen],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(100)),
              ),
            ),
          ),

          // Kaaba icon in the middle
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primaryGreen,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.5),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.mosque_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),

          // South — dimmed
          Expanded(
            child: Container(
              width: 6,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(100),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
