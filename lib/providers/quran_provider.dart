import 'package:flutter/material.dart';
import '../models/quran_models.dart';
import '../services/quran_service.dart';
import '../services/local_data_service.dart';

class QuranProvider extends ChangeNotifier {
  List<Surah> _surahs = [];
  List<Ayah> _currentSurahAyahs = [];
  List<Reciter> _reciters = [];
  List<TajweedRule> _tajweedRules = [];
  
  // Cache system
  static final Map<int, List<Ayah>> _ayahsCache = {};
  static final Map<int, Surah> _surahsCache = {};
  
  Surah? _selectedSurah;
  Ayah? _selectedAyah;
  Reciter? _selectedReciter;
  Tafsir? _currentTafsir;
  
  bool _isLoading = false;
  String? _error;
  
  // Getters
  List<Surah> get surahs => _surahs;
  List<Ayah> get currentSurahAyahs => _currentSurahAyahs;
  List<Reciter> get reciters => _reciters;
  List<TajweedRule> get tajweedRules => _tajweedRules;
  
  Surah? get selectedSurah => _selectedSurah;
  Ayah? get selectedAyah => _selectedAyah;
  Reciter? get selectedReciter => _selectedReciter;
  Tafsir? get currentTafsir => _currentTafsir;
  
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load surahs from JSON files
  Future<void> loadSurahs() async {
    // تجنب إعادة التحميل إذا كانت البيانات موجودة
    if (_surahs.isNotEmpty) {
      return;
    }
    
    _setLoading(true);
    try {
      final List<Surah> localSurahs = await LocalDataService.getSurahs();
      if (localSurahs.isNotEmpty) {
        _surahs = localSurahs;
        _error = null;
        print('تم تحميل ${localSurahs.length} سورة بنجاح');
      } else {
        _surahs = [];
        _error = 'لا يمكن تحميل السور من ملفات JSON';
        print('لا توجد سور متاحة');
      }
    } catch (e) {
      _error = e.toString();
      _surahs = [];
      print('خطأ في تحميل السور: $e');
    }
    _setLoading(false);
  }

  // Load ayahs for a specific surah
  Future<void> loadSurahAyahs(int surahNumber) async {
    // Check cache first
    if (_ayahsCache.containsKey(surahNumber)) {
      _currentSurahAyahs = _ayahsCache[surahNumber]!;
      _selectedSurah = _surahs.firstWhere((s) => s.number == surahNumber, orElse: () => _surahs.first);
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      final List<Ayah> localAyahs = await LocalDataService.getSurahAyahsAsync(surahNumber);
      _currentSurahAyahs = localAyahs;
      
      // تحسين البحث عن السورة
      _selectedSurah = _surahs.isNotEmpty 
          ? _surahs.firstWhere((s) => s.number == surahNumber, orElse: () => _surahs.first)
          : null;
      
      _ayahsCache[surahNumber] = localAyahs;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _currentSurahAyahs = [];
      _ayahsCache[surahNumber] = [];
    }
    _setLoading(false);
  }

  // Load translations in parallel (for API data)
  Future<void> _loadTranslationsInParallel(int surahNumber) async {
    if (_currentSurahAyahs.isEmpty) return;

    final futures = _currentSurahAyahs.asMap().entries.map((entry) async {
      final index = entry.key;
      final ayah = entry.value;
      try {
        final translation = await QuranService.getAyahTranslation(
          surahNumber, 
          ayah.number,
          edition: 'ar.muyassar',
        );
        if (translation.isNotEmpty) {
          _currentSurahAyahs[index] = Ayah(
            number: ayah.number,
            surahNumber: ayah.surahNumber,
            text: ayah.text,
            textAr: ayah.textAr,
            translation: translation,
            translationAr: translation,
            juz: ayah.juz,
            page: ayah.page,
            ruku: ayah.ruku,
            hizbQuarter: ayah.hizbQuarter,
            sajda: ayah.sajda,
          );
        }
      } catch (e) {
        // Ignore individual translation errors
      }
    });

    await Future.wait(futures);
    notifyListeners();
  }

