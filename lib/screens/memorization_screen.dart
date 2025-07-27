import 'package:flutter/material.dart';
import '../models/quran_models.dart';

class MemorizationScreen extends StatefulWidget {
  const MemorizationScreen({super.key});

  @override
  State<MemorizationScreen> createState() => _MemorizationScreenState();
}

class _MemorizationScreenState extends State<MemorizationScreen> {
  int _selectedSurahIndex = 0;
  int _currentAyahIndex = 0;
  bool _showHint = false;
  bool _isTestMode = false;
  String _userInput = '';
  int _score = 0;
  int _totalQuestions = 0;

  final List<MemorizationSurah> _memorizationSurahs = [
    MemorizationSurah(
      surah: Surah(
        number: 1, 
        nameAr: 'الفاتحة', 
        nameEn: 'Al-Fatiha', 
        numberOfAyahs: 7,
        name: 'الفاتحة',
        revelationType: 'مكية',
        description: 'سورة الفاتحة',
      ),
      progress: 0.8,
      lastReviewed: DateTime.now().subtract(const Duration(days: 2)),
      difficulty: 'سهل',
    ),
    MemorizationSurah(
      surah: Surah(
        number: 112, 
        nameAr: 'الإخلاص', 
        nameEn: 'Al-Ikhlas', 
        numberOfAyahs: 4,
        name: 'الإخلاص',
        revelationType: 'مكية',
        description: 'سورة الإخلاص',
      ),
      progress: 1.0,
      lastReviewed: DateTime.now().subtract(const Duration(hours: 6)),
      difficulty: 'سهل',
    ),
    MemorizationSurah(
      surah: Surah(
        number: 113, 
        nameAr: 'الفلق', 
        nameEn: 'Al-Falaq', 
        numberOfAyahs: 5,
        name: 'الفلق',
        revelationType: 'مكية',
        description: 'سورة الفلق',
      ),
      progress: 0.6,
      lastReviewed: DateTime.now().subtract(const Duration(days: 1)),
      difficulty: 'متوسط',
    ),
    MemorizationSurah(
      surah: Surah(
        number: 114, 
        nameAr: 'الناس', 
        nameEn: 'An-Nas', 
        numberOfAyahs: 6,
        name: 'الناس',
        revelationType: 'مكية',
        description: 'سورة الناس',
      ),
      progress: 0.4,
      lastReviewed: DateTime.now().subtract(const Duration(days: 3)),
      difficulty: 'متوسط',
    ),
  ];

