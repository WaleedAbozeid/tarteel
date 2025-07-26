import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppHelper {
  // إخفاء شريط الحالة
  static void hideStatusBar() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  // إظهار شريط الحالة
  static void showStatusBar() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  // تعيين اتجاه الشاشة
  static void setOrientation(List<DeviceOrientation> orientations) {
    SystemChrome.setPreferredOrientations(orientations);
  }

  // تعيين اتجاه الشاشة للوضع الرأسي فقط
  static void setPortraitOnly() {
    setOrientation([DeviceOrientation.portraitUp]);
  }

  // تعيين اتجاه الشاشة للوضع الأفقي فقط
  static void setLandscapeOnly() {
    setOrientation([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  // السماح بجميع الاتجاهات
  static void setAllOrientations() {
    setOrientation([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  // الحصول على حجم الشاشة
  static Size getScreenSize(BuildContext context) {
    return MediaQuery.of(context).size;
  }

  // الحصول على عرض الشاشة
  static double getScreenWidth(BuildContext context) {
    return getScreenSize(context).width;
  }

  // الحصول على ارتفاع الشاشة
  static double getScreenHeight(BuildContext context) {
    return getScreenSize(context).height;
  }

  // التحقق من كون الشاشة صغيرة
  static bool isSmallScreen(BuildContext context) {
    return getScreenWidth(context) < 600;
  }

  // التحقق من كون الشاشة متوسطة
  static bool isMediumScreen(BuildContext context) {
    double width = getScreenWidth(context);
    return width >= 600 && width < 1200;
  }

  // التحقق من كون الشاشة كبيرة
  static bool isLargeScreen(BuildContext context) {
    return getScreenWidth(context) >= 1200;
  }

  // الحصول على نسبة الشاشة
  static double getAspectRatio(BuildContext context) {
    Size size = getScreenSize(context);
    return size.width / size.height;
  }

  // التحقق من الوضع المظلم
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  // الحصول على لون حسب الوضع
  static Color getColorByMode(BuildContext context, Color lightColor, Color darkColor) {
    return isDarkMode(context) ? darkColor : lightColor;
  }

  // الحصول على لون الخلفية حسب الوضع
  static Color getBackgroundColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.white,
      const Color(0xFF1A1A2E),
    );
  }

  // الحصول على لون النص حسب الوضع
  static Color getTextColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.black,
      Colors.white,
    );
  }

  // الحصول على لون البطاقة حسب الوضع
  static Color getCardColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.white,
      const Color(0xFF0F3460),
    );
  }

  // الحصول على لون الحقل حسب الوضع
  static Color getFieldColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.grey[100]!,
      const Color(0xFF16213E),
    );
  }

  // الحصول على لون الحدود حسب الوضع
  static Color getBorderColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.grey[300]!,
      Colors.grey[600]!,
    );
  }

  // الحصول على لون الخطأ حسب الوضع
  static Color getErrorColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.red[700]!,
      Colors.red[400]!,
    );
  }

  // الحصول على لون النجاح حسب الوضع
  static Color getSuccessColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.green[700]!,
      Colors.green[400]!,
    );
  }

  // الحصول على لون التحذير حسب الوضع
  static Color getWarningColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.orange[700]!,
      Colors.orange[400]!,
    );
  }

  // الحصول على لون المعلومات حسب الوضع
  static Color getInfoColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.blue[700]!,
      Colors.blue[400]!,
    );
  }

  // الحصول على لون المفضلة حسب الوضع
  static Color getFavoriteColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.pink[700]!,
      Colors.pink[400]!,
    );
  }

  // الحصول على لون التجويد حسب الوضع
  static Color getTajweedColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.purple[700]!,
      Colors.purple[400]!,
    );
  }

  // الحصول على لون التفسير حسب الوضع
  static Color getTafsirColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.teal[700]!,
      Colors.teal[400]!,
    );
  }

  // الحصول على لون الحفظ حسب الوضع
  static Color getMemorizationColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.indigo[700]!,
      Colors.indigo[400]!,
    );
  }

  // الحصول على لون البحث حسب الوضع
  static Color getSearchColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.cyan[700]!,
      Colors.cyan[400]!,
    );
  }

  // الحصول على لون الإعدادات حسب الوضع
  static Color getSettingsColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.grey[700]!,
      Colors.grey[400]!,
    );
  }

  // الحصول على لون الوحي حسب الوضع
  static Color getInspirationColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.amber[700]!,
      Colors.amber[400]!,
    );
  }

  // الحصول على لون التلاوة حسب الوضع
  static Color getRecitationColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.lightGreen[700]!,
      Colors.lightGreen[400]!,
    );
  }

  // الحصول على لون الصوت حسب الوضع
  static Color getAudioColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.deepOrange[700]!,
      Colors.deepOrange[400]!,
    );
  }

  // الحصول على لون التسجيل حسب الوضع
  static Color getRecordingColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.red[700]!,
      Colors.red[400]!,
    );
  }

  // الحصول على لون التشغيل حسب الوضع
  static Color getPlayColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.green[700]!,
      Colors.green[400]!,
    );
  }

  // الحصول على لون الإيقاف حسب الوضع
  static Color getPauseColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.orange[700]!,
      Colors.orange[400]!,
    );
  }

  // الحصول على لون الإيقاف التام حسب الوضع
  static Color getStopColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.red[700]!,
      Colors.red[400]!,
    );
  }

  // الحصول على لون التقدم حسب الوضع
  static Color getProgressColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.blue[700]!,
      Colors.blue[400]!,
    );
  }

  // الحصول على لون التقييم حسب الوضع
  static Color getRatingColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.yellow[700]!,
      Colors.yellow[400]!,
    );
  }

  // الحصول على لون الدقة حسب الوضع
  static Color getAccuracyColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.green[700]!,
      Colors.green[400]!,
    );
  }

  // الحصول على لون السرعة حسب الوضع
  static Color getSpeedColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.purple[700]!,
      Colors.purple[400]!,
    );
  }

  // الحصول على لون الجودة حسب الوضع
  static Color getQualityColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.teal[700]!,
      Colors.teal[400]!,
    );
  }

  // الحصول على لون النتيجة حسب الوضع
  static Color getScoreColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.indigo[700]!,
      Colors.indigo[400]!,
    );
  }

  // الحصول على لون المستوى حسب الوضع
  static Color getLevelColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.cyan[700]!,
      Colors.cyan[400]!,
    );
  }

  // الحصول على لون التصنيف حسب الوضع
  static Color getRankColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.amber[700]!,
      Colors.amber[400]!,
    );
  }

  // الحصول على لون الإنجاز حسب الوضع
  static Color getAchievementColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.lightGreen[700]!,
      Colors.lightGreen[400]!,
    );
  }

  // الحصول على لون التحدي حسب الوضع
  static Color getChallengeColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.deepOrange[700]!,
      Colors.deepOrange[400]!,
    );
  }

  // الحصول على لون المسابقة حسب الوضع
  static Color getCompetitionColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.pink[700]!,
      Colors.pink[400]!,
    );
  }

  // الحصول على لون الجائزة حسب الوضع
  static Color getRewardColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.yellow[700]!,
      Colors.yellow[400]!,
    );
  }

  // الحصول على لون النقاط حسب الوضع
  static Color getPointsColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.orange[700]!,
      Colors.orange[400]!,
    );
  }

  // الحصول على لون الشارة حسب الوضع
  static Color getBadgeColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.purple[700]!,
      Colors.purple[400]!,
    );
  }

  // الحصول على لون الشهادة حسب الوضع
  static Color getCertificateColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.teal[700]!,
      Colors.teal[400]!,
    );
  }

  // الحصول على لون الدبلومة حسب الوضع
  static Color getDiplomaColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.indigo[700]!,
      Colors.indigo[400]!,
    );
  }

  // الحصول على لون الميدالية حسب الوضع
  static Color getMedalColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.amber[700]!,
      Colors.amber[400]!,
    );
  }

  // الحصول على لون الكأس حسب الوضع
  static Color getTrophyColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.yellow[700]!,
      Colors.yellow[400]!,
    );
  }

  // الحصول على لون التاج حسب الوضع
  static Color getCrownColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.orange[700]!,
      Colors.orange[400]!,
    );
  }

  // الحصول على لون النجم حسب الوضع
  static Color getStarColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.yellow[700]!,
      Colors.yellow[400]!,
    );
  }

  // الحصول على لون القلب حسب الوضع
  static Color getHeartColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.red[700]!,
      Colors.red[400]!,
    );
  }

  // الحصول على لون الإعجاب حسب الوضع
  static Color getLikeColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.pink[700]!,
      Colors.pink[400]!,
    );
  }

  // الحصول على لون المشاركة حسب الوضع
  static Color getShareColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.blue[700]!,
      Colors.blue[400]!,
    );
  }

  // الحصول على لون التعليق حسب الوضع
  static Color getCommentColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.green[700]!,
      Colors.green[400]!,
    );
  }

  // الحصول على لون الإشعار حسب الوضع
  static Color getNotificationColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.red[700]!,
      Colors.red[400]!,
    );
  }

  // الحصول على لون الرسالة حسب الوضع
  static Color getMessageColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.blue[700]!,
      Colors.blue[400]!,
    );
  }

  // الحصول على لون البريد حسب الوضع
  static Color getEmailColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.grey[700]!,
      Colors.grey[400]!,
    );
  }

  // الحصول على لون الهاتف حسب الوضع
  static Color getPhoneColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.green[700]!,
      Colors.green[400]!,
    );
  }

  // الحصول على لون الموقع حسب الوضع
  static Color getLocationColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.red[700]!,
      Colors.red[400]!,
    );
  }

  // الحصول على لون الموقع الإلكتروني حسب الوضع
  static Color getWebsiteColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.blue[700]!,
      Colors.blue[400]!,
    );
  }

  // الحصول على لون وسائل التواصل الاجتماعي حسب الوضع
  static Color getSocialMediaColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      Colors.purple[700]!,
      Colors.purple[400]!,
    );
  }

  // الحصول على لون التطبيق حسب الوضع
  static Color getAppColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      const Color(0xFF4CAF50),
      const Color(0xFF4CAF50),
    );
  }

  // الحصول على لون التطبيق الثانوي حسب الوضع
  static Color getAppSecondaryColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      const Color(0xFF2196F3),
      const Color(0xFF2196F3),
    );
  }

  // الحصول على لون التطبيق الثالثي حسب الوضع
  static Color getAppTertiaryColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      const Color(0xFFFF9800),
      const Color(0xFFFF9800),
    );
  }

  // الحصول على لون التطبيق الرابعي حسب الوضع
  static Color getAppQuaternaryColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      const Color(0xFF9C27B0),
      const Color(0xFF9C27B0),
    );
  }

  // الحصول على لون التطبيق الخامسي حسب الوضع
  static Color getAppQuinaryColorByMode(BuildContext context) {
    return getColorByMode(
      context,
      const Color(0xFF607D8B),
      const Color(0xFF607D8B),
    );
  }
} 