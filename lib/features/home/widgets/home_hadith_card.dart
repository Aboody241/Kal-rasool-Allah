import 'package:arabic_font/arabic_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final homeNotifier = ref.read(homeProvider.notifier);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 20, right: 10, left: 10, top: 20),
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
          Container(height: 4, width: 80, decoration: _greenBarDecoration),
          const Gap(25),

          homeState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : homeState.errorMessage != null
              ? Text(
                  homeState.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                )
              : homeState.todaySunnahs.isEmpty
              ? const SizedBox.shrink()
              : AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  child: Column(
                    key: ValueKey(homeState.currentIndex),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(
                              homeNotifier.isFavorite(
                                    homeState
                                        .todaySunnahs[homeState.currentIndex]
                                        .id,
                                  )
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color:
                                  homeNotifier.isFavorite(
                                    homeState
                                        .todaySunnahs[homeState.currentIndex]
                                        .id,
                                  )
                                  ? Colors.red
                                  : AppColors.mediumGray,
                              size: 26,
                            ),
                            onPressed: () {
                              final id = homeState
                                  .todaySunnahs[homeState.currentIndex]
                                  .id;
                              final isFav = homeNotifier.isFavorite(id);
                              HapticFeedback.lightImpact();
                              homeNotifier.toggleFavorite(id);

                              ScaffoldMessenger.of(context).clearSnackBars();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isFav
                                        ? 'تمت الإزالة من المفضلة'
                                        : 'تمت الإضافة للمفضلة',
                                    style: const TextStyle(
                                      fontFamily: 'Cairo',
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  backgroundColor: isFav
                                      ? Colors.grey.shade800
                                      : AppColors.primaryGreen,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      const Gap(15),
                      Text(
                        homeState.todaySunnahs[homeState.currentIndex].title,
                        style: ArabicTextStyle(
                          fontSize: 22,
                          arabicFont: ArabicFont.amiri,
                          color: isDark ? AppColors.mediumGray : Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Gap(14),
                      Text(
                        homeState
                            .todaySunnahs[homeState.currentIndex]
                            .description,
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
                        homeState.todaySunnahs[homeState.currentIndex].source,
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
          Container(height: 4, width: 80, decoration: _greenBarDecoration),
        ],
      ),
    );
  }

}
