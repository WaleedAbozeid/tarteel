import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  static const String _settingsKey = 'app_settings';
  static const String _userProgressKey = 'user_progress';
  static const String _favoritesKey = 'favorites';
  static const String _recitationHistoryKey = 'recitation_history';

  // الحصول على مجلد التطبيق
  static Future<Directory> getAppDirectory() async {
    Directory appDir = await getApplicationDocumentsDirectory();
    Directory tarteelDir = Directory('${appDir.path}/tarteel');
    
    if (!await tarteelDir.exists()) {
      await tarteelDir.create(recursive: true);
    }
    
    return tarteelDir;
  }

  // الحصول على مجلد الملفات الصوتية
  static Future<Directory> getAudioDirectory() async {
    Directory appDir = await getAppDirectory();
    Directory audioDir = Directory('${appDir.path}/audio');
    
    if (!await audioDir.exists()) {
      await audioDir.create(recursive: true);
    }
    
    return audioDir;
  }

  // حفظ البيانات في SharedPreferences
  static Future<bool> saveData(String key, dynamic data) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      
      if (data is String) {
        return await prefs.setString(key, data);
      } else if (data is int) {
        return await prefs.setInt(key, data);
      } else if (data is double) {
        return await prefs.setDouble(key, data);
      } else if (data is bool) {
        return await prefs.setBool(key, data);
      } else if (data is List<String>) {
        return await prefs.setStringList(key, data);
      } else {
        // تحويل البيانات المعقدة إلى JSON
        String jsonData = json.encode(data);
        return await prefs.setString(key, jsonData);
      }
    } catch (e) {
      print('خطأ في حفظ البيانات: $e');
      return false;
    }
  }

  // استرجاع البيانات من SharedPreferences
  static Future<dynamic> getData(String key, {dynamic defaultValue}) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      
      if (prefs.containsKey(key)) {
        return prefs.get(key);
      }
      
      return defaultValue;
    } catch (e) {
      print('خطأ في استرجاع البيانات: $e');
      return defaultValue;
    }
  }

  // حفظ إعدادات التطبيق
  static Future<bool> saveSettings(Map<String, dynamic> settings) async {
    return await saveData(_settingsKey, settings);
  }

  // استرجاع إعدادات التطبيق
  static Future<Map<String, dynamic>> getSettings() async {
    dynamic data = await getData(_settingsKey, defaultValue: {});
    
    if (data is String) {
      return Map<String, dynamic>.from(json.decode(data));
    }
    
    return Map<String, dynamic>.from(data ?? {});
  }

  // حفظ تقدم المستخدم
  static Future<bool> saveUserProgress(Map<String, dynamic> progress) async {
    return await saveData(_userProgressKey, progress);
  }

  // استرجاع تقدم المستخدم
  static Future<Map<String, dynamic>> getUserProgress() async {
    dynamic data = await getData(_userProgressKey, defaultValue: {});
    
    if (data is String) {
      return Map<String, dynamic>.from(json.decode(data));
    }
    
    return Map<String, dynamic>.from(data ?? {});
  }

  // حفظ المفضلة
  static Future<bool> saveFavorites(List<String> favorites) async {
    return await saveData(_favoritesKey, favorites);
  }

  // استرجاع المفضلة
  static Future<List<String>> getFavorites() async {
    dynamic data = await getData(_favoritesKey, defaultValue: []);
    
    if (data is List) {
      return List<String>.from(data);
    }
    
    return [];
  }

  // إضافة إلى المفضلة
  static Future<bool> addToFavorites(String item) async {
    List<String> favorites = await getFavorites();
    
    if (!favorites.contains(item)) {
      favorites.add(item);
      return await saveFavorites(favorites);
    }
    
    return true;
  }

  // إزالة من المفضلة
  static Future<bool> removeFromFavorites(String item) async {
    List<String> favorites = await getFavorites();
    favorites.remove(item);
    return await saveFavorites(favorites);
  }

  // حفظ تاريخ التلاوة
  static Future<bool> saveRecitationHistory(Map<String, dynamic> history) async {
    return await saveData(_recitationHistoryKey, history);
  }

  // استرجاع تاريخ التلاوة
  static Future<Map<String, dynamic>> getRecitationHistory() async {
    dynamic data = await getData(_recitationHistoryKey, defaultValue: {});
    
    if (data is String) {
      return Map<String, dynamic>.from(json.decode(data));
    }
    
    return Map<String, dynamic>.from(data ?? {});
  }

  // حفظ ملف صوتي
  static Future<String?> saveAudioFile(String fileName, List<int> audioData) async {
    try {
      Directory audioDir = await getAudioDirectory();
      File audioFile = File('${audioDir.path}/$fileName');
      
      await audioFile.writeAsBytes(audioData);
      
      return audioFile.path;
    } catch (e) {
      print('خطأ في حفظ الملف الصوتي: $e');
      return null;
    }
  }

  // حذف ملف صوتي
  static Future<bool> deleteAudioFile(String fileName) async {
    try {
      Directory audioDir = await getAudioDirectory();
      File audioFile = File('${audioDir.path}/$fileName');
      
      if (await audioFile.exists()) {
        await audioFile.delete();
        return true;
      }
      
      return false;
    } catch (e) {
      print('خطأ في حذف الملف الصوتي: $e');
      return false;
    }
  }

  // الحصول على حجم التخزين المستخدم
  static Future<int> getStorageSize() async {
    try {
      Directory appDir = await getAppDirectory();
      int totalSize = 0;
      
      await for (FileSystemEntity entity in appDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      
      return totalSize;
    } catch (e) {
      print('خطأ في حساب حجم التخزين: $e');
      return 0;
    }
  }

  // مسح جميع البيانات
  static Future<bool> clearAllData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      Directory appDir = await getAppDirectory();
      if (await appDir.exists()) {
        await appDir.delete(recursive: true);
      }
      
      return true;
    } catch (e) {
      print('خطأ في مسح البيانات: $e');
      return false;
    }
  }

  // التحقق من وجود ملف
  static Future<bool> fileExists(String fileName) async {
    try {
      Directory audioDir = await getAudioDirectory();
      File file = File('${audioDir.path}/$fileName');
      return await file.exists();
    } catch (e) {
      return false;
    }
  }

  // الحصول على قائمة الملفات الصوتية
  static Future<List<String>> getAudioFiles() async {
    try {
      Directory audioDir = await getAudioDirectory();
      List<String> files = [];
      
      await for (FileSystemEntity entity in audioDir.list()) {
        if (entity is File && entity.path.endsWith('.mp3')) {
          files.add(entity.path.split('/').last);
        }
      }
      
      return files;
    } catch (e) {
      print('خطأ في الحصول على الملفات الصوتية: $e');
      return [];
    }
  }
} 