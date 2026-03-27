import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:kal_rasol_allah/core/const/consts.dart';
import 'package:kal_rasol_allah/core/routes/approuter.dart';
import 'package:kal_rasol_allah/core/theme/apptext_style.dart';
import 'package:kal_rasol_allah/core/theme/colors.dart';
import 'package:kal_rasol_allah/core/widgets/custom_buttons.dart';

class OnboardScreen extends StatefulWidget {
  const OnboardScreen({super.key});

  @override
  State<OnboardScreen> createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  double currentIndex = 0;
  late PageController pageController; // ✅ إصلاح الـ typo

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  final List<OnboardModel> onboardData = [
    OnboardModel(
      icon: Icons.menu_book_rounded,
      title: 'حَديث يومي',
      subtitle:
          'إستقبل كل يوم بحديث نبوي شريف لتكون علي خطى رسولنا الكريم مُحمد ﷺ',
      iconColor: AppColors.primaryGreen,
    ),
    OnboardModel(
      icon: Icons.local_fire_department_outlined,
      title: 'حافظ علي التسلسل',
      subtitle: 'تابع مدى التزامك اليومي واحصل على سلسة من الايام المتتالية',
      iconColor: Colors.orange,
    ),
    OnboardModel(
      icon: Icons.calendar_month_outlined,
      title: 'سجِل إنجازاتك',
      subtitle: 'تابع تاريخك وشاهد تقدمك يوماً بعد يوم',
      iconColor: AppColors.white,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isLast = currentIndex == onboardData.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            children: [
              const Gap(10),

              // ✅ شيلنا الـ Container الفاضي
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(Appconsts.mainLogo, width: 100, height: 100),
              ),

              // ✅ شيلنا Gap(0)
              Directionality(
                textDirection: TextDirection.rtl,
                child: Expanded(
                  child: PageView.builder(
                    controller: pageController, // ✅
                    itemCount: onboardData.length,
                    onPageChanged: (index) {
                      setState(() => currentIndex = index.toDouble());
                    },
                    itemBuilder: (context, index) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            onboardData[index].icon,
                            size: 100,
                            color: onboardData[index].iconColor,
                          ),
                          const Gap(50), // ✅ const
                          Text(
                            onboardData[index].title,
                            style: AppTextStyles.title,
                          ),
                          const Gap(20), // ✅ const
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: Text(
                              onboardData[index].subtitle,
                              style: AppTextStyles.subTitle.copyWith(
                                color: AppColors.darkGray,
                                height: 2,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),

              DotsIndicator(
                dotsCount: onboardData.length,
                position: currentIndex,
                animate: true,
                animationDuration: const Duration(
                  milliseconds: 200,
                ), // ✅ const
                decorator: DotsDecorator(activeColor: AppColors.primaryGreen),
              ),
              const Gap(30), // ✅ const
            ],
          ),
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 50, left: 20, right: 20),
        child: SizedBox(
          width: double.infinity,
          child: PrimaryButton(
            widget: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isLast ? 'ابدأ الآن' : 'التالي', // ✅ نص ديناميكي
                  style: AppTextStyles.buttont,
                ),
                const Gap(5), // ✅ const

                Icon(
                  Icons.arrow_forward_ios_rounded, // ✅ اتجاه صح
                  color: AppColors.white,
                ),
              ],
            ),
            ontap: () {
              if (!isLast) {
                pageController.nextPage(
                  duration: const Duration(milliseconds: 300), // ✅ const
                  curve: Curves.easeInOut,
                );
              } else {
                Navigator.pushReplacementNamed(context, Approuter.mainNavbar);
              }
            },
          ),
        ),
      ),
    );
  }
}

// ✅ إصلاح typo في اسم الـ Model
class OnboardModel {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const OnboardModel({
    // ✅ const constructor
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
  });
}
