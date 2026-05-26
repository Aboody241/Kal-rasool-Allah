import 'package:arabic_font/arabic_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:kal_rasol_allah/controllers/theme/theme_riverPod.dart';
import 'package:kal_rasol_allah/core/theme/colors.dart';
import 'package:kal_rasol_allah/features/home/controllers/home_provider.dart';

class HomeHadithCard extends ConsumerWidget {
  const HomeHadithCard({super.key});

  static final _greenBarDecoration = BoxDecoration(
    color: AppColors.primaryGreen,
    borderRadius: BorderRadius.circular(50),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(ThemeRiverPod);
    final homeState = ref.watch(homeProvider);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        bottom: 20,
        right: 10,
        left: 10,
        top: 20,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightGray,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.secondary : AppColors.mediumGray,
          width: 2.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            height: 4,
            width: 80,
            decoration: _greenBarDecoration,
          ),
          const Gap(25),

          // عرض الحديث
          homeState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : homeState.errorMessage != null
                  ? Text(
                      homeState.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    )
                  : homeState.ahadith.isEmpty
                      ? const SizedBox.shrink()
                      : AnimatedSwitcher(
                          duration: const Duration(milliseconds: 600),
                          child: Column(
                            key: ValueKey(homeState.currentIndex),
                            children: [
                              Text(
                                'قال رسول الله ﷺ ',
                                style: ArabicTextStyle(
                                  fontSize: 20,
                                  arabicFont: ArabicFont.amiri,
                                  color: isDark ? AppColors.mediumGray : Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Gap(14),
                              Text(
                                homeState.ahadith[homeState.currentIndex]['text'],
                                style: ArabicTextStyle(
                                  fontSize: 27,
                                  arabicFont: ArabicFont.amiri,
                                  color: isDark ? AppColors.offWhite : Colors.black,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const Gap(30),
                              Text(
                                homeState.ahadith[homeState.currentIndex]['source'],
                                style: const TextStyle(
                                  fontFamily: ArabicFont.amiri,
                                  color: AppColors.gold,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

          const Gap(25),
          Container(
            height: 4,
            width: 80,
            decoration: _greenBarDecoration,
          ),
        ],
      ),
    );
  }
}
