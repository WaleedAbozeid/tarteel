import 'package:flutter/material.dart';
import '../models/quran_models.dart';
import '../services/quran_service.dart';
import '../services/local_data_service.dart'; // Added import for LocalDataService

class QuranProvider extends ChangeNotifier {
  List<Surah> _surahs = [];
  List<Ayah> _currentSurahAyahs = [];
  List<Reciter> _reciters = [];
  List<TajweedRule> _tajweedRules = [];
  
  // نظام التخزين المؤقت
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

  // تحميل قائمة السور
  Future<void> loadSurahs() async {
    _setLoading(true);
    try {
      _surahs = await QuranService.getSurahs();
      _error = null;
    } catch (e) {
      _error = e.toString();
      // تحميل بيانات محلية كبديل
      _loadLocalSurahs();
    }
    _setLoading(false);
  }

  // تحميل بيانات محلية للسور
  void _loadLocalSurahs() {
    _surahs = [
      Surah(
        number: 1,
        name: 'Al-Fatiha',
        nameAr: 'الفاتحة',
        nameEn: 'The Opening',
        revelationType: 'Meccan',
        numberOfAyahs: 7,
        description: 'أول سورة في القرآن الكريم',
      ),
      Surah(
        number: 2,
        name: 'Al-Baqarah',
        nameAr: 'البقرة',
        nameEn: 'The Cow',
        revelationType: 'Medinan',
        numberOfAyahs: 286,
        description: 'أطول سورة في القرآن الكريم',
      ),
      Surah(
        number: 3,
        name: 'Al-Imran',
        nameAr: 'آل عمران',
        nameEn: 'The Family of Imran',
        revelationType: 'Medinan',
        numberOfAyahs: 200,
        description: 'سورة آل عمران',
      ),
    ];
    notifyListeners();
  }

  // تحميل آيات سورة معينة مع الترجمات
  Future<void> loadSurahAyahs(int surahNumber) async {
    // التحقق من التخزين المؤقت أولاً
    if (_ayahsCache.containsKey(surahNumber)) {
      _currentSurahAyahs = _ayahsCache[surahNumber]!;
      _selectedSurah = _surahs.firstWhere((s) => s.number == surahNumber);
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      // محاولة تحميل البيانات من الخدمة المحلية أولاً (أسرع)
      final localAyahs = LocalDataService.getSurahAyahs(surahNumber);
      if (localAyahs.isNotEmpty) {
        _currentSurahAyahs = localAyahs;
        _selectedSurah = _surahs.firstWhere((s) => s.number == surahNumber);
        // حفظ في التخزين المؤقت
        _ayahsCache[surahNumber] = localAyahs;
        _error = null;
        _setLoading(false);
        return;
      }

      // إذا لم تكن البيانات المحلية متاحة، استخدم API
      _currentSurahAyahs = await QuranService.getSurahAyahs(surahNumber);
      
      // تحميل الترجمات بشكل متوازي لتحسين السرعة
      await _loadTranslationsInParallel(surahNumber);
      
      _selectedSurah = _surahs.firstWhere((s) => s.number == surahNumber);
      // حفظ في التخزين المؤقت
      _ayahsCache[surahNumber] = _currentSurahAyahs;
      _error = null;
    } catch (e) {
      _error = e.toString();
      // تحميل بيانات محلية كبديل
      _loadLocalAyahs(surahNumber);
      // حفظ في التخزين المؤقت
      _ayahsCache[surahNumber] = _currentSurahAyahs;
    }
    _setLoading(false);
  }

