import 'dart:math';
import 'package:arabic_font/arabic_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:kal_rasol_allah/core/theme/apptext_style.dart';
import 'package:kal_rasol_allah/core/theme/colors.dart';
import 'package:kal_rasol_allah/features/qibla/presentation/controller/qibla_controller.dart';
import 'package:kal_rasol_allah/features/qibla/presentation/controller/qibla_state.dart';
import 'package:kal_rasol_allah/features/qibla/presentation/widgets/qibla_compass_widget.dart';

class QiblaScreen extends ConsumerStatefulWidget {
  const QiblaScreen({super.key});

  @override
  ConsumerState<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends ConsumerState<QiblaScreen> {
  static const List<String> _backgrounds = [
    'assets/backgrounds/back1.jpg',
    'assets/backgrounds/back2.jpg',
    'assets/backgrounds/back3.jpg',
    'assets/backgrounds/back4.jpg',
    'assets/backgrounds/back5.jpg',
  ];

  late final String _selectedBackground;

  @override
  void initState() {
    super.initState();
    _selectedBackground = _backgrounds[Random().nextInt(_backgrounds.length)];
  }

  @override
  Widget build(BuildContext context) {
    final status =
        ref.watch(qiblaControllerProvider.select((s) => s.status));

    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      body: Stack(
        children: [
          // ---- Background image ----
          Positioned.fill(
            child: Image.asset(
              _selectedBackground,
              fit: BoxFit.cover,
            ),
          ),

          // ---- Dark overlay ----
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.55)),
          ),

          // ---- Content ----
          SafeArea(
            child: Column(
              children: [
                // ---- AppBar ----
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new,
                            color: AppColors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'القبلة',
                        style: AppTextStyles.title
                            .copyWith(color: AppColors.white),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                // ---- Body ----
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: _buildBody(status),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(QiblaStatus status) {
    return switch (status) {
      QiblaStatus.initial || QiblaStatus.loading => _buildLoading(),
      QiblaStatus.error => _buildError(),
      QiblaStatus.ready => _buildCompass(),
    };
  }

  // ---- Loading State ----
  Widget _buildLoading() {
    return Center(
      key: const ValueKey('loading'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              color: AppColors.primaryGreen,
              strokeWidth: 3,
            ),
          ),
          const Gap(24),
          const Text(
            'جارٍ تحديد موقعك...',
            style: TextStyle(
              fontFamily: ArabicFont.cairo,
              color: AppColors.white,
              fontSize: 18,
            ),
          ),
          const Gap(8),
          Text(
            'يرجى التأكد من تفعيل خدمة GPS',
            style: TextStyle(
              fontFamily: ArabicFont.cairo,
              color: AppColors.mediumGray,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ---- Error State ----
  Widget _buildError() {
    final errorMessage =
        ref.read(qiblaControllerProvider).errorMessage ?? 'خطأ غير معروف';

    return Center(
      key: const ValueKey('error'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_off_rounded,
                size: 56,
                color: Colors.redAccent,
              ),
            ),
            const Gap(20),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: ArabicFont.cairo,
                color: AppColors.white,
                fontSize: 16,
                height: 1.6,
              ),
            ),
            const Gap(28),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50)),
              ),
              onPressed: () =>
                  ref.read(qiblaControllerProvider.notifier).retry(),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(
                'إعادة المحاولة',
                style: TextStyle(
                  fontFamily: ArabicFont.cairo,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---- Ready / Compass State ----
  Widget _buildCompass() {
    return Center(
      key: const ValueKey('compass'),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Instruction text
          const Text(
            'اتجه نحو القبلة',
            style: TextStyle(
              fontFamily: ArabicFont.amiri,
              fontSize: 22,
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Gap(8),
          Text(
            'وجّه هاتفك حتى يشير السهم للأمام',
            style: TextStyle(
              fontFamily: ArabicFont.cairo,
              fontSize: 14,
              color: AppColors.mediumGray,
            ),
          ),
          const Gap(40),

          // The compass
          const QiblaCompassWidget(),

          const Gap(40),

          // Accuracy hint
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 16, color: AppColors.mediumGray),
              const Gap(6),
              Text(
                'ابتعد عن المعادن لدقة أفضل',
                style: TextStyle(
                  fontFamily: ArabicFont.cairo,
                  fontSize: 13,
                  color: AppColors.mediumGray,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
