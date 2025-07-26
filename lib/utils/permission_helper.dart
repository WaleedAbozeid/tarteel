import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionHelper {
  // طلب إذن الميكروفون
  static Future<bool> requestMicrophonePermission(BuildContext context) async {
    PermissionStatus status = await Permission.microphone.status;
    
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied) {
      status = await Permission.microphone.request();
      
      if (status.isGranted) {
        return true;
      } else {
        _showPermissionDialog(
          context,
          'إذن الميكروفون',
          'يحتاج التطبيق إلى إذن الميكروفون لتسجيل التلاوة. يرجى منح الإذن من إعدادات التطبيق.',
        );
        return false;
      }
    }
    
    if (status.isPermanentlyDenied) {
      _showPermissionDialog(
        context,
        'إذن الميكروفون',
        'تم رفض إذن الميكروفون بشكل دائم. يرجى تفعيله من إعدادات التطبيق.',
      );
      return false;
    }
    
    return false;
  }

  // طلب إذن التخزين
  static Future<bool> requestStoragePermission(BuildContext context) async {
    PermissionStatus status = await Permission.storage.status;
    
    if (status.isGranted) {
      return true;
    }
    
    if (status.isDenied) {
      status = await Permission.storage.request();
      
      if (status.isGranted) {
        return true;
      } else {
        _showPermissionDialog(
          context,
          'إذن التخزين',
          'يحتاج التطبيق إلى إذن التخزين لحفظ الملفات الصوتية. يرجى منح الإذن من إعدادات التطبيق.',
        );
        return false;
      }
    }
    
    if (status.isPermanentlyDenied) {
      _showPermissionDialog(
        context,
        'إذن التخزين',
        'تم رفض إذن التخزين بشكل دائم. يرجى تفعيله من إعدادات التطبيق.',
      );
      return false;
    }
    
    return false;
  }

  // طلب جميع الأذونات المطلوبة
  static Future<bool> requestAllPermissions(BuildContext context) async {
    bool microphoneGranted = await requestMicrophonePermission(context);
    bool storageGranted = await requestStoragePermission(context);
    
    return microphoneGranted && storageGranted;
  }

  // التحقق من حالة الأذونات
  static Future<Map<Permission, PermissionStatus>> checkPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.microphone,
      Permission.storage,
    ].request();
    
    return statuses;
  }

  // فتح إعدادات التطبيق
  static Future<void> openAppSettings() async {
    await openAppSettings();
  }

  // عرض حوار الأذونات
  static void _showPermissionDialog(
    BuildContext context,
    String title,
    String message,
  ) {
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
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: const Text(
                'الإعدادات',
                style: TextStyle(color: Color(0xFF4CAF50)),
              ),
            ),
          ],
        );
      },
    );
  }

  // عرض رسالة خطأ الأذونات
  static void showPermissionError(BuildContext context, String permission) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('يجب منح إذن $permission لاستخدام هذه الميزة'),
        backgroundColor: Colors.red,
        action: SnackBarAction(
          label: 'الإعدادات',
          textColor: Colors.white,
          onPressed: () {
            openAppSettings();
          },
        ),
      ),
    );
  }

  // التحقق من إمكانية استخدام الميكروفون
  static Future<bool> canUseMicrophone() async {
    PermissionStatus status = await Permission.microphone.status;
    return status.isGranted;
  }

  // التحقق من إمكانية استخدام التخزين
  static Future<bool> canUseStorage() async {
    PermissionStatus status = await Permission.storage.status;
    return status.isGranted;
  }

  // الحصول على نص حالة الإذن
  static String getPermissionStatusText(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return 'ممنوح';
      case PermissionStatus.denied:
        return 'مرفوض';
      case PermissionStatus.permanentlyDenied:
        return 'مرفوض بشكل دائم';
      case PermissionStatus.restricted:
        return 'مقيد';
      case PermissionStatus.limited:
        return 'محدود';
      case PermissionStatus.provisional:
        return 'مؤقت';
      default:
        return 'غير معروف';
    }
  }

  // الحصول على لون حالة الإذن
  static Color getPermissionStatusColor(PermissionStatus status) {
    switch (status) {
      case PermissionStatus.granted:
        return const Color(0xFF4CAF50);
      case PermissionStatus.denied:
      case PermissionStatus.permanentlyDenied:
        return Colors.red;
      case PermissionStatus.restricted:
      case PermissionStatus.limited:
      case PermissionStatus.provisional:
        return const Color(0xFFFF9800);
      default:
        return Colors.grey;
    }
  }
} 