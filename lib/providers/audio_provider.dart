import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import '../models/quran_models.dart';

class AudioProvider extends ChangeNotifier {
  /// دالة توافقية: تشغيل آية عبر رابط الصوت (للتوافق مع الكود القديم)
  Future<void> playAyah(String audioUrl, {String? reciterId, int? surahNumber, int? ayahNumber}) async {
    // إذا توفرت أرقام السورة والآية، استخدم الدالة الجديدة
    if (surahNumber != null && ayahNumber != null) {
      await playAyahByNumber(surahNumber: surahNumber, ayahNumber: ayahNumber);
      return;
    }
    // وإلا شغل الرابط مباشرة 
    
    //(للتوافق فقط)
    try {
      if (audioUrl.isEmpty) {
        _recordingError = 'رابط الصوت غير متاح';
        notifyListeners();
        return;
      }
      if (_currentAudioUrl != audioUrl) {
        await _stopCurrentAudio();
        _currentAudioUrl = audioUrl;
        _currentReciterId = reciterId ?? '';
      }
      await _audioPlayer.setSourceUrl(audioUrl);
      await _applyAudioSettings();
      await _audioPlayer.resume();
      _isPlaying = true;
      _isPaused = false;
      _isLoading = false;
      _recordingError = '';
      notifyListeners();
    } catch (e) {
      _recordingError = 'خطأ في تشغيل الصوت: $e';
      _isPlaying = false;
      _isPaused = false;
      _isLoading = false;
      notifyListeners();
    }
  }
  // قائمة القراء
  List<Reciter> _reciters = [
    Reciter(
      id: '1',
      name: 'عبد الباسط عبد الصمد (تجويد)',
      nameAr: 'عبد الباسط عبد الصمد',
      style: 'تجويد',
      server: 'https://server.com/tajweed/', // مثال: رابط مجلد ملفات التجويد
      rewaya: 'حفص عن عاصم',
    ),
    Reciter(
      id: '2',
      name: 'مشاري راشد العفاسي (ترتيل)',
      nameAr: 'مشاري راشد العفاسي',
      style: 'ترتيل',
      server: 'https://server.com/tarteel/', // مثال: رابط مجلد ملفات الترتيل
      rewaya: 'حفص عن عاصم',
    ),
  ];
  Reciter? _selectedReciter;

  List<Reciter> get reciters => _reciters;
  Reciter? get selectedReciter => _selectedReciter;

  void selectReciter(Reciter reciter) {
    _selectedReciter = reciter;
    notifyListeners();
  }
  // ... existing code ...

