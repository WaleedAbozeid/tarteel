import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import '../providers/quran_provider.dart';
import '../providers/audio_provider.dart';
import '../models/quran_models.dart';
import 'dart:async'; // Added for StreamSubscription

class SurahScreen extends StatefulWidget {
  final Surah surah;

  const SurahScreen({super.key, required this.surah});

  @override
  State<SurahScreen> createState() => _SurahScreenState();
}

class _SurahScreenState extends State<SurahScreen>
    with TickerProviderStateMixin {
  int _currentPage = 0;
  List<List<Ayah>> _pages = [];
  bool _showTools = false;
  bool _showBars = true;
  late final PageController _pageController;

  // إضافة متغيرات للرسوم المتحركة
  late AnimationController _fadeController;
  late AnimationController _slideController;

  // متغيرات جديدة لتشغيل الصفحة
  bool _isPlayingFullPage = false;
  int _currentPlayingAyahIndex = 0;
  List<Ayah> _currentPageAyahs = [];
  StreamSubscription? _audioCompleteSubscription;

  // متغيرات جديدة لمؤشر الصوت
  bool _showAudioControls = false;
  bool _isAudioPlaying = false;
  Duration _audioPosition = Duration.zero;
  Duration _audioDuration = Duration.zero;

  // متغيرات جديدة لتمييز النص أثناء القراءة
  int _currentReadingAyahIndex = -1;
  int _currentReadingPageIndex = -1;
  bool _isReadingMode = false;

  // متغيرات جديدة لتمييز الكلمة الحالية
  int _currentReadingWordIndex = -1;
  int _currentReadingAyahWordIndex = -1;
  List<String> _currentPageWords = [];
  List<int> _wordStartTimes = [];
  List<int> _wordEndTimes = [];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    // تهيئة الرسوم المتحركة
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final quranProvider = context.read<QuranProvider>();
      quranProvider.loadSurahAyahs(widget.surah.number);

      // إعداد مراقبة حالة الصوت
      _setupAudioStateListener();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    // إيقاف التشغيل عند مغادرة الشاشة
    if (_isPlayingFullPage) {
      _stopFullPage();
    }
    // إلغاء الاشتراك في stream
    _audioCompleteSubscription?.cancel();
    super.dispose();
  }

  // دالة تحسين إخفاء/إظهار العناصر
  void _toggleBars() {
    setState(() {
      _showBars = !_showBars;
    });

    if (_showBars) {
      // إظهار العناصر
      _fadeController.forward();
      _slideController.reverse();
    } else {
      // إخفاء العناصر
      _fadeController.reverse();
      _slideController.forward();
    }
  }

  // دالة إخفاء العناصر تلقائياً بعد فترة
  void _hideBarsAfterDelay() {
    if (!_showBars) return; // إذا كانت مخفية بالفعل

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _showBars) {
        _toggleBars();
      }
    });
  }

  // دالة تشغيل كامل الصفحة
  void _playFullPage(int pageIndex) async {
    if (pageIndex < 0 ||
        pageIndex >= _pages.length ||
        _pages[pageIndex].isEmpty) {
      return;
    }

    setState(() {
      _isPlayingFullPage = true;
      _currentPlayingAyahIndex = 0;
      _currentPageAyahs = _pages[pageIndex];
    });

    // إيقاف أي تشغيل سابق
    try {
      await context.read<AudioProvider>().stopAudio();
    } catch (e) {
      // تجاهل الأخطاء
    }

    // إعداد مراقبة اكتمال الصوت
    _setupAudioCompleteListener();

    // بدء تشغيل آيات الصفحة
    _playNextAyahInPage();
  }

  // إعداد مراقبة اكتمال الصوت
  void _setupAudioCompleteListener() {
    // إلغاء الاشتراك السابق إذا كان موجوداً
    _audioCompleteSubscription?.cancel();

    // الحصول على AudioProvider
    final audioProvider = context.read<AudioProvider>();

    // الاشتراك في stream اكتمال الصوت
    _audioCompleteSubscription = audioProvider.onAudioComplete.listen((_) {
      if (mounted && _isPlayingFullPage) {
        // انتظار قليل ثم تشغيل الآية التالية
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && _isPlayingFullPage) {
            _playNextAyahInPage();
          }
        });
      }
    });
  }

  // دالة تشغيل الآية التالية في الصفحة
  void _playNextAyahInPage() async {
    if (!_isPlayingFullPage ||
        _currentPlayingAyahIndex >= _currentPageAyahs.length) {
      // انتهى تشغيل الصفحة
      setState(() {
        _isPlayingFullPage = false;
        _currentPlayingAyahIndex = 0;
      });
      // إلغاء الاشتراك في stream
      _audioCompleteSubscription?.cancel();
      return;
    }

    final currentAyah = _currentPageAyahs[_currentPlayingAyahIndex];

    try {
      final audioUrl = context.read<QuranProvider>().getAudioUrl(
        widget.surah.number,
        currentAyah.number,
      );

      if (audioUrl.isNotEmpty) {
        // تشغيل الآية
        await context.read<AudioProvider>().playAyah(audioUrl);

        // تحديث مؤشر التشغيل
        setState(() {
          _currentPlayingAyahIndex++;
        });

        // لا نحتاج لـ Future.delayed هنا لأن onAudioComplete سيتعامل مع الانتقال
      } else {
        // إذا لم يكن هناك رابط صوت، انتقل للآية التالية
        setState(() {
          _currentPlayingAyahIndex++;
        });
        // انتظار قليل ثم الانتقال للآية التالية
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted && _isPlayingFullPage) {
            _playNextAyahInPage();
          }
        });
      }
    } catch (e) {
      // في حالة حدوث خطأ، انتقل للآية التالية
      setState(() {
        _currentPlayingAyahIndex++;
      });
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted && _isPlayingFullPage) {
          _playNextAyahInPage();
        }
      });
    }
  }

  // دالة إيقاف تشغيل الصفحة
  void _stopFullPage() async {
    setState(() {
      _isPlayingFullPage = false;
      _currentPlayingAyahIndex = 0;
    });

    try {
      await context.read<AudioProvider>().stopAudio();
    } catch (e) {
      // تجاهل الأخطاء
    }

    // إلغاء الاشتراك في stream
    _audioCompleteSubscription?.cancel();

    // إعادة تعيين مؤشر القراءة
    _resetReadingIndicator();
  }

  // إعادة تعيين مؤشر القراءة
  void _resetReadingIndicator() {
    setState(() {
      _isReadingMode = false;
      _currentReadingAyahIndex = -1;
      _currentReadingPageIndex = -1;
      _currentReadingWordIndex = -1;
      _currentReadingAyahWordIndex = -1;
      _currentPageWords.clear();
      _wordStartTimes.clear();
      _wordEndTimes.clear();
    });
  }

  // بناء مؤشر التحكم في الصوت
  Widget _buildAudioControls() {
    if (!_showAudioControls) return const SizedBox.shrink();

    return Positioned(
      bottom: 100, // فوق أدوات التحكم
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF16213E),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // شريط التقدم
            if (_audioDuration.inSeconds > 0)
              Column(
                children: [
                  Slider(
                    value: _audioPosition.inSeconds.toDouble(),
                    min: 0,
                    max: _audioDuration.inSeconds.toDouble(),
                    onChanged: (value) {
                      final audioProvider = context.read<AudioProvider>();
                      audioProvider.seekTo(Duration(seconds: value.toInt()));
                    },
                    activeColor: const Color(0xFF4CAF50),
                    inactiveColor: Colors.grey[600],
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatDuration(_audioPosition),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          _formatDuration(_audioDuration),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 12),

            // أزرار التحكم
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // زر الإيقاف المؤقت/الإكمال
                IconButton(
                  onPressed: () {
                    final audioProvider = context.read<AudioProvider>();
                    if (_isAudioPlaying) {
                      audioProvider.pauseAudio();
                    } else {
                      audioProvider.resumeAudio();
                    }
                  },
                  icon: Icon(
                    _isAudioPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 28,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    padding: const EdgeInsets.all(12),
                  ),
                ),

                // زر الإيقاف
                IconButton(
                  onPressed: () {
                    final audioProvider = context.read<AudioProvider>();
                    audioProvider.stopAudio();
                    if (_isPlayingFullPage) {
                      _stopFullPage();
                    } else {
                      // إعادة تعيين مؤشر القراءة عند إيقاف الصوت
                      _resetReadingIndicator();
                    }
                  },
                  icon: const Icon(Icons.stop, color: Colors.white, size: 28),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5722),
                    padding: const EdgeInsets.all(12),
                  ),
                ),

                // زر إغلاق المؤشر
                IconButton(
                  onPressed: () {
                    setState(() {
                      _showAudioControls = false;
                    });
                  },
                  icon: const Icon(Icons.close, color: Colors.white, size: 24),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[600],
                    padding: const EdgeInsets.all(12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // تنسيق المدة
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  // بناء نص الآيات بتنسيق مصحف المدينة المنورة
  Widget _buildHighlightedText(List<Ayah> pageAyahs, int pageIndex) {
    // تحليل النص إلى كلمات إذا لم يتم ذلك من قبل
    if (_currentPageWords.isEmpty || _currentReadingPageIndex != pageIndex) {
      // تأخير تحليل الكلمات لتجنب تجميد الـ UI
      Future.microtask(() {
        if (mounted) {
          _analyzePageWords(pageAyahs);
        }
      });
    }

    // التحقق من وجود بسملة في أول الصفحة
    bool hasBasmala =
        pageAyahs.isNotEmpty &&
        pageAyahs.first.number == 1 &&
        widget.surah.number != 1 &&
        widget.surah.number != 9;

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      itemCount: pageAyahs.length + (hasBasmala ? 1 : 0),
      itemBuilder: (context, index) {
        // إضافة البسملة في البداية إذا لزم الأمر
        if (hasBasmala && index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 24, top: 16),
            child: Center(
              child: Text(
                'بِسْمِ ٱللَّهِ ٱلرَّحْمَـٰنِ ٱلرَّحِيمِ',
                style: TextStyle(
                  fontSize: 28,
                  fontFamily: 'Amiri',
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4CAF50),
                  letterSpacing: 1.5,
                ),
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
              ),
            ),
          );
        }

        final ayahIndex = hasBasmala ? index - 1 : index;
        if (ayahIndex >= pageAyahs.length) return const SizedBox.shrink();

        final ayah = pageAyahs[ayahIndex];

        return _buildAyahWithMadinahStyle(
          ayah,
          ayahIndex,
          pageIndex,
          pageAyahs,
        );
      },
    );
  }

  // بناء آية بتنسيق مصحف المدينة المنورة
  Widget _buildAyahWithMadinahStyle(
    Ayah ayah,
    int ayahIndex,
    int pageIndex,
    List<Ayah> pageAyahs,
  ) {
    // تحديد ما إذا كانت الآية الأولى في السورة (بدون رقم)
    final isFirstAyah = ayah.number == 1;
    final isSurahAlFatiha = widget.surah.number == 1;
    final isSurahAlTawbah = widget.surah.number == 9;

    // تحديد ما إذا كانت الآية تحتوي على سجدة
    final hasSajda = ayah.textAr.contains('۩') || ayah.textAr.contains('۩');

    return InkWell(
      onTap: () {
        _playAyah(ayah);
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: TextDirection.rtl,
          children: [
            // رقم الآية بتنسيق مصحف المدينة
            if (!isFirstAyah ||
                (isFirstAyah && (isSurahAlFatiha || isSurahAlTawbah)))
              Container(
                margin: const EdgeInsets.only(left: 8, top: 2),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // الخلفية المزخرفة لرقم الآية
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F3460),
                        border: Border.all(
                          color: const Color(0xFF4CAF50).withOpacity(0.5),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    Text(
                      ayah.number.toString(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontFamily: 'Amiri',
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
              ),

            // نص الآية
            Expanded(
              child: RichText(
                text: TextSpan(
                  children: _buildAyahTextSpans(
                    ayah,
                    ayahIndex,
                    pageIndex,
                    pageAyahs,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: 'Amiri',
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    height: 1.8,
                    letterSpacing: 0.5,
                  ),
                ),
                textAlign: TextAlign.justify,
                textDirection: TextDirection.rtl,
              ),
            ),

            // علامة السجدة إذا وجدت
            if (hasSajda)
              Container(
                margin: const EdgeInsets.only(right: 8, top: 4),
                child: const Text(
                  '۩',
                  style: TextStyle(
                    fontSize: 24,
                    color: Color(0xFF4CAF50),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // بناء النص المنسق للآية
  List<TextSpan> _buildAyahTextSpans(
    Ayah ayah,
    int ayahIndex,
    int pageIndex,
    List<Ayah> pageAyahs,
  ) {
    final words = ayah.textAr.split(RegExp(r'\s+'));
    List<TextSpan> spans = [];

    for (int wordIndex = 0; wordIndex < words.length; wordIndex++) {
      final word = words[wordIndex];
      if (word.trim().isEmpty) continue;

      // حساب الفهرس العام للكلمة
      final globalWordIndex = _getGlobalWordIndex(
        ayahIndex,
        wordIndex,
        pageAyahs,
      );

      // تحديد ما إذا كانت الكلمة الحالية للقراءة
      final isCurrentWord =
          _isReadingMode &&
          _currentReadingPageIndex == pageIndex &&
          _currentReadingWordIndex == globalWordIndex;

      // إضافة مسافة بين الكلمات
      if (wordIndex > 0) {
        spans.add(const TextSpan(text: ' '));
      }

      spans.add(
        TextSpan(
          text: word,
          style: TextStyle(
            color: isCurrentWord ? const Color(0xFF4CAF50) : Colors.white,
            fontSize: 24,
            fontFamily: 'Amiri',
            fontWeight: isCurrentWord ? FontWeight.bold : FontWeight.w500,
            backgroundColor: isCurrentWord
                ? const Color(0xFF4CAF50).withOpacity(0.2)
                : Colors.transparent,
            decoration: isCurrentWord
                ? TextDecoration.underline
                : TextDecoration.none,
            decorationColor: isCurrentWord ? const Color(0xFF4CAF50) : null,
            decorationThickness: isCurrentWord ? 2.0 : null,
          ),
        ),
      );
    }

    return spans;
  }

  // حساب الفهرس العام للكلمة في الصفحة
  int _getGlobalWordIndex(int ayahIndex, int wordIndex, List<Ayah> pageAyahs) {
    int globalIndex = 0;

    for (int i = 0; i < ayahIndex; i++) {
      final words = pageAyahs[i].textAr.split(RegExp(r'\s+'));
      globalIndex += words.where((word) => word.trim().isNotEmpty).length;
    }

    return globalIndex + wordIndex;
  }

  Widget _buildFabTools() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_showTools) ...[
          _buildToolButton(
            icon: Icons.record_voice_over,
            label: 'تغيير القارئ',
            onTap: () {
              Navigator.of(context).pushNamed('/reciter-selection');
            },
          ),
          const SizedBox(height: 12),
          _buildToolButton(
            icon: Icons.info_outline,
            label: 'معلومات',
            onTap: () {
              final type = widget.surah.revelationType == 'Meccan'
                  ? 'مكية'
                  : 'مدنية';
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: const Color(0xFF0F3460),
                  title: Text(
                    'معلومات السورة',
                    style: const TextStyle(color: Colors.white),
                    textDirection: TextDirection.rtl,
                  ),
                  content: Text(
                    'عدد الآيات: ${widget.surah.numberOfAyahs}\nنوع السورة: $type',
                    style: const TextStyle(color: Colors.white),
                    textDirection: TextDirection.rtl,
                  ),
                  actions: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                      ),
                      child: const Text('حسناً'),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildToolButton(
            icon: Icons.arrow_back,
            label: 'السابق',
            onTap: _currentPage > 0
                ? () {
                    setState(() {
                      _currentPage--;
                    });
                    _pageController.animateToPage(
                      _currentPage,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
          ),
          const SizedBox(height: 12),
          // زر تشغيل كامل الصفحة
          _buildToolButton(
            icon: _isPlayingFullPage ? Icons.stop : Icons.playlist_play,
            label: _isPlayingFullPage ? 'إيقاف التشغيل' : 'تشغيل كامل الصفحة',
            onTap: _isPlayingFullPage
                ? () => _stopFullPage()
                : () => _playFullPage(_currentPage),
            color: _isPlayingFullPage
                ? const Color(0xFFFF5722)
                : const Color(0xFF4CAF50),
          ),
          const SizedBox(height: 12),
          // زر تشغيل آية واحدة (الصفحة القديم)
          _buildToolButton(
            icon: Icons.play_arrow,
            label: 'تشغيل آية واحدة',
            onTap: () => _playPage(_currentPage),
          ),
          const SizedBox(height: 12),
          _buildToolButton(
            icon: Icons.arrow_forward,
            label: 'التالي',
            onTap: _currentPage < _pages.length - 1
                ? () {
                    setState(() {
                      _currentPage++;
                    });
                    _pageController.animateToPage(
                      _currentPage,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                : null,
          ),

          const SizedBox(height: 12),
        ],
        FloatingActionButton(
          heroTag: 'mainFab',
          backgroundColor: const Color(0xFF4CAF50),
          onPressed: () {
            setState(() {
              _showTools = !_showTools;
            });
          },
          child: Icon(_showTools ? Icons.close : Icons.menu),
        ),
      ],
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
    Color? color,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: color ?? const Color(0xFF16213E),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // زر الانتقال للسورة التالية
  Widget _buildNextSurahButton(BuildContext context) {
    final quranProvider = context.read<QuranProvider>();
    final allSurahs = quranProvider.surahs;
    final currentSurahIndex = allSurahs.indexWhere(
      (s) => s.number == widget.surah.number,
    );
    if (currentSurahIndex == -1 || currentSurahIndex == allSurahs.length - 1) {
      return const SizedBox.shrink();
    }
    final nextSurah = allSurahs[currentSurahIndex + 1];
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      icon: const Icon(Icons.arrow_forward, size: 22),
      label: Text(
        'الانتقال إلى سورة ${nextSurah.nameAr}',
        style: const TextStyle(fontSize: 18),
      ),
      onPressed: () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => SurahScreen(surah: nextSurah)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        try {
          final audioProvider = context.read<AudioProvider>();
          await audioProvider.stopAudio();
        } catch (e) {}
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0F3460),
        // AppBar مع رسوم متحركة
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 300),
            offset: _showBars ? Offset.zero : const Offset(0, -1),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _showBars ? 1.0 : 0.0,
              child: AppBar(
                backgroundColor: const Color(0xFF16213E),
                iconTheme: const IconThemeData(color: Colors.white),
                title: Text(
                  widget.surah.nameAr,
                  style: const TextStyle(color: Colors.white),
                ),
                elevation: 0,
                // إضافة زر لتغيير حالة العرض
                actions: [
                  IconButton(
                    icon: Icon(
                      _showBars ? Icons.visibility_off : Icons.visibility,
                      color: Colors.white,
                    ),
                    onPressed: _toggleBars,
                    tooltip: _showBars ? 'إخفاء العناصر' : 'إظهار العناصر',
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Consumer2<QuranProvider, AudioProvider>(
          builder: (context, quranProvider, audioProvider, child) {
            if (quranProvider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            if (quranProvider.currentSurahAyahs.isEmpty) {
              return const Center(
                child: Text(
                  'لا توجد آيات متاحة',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            if (_pages.isEmpty) {
              final ayahs = quranProvider.currentSurahAyahs;
              if (ayahs.isNotEmpty) {
                // تأخير معالجة الصفحات لتجنب تجميد الـ UI
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    // استخدام Future.microtask لتأخير المعالجة
                    Future.microtask(() {
                      if (mounted) {
                        setState(() {
                          _pages = _groupAyahsIntoPages(ayahs);
                        });
                      }
                    });
                  }
                });
              }
            }

            if (_pages.isEmpty) {
              return const Center(
                child: Text(
                  'لا توجد صفحات متاحة',
                  style: TextStyle(color: Colors.white),
                ),
              );
            }

            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTapDown: (TapDownDetails details) {
                // التحقق من أن الضغط ليس على النص
                final RenderBox renderBox =
                    context.findRenderObject() as RenderBox;
                final localPosition = renderBox.globalToLocal(
                  details.globalPosition,
                );

                // إذا كان الضغط في منطقة النص، لا تفعل شيئاً
                // دع TapGestureRecognizer يتعامل معه
                if (localPosition.dy > 100 &&
                    localPosition.dy < renderBox.size.height - 100) {
                  return;
                }

                _toggleBars();
                // إخفاء تلقائي بعد فترة
                _hideBarsAfterDelay();
              },
              onDoubleTap: () {
                // إظهار فوري عند النقر المزدوج
                if (!_showBars) {
                  _toggleBars();
                }
              },
              child: Stack(
                children: [
                  PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                      // إظهار العناصر عند تغيير الصفحة
                      if (!_showBars) {
                        _toggleBars();
                      }
                      // إيقاف التشغيل عند تغيير الصفحة
                      if (_isPlayingFullPage) {
                        _stopFullPage();
                      }
                    },
                    itemBuilder: (context, index) {
                      final pageAyahs = _pages[index];
                      int? pageNumber;
                      if (pageAyahs.isNotEmpty &&
                          pageAyahs.first.toJson().containsKey('page')) {
                        pageNumber = pageAyahs
                            .map((a) => a.toJson()['page'] as int)
                            .reduce((a, b) => a < b ? a : b);
                      } else if (pageAyahs.isNotEmpty &&
                          (pageAyahs.first as dynamic).page != null) {
                        pageNumber = pageAyahs
                            .map((a) => (a as dynamic).page as int)
                            .reduce((a, b) => a < b ? a : b);
                      }
                      return Column(
                        children: [
                          Expanded(
                            child: Container(
                              key: ValueKey(index),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F3460),
                                border: Border.all(
                                  color: const Color(
                                    0xFF4CAF50,
                                  ).withOpacity(0.2),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    // لا تفعل شيئاً هنا - دع TapGestureRecognizer يتعامل مع الضغط
                                  },
                                  child: _buildHighlightedText(
                                    pageAyahs,
                                    index,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (pageNumber != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: 12,
                                top: 8,
                              ),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF16213E),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(
                                      0xFF4CAF50,
                                    ).withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  'صفحة $pageNumber',
                                  style: const TextStyle(
                                    color: Color(0xFF4CAF50),
                                    fontSize: 16,
                                    fontFamily: 'Amiri',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          if (index == _pages.length - 1)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: 24,
                                top: 8,
                              ),
                              child: _buildNextSurahButton(context),
                            ),
                        ],
                      );
                    },
                  ),
                  // أدوات التحكم السفلية مع رسوم متحركة محسنة
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    right: 16,
                    bottom: _showBars ? 24 : -100, // إخفاء خارج الشاشة
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: _showBars ? 1.0 : 0.0,
                      child: _buildFabTools(),
                    ),
                  ),
                  // مؤشر حالة العرض
                  if (!_showBars)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'انقر لإظهار العناصر',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),

                  // مؤشر حالة التشغيل
                  if (_isPlayingFullPage)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'تشغيل الصفحة ${_currentPlayingAyahIndex + 1}/${_currentPageAyahs.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // مؤشر الآية الحالية أثناء القراءة
                  if (_isReadingMode &&
                      _currentReadingPageIndex == _currentPage)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.record_voice_over,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _currentReadingWordIndex >= 0 &&
                                      _currentPageWords.isNotEmpty
                                  ? 'الكلمة ${_currentReadingWordIndex + 1}'
                                  : 'الآية ${_currentReadingAyahIndex + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // مؤشر التحكم في الصوت
                  _buildAudioControls(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // تجميع الآيات في صفحات
  // تقسيم الآيات حسب رقم الصفحة المصحفي الحقيقي
  List<List<Ayah>> _groupAyahsIntoPages(List<Ayah> ayahs) {
    if (ayahs.isEmpty) return [];

    // استخدام Map أكثر كفاءة
    final Map<int, List<Ayah>> pageMap = <int, List<Ayah>>{};

    for (final ayah in ayahs) {
      int? pageNum;

      // محاولة استخراج رقم الصفحة بطريقة أكثر كفاءة
      try {
        if (ayah.page != null) {
          pageNum = ayah.page;
        } else if (ayah.toJson().containsKey('page')) {
          pageNum = ayah.toJson()['page'] as int;
        }
      } catch (e) {
        // تجاهل الأخطاء والاستمرار
        continue;
      }

      if (pageNum != null) {
        pageMap.putIfAbsent(pageNum, () => <Ayah>[]).add(ayah);
      }
    }

    // ترتيب الصفحات تصاعدياً حسب مصحف المدينة
    final sortedPages = pageMap.keys.toList()..sort();
    return [for (final p in sortedPages) pageMap[p]!];
  }

  // تشغيل آية محددة
  void _playAyah(Ayah ayah) {
    print(
      'تم الضغط على الآية ${ayah.number} من سورة ${widget.surah.nameAr}',
    ); // طباعة تأكيد مفصلة

    try {
      // إظهار رسالة تأكيد
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'جاري تشغيل الآية ${ayah.number} من سورة ${widget.surah.nameAr}...',
          ),
          backgroundColor: const Color(0xFF4CAF50),
          duration: const Duration(seconds: 2),
        ),
      );

      final audioUrl = context.read<QuranProvider>().getAudioUrl(
        widget.surah.number,
        ayah.number,
      );

      print('رابط الصوت للآية ${ayah.number}: $audioUrl'); // للتأكد من الرابط

      if (audioUrl.isNotEmpty) {
        // إيقاف أي تشغيل سابق
        context.read<AudioProvider>().stopAudio();

        // تشغيل الآية الجديدة
        context
            .read<AudioProvider>()
            .playAyah(
              audioUrl,
              surahNumber: widget.surah.number,
              ayahNumber: ayah.number,
            )
            .then((_) {
              print('تم تشغيل الآية ${ayah.number} بنجاح'); // طباعة نجاح
              // رسالة نجاح
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم تشغيل الآية ${ayah.number} بنجاح'),
                  backgroundColor: const Color(0xFF4CAF50),
                  duration: const Duration(seconds: 1),
                ),
              );
            })
            .catchError((error) {
              print('خطأ في تشغيل الآية ${ayah.number}: $error'); // طباعة خطأ
              // رسالة خطأ
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('خطأ في تشغيل الصوت: $error'),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            });
      } else {
        print('رابط الصوت فارغ للآية ${ayah.number}'); // طباعة رابط فارغ
        // رسالة إذا كان الرابط فارغاً
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('رابط الصوت غير متاح لهذه الآية'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('خطأ عام في تشغيل الآية ${ayah.number}: $e'); // طباعة خطأ عام
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تشغيل الصوت: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // تشغيل صفحة محددة
  void _playPage(int pageIndex) {
    if (pageIndex >= 0 &&
        pageIndex < _pages.length &&
        _pages[pageIndex].isNotEmpty) {
      _playAyah(_pages[pageIndex].first);
    }
  }

  // إعداد مراقبة حالة الصوت
  void _setupAudioStateListener() {
    final audioProvider = context.read<AudioProvider>();

    // مراقبة حالة التشغيل
    audioProvider.addListener(() {
      if (mounted) {
        setState(() {
          _isAudioPlaying = audioProvider.isPlaying;
          _showAudioControls =
              audioProvider.isPlaying || audioProvider.isPaused;
          _audioPosition = audioProvider.currentPosition;
          _audioDuration = audioProvider.totalDuration;

          // تحديث مؤشر القراءة بناءً على موضع الصوت
          _updateReadingIndicator(audioProvider);
        });
      }
    });
  }

  // تحديث مؤشر القراءة بناءً على موضع الصوت
  void _updateReadingIndicator(AudioProvider audioProvider) {
    if (!audioProvider.isPlaying || _pages.isEmpty) {
      _isReadingMode = false;
      _currentReadingAyahIndex = -1;
      _currentReadingPageIndex = -1;
      _currentReadingWordIndex = -1;
      _currentReadingAyahWordIndex = -1;
      return;
    }

    // إذا كان تشغيل كامل الصفحة يعمل، استخدم المؤشر المباشر
    if (_isPlayingFullPage && _currentPageAyahs.isNotEmpty) {
      _isReadingMode = true;
      _currentReadingPageIndex = _currentPage;
      _currentReadingAyahIndex = _currentPlayingAyahIndex;

      // تحديث مؤشر الكلمة الحالية
      _updateCurrentWordIndex(audioProvider);
      return;
    }

    // حساب الآية الحالية بناءً على موضع الصوت
    final currentPage = _currentPage;
    if (currentPage >= 0 && currentPage < _pages.length) {
      final pageAyahs = _pages[currentPage];
      final totalDuration = audioProvider.totalDuration;
      final currentPosition = audioProvider.currentPosition;

      if (totalDuration.inSeconds > 0 && pageAyahs.isNotEmpty) {
        // حساب الآية الحالية بناءً على النسبة المئوية
        final progress = currentPosition.inSeconds / totalDuration.inSeconds;
        final estimatedAyahIndex = (progress * pageAyahs.length).floor();

        if (estimatedAyahIndex >= 0 && estimatedAyahIndex < pageAyahs.length) {
          _isReadingMode = true;
          _currentReadingPageIndex = currentPage;
          _currentReadingAyahIndex = estimatedAyahIndex;

          // تحديث مؤشر الكلمة الحالية
          _updateCurrentWordIndex(audioProvider);
        }
      }
    }
  }

  // تحديث مؤشر الكلمة الحالية
  void _updateCurrentWordIndex(AudioProvider audioProvider) {
    if (!_isReadingMode ||
        _currentReadingPageIndex < 0 ||
        _currentReadingPageIndex >= _pages.length) {
      return;
    }

    final currentPage = _currentReadingPageIndex;
    final pageAyahs = _pages[currentPage];

    if (_currentReadingAyahIndex >= 0 &&
        _currentReadingAyahIndex < pageAyahs.length) {
      final currentAyah = pageAyahs[_currentReadingAyahIndex];

      // تحليل النص إلى كلمات إذا لم يتم ذلك من قبل
      if (_currentPageWords.isEmpty ||
          _currentReadingPageIndex != currentPage) {
        _analyzePageWords(pageAyahs);
      }

      // حساب الكلمة الحالية بناءً على موضع الصوت
      final currentPosition = audioProvider.currentPosition.inMilliseconds;
      final totalDuration = audioProvider.totalDuration.inMilliseconds;

      if (totalDuration > 0 && _wordStartTimes.isNotEmpty) {
        // البحث عن الكلمة الحالية بناءً على التوقيت
        for (int i = 0; i < _wordStartTimes.length; i++) {
          if (currentPosition >= _wordStartTimes[i] &&
              currentPosition <= _wordEndTimes[i]) {
            // إذا تغيرت الكلمة الحالية، ابدأ الأنيميشن
            if (_currentReadingWordIndex != i) {
              _currentReadingWordIndex = i;
              _currentReadingAyahWordIndex = i;

              // تفعيل أنيميشن الكلمة الجديدة
              // _startWordAnimation(); // Removed as per edit hint
            }
            break;
          }
        }
      }
    }
  }

  // تفعيل أنيميشن الكلمة الحالية
  // void _startWordAnimation() { // Removed as per edit hint
  //   // إعادة تعيين الأنيميشن
  //   _wordAnimationController.reset();

  //   // بدء الأنيميشن
  //   _wordAnimationController.forward();

  //   // إعادة تشغيل الأنيميشن بشكل متكرر للنبض
  //   _wordAnimationController.addStatusListener((status) {
  //     if (status == AnimationStatus.completed) {
  //       // إعادة تشغيل الأنيميشن للنبض المستمر
  //       _wordAnimationController.reverse();
  //     } else if (status == AnimationStatus.dismissed) {
  //       // إعادة تشغيل الأنيميشن للأمام
  //       _wordAnimationController.forward();
  //     }
  //   });
  // }

  // بناء كلمة مع أنيميشن متطور
  // Widget _buildAnimatedWord(String word, bool isCurrentWord) { // Removed as per edit hint
  //   if (isCurrentWord) {
  //     return AnimatedBuilder(
  //       animation: _wordAnimationController,
  //       builder: (context, child) {
  //         return Container(
  //           margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
  //           padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
  //           decoration: BoxDecoration(
  //             color: const Color(0xFF4CAF50).withOpacity(0.2 * _wordOpacityAnimation.value),
  //             borderRadius: BorderRadius.circular(8),
  //             border: Border.all(
  //               color: const Color(0xFF4CAF50).withOpacity(_wordGlowAnimation.value),
  //               width: 1.5 * _wordGlowAnimation.value,
  //             ),
  //             boxShadow: [
  //               BoxShadow(
  //                 color: const Color(0xFF4CAF50).withOpacity(_wordGlowAnimation.value * 0.5),
  //                 blurRadius: 8.0 * _wordGlowAnimation.value,
  //                 spreadRadius: 2.0 * _wordGlowAnimation.value,
  //               ),
  //             ],
  //           ),
  //           child: Transform.scale(
  //             scale: _wordScaleAnimation.value,
  //             child: Text(
  //               word,
  //               style: TextStyle(
  //                 color: _wordColorAnimation.value,
  //                 fontSize: 22,
  //                 fontFamily: 'Amiri',
  //                 fontWeight: FontWeight.bold,
  //                 shadows: [
  //                   Shadow(
  //                     color: const Color(0xFF4CAF50).withOpacity(_wordGlowAnimation.value * 0.8),
  //                     blurRadius: 4.0 * _wordGlowAnimation.value,
  //                     offset: const Offset(0, 1),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ),
  //         );
  //       },
  //     );
  //   } else {
  //     return Text(
  //       word,
  //       style: const TextStyle(
  //         color: Colors.white,
  //         fontSize: 22,
  //         fontFamily: 'Amiri',
  //         fontWeight: FontWeight.normal,
  //       ),
  //     );
  //   }
  // }

  // تحليل النص إلى كلمات وحساب التوقيت
  void _analyzePageWords(List<Ayah> pageAyahs) {
    // إعادة تعيين القوائم
    _currentPageWords.clear();
    _wordStartTimes.clear();
    _wordEndTimes.clear();

    int currentTime = 0;

    // استخدام RegExp محسن
    final wordSplitter = RegExp(r'\s+');

    for (final ayah in pageAyahs) {
      try {
        // تقسيم الآية إلى كلمات بطريقة أكثر كفاءة
        final words = ayah.textAr.split(wordSplitter);

        for (final word in words) {
          final trimmedWord = word.trim();
          if (trimmedWord.isNotEmpty) {
            _currentPageWords.add(trimmedWord);

            // حساب توقيت بداية الكلمة
            _wordStartTimes.add(currentTime);

            // تقدير مدة كل كلمة
            final estimatedDuration = _estimateWordDuration(trimmedWord);
            currentTime += estimatedDuration;

            // حساب توقيت نهاية الكلمة
            _wordEndTimes.add(currentTime);
          }
        }

        // إضافة مسافة بين الآيات
        currentTime += 500; // 0.5 ثانية
      } catch (e) {
        // تجاهل الأخطاء والاستمرار
        continue;
      }
    }
  }

  // تقدير مدة الكلمة بناءً على طولها
  int _estimateWordDuration(String word) {
    // قاعدة بسيطة: كل حرف يحتاج حوالي 200 مللي ثانية
    // يمكن تعديل هذه القاعدة حسب سرعة القارئ
    final baseDuration = word.length * 200;

    // إضافة مدة إضافية للكلمات الطويلة
    if (word.length > 5) {
      return baseDuration + 300;
    }

    return baseDuration;
  }

  // تحسين توقيت الكلمات بناءً على سرعة القارئ
  void _adjustWordTiming(double speedMultiplier) {
    if (_wordStartTimes.isEmpty || _wordEndTimes.isEmpty) return;

    final adjustedStartTimes = <int>[];
    final adjustedEndTimes = <int>[];

    int currentTime = 0;

    for (int i = 0; i < _wordStartTimes.length; i++) {
      final originalDuration = _wordEndTimes[i] - _wordStartTimes[i];
      final adjustedDuration = (originalDuration / speedMultiplier).round();

      adjustedStartTimes.add(currentTime);
      currentTime += adjustedDuration;
      adjustedEndTimes.add(currentTime);
    }

    _wordStartTimes = adjustedStartTimes;
    _wordEndTimes = adjustedEndTimes;
  }
}
