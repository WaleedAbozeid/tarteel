import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:provider/provider.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSurahData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // التحقق من تحديث البيانات عند تغيير التبعيات
    final quranProvider = context.read<QuranProvider>();
    if (quranProvider.currentSurahAyahs.isNotEmpty && 
        quranProvider.selectedSurah?.number == widget.surah.number &&
        _pages.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _pages = _groupAyahsIntoPages(quranProvider.currentSurahAyahs);
          });
        }
      });
    }
  }

  // تحميل بيانات السورة مع التحسينات
  Future<void> _loadSurahData() async {
    final quranProvider = context.read<QuranProvider>();
    
    // التحقق من وجود البيانات في التخزين المؤقت
    if (quranProvider.currentSurahAyahs.isNotEmpty && 
        quranProvider.selectedSurah?.number == widget.surah.number) {
      if (mounted) {
        setState(() {
          _pages = _groupAyahsIntoPages(quranProvider.currentSurahAyahs);
        });
      }
      return;
    }
    
    // تحميل البيانات
    await quranProvider.loadSurahAyahs(widget.surah.number);
    
    if (mounted) {
      setState(() {
        _pages = _groupAyahsIntoPages(quranProvider.currentSurahAyahs);
      });
    }
  }

  // تحديث الصفحات
  void _updatePages() {
    final ayahs = context.read<QuranProvider>().currentSurahAyahs;
    if (ayahs.isNotEmpty && mounted) {
      setState(() {
        _pages = _groupAyahsIntoPages(ayahs);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        try {
          final audioProvider = context.read<AudioProvider>();
          await audioProvider.stopAudio();
          return true;
        } catch (e) {
          return true;
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        body: SafeArea(
          child: Consumer2<QuranProvider, AudioProvider>(
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

              // استخدام الصفحات المحسنة - بدون استدعاء setState
              if (_pages.isEmpty) {
                // تحديث الصفحات بدون setState
                final ayahs = quranProvider.currentSurahAyahs;
                if (ayahs.isNotEmpty) {
                  // تأجيل تحديث الصفحات لتجنب مشاكل البناء
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

              return Column(
                children: [
                  // شريط العنوان المدمج
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF16213E), Color(0xFF0F3460)],
                      ),
                    ),
                    child: Row(
                      children: [
                        // زر العودة
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
                        
                        // معلومات السورة
                        Expanded(
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: const Color(0xFF4CAF50),
                                radius: 20,
                                child: Text(
                                  '${widget.surah.number}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.surah.nameAr,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'الصفحة ${_currentPage + 1} من ${_pages.length}',
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // أزرار التحكم + زر التفسير
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.menu_book, color: Colors.amber),
                              tooltip: 'تفسير السورة',
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/tafsir',
                                  arguments: {'surah': widget.surah},
                                );
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

                  // محتوى الصفحة - يأخذ معظم المساحة
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F3460),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF4CAF50).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: SingleChildScrollView(
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24, // زيادة حجم الخط
                              height: 2.5, // زيادة المسافة بين السطور
                              fontFamily: 'Amiri',
                            ),
                            children: _pages[_currentPage].map((ayah) {
                              return TextSpan(
                                text: '${ayah.textAr} ﴿${ayah.number}﴾ ',
                                style: const TextStyle(
                                  color: Colors.white,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    _playAyah(ayah);
                                    // إظهار رسالة تأكيد
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('تشغيل الآية ${ayah.number}'),
                                        backgroundColor: const Color(0xFF4CAF50),
                                        duration: const Duration(seconds: 1),
                                        behavior: SnackBarBehavior.floating,
                                        margin: const EdgeInsets.all(16),
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

                  // أزرار التنقل بين الصفحات - مصغرة
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF16213E).withOpacity(0.9),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      border: Border.all(
                        color: const Color(0xFF4CAF50).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // زر الصفحة السابقة
                        Container(
                          decoration: BoxDecoration(
                            color: _currentPage > 0 
                                ? const Color(0xFF4CAF50) 
                                : Colors.grey.withOpacity(0.3),
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
                        
                        // معلومات الصفحة
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F3460),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF4CAF50).withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'الصفحة ${_currentPage + 1} من ${_pages.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
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
                                  child: const Icon(
                                    Icons.playlist_play,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // زر الصفحة التالية
                        Container(
                          decoration: BoxDecoration(
                            color: _currentPage < _pages.length - 1 
                                ? const Color(0xFF4CAF50) 
                                : Colors.grey.withOpacity(0.3),
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

  // تجميع الآيات في صفحات
  List<List<Ayah>> _groupAyahsIntoPages(List<Ayah> ayahs) {
    List<List<Ayah>> pages = [];
    List<Ayah> currentPage = [];
    int wordsCount = 0;
    const int maxWordsPerPage = 200;
    
    for (Ayah ayah in ayahs) {
      int ayahWords = ayah.textAr.split(' ').length;
      
      if (wordsCount + ayahWords > maxWordsPerPage && currentPage.isNotEmpty) {
        pages.add(List.from(currentPage));
        currentPage.clear();
        wordsCount = 0;
      }
      
      currentPage.add(ayah);
      wordsCount += ayahWords;
      
      if (currentPage.length >= 20) {
        pages.add(List.from(currentPage));
        currentPage.clear();
        wordsCount = 0;
      }
    }
    
    if (currentPage.isNotEmpty) {
      pages.add(List.from(currentPage));
    }
    
    return pages;
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