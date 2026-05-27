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

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(ThemeRiverPod);
    final homeState = ref.watch(homeProvider);
    final homeNotifier = ref.read(homeProvider.notifier);

    final hasHadith = homeState.ahadith.isNotEmpty;
    final currentHadith = hasHadith ? homeState.ahadith[homeState.currentIndex] : null;
    final isFavorite = hasHadith && currentHadith != null && homeNotifier.isFavorite(currentHadith['id']);

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
                const HomeHadithCard(),
                const Gap(50),
                
                PrimaryButton(
                  widget: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isFavorite ? 'أزل من المفضلة' : 'اضف للمفضلة', 
                          style: AppTextStyles.buttont,
                        ),
                        const Gap(5),
                        Icon(
                          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          size: 25,
                          color: isFavorite ? Colors.red : AppColors.lightGray,
                        ),
                      ],
                    ),
                  ),
                  ontap: () {
                    if (hasHadith && currentHadith != null) {
                      homeNotifier.toggleFavorite(currentHadith['id']);
                      
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isFavorite ? 'تمت الإزالة من المفضلة' : 'تمت الإضافة للمفضلة',
                            style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          backgroundColor: isFavorite
                              ? Colors.grey.shade800
                              : AppColors.primaryGreen,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          duration: const Duration(seconds: 2),
                        ),
                      );
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
