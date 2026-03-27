import 'package:arabic_font/arabic_font.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kal_rasol_allah/core/const/consts.dart';
import 'package:kal_rasol_allah/core/theme/apptext_style.dart';
import 'package:kal_rasol_allah/core/theme/colors.dart';
import 'package:kal_rasol_allah/core/widgets/custom_buttons.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.black,
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10), // ✅
              child: Image.asset(Appconsts.mainLogo, height: 50, width: 50),
            ),
            const Gap(10), // ✅ const
            Text(
              'قال رسول الله',
              style: AppTextStyles.small.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.mediumGray,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 5,
              ), // ✅ const
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColors.gold),
              ),
              child: Row(
                children: [
                  Text(
                    '5',
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 20,
                    ),
                  ),
                  const Gap(5), // ✅ const
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
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity, // ✅ infinity بدل maxFinite
                  padding: const EdgeInsets.symmetric(
                    vertical: 35,
                    horizontal: 12,
                  ), // ✅ const
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.secondary, width: 2.5),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 4,
                        width: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                      const Gap(20), // ✅ const
                      Text(
                        'قال رسول الله صلي الله عليه وسلم التبسم في وجه اخيك صدقة',
                        style: ArabicTextStyle(
                          fontSize: 32,
                          arabicFont: ArabicFont.amiri,
                          color: AppColors.offWhite,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const Gap(30), // ✅ const
                      Text(
                        'رواه مُسلم',
                        style: TextStyle(
                          fontFamily: ArabicFont.amiri,
                          color: AppColors.gold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Gap(20), // ✅ const
                      Container(
                        height: 4,
                        width: 80,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(50),
                        ),
                      ),
                    ],
                  ),
                ),
                const Gap(50), // ✅ const
                PrimaryButton(
                  widget: Center(
                    child: Text('تم التطبيق', style: AppTextStyles.buttont),
                  ),
                  ontap: () {},
                ),
                const Gap(20), // ✅ const
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.secondary, width: 2.5),
                  ),
                  child: PrimaryButton(
                    widget: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('مشاركة', style: AppTextStyles.buttont),
                        const Gap(5), // ✅ const
                        const Icon(
                          Icons.share,
                          color: AppColors.white,
                          size: 22,
                        ),
                      ],
                    ),
                    backGround: AppColors.card,
                    ontap: () {},
                  ),
                ),
                const Gap(20), // ✅ const
                Text('إضغط عند تطبيق سُنة اليوم', style: AppTextStyles.small),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
