import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/quran_provider.dart';
import 'providers/audio_provider.dart';
import 'screens/home_screen.dart';
import 'screens/recitation_screen.dart';
import 'screens/surah_screen.dart';
import 'screens/reciter_selection_screen.dart';
import 'screens/audio_settings_screen.dart';
import 'models/quran_models.dart';

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
      ],
      child: MaterialApp(
        title: 'ترتيل - تطبيق القرآن الذكي',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          primaryColor: const Color(0xFF4CAF50),
          scaffoldBackgroundColor: const Color(0xFF1A1A2E),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF16213E),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            color: const Color(0xFF0F3460),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white),
            titleLarge: TextStyle(color: Colors.white),
            titleMedium: TextStyle(color: Colors.white),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
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
          '/reciter-selection': (context) => const ReciterSelectionScreen(),
          '/audio-settings': (context) => const AudioSettingsScreen(),
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
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const Placeholder(), // شاشة التجويد
    const Placeholder(), // شاشة التفسير
    const Placeholder(), // شاشة الحفظ
    const Placeholder(), // شاشة الإعدادات
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
          backgroundColor: const Color(0xFF16213E),
          selectedItemColor: const Color(0xFF4CAF50),
          unselectedItemColor: Colors.grey,
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
