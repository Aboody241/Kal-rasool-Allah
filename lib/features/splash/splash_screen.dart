import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:kal_rasol_allah/controllers/theme/theme_riverPod.dart';
import 'package:kal_rasol_allah/core/routes/approuter.dart';
import 'package:kal_rasol_allah/core/theme/apptext_style.dart';
import 'package:kal_rasol_allah/core/theme/colors.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool isSlide = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => isSlide = true); // ✅ setState so UI rebuilds
      }
    });

    // Navigate after 3 seconds
    Future.delayed(const Duration(milliseconds: 2700), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, Approuter.onboardScreen);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(ThemeRiverPod);
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const Gap(120),
            ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(30),
              child: Image.asset(
                'assets/consts/logo.jpg',
                width: 150,
                height: 150,
              ),
            ),
            const Gap(50),
            AnimatedSlide(
              // ✅ Start below, animate up to natural position
              offset: Offset(0, isSlide ? 0 : 0.3),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOut, // ✅ Smoother feel
              child: AnimatedOpacity(
                // ✅ Bonus: fade in alongside slide
                opacity: isSlide ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 1000),
                child: Column(
                  children: [
                    Text(
                      "مرحبًا بك",
                      style: AppTextStyles.title.copyWith(
                        color: isDark ? AppColors.white : AppColors.card,
                      ),
                    ),
                    const Gap(10),
                    Text(
                      "ابدأ رحلتك مع تطبيق قال رسول الله ﷺ",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.subTitle.copyWith(
                        color: isDark
                            ? AppColors.lightGray
                            : AppColors.darkGray,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),
            const CircularProgressIndicator(
              backgroundColor: AppColors.darkGreen,
              color: AppColors.lightGreen,
              strokeWidth: 5,
            ),
            const Gap(100),
          ],
        ),
      ),
    );
  }
}
