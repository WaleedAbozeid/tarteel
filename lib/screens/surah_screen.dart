import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/gestures.dart';
import '../providers/quran_provider.dart';
import '../providers/audio_provider.dart';
import '../models/quran_models.dart';

class SurahScreen extends StatefulWidget {
  final Surah surah;

  const SurahScreen({
    super.key,
    required this.surah,
  });

  @override
  State<SurahScreen> createState() => _SurahScreenState();
}

class _SurahScreenState extends State<SurahScreen> {

int _currentPage = 0;
List<List<Ayah>> _pages = [];
bool _showTools = false;
bool _showBars = true;
late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final quranProvider = context.read<QuranProvider>();
      quranProvider.loadSurahAyahs(widget.surah.number);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
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
                  title: Text('معلومات السورة'),
                  content: Text('عدد الآيات: ${widget.surah.numberOfAyahs}\nنوع السورة: $type'),
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
                  }
                : null,
          ),
          const SizedBox(height: 12),
          _buildToolButton(
            icon: Icons.playlist_play,
            label: 'تشغيل الصفحة',
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

  Widget _buildToolButton({required IconData icon, required String label, VoidCallback? onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF16213E),
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
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          MaterialPageRoute(
            builder: (_) => SurahScreen(surah: nextSurah),
          ),
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
        appBar: _showBars
            ? AppBar(
                backgroundColor: const Color(0xFF16213E),
                iconTheme: const IconThemeData(color: Colors.white),
                title: Text(
                  widget.surah.nameAr,
                  style: const TextStyle(color: Colors.white),
                ),
              )
            : null,
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
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _pages = _groupAyahsIntoPages(ayahs);
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
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() {
                  _showBars = !_showBars;
                });
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
                    },
                    itemBuilder: (context, index) {
                      final pageAyahs = _pages[index];
                      int? pageNumber;
                      if (pageAyahs.isNotEmpty && pageAyahs.first.toJson().containsKey('page')) {
                        pageNumber = pageAyahs.map((a) => a.toJson()['page'] as int).reduce((a, b) => a < b ? a : b);
                      } else if (pageAyahs.isNotEmpty && (pageAyahs.first as dynamic).page != null) {
                        pageNumber = pageAyahs.map((a) => (a as dynamic).page as int).reduce((a, b) => a < b ? a : b);
                      }
                      return Column(
                        children: [
                          Expanded(
                            child: Container(
                              key: ValueKey(index),
                              width: double.infinity,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              color: const Color(0xFF0F3460),
                              child: SingleChildScrollView(
                                padding: const EdgeInsets.symmetric(horizontal: 0),
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      height: 2.1,
                                      fontFamily: 'Amiri',
                                    ),
                                    children: pageAyahs.map((ayah) {
                                      return TextSpan(
                                        text: ayah.textAr + ' ﴿${ayah.number}﴾ ',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontFamily: 'Amiri',
                                        ),
                                        recognizer: (TapGestureRecognizer()
                                          ..onTap = () => _playAyah(ayah)),
                                      );
                                    }).toList(),
                                  ),
                                  textAlign: TextAlign.justify,
                                  textDirection: TextDirection.rtl,
                                ),
                              ),
                            ),
                          ),
                          if (pageNumber != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 12, top: 4),
                              child: Text(
                                'صفحة $pageNumber',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          if (index == _pages.length - 1)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 24, top: 8),
                              child: _buildNextSurahButton(context),
                            ),
                        ],
                      );
                    },
                  ),
                  // أدوات التحكم السفلية تظهر وتختفي مع _showBars
                  if (_showBars)
                    Positioned(
                      right: 16,
                      bottom: 24,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: _buildFabTools(),
                      ),
                    ),
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
    Map<int, List<Ayah>> pageMap = {};
    for (var ayah in ayahs) {
      int? pageNum;
      // محاولة استخراج رقم الصفحة من خاصية page أو من toJson
      if (ayah.toJson().containsKey('page')) {
        pageNum = ayah.toJson()['page'] as int;
      } else if ((ayah as dynamic).page != null) {
        pageNum = (ayah as dynamic).page as int;
      }
      if (pageNum != null) {
        pageMap.putIfAbsent(pageNum, () => []).add(ayah);
      }
    }
    // ترتيب الصفحات تصاعدياً حسب مصحف المدينة
    final sortedPages = pageMap.keys.toList()..sort();
    // إذا أردت أن تبدأ من أول صفحة مصحفية حقيقية للسورة وتكمل حتى آخر صفحة
    return [for (var p in sortedPages) pageMap[p]!];
  }

  // تشغيل آية محددة
  void _playAyah(Ayah ayah) {
    try {
      final audioUrl = context.read<QuranProvider>().getAudioUrl(
        widget.surah.number,
        ayah.number,
      );
      if (audioUrl.isNotEmpty) {
        context.read<AudioProvider>().playAyah(audioUrl);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('خطأ في تشغيل الصوت: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // تشغيل صفحة محددة
  void _playPage(int pageIndex) {
    if (pageIndex >= 0 && pageIndex < _pages.length && _pages[pageIndex].isNotEmpty) {
      _playAyah(_pages[pageIndex].first);
    }
  }
}