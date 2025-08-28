import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import '../models/quran_models.dart';

class LocalDataService {
  // Quran file path
  static const String _quranFilePath = 'assets/data/qur1/quran.json';
  
  // Cache for the entire Quran data
  static Map<String, dynamic>? _quranDataCache;
  
  // Load the entire Quran data once
  static Future<Map<String, dynamic>> _loadQuranData() async {
    if (_quranDataCache != null) {
      return _quranDataCache!;
    }
    
    try {
      // تحميل البيانات أولاً في الـ Main Thread
      final String response = await rootBundle.loadString(_quranFilePath);
      
      // ثم معالجة JSON في خيط منفصل
      _quranDataCache = await compute(_parseQuranDataInIsolate, response);
      return _quranDataCache!;
    } catch (e) {
      throw Exception('Error loading Quran data: $e');
    }
  }

  // دالة معالجة JSON في خيط منفصل
  static Map<String, dynamic> _parseQuranDataInIsolate(String jsonString) {
    try {
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Error parsing Quran data in isolate: $e');
    }
  }
  
  // Load surahs from the new Quran JSON file
  static Future<List<Surah>> getSurahs() async {
    try {
      final Map<String, dynamic> quranData = await _loadQuranData();
      
      // معالجة السور في خيط منفصل
      return await compute(_processSurahsInIsolate, quranData);
    } catch (e) {
      print('Error loading surahs: $e');
      throw Exception('Error loading surahs: $e');
    }
  }

  // دالة معالجة السور في خيط منفصل
  static List<Surah> _processSurahsInIsolate(Map<String, dynamic> quranData) {
      final List<Surah> surahs = [];
      
    // Create surah objects from the Quran data
      for (int i = 1; i <= 114; i++) {
        try {
        final String surahKey = i.toString();
        final List<dynamic> verses = quranData[surahKey] as List<dynamic>;
        
        if (verses.isNotEmpty) {
          final surah = Surah(
            number: i,
            name: _getSurahNameEn(i),
            nameAr: _getSurahNameAr(i),
            nameEn: _getSurahNameEn(i),
            revelationType: _getRevelationType(i),
            numberOfAyahs: verses.length,
            description: '',
          );
          
          surahs.add(surah);
          }
        } catch (e) {
          // Continue with next surah
        }
      }
      
      return surahs;
  }

  static Future<List<Ayah>> getSurahAyahsAsync(int surahNumber) async {
    try {
      final Map<String, dynamic> quranData = await _loadQuranData();
      
      // معالجة الآيات في خيط منفصل
      return await compute(_processAyahsInIsolate, {
        'quranData': quranData,
        'surahNumber': surahNumber,
      });
    } catch (e) {
      throw Exception('Error loading ayahs for surah $surahNumber: $e');
    }
  }

  // دالة معالجة الآيات في خيط منفصل
  static List<Ayah> _processAyahsInIsolate(Map<String, dynamic> params) {
    final Map<String, dynamic> quranData = params['quranData'] as Map<String, dynamic>;
    final int surahNumber = params['surahNumber'] as int;
    
    final String surahKey = surahNumber.toString();
    final List<dynamic> verses = quranData[surahKey] as List<dynamic>;
    
    return verses.map((v) {
      final Map<String, dynamic> verseData = v as Map<String, dynamic>;
      return Ayah(
        number: verseData['verse'] as int,
        surahNumber: surahNumber,
        text: verseData['text'] as String,
        textAr: verseData['text'] as String,
        translation: '',
        translationAr: '',
        juz: _getJuzForAyah(surahNumber, verseData['verse'] as int),
        page: _getPageForAyah(surahNumber, verseData['verse'] as int),
        ruku: 0,
        hizbQuarter: 0,
        sajda: 'false',
      );
    }).toList();
  }

  static Future<List<Ayah>> searchQuran(String query) async {
    final String normalized = query.trim();
    if (normalized.isEmpty) return [];

    try {
      final Map<String, dynamic> quranData = await _loadQuranData();
      
      // البحث في خيط منفصل
      return await compute(_searchQuranInIsolate, {
        'quranData': quranData,
        'query': normalized,
      });
    } catch (e) {
      throw Exception('Error searching Quran: $e');
    }
  }

  // دالة البحث في خيط منفصل
  static List<Ayah> _searchQuranInIsolate(Map<String, dynamic> params) {
    final Map<String, dynamic> quranData = params['quranData'] as Map<String, dynamic>;
    final String query = params['query'] as String;
    final List<Ayah> results = [];
    
    // Search through all surahs
    for (int i = 1; i <= 114; i++) {
      try {
        final String surahKey = i.toString();
        final List<dynamic> verses = quranData[surahKey] as List<dynamic>;
        
        for (final dynamic v in verses) {
          final Map<String, dynamic> verseData = v as Map<String, dynamic>;
          final String arabicText = verseData['text'] as String;
          
          if (arabicText.contains(query)) {
            results.add(
              Ayah(
                number: verseData['verse'] as int,
                surahNumber: i,
                text: arabicText,
                textAr: arabicText,
                translation: '',
                translationAr: '',
                juz: _getJuzForAyah(i, verseData['verse'] as int),
                page: _getPageForAyah(i, verseData['verse'] as int),
                ruku: 0,
                hizbQuarter: 0,
                sajda: 'false',
              ),
            );
          }
        }
      } catch (e) {
        // Continue with next surah
      }
    }
    
    return results;
  }

