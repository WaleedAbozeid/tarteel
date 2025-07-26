import 'package:flutter/material.dart';

class ErrorHelper {
  // عرض رسالة خطأ عامة
  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'حسناً',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // عرض رسالة خطأ مع إعادة المحاولة
  static void showErrorWithRetry(
    BuildContext context,
    String message,
    VoidCallback onRetry,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'إعادة المحاولة',
          textColor: Colors.white,
          onPressed: onRetry,
        ),
      ),
    );
  }

  // عرض حوار خطأ
  static void showErrorDialog(
    BuildContext context,
    String title,
    String message, {
    String? confirmText,
    VoidCallback? onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0F3460),
          title: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'إلغاء',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            if (confirmText != null)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onConfirm?.call();
                },
                child: Text(
                  confirmText,
                  style: const TextStyle(color: Color(0xFF4CAF50)),
                ),
              ),
          ],
        );
      },
    );
  }

  // عرض رسالة تحذير
  static void showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFFF9800),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // عرض رسالة معلومات
  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF2196F3),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // عرض رسالة نجاح
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF4CAF50),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // معالجة الأخطاء العامة
  static String handleError(dynamic error) {
    if (error is Exception) {
      String errorMessage = error.toString();
      
      // إزالة "Exception:" من بداية الرسالة
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }
      
      return errorMessage;
    }
    
    return error.toString();
  }

  // معالجة أخطاء الشبكة
  static String handleNetworkError(dynamic error) {
    if (error.toString().contains('SocketException')) {
      return 'لا يوجد اتصال بالإنترنت';
    } else if (error.toString().contains('TimeoutException')) {
      return 'انتهت مهلة الاتصال';
    } else if (error.toString().contains('HttpException')) {
      return 'خطأ في الخادم';
    } else {
      return handleError(error);
    }
  }

  // معالجة أخطاء الصوت
  static String handleAudioError(dynamic error) {
    if (error.toString().contains('permission')) {
      return 'يجب منح إذن الميكروفون';
    } else if (error.toString().contains('file')) {
      return 'خطأ في الملف الصوتي';
    } else if (error.toString().contains('format')) {
      return 'تنسيق الملف غير مدعوم';
    } else {
      return handleError(error);
    }
  }

  // معالجة أخطاء التخزين
  static String handleStorageError(dynamic error) {
    if (error.toString().contains('permission')) {
      return 'يجب منح إذن التخزين';
    } else if (error.toString().contains('space')) {
      return 'لا توجد مساحة كافية';
    } else if (error.toString().contains('file')) {
      return 'خطأ في الملف';
    } else {
      return handleError(error);
    }
  }

  // عرض شاشة خطأ
  static Widget buildErrorWidget(
    String message, {
    String? retryText,
    VoidCallback? onRetry,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'حدث خطأ',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
          if (retryText != null && onRetry != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
              ),
              child: Text(
                retryText,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // عرض شاشة لا توجد بيانات
  static Widget buildEmptyWidget(
    String message, {
    IconData? icon,
    String? actionText,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon ?? Icons.inbox_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          if (actionText != null && onAction != null) ...[
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
              ),
              child: Text(
                actionText,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // تسجيل الخطأ
  static void logError(String context, dynamic error, [StackTrace? stackTrace]) {
    print('ERROR in $context: $error');
    if (stackTrace != null) {
      print('StackTrace: $stackTrace');
    }
  }
} 