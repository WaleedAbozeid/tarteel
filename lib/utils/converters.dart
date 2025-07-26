import 'package:flutter/material.dart';

class Converters {
  // تحويل رقم إلى نص عربي
  static String numberToArabicText(int number) {
    const List<String> arabicNumbers = [
      'صفر', 'واحد', 'اثنان', 'ثلاثة', 'أربعة', 'خمسة', 'ستة', 'سبعة', 'ثمانية', 'تسعة', 'عشرة',
      'أحد عشر', 'اثنا عشر', 'ثلاثة عشر', 'أربعة عشر', 'خمسة عشر', 'ستة عشر', 'سبعة عشر', 'ثمانية عشر', 'تسعة عشر', 'عشرون',
      'واحد وعشرون', 'اثنان وعشرون', 'ثلاثة وعشرون', 'أربعة وعشرون', 'خمسة وعشرون', 'ستة وعشرون', 'سبعة وعشرون', 'ثمانية وعشرون', 'تسعة وعشرون', 'ثلاثون',
      'واحد وثلاثون', 'اثنان وثلاثون', 'ثلاثة وثلاثون', 'أربعة وثلاثون', 'خمسة وثلاثون', 'ستة وثلاثون', 'سبعة وثلاثون', 'ثمانية وثلاثون', 'تسعة وثلاثون', 'أربعون',
      'واحد وأربعون', 'اثنان وأربعون', 'ثلاثة وأربعون', 'أربعة وأربعون', 'خمسة وأربعون', 'ستة وأربعون', 'سبعة وأربعون', 'ثمانية وأربعون', 'تسعة وأربعون', 'خمسون',
      'واحد وخمسون', 'اثنان وخمسون', 'ثلاثة وخمسون', 'أربعة وخمسون', 'خمسة وخمسون', 'ستة وخمسون', 'سبعة وخمسون', 'ثمانية وخمسون', 'تسعة وخمسون', 'ستون',
      'واحد وستون', 'اثنان وستون', 'ثلاثة وستون', 'أربعة وستون', 'خمسة وستون', 'ستة وستون', 'سبعة وستون', 'ثمانية وستون', 'تسعة وستون', 'سبعون',
      'واحد وسبعون', 'اثنان وسبعون', 'ثلاثة وسبعون', 'أربعة وسبعون', 'خمسة وسبعون', 'ستة وسبعون', 'سبعة وسبعون', 'ثمانية وسبعون', 'تسعة وسبعون', 'ثمانون',
      'واحد وثمانون', 'اثنان وثمانون', 'ثلاثة وثمانون', 'أربعة وثمانون', 'خمسة وثمانون', 'ستة وثمانون', 'سبعة وثمانون', 'ثمانية وثمانون', 'تسعة وثمانون', 'تسعون',
      'واحد وتسعون', 'اثنان وتسعون', 'ثلاثة وتسعون', 'أربعة وتسعون', 'خمسة وتسعون', 'ستة وتسعون', 'سبعة وتسعون', 'ثمانية وتسعون', 'تسعة وتسعون', 'مائة'
    ];
    
    if (number >= 0 && number < arabicNumbers.length) {
      return arabicNumbers[number];
    }
    return number.toString();
  }

  // تحويل مدة إلى نص عربي
  static String durationToArabicText(Duration duration) {
    int minutes = duration.inMinutes;
    int seconds = duration.inSeconds % 60;
    
    String result = '';
    
    if (minutes > 0) {
      result += '${numberToArabicText(minutes)} دقيقة';
    }
    
    if (seconds > 0) {
      if (result.isNotEmpty) result += ' و';
      result += '${numberToArabicText(seconds)} ثانية';
    }
    
    if (result.isEmpty) {
      result = 'صفر ثانية';
    }
    
    return result;
  }

