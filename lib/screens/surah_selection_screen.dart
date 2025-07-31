import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quran_provider.dart';

class SurahSelectionScreen extends StatelessWidget {
  const SurahSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختر السورة'),
      ),
      body: Consumer<QuranProvider>(
        builder: (context, quranProvider, child) {
          if (quranProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (quranProvider.surahs.isEmpty) {
            return const Center(
              child: Text('لا توجد سور متاحة'),
            );
          } else {
            return ListView.builder(
              itemCount: quranProvider.surahs.length,
              itemBuilder: (context, index) {
                final surah = quranProvider.surahs[index];
                return ListTile(
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
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text('${surah.numberOfAyahs} آية'),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/surah',
                      arguments: {'surah': surah},
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