  // تحميل الترجمات بشكل متوازي
  Future<void> _loadTranslationsInParallel(int surahNumber) async {
    if (_currentSurahAyahs.isEmpty) return;

    // تحميل الترجمات لجميع الآيات في نفس الوقت
    final futures = _currentSurahAyahs.asMap().entries.map((entry) async {
      final index = entry.key;
      final ayah = entry.value;
      
      try {
        final translation = await QuranService.getAyahTranslation(
          surahNumber, 
          ayah.number,
          edition: 'ar.muyassar'
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
        // تجاهل الأخطاء في الترجمات الفردية
        print('خطأ في تحميل ترجمة الآية ${ayah.number}: $e');
      }
    });

    // انتظار اكتمال جميع الترجمات
    await Future.wait(futures);
    // إشعار مرة واحدة فقط بعد اكتمال جميع الترجمات
    notifyListeners();
  }

  // تحميل بيانات محلية للآيات
  void _loadLocalAyahs(int surahNumber) {
    if (surahNumber == 1) {
      _currentSurahAyahs = [
        Ayah(
          number: 1,
          surahNumber: 1,
          text: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
          textAr: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
          translation: 'In the name of Allah, the Entirely Merciful, the Especially Merciful.',
          translationAr: 'باسم الله الرحمن الرحيم',
          juz: 1,
          page: 1,
          ruku: 1,
          hizbQuarter: 1,
          sajda: 'false',
        ),
        Ayah(
          number: 2,
          surahNumber: 1,
          text: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
          textAr: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
          translation: 'All praise is due to Allah, Lord of the worlds.',
          translationAr: 'الحمد لله رب العالمين',
          juz: 1,
          page: 1,
          ruku: 1,
          hizbQuarter: 1,
          sajda: 'false',
        ),
        Ayah(
          number: 3,
          surahNumber: 1,
          text: 'الرَّحْمَٰنِ الرَّحِيمِ',
          textAr: 'الرَّحْمَٰنِ الرَّحِيمِ',
          translation: 'The Entirely Merciful, the Especially Merciful.',
          translationAr: 'الرحمن الرحيم',
          juz: 1,
          page: 1,
          ruku: 1,
          hizbQuarter: 1,
          sajda: 'false',
        ),
        Ayah(
          number: 4,
          surahNumber: 1,
          text: 'مَالِكِ يَوْمِ الدِّينِ',
          textAr: 'مَالِكِ يَوْمِ الدِّينِ',
          translation: 'Sovereign of the Day of Recompense.',
          translationAr: 'مالك يوم الدين',
          juz: 1,
          page: 1,
          ruku: 1,
          hizbQuarter: 1,
          sajda: 'false',
        ),
        Ayah(
          number: 5,
          surahNumber: 1,
          text: 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
          textAr: 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
          translation: 'It is You we worship and You we ask for help.',
          translationAr: 'إياك نعبد وإياك نستعين',
          juz: 1,
          page: 1,
          ruku: 1,
          hizbQuarter: 1,
          sajda: 'false',
        ),
        Ayah(
          number: 6,
          surahNumber: 1,
          text: 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
          textAr: 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
          translation: 'Guide us to the straight path.',
          translationAr: 'اهدنا الصراط المستقيم',
          juz: 1,
          page: 1,
          ruku: 1,
          hizbQuarter: 1,
          sajda: 'false',
        ),
        Ayah(
          number: 7,
          surahNumber: 1,
          text: 'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
          textAr: 'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
          translation: 'The path of those upon whom You have bestowed favor, not of those who have evoked [Your] anger or of those who are astray.',
          translationAr: 'صراط الذين أنعمت عليهم غير المغضوب عليهم ولا الضالين',
          juz: 1,
          page: 1,
          ruku: 1,
          hizbQuarter: 1,
          sajda: 'false',
        ),
      ];
    } else if (surahNumber == 112) {
      // سورة الإخلاص
      _currentSurahAyahs = [
        Ayah(
          number: 1,
          surahNumber: 112,
          text: 'قُلْ هُوَ اللَّهُ أَحَدٌ',
          textAr: 'قُلْ هُوَ اللَّهُ أَحَدٌ',
          translation: 'Say, "He is Allah, [who is] One."',
          translationAr: 'قل هو الله أحد',
          juz: 30,
          page: 602,
          ruku: 1,
          hizbQuarter: 4,
          sajda: 'false',
        ),
        Ayah(
          number: 2,
          surahNumber: 112,
          text: 'اللَّهُ الصَّمَدُ',
          textAr: 'اللَّهُ الصَّمَدُ',
          translation: 'Allah, the Eternal Refuge.',
          translationAr: 'الله الصمد',
          juz: 30,
          page: 602,
          ruku: 1,
          hizbQuarter: 4,
          sajda: 'false',
        ),
        Ayah(
          number: 3,
          surahNumber: 112,
          text: 'لَمْ يَلِدْ وَلَمْ يُولَدْ',
          textAr: 'لَمْ يَلِدْ وَلَمْ يُولَدْ',
          translation: 'He neither begets nor is born.',
          translationAr: 'لم يلد ولم يولد',
          juz: 30,
          page: 602,
          ruku: 1,
          hizbQuarter: 4,
          sajda: 'false',
        ),
        Ayah(
          number: 4,
          surahNumber: 112,
          text: 'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
          textAr: 'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
          translation: 'Nor is there to Him any equivalent.',
          translationAr: 'ولم يكن له كفوا أحد',
          juz: 30,
          page: 602,
          ruku: 1,
          hizbQuarter: 4,
          sajda: 'false',
        ),
      ];
    } else if (surahNumber == 113) {
      // سورة الفلق
      _currentSurahAyahs = [
        Ayah(
          number: 1,
          surahNumber: 113,
          text: 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ',
          textAr: 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ',
          translation: 'Say, "I seek refuge in the Lord of daybreak."',
          translationAr: 'قل أعوذ برب الفلق',
          juz: 30,
          page: 603,
          ruku: 1,
          hizbQuarter: 4,
          sajda: 'false',
        ),
        Ayah(
          number: 2,
          surahNumber: 113,
          text: 'مِن شَرِّ مَا خَلَقَ',
          textAr: 'مِن شَرِّ مَا خَلَقَ',
          translation: 'From the evil of that which He created.',
          translationAr: 'من شر ما خلق',
          juz: 30,
          page: 603,
          ruku: 1,
          hizbQuarter: 4,
          sajda: 'false',
        ),
        Ayah(
          number: 3,
          surahNumber: 113,
          text: 'وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ',
          textAr: 'وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ',
          translation: 'And from the evil of darkness when it settles.',
          translationAr: 'ومن شر غاسق إذا وقب',
          juz: 30,
          page: 603,
          ruku: 1,
          hizbQuarter: 4,
          sajda: 'false',
        ),
        Ayah(
          number: 4,
          surahNumber: 113,
          text: 'وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ',
          textAr: 'وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ',
          translation: 'And from the evil of the blowers in knots.',
          translationAr: 'ومن شر النفاثات في العقد',
          juz: 30,
          page: 603,
          ruku: 1,
          hizbQuarter: 4,
          sajda: 'false',
        ),
        Ayah(
          number: 5,
          surahNumber: 113,
          text: 'وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ',
          textAr: 'وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ',
          translation: 'And from the evil of an envier when he envies.',
          translationAr: 'ومن شر حاسد إذا حسد',
          juz: 30,
          page: 603,
          ruku: 1,
          hizbQuarter: 4,
          sajda: 'false',
        ),
      ];
    } else if (surahNumber == 114) {
      // سورة الناس
      _currentSurahAyahs = [
        Ayah(
          number: 1,
          surahNumber: 114,
          text: 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ',
          textAr: 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ',
          translation: 'Say, "I seek refuge in the Lord of mankind."',
          translationAr: 'قل أعوذ برب الناس',
          juz: 30,
          page: 603,
          ruku: 1,
          hizbQuarter: 4,
          sajda: 'false',
        ),
        Ayah(
          number: 2,
          surahNumber: 114,
          text: 'مَلِكِ النَّاسِ',
          textAr: 'مَلِكِ النَّاسِ',
          translation: 'The Sovereign of mankind.',
          translationAr: 'ملك الناس',
          juz: 30,
          page: 603,
          ruku: 1,
          hizbQuarter: 4,
          sajda: 'false',
        ),
        Ayah(
          number: 3,
          surahNumber: 114,
          text: 'إِلَٰهِ النَّاسِ',
          textAr: 'إِلَٰهِ النَّاسِ',
          translation: 'The God of mankind.',
          translationAr: 'إله الناس',
          juz: 30,
          page: 603,
          ruku: 1,
          hizbQuarter: 4,
          sajda: 'false',
        ),
        Ayah(
          number: 4,
          surahNumber: 114,
          text: 'مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ',
          textAr: 'مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ',
          translation: 'From the evil of the retreating whisperer.',
          translationAr: 'من شر الوسواس الخناس',
          juz: 30,
          page: 603,
          ruku: 1,
          hizbQuarter: 4,
          sajda: 'false',
        ),
        Ayah(
          number: 5,
          surahNumber: 114,
          text: 'الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ',
          textAr: 'الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ',
          translation: 'Who whispers [evil] into the breasts of mankind.',
          translationAr: 'الذي يوسوس في صدور الناس',
          juz: 30,
          page: 603,
          ruku: 1,
          hizbQuarter: 4,
          sajda: 'false',
        ),
        Ayah(
          number: 6,
          surahNumber: 114,
          text: 'مِنَ الْجِنَّةِ وَالنَّاسِ',
          textAr: 'مِنَ الْجِنَّةِ وَالنَّاسِ',
          translation: 'From among the jinn and mankind.',
          translationAr: 'من الجنة والناس',
          juz: 30,
          page: 603,
          ruku: 1,
          hizbQuarter: 4,
          sajda: 'false',
        ),
      ];
    } else {
      _currentSurahAyahs = [];
    }
    notifyListeners();
  }

  // تحميل قائمة القراء
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

  // تحميل قواعد التجويد
  void loadTajweedRules() {
    _tajweedRules = QuranService.getTajweedRules();
    notifyListeners();
  }

  // تحديد سورة
  void selectSurah(Surah surah) {
    _selectedSurah = surah;
    notifyListeners();
  }

  // تحديد آية
  void selectAyah(Ayah ayah) {
    _selectedAyah = ayah;
    notifyListeners();
  }

  // تحديد قارئ
  void selectReciter(Reciter reciter) {
    _selectedReciter = reciter;
    notifyListeners();
  }

  // تحميل تفسير آية
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

  // البحث في القرآن
  Future<List<Ayah>> searchQuran(String query) async {
    try {
      return await QuranService.searchQuran(query);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // الحصول على رابط الصوت
  String getAudioUrl(int surahNumber, int ayahNumber) {
    // استخدام قارئ افتراضي إذا لم يتم اختيار قارئ
    String reciterId = 'mishary_rashid_alafasy'; // أفضل قارئ للسرعة والوضوح
    if (_selectedReciter != null) {
      reciterId = _selectedReciter!.id;
    }
    return QuranService.getAudioUrl(reciterId, surahNumber, ayahNumber);
  }

  // الحصول على رابط الصوت عالي الجودة
  String getHighQualityAudioUrl(int surahNumber, int ayahNumber) {
    String reciterId = 'mishary_rashid_alafasy';
    if (_selectedReciter != null) {
      reciterId = _selectedReciter!.id;
    }
    return QuranService.getHighQualityAudioUrl(reciterId, surahNumber, ayahNumber);
  }

  // الحصول على رابط الصوت من خدمة بديلة
  String getAlternativeAudioUrl(int surahNumber, int ayahNumber) {
    String reciterId = 'mishary_rashid_alafasy';
    if (_selectedReciter != null) {
      reciterId = _selectedReciter!.id;
    }
    return QuranService.getAlternativeAudioUrl(reciterId, surahNumber, ayahNumber);
  }

  // اختيار أفضل قارئ تلقائياً
  void selectBestReciter() {
    // اختيار أفضل قارئ للسرعة والوضوح
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

  // مسح الخطأ
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // مسح التخزين المؤقت
  void clearCache() {
    _ayahsCache.clear();
    _surahsCache.clear();
    notifyListeners();
  }

  // مسح تخزين مؤقت لسورة محددة
  void clearSurahCache(int surahNumber) {
    _ayahsCache.remove(surahNumber);
    notifyListeners();
  }

  // تحميل مسبق لسور شائعة
  Future<void> preloadCommonSurahs() async {
    final commonSurahs = [1, 2, 36, 55, 67, 112, 113, 114]; // السور الأكثر استخداماً
    for (int surahNumber in commonSurahs) {
      if (!_ayahsCache.containsKey(surahNumber)) {
        // تحميل في الخلفية بدون إظهار مؤشر التحميل
        _loadSurahInBackground(surahNumber);
      }
    }
  }

  // تحميل سورة في الخلفية
  Future<void> _loadSurahInBackground(int surahNumber) async {
    try {
      final localAyahs = LocalDataService.getSurahAyahs(surahNumber);
      if (localAyahs.isNotEmpty) {
        _ayahsCache[surahNumber] = localAyahs;
        return;
      }

      final ayahs = await QuranService.getSurahAyahs(surahNumber);
      _ayahsCache[surahNumber] = ayahs;
    } catch (e) {
      // تجاهل الأخطاء في التحميل المسبق
      print('خطأ في التحميل المسبق للسورة $surahNumber: $e');
    }
  }

  // تحسين دالة تحميل السور
  Future<void> loadSurahsOptimized() async {
    // التحقق من التخزين المؤقت أولاً
    if (_surahs.isNotEmpty) {
      return;
    }

    _setLoading(true);
    try {
      _surahs = await QuranService.getSurahs();
      _error = null;
      
      // بدء التحميل المسبق للسور الشائعة
      preloadCommonSurahs();
    } catch (e) {
      _error = e.toString();
      _loadLocalSurahs();
    }
    _setLoading(false);
  }

  // تعيين حالة التحميل
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
} 