import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kal_rasol_allah/controllers/theme/theme_riverPod.dart';
import 'package:kal_rasol_allah/core/theme/colors.dart';

class ContainerBox extends ConsumerWidget {
  const ContainerBox({super.key, required this.child, required this.padding});

  final Widget child;
  final EdgeInsetsGeometry padding;

  static final _decoration = BoxDecoration(
    color: AppColors.card,
    border: Border.all(width: 2, color: AppColors.secondary),
    borderRadius: BorderRadius.circular(20),
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(ThemeRiverPod);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightGray,
        border: Border.all(
          width: 2,
          color: isDark ? AppColors.secondary : AppColors.mediumGray,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}
