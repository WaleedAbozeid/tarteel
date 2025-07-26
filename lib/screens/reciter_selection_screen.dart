import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quran_provider.dart';
import '../models/quran_models.dart';

class ReciterSelectionScreen extends StatefulWidget {
  const ReciterSelectionScreen({super.key});

  @override
  State<ReciterSelectionScreen> createState() => _ReciterSelectionScreenState();
}

class _ReciterSelectionScreenState extends State<ReciterSelectionScreen> {
  @override
  void initState() {
    super.initState();
    // تحميل قائمة القراء عند فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuranProvider>().loadReciters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text(
          'اختيار القارئ',
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
      body: Consumer<QuranProvider>(
        builder: (context, quranProvider, child) {
          if (quranProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }

          if (quranProvider.reciters.isEmpty) {
            return const Center(
              child: Text(
                'لا توجد قراء متاحة',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          return Column(
            children: [
              // معلومات القارئ المحدد حالياً
              if (quranProvider.selectedReciter != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F3460),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF4CAF50),
                      width: 2,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'القارئ المحدد حالياً:',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        quranProvider.selectedReciter!.nameAr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                      ),
                      Text(
                        quranProvider.selectedReciter!.name,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

              // قائمة القراء
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: quranProvider.reciters.length,
                  itemBuilder: (context, index) {
                    final reciter = quranProvider.reciters[index];
                    final isSelected = quranProvider.selectedReciter?.id == reciter.id;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: isSelected 
                          ? const Color(0xFF4CAF50).withOpacity(0.2)
                          : const Color(0xFF0F3460),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isSelected 
                              ? const Color(0xFF4CAF50)
                              : Colors.grey,
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                          ),
                        ),
                        title: Text(
                          reciter.nameAr,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        subtitle: Text(
                          reciter.name,
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(
                                Icons.check_circle,
                                color: Color(0xFF4CAF50),
                              )
                            : null,
                        onTap: () {
                          quranProvider.selectReciter(reciter);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'تم اختيار القارئ: ${reciter.nameAr}',
                                textDirection: TextDirection.rtl,
                              ),
                              backgroundColor: const Color(0xFF4CAF50),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

              // أزرار إضافية
              Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // زر اختيار أفضل قارئ
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          quranProvider.selectBestReciter();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'تم اختيار أفضل قارئ: مشاري راشد العفاسي',
                                textDirection: TextDirection.rtl,
                              ),
                              backgroundColor: Color(0xFF4CAF50),
                            ),
                          );
                        },
                        icon: const Icon(Icons.star, color: Colors.white),
                        label: const Text(
                          'اختيار أفضل قارئ',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF9800),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // زر العودة
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'تم',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
} 