  // Load reciters list
  Future<void> loadReciters() async {
    _setLoading(true);
    try {
      _reciters = await QuranService.getReciters();
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  // Load tajweed rules
  void loadTajweedRules() {
    _tajweedRules = QuranService.getTajweedRules();
    notifyListeners();
  }

  // Select surah
  void selectSurah(Surah surah) {
    _selectedSurah = surah;
    notifyListeners();
  }

  // Select ayah
  void selectAyah(Ayah ayah) {
    _selectedAyah = ayah;
    notifyListeners();
  }

  // Select reciter
  void selectReciter(Reciter reciter) {
    _selectedReciter = reciter;
    notifyListeners();
  }

  // Load ayah tafsir
  Future<void> loadAyahTafsir(int surahNumber, int ayahNumber) async {
    _setLoading(true);
    try {
      _currentTafsir = await QuranService.getAyahTafsir(surahNumber, ayahNumber);
      _error = null;
    } catch (e) {
      _error = e.toString();
    }
    _setLoading(false);
  }

  // Search in Quran
  Future<List<Ayah>> searchQuran(String query) async {
    try {
      return await LocalDataService.searchQuran(query);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Get audio URL
  String getAudioUrl(int surahNumber, int ayahNumber) {
    String reciterId = 'mishary_rashid_alafasy';
    if (_selectedReciter != null) {
      reciterId = _selectedReciter!.id;
    }
    return QuranService.getAudioUrl(reciterId, surahNumber, ayahNumber);
  }

  // Get high quality audio URL
  String getHighQualityAudioUrl(int surahNumber, int ayahNumber) {
    String reciterId = 'mishary_rashid_alafasy';
    if (_selectedReciter != null) {
      reciterId = _selectedReciter!.id;
    }
    return QuranService.getHighQualityAudioUrl(reciterId, surahNumber, ayahNumber);
  }

  // Get alternative audio URL
  String getAlternativeAudioUrl(int surahNumber, int ayahNumber) {
    String reciterId = 'mishary_rashid_alafasy';
    if (_selectedReciter != null) {
      reciterId = _selectedReciter!.id;
    }
    return QuranService.getAlternativeAudioUrl(reciterId, surahNumber, ayahNumber);
  }

  // Auto-select best reciter
  void selectBestReciter() {
    _selectedReciter = Reciter(
      id: 'mishary_rashid_alafasy',
      name: 'Mishary Rashid Alafasy',
      nameAr: 'مشاري راشد العفاسي',
      style: 'Modern',
      server: 'mp3quran',
      rewaya: 'Hafs',
    );
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear cache
  void clearCache() {
    _ayahsCache.clear();
    _surahsCache.clear();
    notifyListeners();
  }

  // Clear specific surah cache
  void clearSurahCache(int surahNumber) {
    _ayahsCache.remove(surahNumber);
    notifyListeners();
  }

  // Preload common surahs
  Future<void> preloadCommonSurahs() async {
    final commonSurahs = [1, 2, 36, 55, 67, 112, 113, 114];
    for (int surahNumber in commonSurahs) {
      if (!_ayahsCache.containsKey(surahNumber)) {
        _loadSurahInBackground(surahNumber);
      }
    }
  }

  // Load surah in background
  Future<void> _loadSurahInBackground(int surahNumber) async {
    try {
      final localAyahs = await LocalDataService.getSurahAyahsAsync(surahNumber);
      if (localAyahs.isNotEmpty) {
        _ayahsCache[surahNumber] = localAyahs;
      }
    } catch (e) {
      // Ignore background loading errors
    }
  }

  // Optimized surah loading
  Future<void> loadSurahsOptimized() async {
    if (_surahs.isNotEmpty) {
      return;
    }

    _setLoading(true);
    
    try {
      final localSurahs = await LocalDataService.getSurahs();
      
      if (localSurahs.isNotEmpty) {
        _surahs = localSurahs;
        _error = null;
        preloadCommonSurahs();
      } else {
        _surahs = [];
        _error = 'لا يمكن تحميل السور من ملفات JSON';
      }
    } catch (e) {
      _error = e.toString();
      _surahs = [];
    }
    _setLoading(false);
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
} 