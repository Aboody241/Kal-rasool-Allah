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

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(ThemeRiverPod);

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
                        Text('اضف للمفضلة', style: AppTextStyles.buttont),
                        const Gap(5),
                        const Icon(
                          Icons.favorite_border_rounded,
                          size: 25,
                          color: AppColors.lightGray,
                        ),
                      ],
                    ),
                  ),
                  ontap: () {
                    // TODO: Add to favorites functionality
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