  // تعيين وضع التشغيل التلقائي للآية التالية
  void setAutoPlayNext(bool value) {
    _autoPlayNext = value;
    notifyListeners();
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  
  // حالات التشغيل
  bool _isPlaying = false;
  bool _isPaused = false;
  bool _isLoading = false;
  bool _isRecording = false;
  bool _isListening = false;
  
  // معلومات الصوت الحالي
  String _currentAudioUrl = '';
  String _currentReciterId = '';
  int _currentSurahNumber = 0;
  int _currentAyahNumber = 0;
  
  // معلومات التشغيل
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  double _volume = 1.0;
  double _playbackSpeed = 1.0;
  
  // معلومات التسجيل والتحليل
  String _recognizedText = '';
  String _recordingError = '';
  Map<String, dynamic>? _lastAnalysisResult;
  
  // قائمة التشغيل
  List<Ayah> _playlist = [];
  int _currentPlaylistIndex = 0;
  bool _isPlaylistMode = false;
  bool _isLoopMode = false;
  bool _isShuffleMode = false;
  
  // إعدادات الجودة
  bool _highQualityMode = false;
  bool _autoPlayNext = true;
  bool _rememberPosition = true;
  
  // Stream لمراقبة اكتمال الصوت
  final StreamController<void> _audioCompleteController = StreamController<void>.broadcast();
  Stream<void> get onAudioComplete => _audioCompleteController.stream;
  
  // Getters
  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  bool get isLoading => _isLoading;
  bool get isRecording => _isRecording;
  bool get isListening => _isListening;
  
  String get currentAudioUrl => _currentAudioUrl;
  String get currentReciterId => _currentReciterId;
  int get currentSurahNumber => _currentSurahNumber;
  int get currentAyahNumber => _currentAyahNumber;
  
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  double get volume => _volume;
  double get playbackSpeed => _playbackSpeed;
  
  String get recognizedText => _recognizedText;
  String get recordingError => _recordingError;
  Map<String, dynamic>? get lastAnalysisResult => _lastAnalysisResult;
  
  bool get isPlaylistMode => _isPlaylistMode;
  bool get isLoopMode => _isLoopMode;
  bool get isShuffleMode => _isShuffleMode;
  int get currentPlaylistIndex => _currentPlaylistIndex;
  int get playlistLength => _playlist.length;
  
  bool get highQualityMode => _highQualityMode;
  bool get autoPlayNext => _autoPlayNext;
  bool get rememberPosition => _rememberPosition;

  AudioProvider() {
    _initializeAudioPlayer();
  }

  // تهيئة مشغل الصوت مع معالجة شاملة للأخطاء
  void _initializeAudioPlayer() {
    try {
      // مراقبة حالة التشغيل
      _audioPlayer.onPlayerStateChanged.listen((state) {
        _handlePlayerStateChange(state);
      });

      // مراقبة الموضع الحالي
      _audioPlayer.onPositionChanged.listen((position) {
        _currentPosition = position;
        notifyListeners();
      });

      // مراقبة المدة الإجمالية
      _audioPlayer.onDurationChanged.listen((duration) {
        _totalDuration = duration;
        notifyListeners();
      });

      // مراقبة اكتمال التشغيل
      _audioPlayer.onPlayerComplete.listen((_) {
        _handlePlaybackComplete();
      });

    } catch (e) {
      _recordingError = 'خطأ في تهيئة مشغل الصوت: $e';
      notifyListeners();
    }
  }

  // معالجة تغيير حالة التشغيل
  void _handlePlayerStateChange(PlayerState state) {
    switch (state) {
      case PlayerState.playing:
        _isPlaying = true;
        _isPaused = false;
        _isLoading = false;
        _recordingError = '';
        break;
      case PlayerState.paused:
        _isPlaying = false;
        _isPaused = true;
        _isLoading = false;
        break;
      case PlayerState.stopped:
        _isPlaying = false;
        _isPaused = false;
        _isLoading = false;
        break;
      case PlayerState.completed:
        _isPlaying = false;
        _isPaused = false;
        _isLoading = false;
        // استدعاء معالجة اكتمال التشغيل
        _handlePlaybackComplete();
        break;
      default:
        _isLoading = false;
    }
    notifyListeners();
  }

  // معالجة أخطاء التشغيل
  void _handlePlayerError(String error) {
    _recordingError = 'خطأ في التشغيل: $error';
    _isPlaying = false;
    _isPaused = false;
    _isLoading = false;
    notifyListeners();
  }

  // معالجة اكتمال التشغيل
  void _handlePlaybackComplete() {
    if (_isPlaylistMode && _autoPlayNext) {
      _playNextInPlaylist();
    } else if (_isLoopMode) {
      _restartCurrentAudio();
    }
    
    // إشعار stream باكتمال الصوت
    _audioCompleteController.add(null);
  }

  // إعادة تشغيل الصوت الحالي
  void _restartCurrentAudio() {
    if (_currentAudioUrl.isNotEmpty) {
      playAyah(_currentAudioUrl);
    }
  }

  // طلب الأذونات مع معالجة شاملة
  Future<bool> requestPermissions() async {
    try {
      Map<Permission, PermissionStatus> statuses = await [
        Permission.microphone,
        Permission.storage,
        Permission.audio,
      ].request();

      bool allGranted = true;
      statuses.forEach((permission, status) {
        if (!status.isGranted) {
          allGranted = false;
        }
      });

      if (!allGranted) {
        _recordingError = 'يجب منح جميع الأذونات المطلوبة';
        notifyListeners();
      }

      return allGranted;
    } catch (e) {
      _recordingError = 'خطأ في طلب الأذونات: $e';
      notifyListeners();
      return false;
    }
  }

  // تشغيل آية مع تحسينات شاملة
  /// تشغيل آية بناءً على القارئ المختار (يدعم التجويد والترتيل)
  Future<void> playAyahByNumber({
    required int surahNumber,
    required int ayahNumber,
  }) async {
    try {
      if (_selectedReciter == null) {
        _recordingError = 'يرجى اختيار القارئ أولاً';
        notifyListeners();
        return;
      }
      
      // بناء رابط الصوت حسب القارئ المختار
      final audioUrl = '${_selectedReciter!.server}$surahNumber/$ayahNumber.mp3';
      if (audioUrl.isEmpty) {
        _recordingError = 'رابط الصوت غير متاح';
        print('خطأ: رابط الصوت فارغ');
        notifyListeners();
        return;
      }
      if (_currentAudioUrl != audioUrl) {
        print('إيقاف التشغيل السابق');
        await _stopCurrentAudio();
        _currentAudioUrl = audioUrl;
        _currentReciterId = _selectedReciter!.id;
        _currentSurahNumber = surahNumber;
        _currentAyahNumber = ayahNumber;
      }
      
      await _audioPlayer.setSourceUrl(audioUrl);
      await _applyAudioSettings();
      await _audioPlayer.resume();
      _isPlaying = true;
      _isPaused = false;
      _isLoading = false;
      _recordingError = '';
      print('تم تشغيل الصوت بنجاح');
      notifyListeners();
    } catch (e) {
      print('خطأ في تشغيل الصوت: $e');
      _recordingError = 'خطأ في تشغيل الصوت: $e';
      _isPlaying = false;
      _isPaused = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // إيقاف التشغيل الحالي
  Future<void> _stopCurrentAudio() async {
    try {
      await _audioPlayer.stop();
      _currentPosition = Duration.zero;
    } catch (e) {
      // تجاهل الأخطاء عند الإيقاف
    }
  }

  // تطبيق إعدادات الصوت
  Future<void> _applyAudioSettings() async {
    try {
      await _audioPlayer.setPlaybackRate(_playbackSpeed);
      await _audioPlayer.setVolume(_volume);
    } catch (e) {
      // تجاهل أخطاء الإعدادات
    }
  }

  // إيقاف التشغيل
  Future<void> pauseAudio() async {
    try {
      await _audioPlayer.pause();
      _isPaused = true;
      _isPlaying = false;
      notifyListeners();
    } catch (e) {
      _recordingError = 'خطأ في إيقاف التشغيل: $e';
      notifyListeners();
    }
  }

  // استئناف التشغيل
  Future<void> resumeAudio() async {
    try {
      await _audioPlayer.resume();
      _isPlaying = true;
      _isPaused = false;
      notifyListeners();
    } catch (e) {
      _recordingError = 'خطأ في استئناف التشغيل: $e';
      notifyListeners();
    }
  }

  // إيقاف التشغيل تماماً
  Future<void> stopAudio() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
      _isPaused = false;
      _isLoading = false;
      _currentPosition = Duration.zero;
      _currentAudioUrl = '';
      _recordingError = '';
      notifyListeners();
    } catch (e) {
      // تجاهل الأخطاء عند الإيقاف
      _isPlaying = false;
      _isPaused = false;
      _isLoading = false;
      _currentPosition = Duration.zero;
      notifyListeners();
    }
  }

  // الانتقال إلى موضع معين
  Future<void> seekTo(Duration position) async {
    try {
      await _audioPlayer.seek(position);
      _currentPosition = position;
      notifyListeners();
    } catch (e) {
      _recordingError = 'خطأ في الانتقال للموضع: $e';
      notifyListeners();
    }
  }

  // تغيير سرعة التشغيل
  Future<void> setPlaybackSpeed(double speed) async {
    try {
      _playbackSpeed = speed.clamp(0.25, 3.0); // حدود منطقية
      await _audioPlayer.setPlaybackRate(_playbackSpeed);
      notifyListeners();
    } catch (e) {
      _recordingError = 'خطأ في تغيير سرعة التشغيل: $e';
      notifyListeners();
    }
  }

  // تغيير مستوى الصوت
  Future<void> setVolume(double volume) async {
    try {
      _volume = volume.clamp(0.0, 1.0);
      await _audioPlayer.setVolume(_volume);
      notifyListeners();
    } catch (e) {
      _recordingError = 'خطأ في تغيير مستوى الصوت: $e';
      notifyListeners();
    }
  }

  // إعداد قائمة التشغيل
  void setPlaylist(List<Ayah> ayahs, {int startIndex = 0}) {
    _playlist = List.from(ayahs);
    _currentPlaylistIndex = startIndex.clamp(0, ayahs.length - 1);
    _isPlaylistMode = true;
    notifyListeners();
  }

  // تشغيل قائمة التشغيل
  Future<void> playPlaylist() async {
    if (_playlist.isNotEmpty && _currentPlaylistIndex < _playlist.length) {
      final ayah = _playlist[_currentPlaylistIndex];
      // هنا يمكن إضافة منطق للحصول على رابط الصوت للآية
      // await playAyah(getAudioUrl(ayah.surahNumber, ayah.number));
    }
  }

  // تشغيل الآية التالية في القائمة
  Future<void> _playNextInPlaylist() async {
    if (_isPlaylistMode && _playlist.isNotEmpty) {
      _currentPlaylistIndex++;
      
      if (_currentPlaylistIndex >= _playlist.length) {
        if (_isLoopMode) {
          _currentPlaylistIndex = 0;
        } else {
          _isPlaylistMode = false;
          _playlist.clear();
          _currentPlaylistIndex = 0;
          notifyListeners();
          return;
        }
      }
      
      await playPlaylist();
    }
  }

  // تشغيل الآية السابقة في القائمة
  Future<void> playPreviousInPlaylist() async {
    if (_isPlaylistMode && _playlist.isNotEmpty) {
      _currentPlaylistIndex--;
      
      if (_currentPlaylistIndex < 0) {
        _currentPlaylistIndex = _playlist.length - 1;
      }
      
      await playPlaylist();
    }
  }

  // تبديل وضع التكرار
  void toggleLoopMode() {
    _isLoopMode = !_isLoopMode;
    notifyListeners();
  }

  // تبديل وضع التشغيل التلقائي
  void toggleAutoPlayNext() {
    _autoPlayNext = !_autoPlayNext;
    notifyListeners();
  }

  // تبديل وضع الجودة العالية
  void toggleHighQualityMode() {
    _highQualityMode = !_highQualityMode;
    notifyListeners();
  }
  
  // تغيير إعدادات سرعة التلاوة
  void changePlaybackSpeed(double speed) {
    setPlaybackSpeed(speed);
  }

  // تشغيل سورة كاملة
  Future<void> playSurah(List<Ayah> ayahs) async {
    setPlaylist(ayahs);
    await playPlaylist();
  }

  // بدء التسجيل (محاكاة)
  Future<void> startRecording() async {
    if (!await requestPermissions()) {
      return;
    }

    try {
      _isListening = true;
      _isRecording = true;
      _recordingError = '';
      notifyListeners();
      
      // محاكاة التعرف على الصوت
      await Future.delayed(const Duration(seconds: 3));
      _recognizedText = 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ';
      notifyListeners();
    } catch (e) {
      _recordingError = 'خطأ في بدء التسجيل: $e';
      _isListening = false;
      _isRecording = false;
      notifyListeners();
    }
  }

  // إيقاف التسجيل
  Future<void> stopRecording() async {
    _isListening = false;
    _isRecording = false;
    notifyListeners();
  }

  // مسح النص المعترف عليه
  void clearRecognizedText() {
    _recognizedText = '';
    _lastAnalysisResult = null;
    notifyListeners();
  }

  // مسح الخطأ
  void clearError() {
    _recordingError = '';
    notifyListeners();
  }

  // تحليل التلاوة (محاكاة الذكاء الاصطناعي)
  Map<String, dynamic> analyzeRecitation(String userText, String originalText) {
    try {
      List<String> userWords = userText.split(' ');
      List<String> originalWords = originalText.split(' ');
      
      int correctWords = 0;
      List<String> mistakes = [];
      
      for (int i = 0; i < userWords.length && i < originalWords.length; i++) {
        if (userWords[i] == originalWords[i]) {
          correctWords++;
        } else {
          mistakes.add('الكلمة ${i + 1}: ${userWords[i]} بدلاً من ${originalWords[i]}');
        }
      }
      
      double accuracy = (correctWords / originalWords.length) * 100;
      
      _lastAnalysisResult = {
        'accuracy': accuracy,
        'correctWords': correctWords,
        'totalWords': originalWords.length,
        'mistakes': mistakes,
        'score': accuracy >= 80 ? 'ممتاز' : accuracy >= 60 ? 'جيد' : 'يحتاج تحسين',
      };
      
      notifyListeners();
      return _lastAnalysisResult!;
    } catch (e) {
      return {
        'accuracy': 0.0,
        'correctWords': 0,
        'totalWords': 0,
        'mistakes': ['خطأ في التحليل'],
        'score': 'خطأ',
      };
    }
  }

  // تنظيف الموارد
  Future<void> cleanup() async {
    try {
      await stopAudio();
      _isRecording = false;
      _isListening = false;
      _recognizedText = '';
      _recordingError = '';
      _lastAnalysisResult = null;
      _playlist.clear();
      _currentPlaylistIndex = 0;
      _isPlaylistMode = false;
      _isLoopMode = false;
      _isShuffleMode = false;
      notifyListeners();
    } catch (e) {
      // تجاهل الأخطاء عند التنظيف
    }
  }

  @override
  void dispose() {
    try {
      cleanup();
      _audioPlayer.dispose();
      _audioCompleteController.close();
    } catch (e) {
      // تجاهل الأخطاء عند التخلص من الموارد
    }
    super.dispose();
  }
} 