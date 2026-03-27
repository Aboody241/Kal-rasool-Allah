import 'package:flutter/material.dart';
import 'package:kal_rasol_allah/core/theme/apptext_style.dart';
import 'package:kal_rasol_allah/core/theme/colors.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({super.key, required this.widget, required this.ontap,  this.backGround = AppColors.primaryGreen});

  final Widget widget;
  final VoidCallback ontap;
  final Color backGround;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: backGround,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: ontap,
      child: widget,
    );
  }
}
