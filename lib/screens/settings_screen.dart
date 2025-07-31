import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart'; // Assuming you have an AudioProvider to manage reciters
import '../providers/theme_provider.dart';
import 'reciter_selection_screen.dart'; // Import the new screen

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final audioProvider = Provider.of<AudioProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // قسم المظهر
          _buildSectionTitle('المظهر'),
          Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('الوضع الليلي'),
                  subtitle: const Text('تفعيل المظهر الداكن للقراءة الليلية'),
                  value: themeProvider.isDarkMode,
                  onChanged: (_) {
                    themeProvider.toggleTheme();
                  },
                  secondary: Icon(
                    themeProvider.isDarkMode
                        ? Icons.dark_mode
                        : Icons.light_mode,
                  ),
                ),
              ],
            ),
          ),

          // قسم الصوت
          _buildSectionTitle('إعدادات الصوت'),
          Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              children: [
                ListTile(
                  title: const Text('مستوى الصوت'),
                  subtitle: Slider(
                    value: audioProvider.volume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: '${(audioProvider.volume * 100).round()}%',
                    onChanged: (value) {
                      audioProvider.setVolume(value);
                    },
                  ),
                  leading: const Icon(Icons.volume_up),
                ),
                ListTile(
                  title: const Text('سرعة التلاوة'),
                  subtitle: Slider(
                    value: audioProvider.playbackSpeed,
                    min: 0.5,
                    max: 1.5,
                    divisions: 10,
                    label: '${audioProvider.playbackSpeed}x',
                    onChanged: (value) {
                      audioProvider.setPlaybackSpeed(value);
                    },
                  ),
                  leading: const Icon(Icons.speed),
                ),
                SwitchListTile(
                  title: const Text('تشغيل تلقائي للآية التالية'),
                  subtitle: const Text('الانتقال تلقائيًا للآية التالية بعد الانتهاء'),
                  value: audioProvider.autoPlayNext,
                  onChanged: (value) {
                    audioProvider.setAutoPlayNext(value);
                  },
                  secondary: const Icon(Icons.skip_next),
                ),
              ],
            ),
          ),

          // قسم اختيار القارئ
          _buildSectionTitle('اختر القارئ'),
          ListTile(
            title: const Text('اختر القارئ'),
            subtitle: Text(
              'القارئ الحالي: ${context.watch<AudioProvider>().selectedReciter?.name ?? 'لم يتم اختيار قارئ'}',
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ReciterSelectionScreen(),
                ),
              );
            },
          ),

          // قسم عن التطبيق
          _buildSectionTitle('عن التطبيق'),
          Card(
            child: Column(
              children: [
                ListTile(
                  title: const Text('ترتيل - تطبيق القرآن الذكي'),
                  subtitle: const Text('الإصدار 1.0.0'),
                  leading: const Icon(Icons.info),
                ),
                const Divider(),
                ListTile(
                  title: const Text('تواصل معنا'),
                  subtitle: const Text('support@tarteel-app.com'),
                  leading: const Icon(Icons.email),
                  onTap: () {
                    // إضافة وظيفة فتح تطبيق البريد الإلكتروني
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 16.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}