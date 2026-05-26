import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kal_rasol_allah/controllers/theme/theme_riverPod.dart';
import 'package:kal_rasol_allah/core/theme/apptext_style.dart';
import 'package:kal_rasol_allah/core/theme/colors.dart';

class QiblaScreen extends ConsumerWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(ThemeRiverPod);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: isDark ? AppColors.white : AppColors.card,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'القبلة',
                    style: AppTextStyles.title.copyWith(
                      color: isDark ? AppColors.white : AppColors.card,
                    ),
                  ),
                  const SizedBox(width: 48), // alignment helper
                ],
              ),
              const Expanded(
                child: Center(
                  child: SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
