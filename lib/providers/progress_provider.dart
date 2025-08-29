import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/quran_models.dart';

class ProgressProvider extends ChangeNotifier {
  // مفاتيح التخزين المحلي
  static const String _readSurahsKey = 'read_surahs';
  static const String _memorizedAyahsKey = 'memorized_ayahs';
  static const String _recitationScoresKey = 'recitation_scores';
  static const String _dailyGoalKey = 'daily_goal';
  static const String _lastReadDateKey = 'last_read_date';
  static const String _streakCountKey = 'streak_count';

  // بيانات التقدم
  final Set<int> _readSurahs = {};
  final Map<String, Set<int>> _memorizedAyahs = {}; // surahId_ayahNumber
  final Map<String, double> _recitationScores = {}; // surahId_ayahNumber: score
  int _dailyGoalPages = 5;
  DateTime? _lastReadDate;
  int _streakCount = 0;
  int _todayReadPages = 0;

  // الحصول على البيانات
  Set<int> get readSurahs => _readSurahs;
  Map<String, Set<int>> get memorizedAyahs => _memorizedAyahs;
  Map<String, double> get recitationScores => _recitationScores;
  int get dailyGoalPages => _dailyGoalPages;
  int get streakCount => _streakCount;
  int get todayReadPages => _todayReadPages;
  double get dailyGoalProgress => _todayReadPages / _dailyGoalPages;

  ProgressProvider() {
    _loadProgress();
  }

  // تحميل البيانات من التخزين المحلي
  Future<void> _loadProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // تحميل السور المقروءة
      final readSurahsList = prefs.getStringList(_readSurahsKey) ?? [];
      _readSurahs.clear();
      _readSurahs.addAll(readSurahsList.map((s) => int.parse(s)));

      // تحميل الآيات المحفوظة
      final memorizedAyahsJson = prefs.getStringList(_memorizedAyahsKey) ?? [];
      _memorizedAyahs.clear();
      for (final entry in memorizedAyahsJson) {
        final parts = entry.split('_');
        if (parts.length == 2) {
          final surahId = parts[0];
          final ayahNumber = int.parse(parts[1]);
          if (!_memorizedAyahs.containsKey(surahId)) {
            _memorizedAyahs[surahId] = {};
          }
          _memorizedAyahs[surahId]!.add(ayahNumber);
        }
      }

      // تحميل درجات التلاوة
      final recitationScoresJson = prefs.getStringList(_recitationScoresKey) ?? [];
      _recitationScores.clear();
      for (final entry in recitationScoresJson) {
        final parts = entry.split(':');
        if (parts.length == 2) {
          final key = parts[0];
          final score = double.parse(parts[1]);
          _recitationScores[key] = score;
        }
      }

      // تحميل الهدف اليومي
      _dailyGoalPages = prefs.getInt(_dailyGoalKey) ?? 5;

      // تحميل تاريخ آخر قراءة وعدد أيام التتابع
      final lastReadDateString = prefs.getString(_lastReadDateKey);
      if (lastReadDateString != null) {
        _lastReadDate = DateTime.parse(lastReadDateString);
        _updateStreak();
      }
      _streakCount = prefs.getInt(_streakCountKey) ?? 0;

