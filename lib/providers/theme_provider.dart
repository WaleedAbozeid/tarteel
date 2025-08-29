import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_colors.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = true; // البدء بالوضع الداكن افتراضيًا
  static const String _themePreferenceKey = 'theme_preference';

  bool get isDarkMode => _isDarkMode;

  // الحصول على السمة الحالية
  ThemeData get currentTheme => _isDarkMode ? _darkTheme : _lightTheme;

  // تعريف السمة الداكنة
  final ThemeData _darkTheme = ThemeData(
    primarySwatch: Colors.green,
    primaryColor: AppColors.primaryGreen,
    scaffoldBackgroundColor: AppColors.primaryDark,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.secondaryDark,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: AppColors.tertiaryDark,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
      titleLarge: TextStyle(color: Colors.white),
      titleMedium: TextStyle(color: Colors.white),
    ),
    iconTheme: const IconThemeData(color: Colors.white),
    brightness: Brightness.dark,
  );

  // تعريف السمة الفاتحة
  final ThemeData _lightTheme = ThemeData(
    primarySwatch: Colors.green,
    primaryColor: AppColors.primaryGreen,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.primaryGreen,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black),
      titleLarge: TextStyle(color: Colors.black),
      titleMedium: TextStyle(color: Colors.black),
    ),
    iconTheme: const IconThemeData(color: AppColors.primaryGreen),
    brightness: Brightness.light,
  );

  ThemeProvider() {
    _loadThemePreference();
  }

  // تحميل تفضيل السمة من التخزين المحلي
  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(_themePreferenceKey) ?? true;
      notifyListeners();
    } catch (e) {
      // استخدام القيمة الافتراضية في حالة حدوث خطأ
      _isDarkMode = true;
    }
  }

  // تبديل وضع السمة
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_themePreferenceKey, _isDarkMode);
    } catch (e) {
      // تجاهل أخطاء التخزين
    }
  }
}