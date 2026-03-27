import 'package:arabic_font/arabic_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:kal_rasol_allah/core/const/consts.dart';
import 'package:kal_rasol_allah/core/theme/apptext_style.dart';
import 'package:kal_rasol_allah/core/theme/colors.dart';
import 'package:kal_rasol_allah/core/widgets/custom_buttons.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState(); // ✅ اسم صح
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
              borderRadius: BorderRadiusGeometry.circular(10),
              child: Image.asset(
                // ✅ شيلنا الـ Row الزيادة
                Appconsts.mainLogo,
                height: 50,
                width: 50,
              ),
            ),
            Gap(10),
            Text(
              'قال رسول الله',
              style: AppTextStyles.small.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.mediumGray,
              ),
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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
                  Gap(5),
                  Icon(
                    Icons.local_fire_department,
                    size: 28,
                    color: Colors.orange,
                  ),
                ],
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),

      // ✅ Center بدل Column عشان الصورة تبان في النص
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: double.maxFinite,
                padding: EdgeInsets.symmetric(vertical: 35, horizontal: 12),
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
                    Gap(20),
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
                    Gap(30),
                    Text(
                      'رواه مُسلم',
                      style: TextStyle(
                        fontFamily: ArabicFont.amiri,
                        color: AppColors.gold,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Gap(20),
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
              Gap(50),
              PrimaryButton(
                widget: Center(
                  child: Text('تم التطبيق', style: AppTextStyles.buttont),
                ),
                ontap: () {},
              ),
              Gap(20),
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
                      Gap(5),
                      Icon(Icons.share, color: AppColors.white, size: 22),
                    ],
                  ),
                  backGround: AppColors.card,
                  ontap: () {},
                ),
              ),
              Gap(20),
              Text('إضغط عند تطبيق سُنة اليوم', style: AppTextStyles.small),
            ],
          ),
        ),
      ),
    );
  } 
}
