import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
import '../providers/quran_provider.dart';
import '../providers/audio_provider.dart';
import '../models/quran_models.dart';
import 'dart:async';

class SurahScreen extends StatefulWidget {
  final Surah surah;
  const SurahScreen({super.key, required this.surah});
  @override
  State<SurahScreen> createState() => _SurahScreenState();
}

class _SurahScreenState extends State<SurahScreen> with TickerProviderStateMixin {
  int _currentPage = 0;
  List<List<Ayah>> _pages = [];
  bool _showTools = false;
  bool _showBars = true;
  late final PageController _pageController;

  // متغيرات جديدة لتشغيل الصفحة
  bool _isPlayingFullPage = false;
  int _currentPlayingAyahIndex = 0;
  List<Ayah> _currentPageAyahs = [];
  StreamSubscription? _audioCompleteSubscription;

  // مؤشر الصوت
  bool _showAudioControls = false;
  bool _isAudioPlaying = false;
  Duration _audioPosition = Duration.zero;
  Duration _audioDuration = Duration.zero;

  // تمييز القراءة
  int _currentReadingAyahIndex = -1;
  int _currentReadingPageIndex = -1;
  bool _isReadingMode = false;
  int _currentReadingWordIndex = -1;
  List<String> _currentPageWords = [];
  List<int> _wordStartTimes = [];
  List<int> _wordEndTimes = [];

