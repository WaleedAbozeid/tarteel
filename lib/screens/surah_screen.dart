import 'package:flutter/material.dart';
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
        appBar: AppBar(
          title: Text(
            'سورة ${widget.surah.nameAr}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF16213E),
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
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
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                Navigator.pushNamed(context, '/audio-settings');
              },
            ),
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: () {
                Navigator.pushNamed(context, '/reciter-selection');
              },
            ),
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: () {
                if (_currentPage < _pages.length) {
                  _playPage(_currentPage);
                }
              },
            ),
          ],
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
                // معلومات السورة
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF16213E), Color(0xFF0F3460)],
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFF4CAF50),
                        radius: 25,
                        child: Text(
                          '${widget.surah.number}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
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
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // محتوى الصفحة
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F3460),
                      borderRadius: BorderRadius.circular(16),
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
                            fontSize: 20,
                            height: 2.2,
                            fontFamily: 'Amiri',
                          ),
                          children: _pages[_currentPage].map((ayah) {
                            return TextSpan(
                              text: '${ayah.textAr} ﴿${ayah.number}﴾ ',
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            );
                          }).toList(),
                        ),
                        textAlign: TextAlign.justify,
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ),
                ),

                // أزرار التنقل بين الصفحات
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16213E).withOpacity(0.9),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
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
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: _currentPage > 0
                              ? () {
                                  setState(() {
                                    _currentPage--;
                                  });
                                }
                              : null,
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                        ),
                      ),
                      
                      // معلومات الصفحة
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F3460),
                          borderRadius: BorderRadius.circular(20),
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
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                            const SizedBox(width: 16),
                            GestureDetector(
                              onTap: () {
                                _playPage(_currentPage);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF4CAF50),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(
                                  Icons.playlist_play,
                                  color: Colors.white,
                                  size: 20,
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
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: _currentPage < _pages.length - 1
                              ? () {
                                  setState(() {
                                    _currentPage++;
                                  });
                                }
                              : null,
                          icon: const Icon(Icons.arrow_forward, color: Colors.white),
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