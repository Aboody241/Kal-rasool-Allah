import 'dart:async';
import 'dart:convert';

import 'package:arabic_font/arabic_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:kal_rasol_allah/controllers/theme/theme_riverPod.dart';
import 'package:kal_rasol_allah/core/theme/apptext_style.dart';
import 'package:kal_rasol_allah/core/theme/colors.dart';
import 'package:kal_rasol_allah/core/widgets/custom_buttons.dart';
import 'package:kal_rasol_allah/features/home/widgets/home_appbar.dart';
import 'package:kal_rasol_allah/features/home/widgets/share_button.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  static final _greenBarDecoration = BoxDecoration(
    color: AppColors.primaryGreen,
    borderRadius: BorderRadius.circular(50),
  );

  List<dynamic> _ahadith = [];
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadAndStart();
  }

  Future<void> _loadAndStart() async {
    final String data = await rootBundle.loadString(
      'assets/content/ahadith.json',
    );
    final List<dynamic> ahadith = jsonDecode(data);

    if (!mounted) return;

    setState(() {
      _ahadith = ahadith;
      _currentIndex = 0;
    });

    // ابدأ التايمر بعد ما الداتا تتحمل
    _timer = Timer.periodic(const Duration(days: 1), (_) {
      if (!mounted) return;
      setState(() {
        _currentIndex = (_currentIndex + 1) % _ahadith.length;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // مهم جداً عشان ما يحصل memory leak
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(ThemeRiverPod);

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(58),
        child: const HomeAppbar(),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.only(
                    bottom: 20,
                    right: 10,
                    left: 10,
                    top: 20,
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
                      // Row(
                      //   mainAxisAlignment: .spaceBetween,
                      //   children: [
                      //     IconButton(
                      //       onPressed: () {},
                      //       icon: Icon(Icons.bookmark_border_rounded, size: 26),
                      //     ),

                      //     IconButton(
                      //       onPressed: () {},
                      //       icon: Icon(
                      //         Icons.bookmark_border_rounded,
                      //         size: 0,
                      //         color: isDark
                      //             ? AppColors.card
                      //             : AppColors.lightGray,
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      Container(
                        height: 4,
                        width: 80,
                        decoration: _greenBarDecoration,
                      ),
                      const Gap(25),

                      // عرض الحديث
                      _ahadith.isEmpty
                          ? const CircularProgressIndicator()
                          : AnimatedSwitcher(
                              duration: const Duration(milliseconds: 600),
                              child: Column(
                                // المفتاح ده بيخلي الأنيميشن يشتغل صح عند التغيير
                                key: ValueKey(_currentIndex),
                                children: [
                                  Text(
                                    'قال رسول الله ﷺ ',
                                    style: ArabicTextStyle(
                                      fontSize: 20,
                                      arabicFont: ArabicFont.amiri,
                                      color: isDark
                                          ? AppColors.mediumGray
                                          : Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Gap(14),
                                  Text(
                                    _ahadith[_currentIndex]['text'],
                                    style: ArabicTextStyle(
                                      fontSize: 27,
                                      arabicFont: ArabicFont.amiri,
                                      color: isDark
                                          ? AppColors.offWhite
                                          : Colors.black,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const Gap(30),
                                  Text(
                                    _ahadith[_currentIndex]['source'],
                                    style: TextStyle(
                                      fontFamily: ArabicFont.amiri,
                                      color: AppColors.gold,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
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
                    child: Row(
                      mainAxisAlignment: .center,
                      children: [
                        Text('اضف للمفضلة', style: AppTextStyles.buttont),
                        Gap(5),
                        Icon(
                          Icons.favorite_border_rounded,
                          size: 25,
                          color: AppColors.lightGray,
                        ),
                      ],
                    ),
                  ),
                  ontap: () {},
                ),
                const Gap(20),
                ShareButton(
                  isDark: isDark,
                  ontap: () {
                    // TODO: Share Action
                  },
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