  // تحويل حجم الملف إلى نص مقروء
  static String fileSizeToReadable(int bytes) {
    if (bytes < 1024) {
      return '$bytes بايت';
    } else if (bytes < 1024 * 1024) {
      double kb = bytes / 1024;
      return '${kb.toStringAsFixed(1)} كيلوبايت';
    } else if (bytes < 1024 * 1024 * 1024) {
      double mb = bytes / (1024 * 1024);
      return '${mb.toStringAsFixed(1)} ميجابايت';
    } else {
      double gb = bytes / (1024 * 1024 * 1024);
      return '${gb.toStringAsFixed(1)} جيجابايت';
    }
  }

  // تحويل النسبة المئوية إلى نص عربي
  static String percentageToArabicText(double percentage) {
    if (percentage >= 100) {
      return 'مائة بالمائة';
    } else if (percentage >= 90) {
      return 'تسعون بالمائة';
    } else if (percentage >= 80) {
      return 'ثمانون بالمائة';
    } else if (percentage >= 70) {
      return 'سبعون بالمائة';
    } else if (percentage >= 60) {
      return 'ستون بالمائة';
    } else if (percentage >= 50) {
      return 'خمسون بالمائة';
    } else if (percentage >= 40) {
      return 'أربعون بالمائة';
    } else if (percentage >= 30) {
      return 'ثلاثون بالمائة';
    } else if (percentage >= 20) {
      return 'عشرون بالمائة';
    } else if (percentage >= 10) {
      return 'عشرة بالمائة';
    } else {
      return 'أقل من عشرة بالمائة';
    }
  }

  // تحويل التاريخ إلى نص عربي
  static String dateToArabicText(DateTime date) {
    const List<String> months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    
    const List<String> days = [
      'الأحد', 'الاثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت'
    ];
    
    String dayName = days[date.weekday - 1];
    String monthName = months[date.month - 1];
    String dayNumber = numberToArabicText(date.day);
    String year = numberToArabicText(date.year);
    
    return '$dayName $dayNumber من $monthName سنة $year';
  }

  // تحويل النص إلى أحرف عربية منقوطة
  static String addArabicDots(String text) {
    // إضافة النقاط للكلمات العربية
    Map<String, String> arabicDots = {
      'ا': 'ا',
      'ب': 'ب',
      'ت': 'ت',
      'ث': 'ث',
      'ج': 'ج',
      'ح': 'ح',
      'خ': 'خ',
      'د': 'د',
      'ذ': 'ذ',
      'ر': 'ر',
      'ز': 'ز',
      'س': 'س',
      'ش': 'ش',
      'ص': 'ص',
      'ض': 'ض',
      'ط': 'ط',
      'ظ': 'ظ',
      'ع': 'ع',
      'غ': 'غ',
      'ف': 'ف',
      'ق': 'ق',
      'ك': 'ك',
      'ل': 'ل',
      'م': 'م',
      'ن': 'ن',
      'ه': 'ه',
      'و': 'و',
      'ي': 'ي',
    };
    
    String result = '';
    for (int i = 0; i < text.length; i++) {
      String char = text[i];
      result += arabicDots[char] ?? char;
    }
    
    return result;
  }

  // تنظيف النص من الأحرف الخاصة
  static String cleanText(String text) {
    return text
        .replaceAll(RegExp(r'[^\u0600-\u06FF\u0750-\u077F\u08A0-\u08FF\uFB50-\uFDFF\uFE70-\uFEFF\s]'), '')
        .trim();
  }

  // حساب تشابه النصوص
  static double calculateTextSimilarity(String text1, String text2) {
    String cleanText1 = cleanText(text1.toLowerCase());
    String cleanText2 = cleanText(text2.toLowerCase());
    
    if (cleanText1.isEmpty || cleanText2.isEmpty) {
      return 0.0;
    }
    
    List<String> words1 = cleanText1.split(' ');
    List<String> words2 = cleanText2.split(' ');
    
    int commonWords = 0;
    for (String word in words1) {
      if (words2.contains(word)) {
        commonWords++;
      }
    }
    
    int totalWords = words1.length + words2.length - commonWords;
    if (totalWords == 0) return 1.0;
    
    return (commonWords * 2.0) / totalWords;
  }
} 