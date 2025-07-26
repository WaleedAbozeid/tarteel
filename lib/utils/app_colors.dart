import 'package:flutter/material.dart';

class AppColors {
  // الألوان الرئيسية
  static const Color primaryDark = Color(0xFF1A1A2E);
  static const Color secondaryDark = Color(0xFF16213E);
  static const Color tertiaryDark = Color(0xFF0F3460);
  
  // ألوان الأزرار والميزات
  static const Color primaryGreen = Color(0xFF4CAF50);
  static const Color primaryBlue = Color(0xFF2196F3);
  static const Color primaryOrange = Color(0xFFFF9800);
  static const Color primaryPurple = Color(0xFF9C27B0);
  static const Color primaryRed = Color(0xFFF44336);
  
  // ألوان النصوص
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textGrey = Color(0xFF808080);
  
  // ألوان الحالات
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // ألوان التجويد
  static const Color tajweedGhunna = Color(0xFF4CAF50);
  static const Color tajweedMadd = Color(0xFFFF9800);
  static const Color tajweedIdgham = Color(0xFF2196F3);
  static const Color tajweedQalqalah = Color(0xFF9C27B0);
  static const Color tajweedIkhfa = Color(0xFF607D8B);
  
  // التدرجات اللونية
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [secondaryDark, tertiaryDark],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [tertiaryDark, secondaryDark],
  );
  
  // الحصول على لون حسب النتيجة
  static Color getScoreColor(double score) {
    if (score >= 80) return success;
    if (score >= 60) return warning;
    return error;
  }
  
  // الحصول على لون حسب التقييم
  static Color getRatingColor(String rating) {
    switch (rating.toLowerCase()) {
      case 'ممتاز':
        return success;
      case 'جيد':
        return warning;
      case 'يحتاج تحسين':
        return error;
      default:
        return info;
    }
  }
} 