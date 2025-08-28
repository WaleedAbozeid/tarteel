import 'package:flutter/material.dart';

class AppSizes {
  // Padding and margins
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  
  // Border radius
  static const double radiusXs = 4.0;
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusCircular = 50.0;
  
  // Icon sizes
  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;
  static const double iconXxl = 64.0;
  
  // Button sizes
  static const double buttonHeight = 48.0;
  static const double buttonMinWidth = 120.0;
  static const double buttonRadius = 12.0;
  
  // Card sizes
  static const double cardRadius = 16.0;
  static const double cardElevation = 4.0;
  static const double cardPadding = 16.0;
  
  // App bar
  static const double appBarHeight = 56.0;
  static const double appBarElevation = 0.0;
  
  // Bottom navigation
  static const double bottomNavHeight = 56.0;
  static const double bottomNavElevation = 8.0;
  
  // Text sizes
  static const double textXs = 10.0;
  static const double textSm = 12.0;
  static const double textMd = 14.0;
  static const double textLg = 16.0;
  static const double textXl = 18.0;
  static const double textXxl = 24.0;
  static const double textTitle = 28.0;
  
  // Spacing
  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);
  
  static const EdgeInsets paddingHorizontalMd = EdgeInsets.symmetric(horizontal: md);
  static const EdgeInsets paddingVerticalMd = EdgeInsets.symmetric(vertical: md);
  static const EdgeInsets paddingHorizontalLg = EdgeInsets.symmetric(horizontal: lg);
  static const EdgeInsets paddingVerticalLg = EdgeInsets.symmetric(vertical: lg);
  
  // Gaps
  static const SizedBox gapXs = SizedBox(height: xs);
  static const SizedBox gapSm = SizedBox(height: sm);
  static const SizedBox gapMd = SizedBox(height: md);
  static const SizedBox gapLg = SizedBox(height: lg);
  static const SizedBox gapXl = SizedBox(height: xl);
  
  static const SizedBox gapHorizontalXs = SizedBox(width: xs);
  static const SizedBox gapHorizontalSm = SizedBox(width: sm);
  static const SizedBox gapHorizontalMd = SizedBox(width: md);
  static const SizedBox gapHorizontalLg = SizedBox(width: lg);
  static const SizedBox gapHorizontalXl = SizedBox(width: xl);
  
  // Animation durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  
  // Grid spacing
  static const double gridSpacing = 16.0;
  static const double gridChildAspectRatio = 0.85;
  
  // List spacing
  static const double listItemSpacing = 8.0;
  static const double listItemPadding = 16.0;
  
  // Dialog sizes
  static const double dialogWidth = 400.0;
  static const double dialogRadius = 16.0;
  
  // Loading indicator
  static const double loadingIndicatorSize = 24.0;
  static const double loadingIndicatorStrokeWidth = 2.0;
}
