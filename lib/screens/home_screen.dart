import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quran_provider.dart';
import '../widgets/surah_card.dart';
import '../widgets/feature_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuranProvider>().loadSurahsOptimized();
      context.read<QuranProvider>().loadTajweedRules();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Consumer<QuranProvider>(
          builder: (context, quranProvider, child) {
            return CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  expandedHeight: 120,
                  floating: false,
                  pinned: true,
                  backgroundColor: const Color(0xFF16213E),
                  flexibleSpace: FlexibleSpaceBar(
                    title: const Text(
                      'ترتيل',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF16213E),
                            Color(0xFF0F3460),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // الميزات الرئيسية
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'الميزات الرئيسية',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 16),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1.2,
                          children: [
                            FeatureCard(
                              title: 'التلاوة الذكية',
                              subtitle: 'تحسين التلاوة بالذكاء الاصطناعي',
                              icon: Icons.mic,
                              color: const Color(0xFF4CAF50),
                              onTap: () {
                                // التنقل إلى شاشة السورة
                                if (quranProvider.surahs.isNotEmpty) {
                                  Navigator.pushNamed(
                                    context,
                                    '/surah',
                                    arguments: {
                                      'surah': quranProvider.surahs.first,
                                    },
                                  );
                                }
                              },
                            ),
                            FeatureCard(
                              title: 'التجويد',
                              subtitle: 'تعلم قواعد التجويد',
                              icon: Icons.book,
                              color: const Color(0xFF2196F3),
                              onTap: () {
                                // التنقل إلى شاشة التجويد
                              },
                            ),
                            FeatureCard(
                              title: 'التفسير',
                              subtitle: 'تفسير ميسر للآيات',
                              icon: Icons.lightbulb,
                              color: const Color(0xFFFF9800),
                              onTap: () {
                                // التنقل إلى شاشة التفسير
                              },
                            ),
                            FeatureCard(
                              title: 'الحفظ',
                              subtitle: 'برنامج الحفظ التفاعلي',
                              icon: Icons.school,
                              color: const Color(0xFF9C27B0),
                              onTap: () {
                                // التنقل إلى شاشة الحفظ
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // آخر السور المقروءة
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'آخر السور المقروءة',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 120,
                          child: quranProvider.isLoading
                              ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                )
                              : quranProvider.surahs.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'لا توجد سور متاحة',
                                        style: TextStyle(color: Colors.grey),
                                        textDirection: TextDirection.rtl,
                                      ),
                                    )
                                  : ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount: quranProvider.surahs.take(5).length,
                                      itemBuilder: (context, index) {
                                        final surah = quranProvider.surahs[index];
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 12),
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.pushNamed(
                                                context,
                                                '/surah',
                                                arguments: {
                                                  'surah': surah,
                                                },
                                              );
                                            },
                                            child: SurahCard(surah: surah),
                                          ),
                                        );
                                      },
                                    ),
                        ),
                      ],
                    ),
                  ),
                ),

                // قائمة السور
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'القرآن الكريم',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 16),
                        if (quranProvider.isLoading)
                          const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        else if (quranProvider.surahs.isEmpty)
                          const Center(
                            child: Text(
                              'لا توجد سور متاحة',
                              style: TextStyle(color: Colors.grey),
                              textDirection: TextDirection.rtl,
                            ),
                          )
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: quranProvider.surahs.length,
                            itemBuilder: (context, index) {
                              final surah = quranProvider.surahs[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 8),
                                color: const Color(0xFF0F3460),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: const Color(0xFF4CAF50),
                                    child: Text(
                                      '${surah.number}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    surah.nameAr,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textDirection: TextDirection.rtl,
                                  ),
                                  subtitle: Text(
                                    '${surah.numberOfAyahs} آية',
                                    style: const TextStyle(
                                      color: Colors.grey,
                                    ),
                                    textDirection: TextDirection.rtl,
                                  ),
                                  trailing: const Icon(
                                    Icons.arrow_forward_ios,
                                    color: Colors.white,
                                  ),
                                  onTap: () {
                                    // التنقل إلى شاشة السورة
                                    Navigator.pushNamed(
                                      context,
                                      '/surah',
                                      arguments: {
                                        'surah': surah,
                                      },
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
} 