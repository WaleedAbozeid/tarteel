import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/quran_models.dart';

class LocalDataService {
  static List<Surah> _surahs = [];
  static List<Ayah> _ayahs = [];

  // تحميل البيانات المحلية
  static Future<void> loadLocalData() async {
    await _loadSurahs();
    await _loadAyahs();
  }

  // تحميل السور من الملف المحلي
  static Future<void> _loadSurahs() async {
    try {
      final String response = await rootBundle.loadString('assets/data/sample_surahs.json');
      final List<dynamic> data = json.decode(response);
      _surahs = data.map((json) => Surah.fromJson(json)).toList();
    } catch (e) {
      print('خطأ في تحميل السور: $e');
    }
  }

  // تحميل الآيات من الملف المحلي
  static Future<void> _loadAyahs() async {
    try {
      final String response = await rootBundle.loadString('assets/data/sample_ayahs.json');
      final List<dynamic> data = json.decode(response);
      _ayahs = data.map((json) => Ayah.fromJson(json)).toList();
    } catch (e) {
      print('خطأ في تحميل الآيات: $e');
    }
  }

  // الحصول على قائمة السور
  static List<Surah> getSurahs() {
    return _surahs;
  }

  // الحصول على آيات سورة معينة
  static List<Ayah> getSurahAyahs(int surahNumber) {
    return _ayahs.where((ayah) => ayah.surahNumber == surahNumber).toList();
  }

  // الحصول على آية محددة
  static Ayah? getAyah(int surahNumber, int ayahNumber) {
    try {
      return _ayahs.firstWhere(
        (ayah) => ayah.surahNumber == surahNumber && ayah.number == ayahNumber,
      );
    } catch (e) {
      return null;
    }
  }

  // البحث في النصوص المحلية
  static List<Ayah> searchLocalQuran(String query) {
    if (query.isEmpty) return [];
    
    return _ayahs.where((ayah) {
      return ayah.textAr.contains(query) ||
             ayah.translationAr.contains(query) ||
             ayah.translation.contains(query);
    }).toList();
  }

  // الحصول على تفسير تجريبي
  static Tafsir getSampleTafsir(int surahNumber, int ayahNumber) {
    return Tafsir(
      ayahNumber: ayahNumber,
      surahNumber: surahNumber,
      text: 'هذا تفسير تجريبي للآية. في التطبيق الحقيقي سيتم جلب التفسير من API.',
      source: 'التفسير الميسر',
      author: 'مجمع الملك فهد',
    );
  }

  // الحصول على قائمة قراء تجريبية
  static List<Reciter> getSampleReciters() {
    return [
      Reciter(
        id: 'abdul_basit',
        name: 'Abdul Basit Abdul Samad',
        nameAr: 'عبد الباسط عبد الصمد',
        style: 'Egyptian',
        server: 'abdul_basit',
        rewaya: 'Hafs',
      ),
      Reciter(
        id: 'mishary_rashid',
        name: 'Mishary Rashid Alafasy',
        nameAr: 'مشاري راشد العفاسي',
        style: 'Kuwaiti',
        server: 'mishary_rashid',
        rewaya: 'Hafs',
      ),
      Reciter(
        id: 'saad_al_ghamdi',
        name: 'Saad Al-Ghamdi',
        nameAr: 'سعد الغامدي',
        style: 'Saudi',
        server: 'saad_al_ghamdi',
        rewaya: 'Hafs',
      ),
      Reciter(
        id: 'mahmoud_khalil',
        name: 'Mahmoud Khalil Al-Husary',
        nameAr: 'محمود خليل الحصري',
        style: 'Egyptian',
        server: 'mahmoud_khalil',
        rewaya: 'Hafs',
      ),
    ];
  }
} 