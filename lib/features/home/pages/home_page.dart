import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:kal_rasol_allah/controllers/theme/theme_riverPod.dart';
import 'package:kal_rasol_allah/core/theme/apptext_style.dart';
import 'package:kal_rasol_allah/core/theme/colors.dart';
import 'package:kal_rasol_allah/core/widgets/custom_buttons.dart';
import 'package:kal_rasol_allah/features/home/widgets/home_appbar.dart';
import 'package:kal_rasol_allah/features/home/widgets/home_hadith_card.dart';
import 'package:kal_rasol_allah/features/home/widgets/share_button.dart';
import 'package:kal_rasol_allah/features/home/controllers/home_provider.dart';
import 'package:kal_rasol_allah/features/home/controllers/streak_provider.dart';
import 'package:lottie/lottie.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(ThemeRiverPod);
    final homeState = ref.watch(homeProvider);
    final homeNotifier = ref.read(homeProvider.notifier);
    final streakState = ref.watch(streakProvider);

    final hasSunnah = homeState.todaySunnahs.isNotEmpty;
    final currentSunnah = hasSunnah ? homeState.todaySunnahs[homeState.currentIndex] : null;
    final isCompleted = hasSunnah && currentSunnah != null && currentSunnah.isCompleted;

    if (streakState.streakJustIncremented) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: true,
          builder: (context) {
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Lottie.asset(
                'assets/consts/Streak complete.json',
                repeat: false,
                onLoaded: (composition) {
                  Future.delayed(composition.duration, () {
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  });
                },
              ),
            );
          },
        );
        ref.read(streakProvider.notifier).markAnimationPlayed();
      });
    }

    return Scaffold(
      appBar: const PreferredSize(
        preferredSize: Size.fromHeight(58),
        child: HomeAppbar(),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Gap(10),
                // Streak Card
                // Container(
                //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                //   decoration: BoxDecoration(
                //     color: isDark ? AppColors.card : Colors.white,
                //     borderRadius: BorderRadius.circular(15),
                //     border: Border.all(
                //       color: AppColors.primaryGreen.withOpacity(0.3),
                //       width: 1,
                //     ),
                //     boxShadow: [
                //       BoxShadow(
                //         color: Colors.black.withOpacity(0.05),
                //         blurRadius: 10,
                //         offset: const Offset(0, 4),
                //       ),
                //     ],
                //   ),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                //     children: [
                //       Column(
                //         children: [
                //           const Text('🔥 متتالية', style: TextStyle(fontSize: 12, color: Colors.grey, fontFamily: 'Cairo')),
                //           Text('${streakState.currentStreak} يوم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryGreen, fontFamily: 'Cairo')),
                //         ],
                //       ),
                //       Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.3)),
                //       Column(
                //         children: [
                //           const Text('👑 الرقم القياسي', style: TextStyle(fontSize: 12, color: Colors.grey, fontFamily: 'Cairo')),
                //           Text('${streakState.longestStreak} يوم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber, fontFamily: 'Cairo')),
                //         ],
                //       ),
                //     ],
                //   ),
                // ),
                const Gap(20),
                const HomeHadithCard(),
                const Gap(50),
                
                if (isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: AppColors.primaryGreen, width: 1.5),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'أتممت هذه السُنة اليوم، تقبل الله!',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                            fontSize: 16,
                          ),
                        ),
                        Gap(10),
                        Icon(Icons.check_circle_rounded, color: AppColors.primaryGreen),
                      ],
                    ),
                  )
                else
                  PrimaryButton(
                    widget: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'أتممت السُنة', 
                            style: AppTextStyles.buttont,
                          ),
                          Gap(5),
                          Icon(Icons.check_circle_outline_rounded, size: 25, color: Colors.white),
                        ],
                      ),
                    ),
                    ontap: () {
                      if (hasSunnah) {
                        homeNotifier.completeCurrentSunnah();
                        // Animation is triggered by streakState listener automatically
                      }
                    },
                  ),
                
                const Gap(20),
                
                ShareButton(
                  isDark: isDark,
                  ontap: () {
                    // TODO: Share Action
                  },
                ),
                
                const Gap(20),
                
                Text(
                  'إضغط عند تطبيق سُنة اليوم',
                  style: AppTextStyles.small,
                ),
                
                const Gap(20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