  final Map<int, List<String>> _surahAyahs = {
    1: [
      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
      'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
      'الرَّحْمَٰنِ الرَّحِيمِ',
      'مَالِكِ يَوْمِ الدِّينِ',
      'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
      'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
      'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
    ],
    112: [
      'قُلْ هُوَ اللَّهُ أَحَدٌ',
      'اللَّهُ الصَّمَدُ',
      'لَمْ يَلِدْ وَلَمْ يُولَدْ',
      'وَلَمْ يَكُن لَّهُ كُفُوًا أَحَدٌ',
    ],
    113: [
      'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ',
      'مِن شَرِّ مَا خَلَقَ',
      'وَمِن شَرِّ غَاسِقٍ إِذَا وَقَبَ',
      'وَمِن شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ',
      'وَمِن شَرِّ حَاسِدٍ إِذَا حَسَدَ',
    ],
    114: [
      'قُلْ أَعُوذُ بِرَبِّ النَّاسِ',
      'مَلِكِ النَّاسِ',
      'إِلَٰهِ النَّاسِ',
      'مِن شَرِّ الْوَسْوَاسِ الْخَنَّاسِ',
      'الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ',
      'مِنَ الْجِنَّةِ وَالنَّاسِ',
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text(
          'برنامج الحفظ',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF16213E),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isTestMode ? Icons.quiz : Icons.quiz_outlined,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isTestMode = !_isTestMode;
                if (_isTestMode) {
                  _startTest();
                } else {
                  _resetTest();
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // إحصائيات الحفظ
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'السور المحفوظة',
                    '${_memorizationSurahs.where((s) => s.progress >= 1.0).length}',
                    Icons.book,
                    const Color(0xFF4CAF50),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'في التقدم',
                    '${_memorizationSurahs.where((s) => s.progress > 0 && s.progress < 1.0).length}',
                    Icons.trending_up,
                    const Color(0xFFFF9800),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'النسبة المئوية',
                    '${((_memorizationSurahs.fold(0.0, (sum, s) => sum + s.progress) / _memorizationSurahs.length) * 100).toInt()}%',
                    Icons.percent,
                    const Color(0xFF2196F3),
                  ),
                ),
              ],
            ),
          ),

          if (!_isTestMode) ...[
            // قائمة السور
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _memorizationSurahs.length,
                itemBuilder: (context, index) {
                  final memorizationSurah = _memorizationSurahs[index];
                  return _buildSurahCard(memorizationSurah, index);
                },
              ),
            ),
          ] else ...[
            // وضع الاختبار
            Expanded(
              child: _buildTestMode(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F3460),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSurahCard(MemorizationSurah memorizationSurah, int index) {
    final progress = memorizationSurah.progress;
    final daysSinceReview = DateTime.now().difference(memorizationSurah.lastReviewed).inDays;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F3460),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getDifficultyColor(memorizationSurah.difficulty).withOpacity(0.3),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getDifficultyColor(memorizationSurah.difficulty),
          child: Text(
            '${memorizationSurah.surah.number}',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          memorizationSurah.surah.nameAr,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textDirection: TextDirection.rtl,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.withOpacity(0.3),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getDifficultyColor(memorizationSurah.difficulty),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(memorizationSurah.difficulty).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    memorizationSurah.difficulty,
                    style: TextStyle(
                      color: _getDifficultyColor(memorizationSurah.difficulty),
                      fontSize: 12,
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'آخر مراجعة: منذ $daysSinceReview يوم',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) {
            switch (value) {
              case 'practice':
                _startPractice(index);
                break;
              case 'review':
                _startReview(index);
                break;
              case 'test':
                _startSurahTest(index);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'practice',
              child: Text('تدرب على الحفظ'),
            ),
            const PopupMenuItem(
              value: 'review',
              child: Text('راجع السورة'),
            ),
            const PopupMenuItem(
              value: 'test',
              child: Text('اختبر حفظك'),
            ),
          ],
        ),
        onTap: () {
          _startPractice(index);
        },
      ),
    );
  }

  Widget _buildTestMode() {
    if (_totalQuestions == 0) {
      return const Center(
        child: Text(
          'اضغط على أي سورة لبدء الاختبار',
          style: TextStyle(color: Colors.white),
          textDirection: TextDirection.rtl,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // شريط التقدم
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F3460),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'النتيجة: $_score/$_totalQuestions',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    Text(
                      '${((_score / _totalQuestions) * 100).toInt()}%',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: _score / _totalQuestions,
                  backgroundColor: Colors.grey.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          
          // رسالة النتيجة
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0F3460),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Icon(
                  _score >= (_totalQuestions * 0.8) ? Icons.celebration : Icons.school,
                  color: _score >= (_totalQuestions * 0.8) ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  _score >= (_totalQuestions * 0.8) ? 'أحسنت! حفظ ممتاز' : 'جيد، واصل التدريب',
                  style: TextStyle(
                    color: _score >= (_totalQuestions * 0.8) ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 8),
                Text(
                  'النتيجة: $_score من $_totalQuestions',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ],
            ),
          ),
          const Spacer(),
          
          // أزرار التحكم
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isTestMode = false;
                      _resetTest();
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'العودة للقائمة',
                    style: TextStyle(color: Colors.white),
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _startTest();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'اختبار جديد',
                    style: TextStyle(color: Colors.white),
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'سهل':
        return const Color(0xFF4CAF50);
      case 'متوسط':
        return const Color(0xFFFF9800);
      case 'صعب':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF4CAF50);
    }
  }

  void _startPractice(int surahIndex) {
    setState(() {
      _selectedSurahIndex = surahIndex;
      _currentAyahIndex = 0;
      _showHint = false;
    });
    
    // يمكن إضافة شاشة التدريب هنا
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'بدء التدريب على ${_memorizationSurahs[surahIndex].surah.nameAr}',
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );
  }

  void _startReview(int surahIndex) {
    // يمكن إضافة شاشة المراجعة هنا
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'بدء مراجعة ${_memorizationSurahs[surahIndex].surah.nameAr}',
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: const Color(0xFF2196F3),
      ),
    );
  }

  void _startSurahTest(int surahIndex) {
    setState(() {
      _isTestMode = true;
      _selectedSurahIndex = surahIndex;
      _startTest();
    });
  }

  void _startTest() {
    setState(() {
      _score = 0;
      _totalQuestions = 5; // عدد أسئلة الاختبار
      
      // محاكاة الاختبار
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _score = 4; // نتيجة وهمية
        });
      });
    });
  }

  void _resetTest() {
    setState(() {
      _score = 0;
      _totalQuestions = 0;
    });
  }
}

class MemorizationSurah {
  final Surah surah;
  final double progress;
  final DateTime lastReviewed;
  final String difficulty;

  MemorizationSurah({
    required this.surah,
    required this.progress,
    required this.lastReviewed,
    required this.difficulty,
  });
} 