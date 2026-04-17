import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:kal_rasol_allah/controllers/theme/theme_riverPod.dart';
import 'package:kal_rasol_allah/core/theme/apptext_style.dart';
import 'package:kal_rasol_allah/core/theme/colors.dart';
import 'package:kal_rasol_allah/core/widgets/container_box.dart';
import 'package:kal_rasol_allah/core/widgets/pages_title.dart';

class ToolsScreen extends ConsumerWidget {
  const ToolsScreen({super.key});

  static const List<_ToolItem> _toolItems = [
    _ToolItem(
      title: 'السبحة',
      icon: _IconWidget(
        imagepath: 'assets/icnos/sebha_icon.svg',
        width: 50,
        height: 50,
      ),
    ),
    _ToolItem(
      title: 'الأدعية',
      icon: _IconWidget(
        imagepath: 'assets/icnos/duaa_icon.svg',
        width: 50,
        height: 50,
      ),
    ),
    _ToolItem(
      title: 'اسماء الله الحسنى',
      icon: _IconWidget(
        imagepath: 'assets/icnos/smaa_allah.svg',
        width: 50,
        height: 50,
      ),
    ),
    _ToolItem(
      title: 'القِبلة',
      icon: _IconWidget(
        imagepath: 'assets/icnos/qibla_icon.svg',
        width: 50,
        height: 50,
      ),
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(ThemeRiverPod);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: Column(
              children: [
                const Gap(10),

        const    PagesTitle(title: 'الأدوات', subtitle: 'جزء للأدعية والأذكار وبعض الادوات'),
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.only(top: 50), // ✅ const
                    itemCount: _toolItems.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          // ✅ const
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          crossAxisCount: 2,
                        ),
                    itemBuilder: (context, index) {
                      final item = _toolItems[index];
                      return InkWell(
                        // ✅ ربطنا الـ onTap
                        onTap: item.onTap,
                        borderRadius: BorderRadius.circular(12),
                        child: ContainerBox(
                          padding: const EdgeInsets.symmetric(), // ✅ const
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              item.icon,
                              const Gap(20), // ✅ const
                              Text(item.title, style: AppTextStyles.body),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IconWidget extends StatelessWidget {
  const _IconWidget({required this.imagepath, this.width, this.height});

  final String imagepath;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(imagepath, width: width, height: height);
  }
}

class _ToolItem {
  final String title;
  final Widget icon;
  final VoidCallback? onTap; // ✅ nullable عشان مش كل item لازم يكون عنده action

  const _ToolItem({
    // ✅ const constructor
    required this.title,
    required this.icon,
    this.onTap,
  });
}