  // Helper methods for surah information
  static String _getSurahNameAr(int surahNumber) {
    final Map<int, String> surahNames = {
      1: 'الفاتحة', 2: 'البقرة', 3: 'آل عمران', 4: 'النساء', 5: 'المائدة',
      6: 'الأنعام', 7: 'الأعراف', 8: 'الأنفال', 9: 'التوبة', 10: 'يونس',
      11: 'هود', 12: 'يوسف', 13: 'الرعد', 14: 'إبراهيم', 15: 'الحجر',
      16: 'النحل', 17: 'الإسراء', 18: 'الكهف', 19: 'مريم', 20: 'طه',
      21: 'الأنبياء', 22: 'الحج', 23: 'المؤمنون', 24: 'النور', 25: 'الفرقان',
      26: 'الشعراء', 27: 'النمل', 28: 'القصص', 29: 'العنكبوت', 30: 'الروم',
      31: 'لقمان', 32: 'السجدة', 33: 'الأحزاب', 34: 'سبأ', 35: 'فاطر',
      36: 'يس', 37: 'الصافات', 38: 'ص', 39: 'الزمر', 40: 'غافر',
      41: 'فصلت', 42: 'الشورى', 43: 'الزخرف', 44: 'الدخان', 45: 'الجاثية',
      46: 'الأحقاف', 47: 'محمد', 48: 'الفتح', 49: 'الحجرات', 50: 'ق',
      51: 'الذاريات', 52: 'الطور', 53: 'النجم', 54: 'القمر', 55: 'الرحمن',
      56: 'الواقعة', 57: 'الحديد', 58: 'المجادلة', 59: 'الحشر', 60: 'الممتحنة',
      61: 'الصف', 62: 'الجمعة', 63: 'المنافقون', 64: 'التغابن', 65: 'الطلاق',
      66: 'التحريم', 67: 'الملك', 68: 'القلم', 69: 'الحاقة', 70: 'المعارج',
      71: 'نوح', 72: 'الجن', 73: 'المزمل', 74: 'المدثر', 75: 'القيامة',
      76: 'الإنسان', 77: 'المرسلات', 78: 'النبأ', 79: 'النازعات', 80: 'عبس',
      81: 'التكوير', 82: 'الإنفطار', 83: 'المطففين', 84: 'الإنشقاق', 85: 'البروج',
      86: 'الطارق', 87: 'الأعلى', 88: 'الغاشية', 89: 'الفجر', 90: 'البلد',
      91: 'الشمس', 92: 'الليل', 93: 'الضحى', 94: 'الشرح', 95: 'التين',
      96: 'العلق', 97: 'القدر', 98: 'البينة', 99: 'الزلزلة', 100: 'العاديات',
      101: 'القارعة', 102: 'التكاثر', 103: 'العصر', 104: 'الهمزة', 105: 'الفيل',
      106: 'قريش', 107: 'الماعون', 108: 'الكوثر', 109: 'الكافرون', 110: 'النصر',
      111: 'المسد', 112: 'الإخلاص', 113: 'الفلق', 114: 'الناس'
    };
    return surahNames[surahNumber] ?? 'سورة $surahNumber';
  }

