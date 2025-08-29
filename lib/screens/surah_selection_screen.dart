import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quran_provider.dart';
import '../models/quran_models.dart';

class SurahSelectionScreen extends StatelessWidget {
  const SurahSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
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
            return Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                  decoration: const BoxDecoration(
                    color: Color(0xFF16213E),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(18),
                      bottomRight: Radius.circular(18),
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'اختر السورة',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: quranProvider.surahs.length,
                    separatorBuilder: (context, index) => const Divider(color: Colors.grey, height: 1, thickness: 0.5),
                    itemBuilder: (context, index) {
                      final surah = quranProvider.surahs[index];
                      return Container(
                        color: index % 2 == 0 ? const Color(0xFF1A1A2E) : const Color(0xFF16213E),
                        child: ListTile(
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          title: Text(surah.nameAr, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            'عدد الآيات: ${surah.numberOfAyahs}  •  ${surah.revelationType == "Meccan" ? "مكية" : "مدنية"}',
                            style: const TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/surah',
                              arguments: {'surah': surah},
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
