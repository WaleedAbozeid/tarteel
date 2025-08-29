import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AudioProvider with ChangeNotifier {
  bool _isAudioEnabled = true;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  bool get isAudioEnabled => _isAudioEnabled;
  bool get isPlaying => _isPlaying;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;

  void toggleAudio() {
    _isAudioEnabled = !_isAudioEnabled;
    notifyListeners();
  }

  void play() {
    _isPlaying = true;
    notifyListeners();
  }

  void pause() {
    _isPlaying = false;
    notifyListeners();
  }

  void stop() {
    _isPlaying = false;
    _currentPosition = Duration.zero;
    notifyListeners();
  }

  void updatePosition(Duration position, Duration duration) {
    _currentPosition = position;
    _totalDuration = duration;
    notifyListeners();
  }
}