  static String _getSurahNameEn(int surahNumber) {
    final Map<int, String> surahNames = {
      1: 'Al-Fatiha', 2: 'Al-Baqarah', 3: 'Aal-Imran', 4: 'An-Nisa', 5: 'Al-Ma\'idah',
      6: 'Al-An\'am', 7: 'Al-A\'raf', 8: 'Al-Anfal', 9: 'At-Tawbah', 10: 'Yunus',
      11: 'Hud', 12: 'Yusuf', 13: 'Ar-Ra\'d', 14: 'Ibrahim', 15: 'Al-Hijr',
      16: 'An-Nahl', 17: 'Al-Isra', 18: 'Al-Kahf', 19: 'Maryam', 20: 'Ta-Ha',
      21: 'Al-Anbya', 22: 'Al-Hajj', 23: 'Al-Mu\'minun', 24: 'An-Nur', 25: 'Al-Furqan',
      26: 'Ash-Shu\'ara', 27: 'An-Naml', 28: 'Al-Qasas', 29: 'Al-Ankabut', 30: 'Ar-Rum',
      31: 'Luqman', 32: 'As-Sajdah', 33: 'Al-Ahzab', 34: 'Saba', 35: 'Fatir',
      36: 'Ya-Sin', 37: 'As-Saffat', 38: 'Sad', 39: 'Az-Zumar', 40: 'Ghafir',
      41: 'Fussilat', 42: 'Ash-Shura', 43: 'Az-Zukhruf', 44: 'Ad-Dukhan', 45: 'Al-Jathiyah',
      46: 'Al-Ahqaf', 47: 'Muhammad', 48: 'Al-Fath', 49: 'Al-Hujurat', 50: 'Qaf',
      51: 'Adh-Dhariyat', 52: 'At-Tur', 53: 'An-Najm', 54: 'Al-Qamar', 55: 'Ar-Rahman',
      56: 'Al-Waqi\'ah', 57: 'Al-Hadid', 58: 'Al-Mujadila', 59: 'Al-Hashr', 60: 'Al-Mumtahanah',
      61: 'As-Saf', 62: 'Al-Jumu\'ah', 63: 'Al-Munafiqun', 64: 'At-Taghabun', 65: 'At-Talaq',
      66: 'At-Tahrim', 67: 'Al-Mulk', 68: 'Al-Qalam', 69: 'Al-Haqqah', 70: 'Al-Ma\'arij',
      71: 'Nuh', 72: 'Al-Jinn', 73: 'Al-Muzzammil', 74: 'Al-Muddathir', 75: 'Al-Qiyamah',
      76: 'Al-Insan', 77: 'Al-Mursalat', 78: 'An-Naba', 79: 'An-Nazi\'at', 80: 'Abasa',
      81: 'At-Takwir', 82: 'Al-Infitar', 83: 'Al-Mutaffifin', 84: 'Al-Inshiqaq', 85: 'Al-Buruj',
      86: 'At-Tariq', 87: 'Al-A\'la', 88: 'Al-Ghashiyah', 89: 'Al-Fajr', 90: 'Al-Balad',
      91: 'Ash-Shams', 92: 'Al-Layl', 93: 'Ad-Duha', 94: 'Ash-Sharh', 95: 'At-Tin',
      96: 'Al-Alaq', 97: 'Al-Qadr', 98: 'Al-Bayyinah', 99: 'Az-Zalzalah', 100: 'Al-Adiyat',
      101: 'Al-Qari\'ah', 102: 'At-Takathur', 103: 'Al-Asr', 104: 'Al-Humazah', 105: 'Al-Fil',
      106: 'Quraish', 107: 'Al-Ma\'un', 108: 'Al-Kawthar', 109: 'Al-Kafirun', 110: 'An-Nasr',
      111: 'Al-Masad', 112: 'Al-Ikhlas', 113: 'Al-Falaq', 114: 'An-Nas'
    };
    return surahNames[surahNumber] ?? 'Surah $surahNumber';
  }

  static String _getRevelationType(int surahNumber) {
    // Makki surahs (revealed in Mecca)
    final List<int> makkiSurahs = [
      1, 6, 7, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 50, 51, 52, 53, 54, 56, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 111, 112, 113, 114
    ];
    return makkiSurahs.contains(surahNumber) ? 'Meccan' : 'Medinan';
  }

  // Simplified Juz calculation
  static int _getJuzForAyah(int surahNumber, int ayahNumber) {
    if (surahNumber <= 2) return 1;
    if (surahNumber <= 4) return 2;
    if (surahNumber <= 6) return 3;
    if (surahNumber <= 8) return 4;
    if (surahNumber <= 10) return 5;
    if (surahNumber <= 12) return 6;
    if (surahNumber <= 15) return 7;
    if (surahNumber <= 17) return 8;
    if (surahNumber <= 20) return 9;
    if (surahNumber <= 22) return 10;
    if (surahNumber <= 25) return 11;
    if (surahNumber <= 27) return 12;
    if (surahNumber <= 29) return 13;
    if (surahNumber <= 32) return 14;
    if (surahNumber <= 34) return 15;
    if (surahNumber <= 36) return 16;
    if (surahNumber <= 38) return 17;
    if (surahNumber <= 40) return 18;
    if (surahNumber <= 42) return 19;
    if (surahNumber <= 45) return 20;
    if (surahNumber <= 47) return 21;
    if (surahNumber <= 49) return 22;
    if (surahNumber <= 51) return 23;
    if (surahNumber <= 53) return 24;
    if (surahNumber <= 55) return 25;
    if (surahNumber <= 57) return 26;
    if (surahNumber <= 59) return 27;
    if (surahNumber <= 61) return 28;
    if (surahNumber <= 64) return 29;
    if (surahNumber <= 66) return 30;
    return 30;
  }

  // Simplified page calculation
  static int _getPageForAyah(int surahNumber, int ayahNumber) {
    return ((surahNumber - 1) * 2) + ((ayahNumber - 1) ~/ 10) + 1;
  }
} 