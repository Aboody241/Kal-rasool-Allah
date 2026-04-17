import 'package:arabic_font/arabic_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:kal_rasol_allah/controllers/theme/theme_riverPod.dart';
import 'package:kal_rasol_allah/core/theme/apptext_style.dart';
import 'package:kal_rasol_allah/core/theme/colors.dart';
import 'package:kal_rasol_allah/core/widgets/custom_buttons.dart';
import 'package:kal_rasol_allah/features/home/widgets/home_appbar.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static final _greenBarDecoration = BoxDecoration(
    color: AppColors.primaryGreen,
    borderRadius: BorderRadius.circular(50),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(ThemeRiverPod);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(58),
        child: const HomeAppbar(),
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 28,
                    horizontal: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.card : AppColors.lightGray,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? AppColors.secondary
                          : AppColors.mediumGray,
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
                      Text(
                        'قال رسول الله صلي الله عليه وسلم التبسم في وجه اخيك صدقة',
                        style: ArabicTextStyle(
                          fontSize: 32,
                          arabicFont: ArabicFont.amiri,
                          color: isDark ? AppColors.offWhite : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Gap(30),
                      Text(
                        'رواه مُسلم',
                        style: TextStyle(
                          fontFamily: ArabicFont.amiri,
                          color: AppColors.gold,
                          fontWeight: FontWeight.w600,
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
                ),
                const Gap(50),
                PrimaryButton(
                  widget: Center(
                    child: Text('تم التطبيق', style: AppTextStyles.buttont),
                  ),
                  ontap: () {},
                ),
                const Gap(20),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? AppColors.secondary
                          : const Color.fromARGB(255, 169, 169, 177),
                      width: 2.5,
                    ),
                  ),
                  child: PrimaryButton(
                    widget: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'مشاركة',
                          style: AppTextStyles.buttont.copyWith(
                            color: isDark ? AppColors.offWhite : AppColors.card,
                          ),
                        ),
                        const Gap(5),
                        Icon(
                          Icons.share,
                          color: isDark ? AppColors.white : AppColors.card,
                          size: 22,
                        ),
                      ],
                    ),
                    backGround: isDark ? AppColors.card : AppColors.offWhite,
                    ontap: () {},
                  ),
                ),
                const Gap(20),
                Text('إضغط عند تطبيق سُنة اليوم', style: AppTextStyles.small),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
