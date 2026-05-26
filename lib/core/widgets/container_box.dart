import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kal_rasol_allah/controllers/theme/theme_riverPod.dart';
import 'package:kal_rasol_allah/core/theme/colors.dart';

class ContainerBox extends ConsumerWidget {
  const ContainerBox({super.key, required this.child, required this.padding, this.borderRadius, this.margin});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry? margin;


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(ThemeRiverPod);
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.card : AppColors.lightGray,
        border: Border.all(
          width: 2,
          color: isDark ? AppColors.secondary : AppColors.mediumGray,
        ),
        borderRadius:borderRadius?? BorderRadius.circular(20),
      ),
      child: child,
    );
  }
}
