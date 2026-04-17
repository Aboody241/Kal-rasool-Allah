import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:kal_rasol_allah/controllers/theme/theme_riverPod.dart';
import 'package:kal_rasol_allah/core/theme/apptext_style.dart';
import 'package:kal_rasol_allah/core/theme/colors.dart';

class PagesTitle extends ConsumerWidget {
  const PagesTitle({super.key, required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(ThemeRiverPod);
    return Column(
      children: [
        // ✅ Header
        Text(
          title,
          style: AppTextStyles.title.copyWith(
            color: isDark ? AppColors.white : AppColors.card,
          ),
        ),
        const Gap(8),
        Text(
          subtitle,
          style: AppTextStyles.subTitle.copyWith(color: AppColors.darkGray),
        ),
        const Gap(30),
      ],
    );
  }
}
