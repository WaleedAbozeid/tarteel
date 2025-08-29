import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/quran_provider.dart';
import 'providers/audio_provider.dart' as Provider;
import 'providers/theme_provider.dart';
import 'providers/progress_provider.dart';
import 'screens/home_screen.dart';
import 'screens/recitation_screen.dart';
import 'screens/surah_screen.dart';
import 'screens/quran_list_screen.dart';
import 'screens/reciter_selection_screen.dart';
import 'screens/audio_settings_screen.dart';
import 'screens/tajweed_screen.dart';
import 'screens/tafsir_screen.dart';
import 'screens/memorization_screen.dart';
import 'screens/settings_screen.dart';
import 'constants/app_colors.dart';
import 'constants/app_strings.dart';
import 'constants/app_sizes.dart';
import 'models/quran_models.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (kDebugMode) {
    debugPrint('=== بدء تشغيل تطبيق ترتيل ===');
  }
  
  // تحسين بدء التطبيق
  runApp(const TarteelApp());
}

class TarteelApp extends StatelessWidget {
  const TarteelApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QuranProvider()),
        ChangeNotifierProvider(create: (_) => Provider.AudioProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => MaterialApp(
          title: AppStrings.appTitle,
          debugShowCheckedModeBanner: false,
          theme: themeProvider.currentTheme,
          home: const MainScreen(),
          routes: _buildAppRoutes(),
          onGenerateRoute: _handleUnknownRoutes,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.noScaling,
              ),
              child: child!,
            );
          },
        ),
      ),
    );
  }

  Map<String, WidgetBuilder> _buildAppRoutes() {
    return {
      '/home': (context) => const MainScreen(),
      '/quran-list': (context) => const QuranListScreen(),
      '/reciter-selection': (context) => const ReciterSelectionScreen(),
      '/audio-settings': (context) => const AudioSettingsScreen(),
      '/tajweed': (context) => const TajweedScreen(),
      '/tafsir': (context) => const TafsirScreen(),
      '/memorization': (context) => const MemorizationScreen(),
      '/settings': (context) => const SettingsScreen(),
      '/surah': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return SurahScreen(surah: args['surah'] as Surah);
      },
      '/recitation': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
        return RecitationScreen(
          surah: args['surah'] as Surah,
          ayah: args['ayah'] as Ayah?,
        );
      },
    };
  }

  Route<dynamic>? _handleUnknownRoutes(RouteSettings settings) {
    if (kDebugMode) {
      debugPrint('Unknown route: ${settings.name}');
    }
    // إرجاع الشاشة الرئيسية للمسارات غير المعروفة
    return MaterialPageRoute(
      builder: (context) => const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Widget> _screens = [
    const HomeScreen(),
    const TajweedScreen(),
    const TafsirScreen(),
    const MemorizationScreen(),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: AppSizes.animationNormal,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
      _restartAnimation();
    }
  }

  void _restartAnimation() {
    _animationController.reset();
    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        try {
          if (_currentIndex == 0) {
            return;
          } else {
            setState(() {
              _currentIndex = 0;
            });
          }
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Back navigation error: $e');
          }
        }
      },
      child: Scaffold(
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: _screens[_currentIndex],
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.overlay,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.cardBackground,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        elevation: AppSizes.bottomNavElevation,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: AppStrings.home,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: AppStrings.tajweed,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb),
            label: AppStrings.tafsir,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: AppStrings.memorization,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: AppStrings.settings,
          ),
        ],
      ),
    );
  }
}