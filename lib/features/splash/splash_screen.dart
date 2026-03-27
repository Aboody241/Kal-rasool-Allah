import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kal_rasol_allah/core/routes/approuter.dart';
import 'package:kal_rasol_allah/core/theme/apptext_style.dart';
import 'package:kal_rasol_allah/core/theme/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
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
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Gap(120),
            ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(30),
              child: Image.asset(
                'assets/consts/logo.png',
                width: 150,
                height: 150,
              ),
            ),
            Gap(50),
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
                    Text("مرحبًا بك", style: AppTextStyles.title),
                    const Gap(10),
                    Text(
                      "ابدأ رحلتك مع تطبيق قال رسول الله ﷺ",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.subTitle,
                    ),
                  ],
                ),
              ),
            ),

            Spacer(),
            CircularProgressIndicator(
              backgroundColor: AppColors.darkGreen,
              color: AppColors.lightGreen,
              strokeWidth: 5,
            ),
            Gap(100),
          ],
        ),
      ),
    );
  }
}
