import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:kal_rasol_allah/controllers/theme/theme_riverPod.dart';
import 'package:kal_rasol_allah/core/const/consts.dart';
import 'package:kal_rasol_allah/core/routes/approuter.dart';
import 'package:kal_rasol_allah/core/theme/apptext_style.dart';
import 'package:kal_rasol_allah/core/theme/colors.dart';

class HomeAppbar extends ConsumerWidget {
  const HomeAppbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(ThemeRiverPod);
    return AppBar(
      backgroundColor: AppColors.black,
      title: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushReplacementNamed(context, Approuter.splashScreen);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(Appconsts.mainLogo, height: 50, width: 50),
            ),
          ),
          const Gap(10),
          Text(
            'قال رسول الله ﷺ',
            style: AppTextStyles.small.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.mediumGray : AppColors.card,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: isDark ? AppColors.secondary : AppColors.lightGray,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppColors.gold),
            ),
            child: Row(
              children: [
                Text(
                  '5',
                  style: AppTextStyles.small.copyWith(
                    color: isDark ? AppColors.white : AppColors.card,
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
                const Gap(5),
                const Icon(
                  Icons.local_fire_department,
                  size: 28,
                  color: Colors.orange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
