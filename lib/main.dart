import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/quran_provider.dart';
import 'providers/audio_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/progress_provider.dart';
import 'screens/home_screen.dart';
import 'screens/recitation_screen.dart';
import 'screens/surah_screen.dart';
import 'screens/reciter_selection_screen.dart';
import 'screens/audio_settings_screen.dart';
import 'screens/settings_screen.dart';
import 'models/quran_models.dart';
import 'screens/tajweed_screen.dart';
import 'screens/tafsir_screen.dart';
import 'screens/memorization_screen.dart';
import 'screens/tafsir_screen.dart';

void main() {
  runApp(const TarteelApp());
}

class TarteelApp extends StatelessWidget {
  const TarteelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuranProvider()),
        ChangeNotifierProvider(create: (_) => AudioProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => MaterialApp(
        title: 'ترتيل - تطبيق القرآن الذكي',
        debugShowCheckedModeBanner: false,
        theme: themeProvider.currentTheme,
        home: const MainScreen(),
        routes: {
          '/home': (context) => const MainScreen(),
          '/recitation': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return RecitationScreen(
              surah: args['surah'] as Surah,
              ayah: args['ayah'] as Ayah?,
            );
          },
          '/surah': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return SurahScreen(
              surah: args['surah'] as Surah,
            );
          },
          '/tafsir': (context) {
            final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return TafsirScreen(surah: args['surah'] as Surah);
          },
          '/reciter-selection': (context) => const ReciterSelectionScreen(),
          '/audio-settings': (context) => const AudioSettingsScreen(),
          '/settings': (context) => const SettingsScreen(),
        },
        onGenerateRoute: (settings) {
          // معالجة الأخطاء في التنقل
          if (settings.name == '/recitation' || settings.name == '/surah') {
            return MaterialPageRoute(
              builder: (context) => const MainScreen(),
            );
          }
          return null;
        },
      ),
    ));
  }
  }
// This closing brace should be removed as it's an extra closing brace

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const TajweedScreen(), // شاشة التجويد
    const TafsirScreen(), // شاشة التفسير
    const MemorizationScreen(), // شاشة الحفظ
    const SettingsScreen(), // شاشة الإعدادات
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        try {
          // إذا كان المستخدم في الشاشة الرئيسية، اخرج من التطبيق
          // وإلا ارجع للشاشة الرئيسية
          if (_currentIndex == 0) {
            return true; // السماح بالخروج من التطبيق
          } else {
            setState(() {
              _currentIndex = 0;
            });
            return false; // منع الخروج من التطبيق
          }
        } catch (e) {
          // في حالة حدوث خطأ، اخرج من التطبيق
          return true;
        }
      },
      child: Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Theme.of(context).unselectedWidgetColor,
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.book),
              label: 'التجويد',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.lightbulb),
              label: 'التفسير',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.school),
              label: 'الحفظ',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'الإعدادات',
            ),
          ],
        ),
      ),
    );
  }
}
