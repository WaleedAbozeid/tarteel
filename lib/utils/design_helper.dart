import 'package:flutter/material.dart';

class DesignHelper {
  // الحصول على لون حسب النوع
  static Color getColorByType(String type) {
    switch (type.toLowerCase()) {
      case 'success':
      case 'green':
        return const Color(0xFF4CAF50);
      case 'warning':
      case 'orange':
        return const Color(0xFFFF9800);
      case 'error':
      case 'red':
        return Colors.red;
      case 'info':
      case 'blue':
        return const Color(0xFF2196F3);
      case 'purple':
        return const Color(0xFF9C27B0);
      case 'grey':
      case 'gray':
        return Colors.grey;
      default:
        return const Color(0xFF4CAF50);
    }
  }

  // الحصول على لون خلفية حسب النوع
  static Color getBackgroundColorByType(String type) {
    switch (type.toLowerCase()) {
      case 'success':
      case 'green':
        return const Color(0xFF4CAF50).withOpacity(0.1);
      case 'warning':
      case 'orange':
        return const Color(0xFFFF9800).withOpacity(0.1);
      case 'error':
      case 'red':
        return Colors.red.withOpacity(0.1);
      case 'info':
      case 'blue':
        return const Color(0xFF2196F3).withOpacity(0.1);
      case 'purple':
        return const Color(0xFF9C27B0).withOpacity(0.1);
      default:
        return const Color(0xFF4CAF50).withOpacity(0.1);
    }
  }

  // إنشاء تدرج لوني
  static LinearGradient createGradient(List<Color> colors, {
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: colors,
    );
  }

  // إنشاء تدرج لوني للتطبيق
  static LinearGradient getAppGradient() {
    return const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Color(0xFF16213E),
        Color(0xFF0F3460),
      ],
    );
  }

  // إنشاء تدرج لوني للبطاقات
  static LinearGradient getCardGradient() {
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFF0F3460),
        Color(0xFF16213E),
      ],
    );
  }

  // إنشاء ظل
  static List<BoxShadow> createShadow({
    Color color = Colors.black,
    double blurRadius = 8,
    double offsetX = 0,
    double offsetY = 4,
    double opacity = 0.2,
  }) {
    return [
      BoxShadow(
        color: color.withOpacity(opacity),
        blurRadius: blurRadius,
        offset: Offset(offsetX, offsetY),
      ),
    ];
  }

  // إنشاء ظل للبطاقات
  static List<BoxShadow> getCardShadow() {
    return createShadow(
      color: Colors.black,
      blurRadius: 8,
      offsetY: 4,
      opacity: 0.2,
    );
  }

  // إنشاء ظل للأزرار
  static List<BoxShadow> getButtonShadow() {
    return createShadow(
      color: Colors.black,
      blurRadius: 4,
      offsetY: 2,
      opacity: 0.3,
    );
  }

  // إنشاء زوايا مدورة
  static BorderRadius getBorderRadius(double radius) {
    return BorderRadius.circular(radius);
  }

  // إنشاء زوايا مدورة للبطاقات
  static BorderRadius getCardBorderRadius() {
    return getBorderRadius(12);
  }

  // إنشاء زوايا مدورة للأزرار
  static BorderRadius getButtonBorderRadius() {
    return getBorderRadius(8);
  }

  // إنشاء نمط نص
  static TextStyle getTextStyle({
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      color: color ?? Colors.white,
      fontSize: fontSize ?? 16,
      fontWeight: fontWeight ?? FontWeight.normal,
      decoration: decoration,
    );
  }

  // إنشاء نمط نص للعناوين
  static TextStyle getTitleTextStyle() {
    return getTextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
    );
  }

  // إنشاء نمط نص للعناوين الفرعية
  static TextStyle getSubtitleTextStyle() {
    return getTextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Colors.grey,
    );
  }

  // إنشاء نمط نص للجسم
  static TextStyle getBodyTextStyle() {
    return getTextStyle(
      fontSize: 14,
    );
  }

  // إنشاء نمط نص للقرآن
  static TextStyle getQuranTextStyle() {
    return getTextStyle(
      fontSize: 24,
      fontWeight: FontWeight.normal,
    );
  }

  // إنشاء نمط نص للتفسير
  static TextStyle getTafsirTextStyle() {
    return getTextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
    );
  }

  // إنشاء نمط زر
  static ButtonStyle getButtonStyle({
    Color? backgroundColor,
    Color? foregroundColor,
    double? elevation,
    EdgeInsetsGeometry? padding,
  }) {
    return ElevatedButton.styleFrom(
      backgroundColor: backgroundColor ?? const Color(0xFF4CAF50),
      foregroundColor: foregroundColor ?? Colors.white,
      elevation: elevation ?? 2,
      padding: padding ?? const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: getButtonBorderRadius(),
      ),
    );
  }

  // إنشاء نمط زر رئيسي
  static ButtonStyle getPrimaryButtonStyle() {
    return getButtonStyle(
      backgroundColor: const Color(0xFF4CAF50),
      foregroundColor: Colors.white,
    );
  }

  // إنشاء نمط زر ثانوي
  static ButtonStyle getSecondaryButtonStyle() {
    return getButtonStyle(
      backgroundColor: Colors.transparent,
      foregroundColor: const Color(0xFF4CAF50),
      elevation: 0,
    );
  }

  // إنشاء نمط زر خطير
  static ButtonStyle getDangerButtonStyle() {
    return getButtonStyle(
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
    );
  }

  // إنشاء نمط حقل إدخال
  static InputDecoration getInputDecoration({
    String? hintText,
    String? labelText,
    IconData? prefixIcon,
    IconData? suffixIcon,
    VoidCallback? onSuffixIconPressed,
  }) {
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
      suffixIcon: suffixIcon != null
          ? IconButton(
              icon: Icon(suffixIcon),
              onPressed: onSuffixIconPressed,
            )
          : null,
      border: OutlineInputBorder(
        borderRadius: getBorderRadius(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: getBorderRadius(8),
        borderSide: const BorderSide(color: Colors.grey),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: getBorderRadius(8),
        borderSide: const BorderSide(color: Color(0xFF4CAF50), width: 2),
      ),
      filled: true,
      fillColor: const Color(0xFF0F3460),
      hintStyle: const TextStyle(color: Colors.grey),
      labelStyle: const TextStyle(color: Colors.grey),
    );
  }

  // إنشاء مسافات
  static EdgeInsets getPadding(double all) {
    return EdgeInsets.all(all);
  }

  static EdgeInsets getPaddingSymmetric({
    double horizontal = 0,
    double vertical = 0,
  }) {
    return EdgeInsets.symmetric(
      horizontal: horizontal,
      vertical: vertical,
  );
  }

  // إنشاء مسافات قياسية
  static EdgeInsets getStandardPadding() {
    return getPadding(16);
  }

  static EdgeInsets getSmallPadding() {
    return getPadding(8);
  }

  static EdgeInsets getLargePadding() {
    return getPadding(24);
  }

  // إنشاء مسافات أفقية
  static SizedBox getHorizontalSpace(double width) {
    return SizedBox(width: width);
  }

  // إنشاء مسافات رأسية
  static SizedBox getVerticalSpace(double height) {
    return SizedBox(height: height);
  }

  // إنشاء مسافات قياسية
  static SizedBox getSmallSpace() {
    return getVerticalSpace(8);
  }

  static SizedBox getMediumSpace() {
    return getVerticalSpace(16);
  }

  static SizedBox getLargeSpace() {
    return getVerticalSpace(24);
  }
} 