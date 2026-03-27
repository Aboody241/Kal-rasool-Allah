import 'package:flutter/material.dart';

class AppColors {
  // ================== Backgrounds ==================
  static const Color background = Color(0xFF0A0A0A); // Main background
  static const Color card = Color(0xFF1A1A1A); // Card background
  static const Color secondary = Color(0xFF2A2A2A); // Secondary elements
  static const Color border = Color(0xFF3A3A3A); // Borders & inputs
  static const Color black = Color.fromARGB(0, 0, 0, 0); // Borders & inputs

  // ================== Brand Colors ==================
  static const Color primaryGreen = Color(0xFF2D7A5E);
  static const Color darkGreen = Color(0xFF236E52);
  static const Color lightGreen = Color(0xFF3A9674);
  static const Color gold = Color(0xFFD4AF37);

  // ================== Text Colors ==================
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF5F5F5);
  static const Color lightGray = Color(0xFFE5E5E5);
  static const Color mediumGray = Color(0xFF9CA3AF);
  static const Color darkGray = Color(0xFF6B7280);
  static const Color mutedGray = Color(0xFF71717A);

  // ================== Effects ==================
  static const Color greenGlow = Color.fromRGBO(45, 122, 94, 0.3);
  static const Color strongGreenGlow = Color.fromRGBO(45, 122, 94, 0.4);
  static const Color borderGlow = Color.fromRGBO(45, 122, 94, 0.3);

  // ================== Gradients ==================
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [
      primaryGreen,
      lightGreen,
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
