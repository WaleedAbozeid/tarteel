import 'dart:io';
import 'package:flutter/material.dart';

class NetworkHelper {
  // التحقق من الاتصال بالإنترنت
  static Future<bool> isConnected() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  // التحقق من الاتصال مع رسالة
  static Future<bool> checkConnectionWithMessage(BuildContext context) async {
    bool connected = await isConnected();
    
    if (!connected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يوجد اتصال بالإنترنت'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
    
    return connected;
  }

  // عرض رسالة خطأ الاتصال
  static void showConnectionError(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F3460),
          title: const Text(
            'خطأ في الاتصال',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'لا يمكن الاتصال بالخادم. يرجى التحقق من اتصال الإنترنت والمحاولة مرة أخرى.',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'حسناً',
                style: TextStyle(color: Color(0xFF4CAF50)),
              ),
            ),
          ],
        );
      },
    );
  }

  // عرض رسالة تحميل
  static void showLoadingMessage(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F3460),
          content: Row(
            children: [
              const CircularProgressIndicator(
                color: Color(0xFF4CAF50),
              ),
              const SizedBox(width: 16),
              Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }

  // إخفاء رسالة التحميل
  static void hideLoadingMessage(BuildContext context) {
    Navigator.of(context).pop();
  }

  // عرض رسالة نجاح
  static void showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF4CAF50),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // عرض رسالة خطأ
  static void showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'إعادة المحاولة',
          textColor: Colors.white,
          onPressed: () {
            // يمكن إضافة منطق إعادة المحاولة هنا
          },
        ),
      ),
    );
  }

  // التحقق من سرعة الاتصال
  static Future<double> checkConnectionSpeed() async {
    try {
      final stopwatch = Stopwatch()..start();
      
      final result = await InternetAddress.lookup('google.com');
      
      stopwatch.stop();
      
      // حساب السرعة التقريبية (مللي ثانية)
      return stopwatch.elapsedMilliseconds.toDouble();
    } catch (e) {
      return -1; // خطأ في الاتصال
    }
  }

  // الحصول على نص سرعة الاتصال
  static String getConnectionSpeedText(double speedMs) {
    if (speedMs < 0) {
      return 'غير متصل';
    } else if (speedMs < 100) {
      return 'سريع جداً';
    } else if (speedMs < 300) {
      return 'سريع';
    } else if (speedMs < 1000) {
      return 'متوسط';
    } else {
      return 'بطيء';
    }
  }

  // الحصول على لون سرعة الاتصال
  static Color getConnectionSpeedColor(double speedMs) {
    if (speedMs < 0) {
      return Colors.red;
    } else if (speedMs < 100) {
      return const Color(0xFF4CAF50);
    } else if (speedMs < 300) {
      return const Color(0xFF8BC34A);
    } else if (speedMs < 1000) {
      return const Color(0xFFFF9800);
    } else {
      return Colors.red;
    }
  }

  // التحقق من نوع الاتصال
  static Future<String> getConnectionType() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      
      if (result.isNotEmpty) {
        // هذا تبسيط - في التطبيق الحقيقي يمكن استخدام مكتبة للتحقق من نوع الاتصال
        return 'WiFi'; // أو Mobile
      }
      
      return 'غير متصل';
    } catch (e) {
      return 'غير متصل';
    }
  }

  // إعادة المحاولة مع تأخير
  static Future<T?> retryWithDelay<T>(
    Future<T> Function() operation,
    int maxRetries,
    Duration delay,
  ) async {
    for (int i = 0; i < maxRetries; i++) {
      try {
        return await operation();
      } catch (e) {
        if (i == maxRetries - 1) {
          rethrow;
        }
        await Future.delayed(delay);
      }
    }
    throw Exception('فشلت جميع المحاولات');
  }
} 