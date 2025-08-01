import 'package:flutter/material.dart';
import '../models/quran_models.dart';

class SurahSelectionScreen extends StatelessWidget {
  final List<Surah> surahs;
  const SurahSelectionScreen({Key? key, required this.surahs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: Column(
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
              itemCount: surahs.length,
              separatorBuilder: (context, index) => const Divider(color: Colors.grey, height: 1, thickness: 0.5),
              itemBuilder: (context, index) {
                final surah = surahs[index];
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
                      Navigator.pop(context, surah);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