      notifyListeners();
    } catch (e) {
      // استخدام القيم الافتراضية في حالة حدوث خطأ
    }
  }

  // حفظ البيانات في التخزين المحلي
  Future<void> _saveProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // حفظ السور المقروءة
      await prefs.setStringList(_readSurahsKey, _readSurahs.map((id) => id.toString()).toList());

      // حفظ الآيات المحفوظة
      final memorizedAyahsList = <String>[];
      for (final surahId in _memorizedAyahs.keys) {
        for (final ayahNumber in _memorizedAyahs[surahId]!) {
          memorizedAyahsList.add('${surahId}_$ayahNumber');
        }
      }
      await prefs.setStringList(_memorizedAyahsKey, memorizedAyahsList);

      // حفظ درجات التلاوة
      final recitationScoresList = <String>[];
      for (final key in _recitationScores.keys) {
        recitationScoresList.add('$key:${_recitationScores[key]}');
      }
      await prefs.setStringList(_recitationScoresKey, recitationScoresList);

      // حفظ الهدف اليومي
      await prefs.setInt(_dailyGoalKey, _dailyGoalPages);

      // حفظ تاريخ آخر قراءة وعدد أيام التتابع
      if (_lastReadDate != null) {
        await prefs.setString(_lastReadDateKey, _lastReadDate!.toIso8601String());
      }
      await prefs.setInt(_streakCountKey, _streakCount);
    } catch (e) {
      // تجاهل أخطاء التخزين
    }
  }

  // تحديث عدد أيام التتابع
  void _updateStreak() {
    if (_lastReadDate == null) return;
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastRead = DateTime(_lastReadDate!.year, _lastReadDate!.month, _lastReadDate!.day);
    
    // إذا كانت آخر قراءة بالأمس، زيادة عدد أيام التتابع
    if (today.difference(lastRead).inDays == 1) {
      _streakCount++;
    } 
    // إذا كانت آخر قراءة قبل أكثر من يوم، إعادة تعيين عدد أيام التتابع
    else if (today.difference(lastRead).inDays > 1) {
      _streakCount = 1;
    }
    // إذا كانت آخر قراءة اليوم، لا تغيير في عدد أيام التتابع
  }

  // تسجيل قراءة سورة
  Future<void> markSurahAsRead(int surahId, int pagesCount) async {
    _readSurahs.add(surahId);
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // إذا كان اليوم مختلفًا عن آخر يوم قراءة، إعادة تعيين عدد الصفحات المقروءة اليوم
    if (_lastReadDate == null || 
        DateTime(_lastReadDate!.year, _lastReadDate!.month, _lastReadDate!.day) != today) {
      _todayReadPages = 0;
    }
    
    _todayReadPages += pagesCount;
    _lastReadDate = now;
    _updateStreak();
    
    notifyListeners();
    await _saveProgress();
  }

  // تسجيل حفظ آية
  Future<void> markAyahAsMemorized(String surahId, int ayahNumber) async {
    if (!_memorizedAyahs.containsKey(surahId)) {
      _memorizedAyahs[surahId] = {};
    }
    _memorizedAyahs[surahId]!.add(ayahNumber);
    
    notifyListeners();
    await _saveProgress();
  }

  // تسجيل درجة تلاوة
  Future<void> saveRecitationScore(String surahId, int ayahNumber, double score) async {
    final key = '${surahId}_$ayahNumber';
    _recitationScores[key] = score;
    
    notifyListeners();
    await _saveProgress();
  }

  // تعيين الهدف اليومي
  Future<void> setDailyGoal(int pages) async {
    _dailyGoalPages = pages;
    
    notifyListeners();
    await _saveProgress();
  }

  // الحصول على درجة تلاوة آية
  double getRecitationScore(String surahId, int ayahNumber) {
    final key = '${surahId}_$ayahNumber';
    return _recitationScores[key] ?? 0.0;
  }

  // التحقق مما إذا كانت الآية محفوظة
  bool isAyahMemorized(String surahId, int ayahNumber) {
    if (!_memorizedAyahs.containsKey(surahId)) return false;
    return _memorizedAyahs[surahId]!.contains(ayahNumber);
  }

  // الحصول على عدد الآيات المحفوظة في سورة
  int getMemorizedAyahsCount(String surahId) {
    if (!_memorizedAyahs.containsKey(surahId)) return 0;
    return _memorizedAyahs[surahId]!.length;
  }

  // الحصول على نسبة الحفظ في سورة
  double getMemorizationPercentage(String surahId, int totalAyahs) {
    final memorizedCount = getMemorizedAyahsCount(surahId);
    if (totalAyahs == 0) return 0.0;
    return memorizedCount / totalAyahs;
  }
}