  // تخزين مؤقت للصفحات
  List<List<Ayah>>? _cachedPages;
  int? _cachedPagesKey;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final quranProvider = context.read<QuranProvider>();
      quranProvider.loadSurahAyahs(widget.surah.number);
      _setupAudioStateListener();
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _audioCompleteSubscription?.cancel();
    _pages.clear();
    _currentPageWords.clear();
    _wordStartTimes.clear();
    _wordEndTimes.clear();
    super.dispose();
  }

  void _toggleBars() {
    setState(() {
      _showBars = !_showBars;
    });
  }

  void _hideBarsAfterDelay() {
    if (!_showBars) return;
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _showBars) {
        _toggleBars();
      }
    });
  }

  void _playFullPage(int pageIndex) async {
    if (pageIndex < 0 || pageIndex >= _pages.length || _pages[pageIndex].isEmpty) {
      return;
    }
    setState(() {
      _isPlayingFullPage = true;
      _currentPlayingAyahIndex = 0;
      _currentPageAyahs = _pages[pageIndex];
    });

    try {
      await context.read<AudioProvider>().stopAudio();
    } catch (e) {}

    _setupAudioCompleteListener();
    _playNextAyahInPage();
  }

  void _setupAudioCompleteListener() {
    _audioCompleteSubscription?.cancel();
    try {
      final audioProvider = context.read<AudioProvider>();
      _audioCompleteSubscription = audioProvider.onAudioComplete.listen((_) {
        if (mounted && _isPlayingFullPage) {
          Future.microtask(() {
            if (mounted && _isPlayingFullPage) {
              _playNextAyahInPage();
            }
          });
        }
      });
    } catch (e) {
      debugPrint('Failed to setup audio listener: $e');
    }
  }

  void _playNextAyahInPage() async {
    if (!_isPlayingFullPage || _currentPlayingAyahIndex >= _currentPageAyahs.length) {
      if (mounted) {
        setState(() {
          _isPlayingFullPage = false;
          _currentPlayingAyahIndex = 0;
        });
      }
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
        await context.read<AudioProvider>().playAyah(audioUrl);
        if (mounted) {
          setState(() {
            _currentPlayingAyahIndex++;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _currentPlayingAyahIndex++;
          });
        }
        Future.microtask(() {
          if (mounted && _isPlayingFullPage) {
            _playNextAyahInPage();
          }
        });
      }
    } catch (e) {
      debugPrint('Error playing ayah: $e');
      if (mounted) {
        setState(() {
          _currentPlayingAyahIndex++;
        });
      }
      Future.microtask(() {
        if (mounted && _isPlayingFullPage) {
          _playNextAyahInPage();
        }
      });
    }
  }

  void _stopFullPage() async {
    setState(() {
      _isPlayingFullPage = false;
      _currentPlayingAyahIndex = 0;
    });
    try {
      await context.read<AudioProvider>().stopAudio();
    } catch (e) {}
    _audioCompleteSubscription?.cancel();
    _resetReadingIndicator();
  }

  void _resetReadingIndicator() {
    setState(() {
      _isReadingMode = false;
      _currentReadingAyahIndex = -1;
      _currentReadingPageIndex = -1;
      _currentReadingWordIndex = -1;
      _currentPageWords.clear();
      _wordStartTimes.clear();
      _wordEndTimes.clear();
    });
  }

  Widget _buildAudioControls() {
    if (!_showAudioControls) return const SizedBox.shrink();
    return Positioned(
      bottom: 100,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
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
                IconButton(
                  onPressed: () {
                    final audioProvider = context.read<AudioProvider>();
                    audioProvider.stopAudio();
                    if (_isPlayingFullPage) {
                      _stopFullPage();
                    } else {
                      _resetReadingIndicator();
                    }
                  },
                  icon: const Icon(Icons.stop, color: Colors.white, size: 28),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5722),
                    padding: const EdgeInsets.all(12),
                  ),
                ),
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

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Widget _buildHighlightedText(List<Ayah> pageAyahs, int pageIndex) {
    if (_currentPageWords.isEmpty || _currentReadingPageIndex != pageIndex) {
      Future.microtask(() {
        if (mounted) {
          _analyzePageWords(pageAyahs);
        }
      });
    }

    bool hasBasmala = pageAyahs.isNotEmpty && 
                     pageAyahs.first.number == 1 && 
                     widget.surah.number != 1 && 
                     widget.surah.number != 9;

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      itemCount: pageAyahs.length + (hasBasmala ? 1 : 0),
      itemBuilder: (context, index) {
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
        return _buildAyahWithMadinahStyle(ayah, ayahIndex, pageIndex, pageAyahs);
      },
    );
  }

  Widget _buildAyahWithMadinahStyle(Ayah ayah, int ayahIndex, int pageIndex, List<Ayah> pageAyahs) {
    final isFirstAyah = ayah.number == 1;
    final isSurahAlFatiha = widget.surah.number == 1;
    final isSurahAlTawbah = widget.surah.number == 9;
    final hasSajda = ayah.textAr.contains('۩');

    return InkWell(
      onTap: () => _playAyah(ayah),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          textDirection: TextDirection.rtl,
          children: [
            if (!isFirstAyah || (isFirstAyah && (isSurahAlFatiha || isSurahAlTawbah)))
              Container(
                margin: const EdgeInsets.only(left: 8, top: 2),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
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
            Expanded(
              child: RichText(
                text: TextSpan(
                  children: _buildAyahTextSpans(ayah, ayahIndex, pageIndex, pageAyahs),
                  style: const TextStyle(
                    fontSize: 28, // ✅ تم زيادة الحجم
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

  List<TextSpan> _buildAyahTextSpans(Ayah ayah, int ayahIndex, int pageIndex, List<Ayah> pageAyahs) {
    final words = ayah.textAr.split(RegExp(r'\s+'));
    List<TextSpan> spans = [];
    for (int wordIndex = 0; wordIndex < words.length; wordIndex++) {
      final word = words[wordIndex];
      if (word.trim().isEmpty) continue;
      final globalWordIndex = _getGlobalWordIndex(ayahIndex, wordIndex, pageAyahs);
      final isCurrentWord = _isReadingMode && 
                          _currentReadingPageIndex == pageIndex && 
                          _currentReadingWordIndex == globalWordIndex;

      if (wordIndex > 0) {
        spans.add(const TextSpan(text: ' '));
      }

      spans.add(
        TextSpan(
          text: word,
          style: TextStyle(
            color: isCurrentWord ? const Color(0xFF4CAF50) : Colors.white,
            fontSize: 28,
            fontFamily: 'Amiri',
            fontWeight: isCurrentWord ? FontWeight.bold : FontWeight.w500,
            backgroundColor: isCurrentWord 
                ? const Color(0xFF4CAF50).withOpacity(0.2)
                : Colors.transparent,
            decoration: isCurrentWord ? TextDecoration.underline : TextDecoration.none,
            decorationColor: isCurrentWord ? const Color(0xFF4CAF50) : null,
            decorationThickness: isCurrentWord ? 2.0 : null,
          ),
        ),
      );
    }
    return spans;
  }

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
              final type = widget.surah.revelationType == 'Meccan' ? 'مكية' : 'مدنية';
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
          _buildToolButton(
            icon: _isPlayingFullPage ? Icons.stop : Icons.playlist_play,
            label: _isPlayingFullPage ? 'إيقاف التشغيل' : 'تشغيل كامل الصفحة',
            onTap: _isPlayingFullPage 
                ? () => _stopFullPage()
                : () => _playFullPage(_currentPage),
            color: _isPlayingFullPage ? const Color(0xFFFF5722) : const Color(0xFF4CAF50),
          ),
          const SizedBox(height: 12),
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
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNextSurahButton(BuildContext context) {
    final quranProvider = context.read<QuranProvider>();
    final allSurahs = quranProvider.surahs;
    final currentSurahIndex = allSurahs.indexWhere((s) => s.number == widget.surah.number);
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
      label: Text('الانتقال إلى سورة ${nextSurah.nameAr}', style: const TextStyle(fontSize: 18)),
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
        backgroundColor: const Color(0xFF1A1A2E),
        body: SafeArea(
          child: Consumer2<QuranProvider, AudioProvider>(
            builder: (context, quranProvider, audioProvider, child) {
              if (quranProvider.isLoading) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              }
              if (quranProvider.currentSurahAyahs.isEmpty) {
                return const Center(child: Text('لا توجد آيات متاحة', style: TextStyle(color: Colors.white)));
              }

              if (_pages.isEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted && _pages.isEmpty) {
                    final newPages = _groupAyahsIntoPages(quranProvider.currentSurahAyahs);
                    if (mounted) {
                      setState(() {
                        _pages = newPages;
                      });
                    }
                  }
                });
              }

              if (_pages.isEmpty) {
                return const Center(child: Text('لا توجد صفحات متاحة', style: TextStyle(color: Colors.white)));
              }

              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [Color(0xFF16213E), Color(0xFF0F3460)]),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: () async {
                            try {
                              final audioProvider = context.read<AudioProvider>();
                              await audioProvider.stopAudio();
                              if (mounted) {
                                Navigator.of(context).pop();
                              }
                            } catch (e) {
                              if (mounted) {
                                Navigator.of(context).pop();
                              }
                            }
                          },
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: const Color(0xFF4CAF50),
                                radius: 20,
                                child: Text(
                                  '${widget.surah.number}',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.surah.nameAr,
                                      style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'الصفحة ${_currentPage + 1} من ${_pages.length}',
                                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.menu_book, color: Colors.amber),
                              tooltip: 'تفسير السورة',
                              onPressed: () {
                                Navigator.pushNamed(context, '/tafsir', arguments: {'surah': widget.surah});
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.settings, color: Colors.white),
                              onPressed: () {
                                Navigator.pushNamed(context, '/audio-settings');
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.person, color: Colors.white),
                              onPressed: () {
                                Navigator.pushNamed(context, '/reciter-selection');
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.play_arrow, color: Colors.white),
                              onPressed: () {
                                if (_currentPage < _pages.length) {
                                  _playPage(_currentPage);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F3460),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3), width: 1),
                      ),
                      child: SingleChildScrollView(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28, // ✅ حجم أكبر
                              height: 1.8,
                              fontFamily: 'Amiri',
                            ),
                            children: _pages[_currentPage].map((ayah) {
                              return TextSpan(
                                text: '${ayah.textAr} ﴿${ayah.number}﴾ ',
                                style: const TextStyle(color: Colors.white),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    _playAyah(ayah);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('تشغيل الآية ${ayah.number}'),
                                        backgroundColor: const Color(0xFF4CAF50),
                                        duration: const Duration(seconds: 1),
                                      ),
                                    );
                                  },
                              );
                            }).toList(),
                          ),
                          textAlign: TextAlign.justify,
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16213E).withOpacity(0.9),
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                      border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3), width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: _currentPage > 0 ? const Color(0xFF4CAF50) : Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            onPressed: _currentPage > 0
                                ? () {
                                    setState(() {
                                      _currentPage--;
                                    });
                                  }
                                : null,
                            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F3460),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFF4CAF50).withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'الصفحة ${_currentPage + 1} من ${_pages.length}',
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                textDirection: TextDirection.rtl,
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () {
                                  _playPage(_currentPage);
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF4CAF50),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(Icons.playlist_play, color: Colors.white, size: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: _currentPage < _pages.length - 1 ? const Color(0xFF4CAF50) : Colors.grey.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: IconButton(
                            onPressed: _currentPage < _pages.length - 1
                                ? () {
                                    setState(() {
                                      _currentPage++;
                                    });
                                  }
                                : null,
                            icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  List<List<Ayah>> _groupAyahsIntoPages(List<Ayah> ayahs) {
    if (ayahs.isEmpty) return [];
    final cacheKey = ayahs.hashCode;
    if (_cachedPages != null && _cachedPagesKey == cacheKey) {
      return _cachedPages!;
    }
    final Map<int, List<Ayah>> pageMap = <int, List<Ayah>>{};
    for (final ayah in ayahs) {
      int? pageNum;
      try {
        if (ayah.page != null) {
          pageNum = ayah.page;
        } else if (ayah.toJson().containsKey('page')) {
          pageNum = ayah.toJson()['page'] as int;
        }
      } catch (e) {
        continue;
      }
      if (pageNum != null) {
        pageMap.putIfAbsent(pageNum, () => <Ayah>[]).add(ayah);
      }
    }
    final sortedPages = pageMap.keys.toList()..sort();
    final result = <List<Ayah>>[];
    for (final p in sortedPages) {
      result.add(pageMap[p]!);
    }
    _cachedPages = result;
    _cachedPagesKey = cacheKey;
    return result;
  }

  void _playAyah(Ayah ayah) {
    try {
      final audioUrl = context.read<QuranProvider>().getAudioUrl(widget.surah.number, ayah.number);
      if (audioUrl.isNotEmpty) {
        context.read<AudioProvider>().stopAudio();
        context.read<AudioProvider>().playAyah(audioUrl, surahNumber: widget.surah.number, ayahNumber: ayah.number);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطأ في تشغيل الصوت'), backgroundColor: Colors.red),
      );
    }
  }

  void _playPage(int pageIndex) {
    if (pageIndex >= 0 && pageIndex < _pages.length && _pages[pageIndex].isNotEmpty) {
      _playAyah(_pages[pageIndex].first);
    }
  }

  void _setupAudioStateListener() {
    final audioProvider = context.read<AudioProvider>();
    audioProvider.addListener(() {
      if (mounted) {
        setState(() {
          _isAudioPlaying = audioProvider.isPlaying;
          _showAudioControls = audioProvider.isPlaying || audioProvider.isPaused;
          _audioPosition = audioProvider.currentPosition;
          _audioDuration = audioProvider.totalDuration;
          _updateReadingIndicator(audioProvider);
        });
      }
    });
  }

  void _updateReadingIndicator(AudioProvider audioProvider) {
    if (!audioProvider.isPlaying || _pages.isEmpty) {
      _isReadingMode = false;
      _currentReadingAyahIndex = -1;
      _currentReadingPageIndex = -1;
      _currentReadingWordIndex = -1;
      return;
    }
    if (_isPlayingFullPage && _currentPageAyahs.isNotEmpty) {
      _isReadingMode = true;
      _currentReadingPageIndex = _currentPage;
      _currentReadingAyahIndex = _currentPlayingAyahIndex;
      _updateCurrentWordIndex(audioProvider);
      return;
    }
    final currentPage = _currentPage;
    if (currentPage >= 0 && currentPage < _pages.length) {
      final pageAyahs = _pages[currentPage];
      final totalDuration = audioProvider.totalDuration;
      final currentPosition = audioProvider.currentPosition;
      if (totalDuration.inSeconds > 0 && pageAyahs.isNotEmpty) {
        final progress = currentPosition.inSeconds / totalDuration.inSeconds;
        final estimatedAyahIndex = (progress * pageAyahs.length).floor();
        if (estimatedAyahIndex >= 0 && estimatedAyahIndex < pageAyahs.length) {
          _isReadingMode = true;
          _currentReadingPageIndex = currentPage;
          _currentReadingAyahIndex = estimatedAyahIndex;
          _updateCurrentWordIndex(audioProvider);
        }
      }
    }
  }

  void _updateCurrentWordIndex(AudioProvider audioProvider) {
    if (!_isReadingMode || _currentReadingPageIndex < 0 || _currentReadingPageIndex >= _pages.length) return;
    final currentPage = _currentReadingPageIndex;
    final pageAyahs = _pages[currentPage];
    if (_currentReadingAyahIndex >= 0 && _currentReadingAyahIndex < pageAyahs.length) {
      final currentAyah = pageAyahs[_currentReadingAyahIndex];
      if (_currentPageWords.isEmpty || _currentReadingPageIndex != currentPage) {
        _analyzePageWords(pageAyahs);
      }
      final currentPosition = audioProvider.currentPosition.inMilliseconds;
      final totalDuration = audioProvider.totalDuration.inMilliseconds;
      if (totalDuration > 0 && _wordStartTimes.isNotEmpty) {
        for (int i = 0; i < _wordStartTimes.length; i++) {
          if (currentPosition >= _wordStartTimes[i] && currentPosition <= _wordEndTimes[i]) {
            if (_currentReadingWordIndex != i) {
              _currentReadingWordIndex = i;
            }
            break;
          }
        }
      }
    }
  }

  void _analyzePageWords(List<Ayah> pageAyahs) {
    _currentPageWords.clear();
    _wordStartTimes.clear();
    _wordEndTimes.clear();
    int currentTime = 0;
    final wordSplitter = RegExp(r'\s+');
    for (final ayah in pageAyahs) {
      final words = ayah.textAr.split(wordSplitter);
      for (final word in words) {
        final trimmedWord = word.trim();
        if (trimmedWord.isNotEmpty) {
          _currentPageWords.add(trimmedWord);
          _wordStartTimes.add(currentTime);
          final estimatedDuration = _estimateWordDuration(trimmedWord);
          currentTime += estimatedDuration;
          _wordEndTimes.add(currentTime);
        }
      }
      currentTime += 500;
    }
  }

  int _estimateWordDuration(String word) {
    final baseDuration = word.length * 200;
    return word.length > 5 ? baseDuration + 300 : baseDuration;
  }
}