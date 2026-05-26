import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kal_rasol_allah/core/theme/apptext_style.dart';
import 'package:kal_rasol_allah/core/theme/colors.dart';
import 'package:kal_rasol_allah/core/widgets/custom_buttons.dart';

class ShareButton extends StatelessWidget {
  const ShareButton({super.key, required this.isDark, required this.ontap});

  final bool isDark;

  final VoidCallback ontap;

  @override
  Widget build(BuildContext context) {
    return Container(
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
        ontap: ontap,
      ),
    );
  }
}
