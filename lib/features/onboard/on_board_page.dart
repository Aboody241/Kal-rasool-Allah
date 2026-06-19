import 'dart:ui';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:kal_rasol_allah/controllers/theme/theme_riverPod.dart';
import 'package:kal_rasol_allah/core/const/consts.dart';
import 'package:kal_rasol_allah/core/routes/approuter.dart';
import 'package:kal_rasol_allah/core/theme/apptext_style.dart';
import 'package:kal_rasol_allah/core/theme/colors.dart';
import 'package:kal_rasol_allah/core/widgets/custom_buttons.dart';

class OnboardScreen extends ConsumerStatefulWidget {
  const OnboardScreen({super.key});

  @override
  ConsumerState<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends ConsumerState<OnboardScreen> {
  double currentIndex = 0;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  final List<OnboardModel> onboardData = [
    OnboardModel(
      icon: Icons.menu_book_rounded,
      title: 'حَديث يومي',
      subtitle:
          'استقبل كل يوم بحديث نبوي شريف لتكون على خطى رسولنا الكريم مُحمد ﷺ',
      iconColor: AppColors.primaryGreen,
    ),
    OnboardModel(
      icon: Icons.local_fire_department_outlined,
      title: 'حافظ على التسلسل',
      subtitle: 'تابع مدى التزامك اليومي واحصل على سلسلة من الأيام المتتالية',
      iconColor: Colors.orange,
    ),
    OnboardModel(
      icon: Icons.calendar_month_outlined,
      title: 'سجِل إنجازاتك',
      subtitle: 'تابع تاريخك وشاهد تقدمك وسننك المفضلة يوماً بعد يوم',
      iconColor: AppColors.gold,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isLast = currentIndex == onboardData.length - 1;
    final isDark = ref.watch(ThemeRiverPod);

    return Scaffold(
      body: Stack(
        children: [
          // ---- Background Gradient & Blur Orbs (RepaintBoundary optimized for smooth PageView scrolling) ----
          Positioned.fill(
            child: RepaintBoundary(
              child: _OnboardBackground(isDark: isDark),
            ),
          ),

          // ---- Main Content ----
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const Gap(15),
                  
                  // Header Row with App Logo & Skip button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Mini premium App logo decoration
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              Appconsts.mainLogo,
                              width: 38,
                              height: 38,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const Gap(10),
                          Text(
                            'قال رسول الله ﷺ',
                            style: AppTextStyles.button.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : AppColors.card,
                            ),
                          ),
                        ],
                      ),
                      
                      // Skip Button
                      if (!isLast)
                        TextButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            Hive.box('streak_box').put('onboarding_seen', true);
                            Navigator.pushReplacementNamed(
                              context,
                              Approuter.dailyReminderScreen,
                            );
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            backgroundColor: isDark 
                                ? Colors.white.withValues(alpha: 0.05) 
                                : Colors.black.withValues(alpha: 0.03),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'تخطي',
                            style: AppTextStyles.button.copyWith(
                              fontSize: 12,
                              color: isDark ? AppColors.mediumGray : AppColors.mutedGray,
                            ),
                          ),
                        )
                      else
                        const SizedBox(height: 38),
                    ],
                  ),

                  const Gap(40),

                  // Carousel content wrapped in a premium Glassmorphic Card
                  Expanded(
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: onboardData.length,
                      onPageChanged: (index) {
                        HapticFeedback.selectionClick();
                        setState(() => currentIndex = index.toDouble());
                      },
                      itemBuilder: (context, index) {
                        final item = onboardData[index];
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15.0),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.white.withValues(alpha: 0.05)
                                    : Colors.black.withValues(alpha: 0.02),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isDark
                                      ? Colors.white.withValues(alpha: 0.08)
                                      : Colors.black.withValues(alpha: 0.04),
                                  width: 1,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Glowing Medallion for Icon
                                  Container(
                                    width: 130,
                                    height: 130,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          item.iconColor.withValues(alpha: 0.25),
                                          item.iconColor.withValues(alpha: 0.08),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      border: Border.all(
                                        color: item.iconColor.withValues(alpha: 0.4),
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: item.iconColor.withValues(alpha: 0.15),
                                          blurRadius: 20,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      item.icon,
                                      size: 64,
                                      color: item.iconColor,
                                    ),
                                  ),
                                  const Gap(45),
                                  
                                  // Title
                                  Text(
                                    item.title,
                                    style: AppTextStyles.title.copyWith(
                                      color: isDark ? AppColors.white : AppColors.card,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const Gap(18),
                                  
                                  // Subtitle
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 10),
                                    child: Text(
                                      item.subtitle,
                                      style: AppTextStyles.subTitle.copyWith(
                                        color: isDark ? AppColors.mediumGray : AppColors.mutedGray,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w400,
                                        height: 1.8,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const Gap(40),

                  // Elongated rounded dots indicator
                  DotsIndicator(
                    dotsCount: onboardData.length,
                    position: currentIndex,
                    animate: true,
                    animationDuration: const Duration(milliseconds: 200),
                    decorator: DotsDecorator(
                      activeColor: isLast ? AppColors.gold : AppColors.primaryGreen,
                      color: isDark 
                          ? Colors.white.withValues(alpha: 0.15) 
                          : Colors.black.withValues(alpha: 0.08),
                      size: const Size(8.0, 8.0),
                      activeSize: const Size(20.0, 8.0),
                      activeShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                    ),
                  ),
                  
                  const Gap(30),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      backGround: isLast ? AppColors.gold : AppColors.primaryGreen,
                      widget: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isLast ? 'ابدأ الآن' : 'التالي',
                            style: AppTextStyles.buttont.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Gap(8),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppColors.white,
                            size: 16,
                          ),
                        ],
                      ),
                      ontap: () {
                        HapticFeedback.lightImpact();
                        if (!isLast) {
                          pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          // Save onboarding seen preference
                          Hive.box('streak_box').put('onboarding_seen', true);
                          Navigator.pushReplacementNamed(
                            context,
                            Approuter.dailyReminderScreen,
                          );
                        }
                      },
                    ),
                  ),
                  
                  const Gap(40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardModel {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const OnboardModel({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
  });
}

class _OnboardBackground extends StatelessWidget {
  final bool isDark;
  const _OnboardBackground({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ---- Background Gradient ----
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF0C1712), const Color(0xFF050806)]
                  : [const Color(0xFFF3F7F5), const Color(0xFFE5EDE9)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
        // ---- Floating Blur Orbs ----
        Positioned(
          top: -50,
          left: -50,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primaryGreen.withValues(alpha: isDark ? 0.18 : 0.12),
                  AppColors.primaryGreen.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          right: -100,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.gold.withValues(alpha: isDark ? 0.15 : 0.10),
                  AppColors.gold.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
