import 'package:flutter/material.dart';
import 'package:arabic_font/arabic_font.dart';
import 'colors.dart';

class AppTextStyles {
  // 🟢 Title كبير
  static TextStyle title = ArabicTextStyle(
    arabicFont: ArabicFont.cairo,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );

  // 🟢 Subtitle
  static TextStyle subTitle = ArabicTextStyle(
    arabicFont: ArabicFont.cairo,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.lightGray,
  );

  // 🟢 Body Text
  static TextStyle body = ArabicTextStyle(
    arabicFont: ArabicFont.cairo,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.white,
  );

  // 🟢 Small Text
  static TextStyle small = ArabicTextStyle(
    arabicFont: ArabicFont.amiri,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.mutedGray,
  );

  // 🟢 Button Text
  static TextStyle button = ArabicTextStyle(
    arabicFont: ArabicFont.cairo,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );
  static TextStyle buttont = ArabicTextStyle(
    arabicFont: ArabicFont.cairo,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.white,
  );
}
