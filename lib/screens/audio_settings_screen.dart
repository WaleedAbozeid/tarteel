import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';

class AudioSettingsScreen extends StatefulWidget {
  const AudioSettingsScreen({super.key});

  @override
  State<AudioSettingsScreen> createState() => _AudioSettingsScreenState();
}

class _AudioSettingsScreenState extends State<AudioSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text(
          'إعدادات الصوت',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF16213E),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Consumer<AudioProvider>(
        builder: (context, audioProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // إعدادات التشغيل
                _buildSection(
                  'إعدادات التشغيل',
                  [
                    _buildSwitchTile(
                      'التشغيل التلقائي للآية التالية',
                      audioProvider.autoPlayNext,
                      (value) => audioProvider.toggleAutoPlayNext(),
                    ),
                    _buildSwitchTile(
                      'وضع التكرار',
                      audioProvider.isLoopMode,
                      (value) => audioProvider.toggleLoopMode(),
                    ),
                    _buildSwitchTile(
                      'تذكر الموضع',
                      audioProvider.rememberPosition,
                      (value) {
                        // سيتم إضافة هذه الوظيفة لاحقاً
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // إعدادات الجودة
                _buildSection(
                  'إعدادات الجودة',
                  [
                    _buildSwitchTile(
                      'وضع الجودة العالية',
                      audioProvider.highQualityMode,
                      (value) => audioProvider.toggleHighQualityMode(),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // إعدادات الصوت
                _buildSection(
                  'إعدادات الصوت',
                  [
                    _buildSliderTile(
                      'مستوى الصوت',
                      audioProvider.volume,
                      (value) => audioProvider.setVolume(value),
                      min: 0.0,
                      max: 1.0,
                      divisions: 10,
                    ),
                    _buildSliderTile(
                      'سرعة التشغيل',
                      audioProvider.playbackSpeed,
                      (value) => audioProvider.setPlaybackSpeed(value),
                      min: 0.25,
                      max: 3.0,
                      divisions: 11,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // معلومات التشغيل الحالي
                if (audioProvider.currentAudioUrl.isNotEmpty)
                  _buildSection(
                    'معلومات التشغيل الحالي',
                    [
                      _buildInfoTile('الرابط', audioProvider.currentAudioUrl),
                      _buildInfoTile('القارئ', audioProvider.currentReciterId),
                      _buildInfoTile('السورة', audioProvider.currentSurahNumber.toString()),
                      _buildInfoTile('الآية', audioProvider.currentAyahNumber.toString()),
                      _buildInfoTile('الموضع الحالي', _formatDuration(audioProvider.currentPosition)),
                      _buildInfoTile('المدة الإجمالية', _formatDuration(audioProvider.totalDuration)),
                    ],
                  ),

                const SizedBox(height: 24),

                // أزرار التحكم
                _buildSection(
                  'أزرار التحكم',
                  [
                    _buildButtonTile(
                      'إيقاف التشغيل',
                      Icons.stop,
                      Colors.red,
                      () => audioProvider.stopAudio(),
                    ),
                    _buildButtonTile(
                      audioProvider.isPlaying ? 'إيقاف مؤقت' : 'استئناف',
                      audioProvider.isPlaying ? Icons.pause : Icons.play_arrow,
                      const Color(0xFF4CAF50),
                      () {
                        if (audioProvider.isPlaying) {
                          audioProvider.pauseAudio();
                        } else {
                          audioProvider.resumeAudio();
                        }
                      },
                    ),
                    _buildButtonTile(
                      'مسح الأخطاء',
                      Icons.clear,
                      const Color(0xFFFF9800),
                      () => audioProvider.clearError(),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // رسائل الخطأ
                if (audioProvider.recordingError.isNotEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'رسالة الخطأ:',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          audioProvider.recordingError,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF0F3460),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF4CAF50),
      ),
    );
  }

  Widget _buildSliderTile(
    String title,
    double value,
    Function(double) onChanged, {
    required double min,
    required double max,
    required int divisions,
  }) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Column(
        children: [
          Slider(
            value: value,
            onChanged: onChanged,
            min: min,
            max: max,
            divisions: divisions,
            activeColor: const Color(0xFF4CAF50),
            inactiveColor: Colors.grey,
          ),
          Text(
            '${value.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, String value) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        value,
        style: const TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget _buildButtonTile(
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      trailing: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
} 