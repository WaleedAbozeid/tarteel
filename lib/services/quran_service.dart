import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/quran_models.dart';

class QuranService {
  static const String baseUrl = 'https://api.alquran.cloud/v1';
  static const String tafsirUrl = 'https://api.alquran.cloud/v1/tafsir';
  
  // الحصول على قائمة السور
  static Future<List<Surah>> getSurahs() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/surah'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> surahsData = data['data'];
        
        List<Surah> surahs = [];
        for (var surahData in surahsData) {
          surahs.add(Surah(
            number: surahData['number'],
            name: surahData['englishName'],
            nameAr: surahData['name'],
            nameEn: surahData['englishName'],
            revelationType: surahData['revelationType'],
            numberOfAyahs: surahData['numberOfAyahs'],
            description: surahData['englishNameTranslation'] ?? '',
          ));
        }
        
        return surahs;
      } else {
        throw Exception('فشل في تحميل السور: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // الحصول على آيات سورة معينة
  static Future<List<Ayah>> getSurahAyahs(int surahNumber) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/surah/$surahNumber/quran-simple'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> ayahsData = data['data']['ayahs'];
        
        List<Ayah> ayahs = [];
        for (var ayahData in ayahsData) {
          ayahs.add(Ayah(
            number: ayahData['numberInSurah'],
            surahNumber: surahNumber,
            text: ayahData['text'],
            textAr: ayahData['text'],
            translation: '', // سنحصل عليها من API منفصل
            translationAr: '', // سنحصل عليها من API منفصل
            juz: ayahData['juz'],
            page: ayahData['page'],
            ruku: ayahData['ruku'],
            hizbQuarter: ayahData['hizbQuarter'],
            sajda: ayahData['sajda'].toString(),
          ));
        }
        
        return ayahs;
      } else {
        throw Exception('فشل في تحميل آيات السورة: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // الحصول على ترجمة آية
  static Future<String> getAyahTranslation(int surahNumber, int ayahNumber, {String edition = 'ar.muyassar'}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/surah/$surahNumber/$ayahNumber/$edition'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['text'];
      } else {
        return '';
      }
    } catch (e) {
      return '';
    }
  }

  // الحصول على تفسير آية
  static Future<Tafsir> getAyahTafsir(int surahNumber, int ayahNumber) async {
    try {
      final response = await http.get(
        Uri.parse('$tafsirUrl/ar.muyassar/$surahNumber/$ayahNumber'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Tafsir(
          ayahNumber: ayahNumber,
          surahNumber: surahNumber,
          text: data['data']['text'],
          source: 'التفسير الميسر',
          author: 'مجمع الملك فهد',
        );
      } else {
        throw Exception('فشل في تحميل التفسير: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // البحث في القرآن
  static Future<List<Ayah>> searchQuran(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/search/$query/all/quran-simple'),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> searchResults = data['data']['matches'];
        
        List<Ayah> ayahs = [];
        for (var result in searchResults) {
          ayahs.add(Ayah(
            number: result['numberInSurah'],
            surahNumber: result['surah']['number'],
            text: result['text'],
            textAr: result['text'],
            translation: '',
            translationAr: '',
            juz: result['juz'],
            page: result['page'],
            ruku: result['ruku'],
            hizbQuarter: result['hizbQuarter'],
            sajda: result['sajda'].toString(),
          ));
        }
        
        return ayahs;
      } else {
        throw Exception('فشل في البحث: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('خطأ في الاتصال: $e');
    }
  }

  // الحصول على قائمة القراء
  static Future<List<Reciter>> getReciters() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/edition'));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> editions = data['data'];
        
        List<Reciter> reciters = [];
        for (var edition in editions) {
          if (edition['format'] == 'audio') {
            reciters.add(Reciter(
              id: edition['identifier'],
              name: edition['englishName'],
              nameAr: edition['name'],
              style: edition['type'],
              server: edition['identifier'],
              rewaya: edition['format'],
            ));
          }
        }
        
        // إضافة قراء محسنة يدوياً
        reciters.addAll([
          Reciter(
            id: 'mishary_rashid_alafasy',
            name: 'Mishary Rashid Alafasy',
            nameAr: 'مشاري راشد العفاسي',
            style: 'Modern',
            server: 'mp3quran',
            rewaya: 'Hafs',
          ),
          Reciter(
            id: 'sudais_shuraim',
            name: 'Abdur-Rahman As-Sudais & Sa\'ud Al-Shuraim',
            nameAr: 'عبد الرحمن السديس وسعود الشريم',
            style: 'Traditional',
            server: 'mp3quran',
            rewaya: 'Hafs',
          ),
          Reciter(
            id: 'maher_al_mueaqly',
            name: 'Maher Al Mueaqly',
            nameAr: 'ماهر المعيقلي',
            style: 'Modern',
            server: 'mp3quran',
            rewaya: 'Hafs',
          ),
          Reciter(
            id: 'ahmed_al_ajmi',
            name: 'Ahmed Al Ajmi',
            nameAr: 'أحمد العجمي',
            style: 'Traditional',
            server: 'mp3quran',
            rewaya: 'Hafs',
          ),
          Reciter(
            id: 'ali_hudhaify',
            name: 'Ali Hudhaify',
            nameAr: 'علي الحذيفي',
            style: 'Traditional',
            server: 'mp3quran',
            rewaya: 'Hafs',
          ),
          Reciter(
            id: 'saad_al_ghamdi',
            name: 'Saad Al Ghamdi',
            nameAr: 'سعد الغامدي',
            style: 'Modern',
            server: 'mp3quran',
            rewaya: 'Hafs',
          ),
          Reciter(
            id: 'abdullah_basfar',
            name: 'Abdullah Basfar',
            nameAr: 'عبد الله بصفر',
            style: 'Traditional',
            server: 'mp3quran',
            rewaya: 'Hafs',
          ),
          Reciter(
            id: 'muhammad_ayyub',
            name: 'Muhammad Ayyub',
            nameAr: 'محمد أيوب',
            style: 'Traditional',
            server: 'mp3quran',
            rewaya: 'Hafs',
          ),
          Reciter(
            id: 'abu_bakr_ash_shaatree',
            name: 'Abu Bakr Ash-Shaatree',
            nameAr: 'أبو بكر الشاطري',
            style: 'Modern',
            server: 'mp3quran',
            rewaya: 'Hafs',
          ),
          Reciter(
            id: 'salah_al_budair',
            name: 'Salah Al Budair',
            nameAr: 'صلاح البدير',
            style: 'Modern',
            server: 'mp3quran',
            rewaya: 'Hafs',
          ),
        ]);
        
        return reciters;
      } else {
        throw Exception('فشل في تحميل القراء: ${response.statusCode}');
      }
    } catch (e) {
      // إرجاع قائمة افتراضية في حالة فشل الاتصال
      return [
        Reciter(
          id: 'mishary_rashid_alafasy',
          name: 'Mishary Rashid Alafasy',
          nameAr: 'مشاري راشد العفاسي',
          style: 'Modern',
          server: 'mp3quran',
          rewaya: 'Hafs',
        ),
        Reciter(
          id: 'abdul_basit_abdul_samad',
          name: 'Abdul Basit Abdul Samad',
          nameAr: 'عبد الباسط عبد الصمد',
          style: 'Traditional',
          server: 'mp3quran',
          rewaya: 'Hafs',
        ),
        Reciter(
          id: 'sudais_shuraim',
          name: 'Abdur-Rahman As-Sudais & Sa\'ud Al-Shuraim',
          nameAr: 'عبد الرحمن السديس وسعود الشريم',
          style: 'Traditional',
          server: 'mp3quran',
          rewaya: 'Hafs',
        ),
        Reciter(
          id: 'maher_al_mueaqly',
          name: 'Maher Al Mueaqly',
          nameAr: 'ماهر المعيقلي',
          style: 'Modern',
          server: 'mp3quran',
          rewaya: 'Hafs',
        ),
        Reciter(
          id: 'ahmed_al_ajmi',
          name: 'Ahmed Al Ajmi',
          nameAr: 'أحمد العجمي',
          style: 'Traditional',
          server: 'mp3quran',
          rewaya: 'Hafs',
        ),
      ];
    }
  }

  // الحصول على رابط الصوت لآية
  static String getAudioUrl(String reciterId, int surahNumber, int ayahNumber) {
    // تنسيق رقم السورة والآية بشكل صحيح
    String surahStr = surahNumber.toString().padLeft(3, '0');
    String ayahStr = ayahNumber.toString().padLeft(3, '0');
    
    // استخدام روابط صوتية من Quran.com API
    switch (reciterId) {
      case 'abdul_basit_abdul_samad':
        return 'https://verses.quran.com/AbdulBaset/Mujawwad/mp3/$surahStr$ayahStr.mp3';
      
      case 'mishary_rashid_alafasy':
        return 'https://verses.quran.com/Alafasy/mp3/$surahStr$ayahStr.mp3';
      
      case 'sudais_shuraim':
        return 'https://verses.quran.com/Sudais/mp3/$surahStr$ayahStr.mp3';
      
      case 'maher_al_mueaqly':
        return 'https://verses.quran.com/Maher/mp3/$surahStr$ayahStr.mp3';
      
      case 'ahmed_al_ajmi':
        return 'https://verses.quran.com/Ajmi/mp3/$surahStr$ayahStr.mp3';
      
      case 'ali_hudhaify':
        return 'https://verses.quran.com/Hudhaify/mp3/$surahStr$ayahStr.mp3';
      
      case 'saad_al_ghamdi':
        return 'https://verses.quran.com/Ghamdi/mp3/$surahStr$ayahStr.mp3';
      
      case 'abdullah_basfar':
        return 'https://verses.quran.com/Basfar/mp3/$surahStr$ayahStr.mp3';
      
      case 'muhammad_ayyub':
        return 'https://verses.quran.com/Ayyub/mp3/$surahStr$ayahStr.mp3';
      
      case 'abu_bakr_ash_shaatree':
        return 'https://verses.quran.com/Shaatree/mp3/$surahStr$ayahStr.mp3';
      
      case 'salah_al_budair':
        return 'https://verses.quran.com/Budair/mp3/$surahStr$ayahStr.mp3';
      
      default:
        // الخدمة الافتراضية - عبد الباسط عبد الصمد
        return 'https://verses.quran.com/AbdulBaset/Mujawwad/mp3/$surahStr$ayahStr.mp3';
    }
  }

  // الحصول على رابط الصوت عالي الجودة
  static String getHighQualityAudioUrl(String reciterId, int surahNumber, int ayahNumber) {
    String surahStr = surahNumber.toString().padLeft(3, '0');
    String ayahStr = ayahNumber.toString().padLeft(3, '0');
    
    // روابط بديلة أكثر موثوقية
    switch (reciterId) {
      case 'mishary_rashid_alafasy':
        return 'https://server8.mp3quran.net/afs/$surahStr$ayahStr.mp3';
      
      case 'abdul_basit_abdul_samad':
        return 'https://server8.mp3quran.net/abdul_basit_mujawwad/$surahStr$ayahStr.mp3';
      
      case 'sudais_shuraim':
        return 'https://server8.mp3quran.net/sudais/$surahStr$ayahStr.mp3';
      
      default:
        return 'https://server8.mp3quran.net/afs/$surahStr$ayahStr.mp3';
    }
  }

  // الحصول على رابط الصوت من خدمة بديلة
  static String getAlternativeAudioUrl(String reciterId, int surahNumber, int ayahNumber) {
    String surahStr = surahNumber.toString().padLeft(3, '0');
    String ayahStr = ayahNumber.toString().padLeft(3, '0');
    
    // روابط بديلة من mp3quran.net
    return 'https://server8.mp3quran.net/afs/$surahStr$ayahStr.mp3';
  }

  // الحصول على رابط صوتي محلي للاختبار
  static String getLocalTestAudioUrl(int surahNumber, int ayahNumber) {
    // رابط صوتي محلي للاختبار - يمكن استبداله برابط حقيقي
    return 'https://www.soundjay.com/misc/sounds/bell-ringing-05.wav';
  }

  // الحصول على رابط صوتي من مصدر موثوق
  static String getReliableAudioUrl(String reciterId, int surahNumber, int ayahNumber) {
    String surahStr = surahNumber.toString().padLeft(3, '0');
    String ayahStr = ayahNumber.toString().padLeft(3, '0');
    
    // روابط من مصادر موثوقة
    switch (reciterId) {
      case 'mishary_rashid_alafasy':
        return 'https://server8.mp3quran.net/afs/$surahStr$ayahStr.mp3';
      
      case 'abdul_basit_abdul_samad':
        return 'https://server8.mp3quran.net/abdul_basit_mujawwad/$surahStr$ayahStr.mp3';
      
      case 'sudais_shuraim':
        return 'https://server8.mp3quran.net/sudais/$surahStr$ayahStr.mp3';
      
      default:
        return 'https://server8.mp3quran.net/afs/$surahStr$ayahStr.mp3';
    }
  }

  // الحصول على قواعد التجويد
  static List<TajweedRule> getTajweedRules() {
    return [
      TajweedRule(
        name: 'الغنة',
        arabicName: 'الغنة',
        description: 'صوت يخرج من الخيشوم مع النون والميم',
        examples: ['مِنْ نُّطْفَةٍ', 'نَعَمْ', 'إِنَّ', 'أَمَّا'],
        practiceText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        practiceInstructions: 'ركز على النطق الصحيح لحرفي النون والميم مع الغنة',
      ),
      TajweedRule(
        name: 'المد',
        arabicName: 'المد',
        description: 'إطالة الصوت في الحروف المدية',
        examples: ['الرَّحْمَٰنِ', 'الرَّحِيمِ', 'اللَّهُ'],
        practiceText: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
        practiceInstructions: 'أطِل الصوت عند النطق بالحروف المدية',
      ),
      TajweedRule(
        name: 'الإدغام',
        arabicName: 'الإدغام',
        description: 'دمج حرف ساكن في حرف متحرك',
        examples: ['مِن نَّفْسٍ', 'عَلَىٰ نَّفْسِهِ', 'مِن مَّاءٍ'],
        practiceText: 'مِنْ نَفْسٍ وَمِنْ مَاءٍ مَّهِينٍ',
        practiceInstructions: 'دمج الحروف الساكنة مع الحروف المتحركة',
      ),
      TajweedRule(
        name: 'القلقلة',
        arabicName: 'القلقلة',
        description: 'اهتزاز الصوت في الحروف القلقلة',
        examples: ['قُلْ هُوَ اللَّهُ', 'طَهَ', 'بِسْمِ', 'جَعَلَ', 'دَعَا'],
        practiceText: 'قُلْ هُوَ اللَّهُ أَحَدٌ',
        practiceInstructions: 'اهتز الصوت عند النطق بحروف القلقلة',
      ),
      TajweedRule(
        name: 'الإخفاء',
        arabicName: 'الإخفاء',
        description: 'إخفاء النون والميم عند بعض الحروف',
        examples: ['مِن فَضْلِهِ', 'مِن كُلِّ', 'مِن شَيْءٍ'],
        practiceText: 'مِنْ فَضْلِهِ وَمِنْ كُلِّ شَيْءٍ',
        practiceInstructions: 'أخفِ حرف النون عند النطق به',
      ),
    ];
  }
} 