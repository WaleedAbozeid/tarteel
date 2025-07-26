import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quran_provider.dart';
import '../providers/audio_provider.dart';
import '../models/quran_models.dart';

class RecitationScreen extends StatefulWidget {
  final Surah surah;
  final Ayah? ayah;

  const RecitationScreen({
    super.key,
    required this.surah,
    this.ayah,
  });

  @override
  State<RecitationScreen> createState() => _RecitationScreenState();
}

class _RecitationScreenState extends State<RecitationScreen> {
  int _currentAyahIndex = 0;
  bool _showTafsir = false;
  Map<String, dynamic>? _analysisResult;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuranProvider>().loadSurahAyahs(widget.surah.number);
      if (widget.ayah != null) {
        _currentAyahIndex = widget.ayah!.number - 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        try {
          // إيقاف الصوت قبل الرجوع
          final audioProvider = context.read<AudioProvider>();
          await audioProvider.stopAudio();
          return true;
        } catch (e) {
          // في حالة حدوث خطأ، ارجع مباشرة
          return true;
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        appBar: AppBar(
          title: Text(
            'تلاوة ${widget.surah.nameAr}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF16213E),
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () async {
              try {
                // إيقاف الصوت قبل الرجوع
                final audioProvider = context.read<AudioProvider>();
                await audioProvider.stopAudio();
                
                // التحقق من أن الشاشة لا تزال موجودة
                if (mounted) {
                  Navigator.of(context).pop();
                }
              } catch (e) {
                // في حالة حدوث خطأ، ارجع مباشرة
                if (mounted) {
                  Navigator.of(context).pop();
                }
              }
            },
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

            final currentAyah = quranProvider.currentSurahAyahs[_currentAyahIndex];

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
                        child: Text(
                          '${widget.surah.number}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
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
                              'الآية ${currentAyah.number} من ${quranProvider.currentSurahAyahs.length}',
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // النص القرآني
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // النص العربي
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F3460),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Text(
                                currentAyah.textAr,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  height: 2.0,
                                ),
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                currentAyah.translationAr,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                  height: 1.5,
                                ),
                                textAlign: TextAlign.center,
                                textDirection: TextDirection.rtl,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // أزرار التحكم
                        Column(
                          children: [
                            // عرض رسائل الخطأ
                            if (audioProvider.recordingError.isNotEmpty)
                              Container(
                                width: double.infinity,
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        audioProvider.recordingError,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 14,
                                        ),
                                        textDirection: TextDirection.rtl,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.close, color: Colors.red),
                                      onPressed: () {
                                        audioProvider.clearError();
                                      },
                                    ),
                                  ],
                                ),
                              ),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // زر التشغيل
                                FloatingActionButton(
                                  onPressed: () {
                                    try {
                                      final audioUrl = quranProvider.getAudioUrl(
                                        widget.surah.number,
                                        currentAyah.number,
                                      );
                                      if (audioUrl.isNotEmpty) {
                                        audioProvider.playAyah(audioUrl);
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'رابط الصوت غير متاح لهذه الآية',
                                              textDirection: TextDirection.rtl,
                                            ),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'خطأ في تشغيل الصوت: $e',
                                            textDirection: TextDirection.rtl,
                                          ),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  backgroundColor: const Color(0xFF4CAF50),
                                  child: Icon(
                                    audioProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                                    color: Colors.white,
                                  ),
                                ),

                                // زر التسجيل
                                FloatingActionButton(
                                  onPressed: () {
                                    if (audioProvider.isListening) {
                                      audioProvider.stopRecording();
                                    } else {
                                      audioProvider.startRecording();
                                    }
                                  },
                                  backgroundColor: audioProvider.isListening 
                                      ? Colors.red 
                                      : const Color(0xFF2196F3),
                                  child: Icon(
                                    audioProvider.isListening ? Icons.stop : Icons.mic,
                                    color: Colors.white,
                                  ),
                                ),

                                // زر التفسير
                                FloatingActionButton(
                                  onPressed: () {
                                    setState(() {
                                      _showTafsir = !_showTafsir;
                                    });
                                    if (_showTafsir) {
                                      quranProvider.loadAyahTafsir(
                                        widget.surah.number,
                                        currentAyah.number,
                                      );
                                    }
                                  },
                                  backgroundColor: const Color(0xFFFF9800),
                                  child: const Icon(
                                    Icons.lightbulb,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // النص المعترف عليه
                        if (audioProvider.recognizedText.isNotEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F3460),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFF4CAF50),
                                width: 2,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'نص التلاوة:',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  audioProvider.recognizedText,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                  textDirection: TextDirection.rtl,
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () {
                                    final analysis = audioProvider.analyzeRecitation(
                                      audioProvider.recognizedText,
                                      currentAyah.textAr,
                                    );
                                    setState(() {
                                      _analysisResult = analysis;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4CAF50),
                                  ),
                                  child: const Text(
                                    'تحليل التلاوة',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // نتائج التحليل
                        if (_analysisResult != null)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F3460),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'نتائج التحليل:',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildAnalysisItem(
                                  'الدقة',
                                  '${_analysisResult!['accuracy'].toStringAsFixed(1)}%',
                                  _getAccuracyColor(_analysisResult!['accuracy']),
                                ),
                                _buildAnalysisItem(
                                  'التقييم',
                                  _analysisResult!['score'],
                                  _getScoreColor(_analysisResult!['score']),
                                ),
                                _buildAnalysisItem(
                                  'الكلمات الصحيحة',
                                  '${_analysisResult!['correctWords']}/${_analysisResult!['totalWords']}',
                                  const Color(0xFF4CAF50),
                                ),
                              ],
                            ),
                          ),

                        // التفسير
                        if (_showTafsir && quranProvider.currentTafsir != null)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(top: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F3460),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'التفسير الميسر:',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  quranProvider.currentTafsir!.text,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    height: 1.5,
                                  ),
                                  textDirection: TextDirection.rtl,
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // أزرار التنقل
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: _currentAyahIndex > 0
                            ? () {
                                setState(() {
                                  _currentAyahIndex--;
                                  _analysisResult = null;
                                  audioProvider.clearRecognizedText();
                                });
                              }
                            : null,
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      Text(
                        '${_currentAyahIndex + 1} من ${quranProvider.currentSurahAyahs.length}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      IconButton(
                        onPressed: _currentAyahIndex < quranProvider.currentSurahAyahs.length - 1
                            ? () {
                                setState(() {
                                  _currentAyahIndex++;
                                  _analysisResult = null;
                                  audioProvider.clearRecognizedText();
                                });
                              }
                            : null,
                        icon: const Icon(Icons.arrow_forward, color: Colors.white),
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

  Widget _buildAnalysisItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 80) return const Color(0xFF4CAF50);
    if (accuracy >= 60) return const Color(0xFFFF9800);
    return Colors.red;
  }

  Color _getScoreColor(String score) {
    switch (score) {
      case 'ممتاز':
        return const Color(0xFF4CAF50);
      case 'جيد':
        return const Color(0xFFFF9800);
      default:
        return Colors.red;
    }
  }
} 