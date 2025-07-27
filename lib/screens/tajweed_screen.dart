import 'package:flutter/material.dart';
import '../models/quran_models.dart';

class TajweedScreen extends StatefulWidget {
  const TajweedScreen({super.key});

  @override
  State<TajweedScreen> createState() => _TajweedScreenState();
}

class _TajweedScreenState extends State<TajweedScreen> {
  int _selectedRuleIndex = 0;
  bool _showPractice = false;

  final List<TajweedRule> _tajweedRules = [
    TajweedRule(
      name: 'الغنة',
      arabicName: 'الغنة',
      description: 'صوت يخرج من الخيشوم عند النطق بحرفي النون والميم',
      examples: ['مِنْ', 'نَعَمْ', 'إِنَّ', 'أَمَّا'],
      practiceText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
      practiceInstructions: 'ركز على النطق الصحيح لحرفي النون والميم مع الغنة',
    ),
    TajweedRule(
      name: 'المد',
      arabicName: 'المد',
      description: 'إطالة الصوت عند النطق بالحروف المدية (أ، و، ي)',
      examples: ['اللَّهُ', 'الرَّحْمَٰنِ', 'الرَّحِيمِ'],
      practiceText: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
      practiceInstructions: 'أطِل الصوت عند النطق بالحروف المدية',
    ),
    TajweedRule(
      name: 'الإدغام',
      arabicName: 'الإدغام',
      description: 'دمج حرف ساكن مع حرف متحرك يليه',
      examples: ['مِنْ نَفْسٍ', 'عَلَىٰ نَفْسِهِ', 'مِنْ مَاءٍ'],
      practiceText: 'مِنْ نَفْسٍ وَمِنْ مَاءٍ مَّهِينٍ',
      practiceInstructions: 'دمج الحروف الساكنة مع الحروف المتحركة',
    ),
    TajweedRule(
      name: 'القَلْقَلَة',
      arabicName: 'القَلْقَلَة',
      description: 'اهتزاز الصوت عند النطق بحروف القلقلة (ق، ط، ب، ج، د)',
      examples: ['قُلْ', 'طَهَ', 'بِسْمِ', 'جَعَلَ', 'دَعَا'],
      practiceText: 'قُلْ هُوَ اللَّهُ أَحَدٌ',
      practiceInstructions: 'اهتز الصوت عند النطق بحروف القلقلة',
    ),
    TajweedRule(
      name: 'الإخفاء',
      arabicName: 'الإخفاء',
      description: 'إخفاء حرف النون عند النطق به في بعض الحالات',
      examples: ['مِنْ فَضْلِهِ', 'مِنْ كُلِّ', 'مِنْ شَيْءٍ'],
      practiceText: 'مِنْ فَضْلِهِ وَمِنْ كُلِّ شَيْءٍ',
      practiceInstructions: 'أخفِ حرف النون عند النطق به',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text(
          'قواعد التجويد',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF16213E),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // قائمة قواعد التجويد
          Container(
            height: 120,
            padding: const EdgeInsets.all(16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _tajweedRules.length,
              itemBuilder: (context, index) {
                final rule = _tajweedRules[index];
                final isSelected = index == _selectedRuleIndex;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedRuleIndex = index;
                      _showPractice = false;
                    });
                  },
                  child: Container(
                    width: 150,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? const Color(0xFF4CAF50).withOpacity(0.2)
                          : const Color(0xFF0F3460),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected 
                            ? const Color(0xFF4CAF50)
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          rule.arabicName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          rule.name,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // تفاصيل القاعدة المختارة
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // عنوان القاعدة
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF16213E), Color(0xFF0F3460)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          _tajweedRules[_selectedRuleIndex].arabicName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _tajweedRules[_selectedRuleIndex].name,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // وصف القاعدة
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F3460),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'الوصف:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _tajweedRules[_selectedRuleIndex].description,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            height: 1.5,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // أمثلة
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F3460),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'أمثلة:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textDirection: TextDirection.rtl,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _tajweedRules[_selectedRuleIndex].examples.map((example) {
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4CAF50).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF4CAF50),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                example,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Amiri',
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // زر التمرين
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showPractice = !_showPractice;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4CAF50),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _showPractice ? 'إخفاء التمرين' : 'بدء التمرين',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                    ),
                  ),

                  // قسم التمرين
                  if (_showPractice) ...[
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F3460),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF4CAF50),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'تمرين عملي:',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                          const SizedBox(height: 16),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF16213E),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _tajweedRules[_selectedRuleIndex].practiceText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                height: 2.0,
                                fontFamily: 'Amiri',
                              ),
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.rtl,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _tajweedRules[_selectedRuleIndex].practiceInstructions,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              height: 1.5,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  // تشغيل الصوت
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'سيتم إضافة تشغيل الصوت قريباً',
                                        textDirection: TextDirection.rtl,
                                      ),
                                      backgroundColor: Color(0xFF4CAF50),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.play_arrow, color: Colors.white),
                                label: const Text(
                                  'تشغيل',
                                  style: TextStyle(color: Colors.white),
                                  textDirection: TextDirection.rtl,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2196F3),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () {
                                  // تسجيل التلاوة
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'سيتم إضافة تسجيل التلاوة قريباً',
                                        textDirection: TextDirection.rtl,
                                      ),
                                      backgroundColor: Color(0xFFFF9800),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.mic, color: Colors.white),
                                label: const Text(
                                  'تسجيل',
                                  style: TextStyle(color: Colors.white),
                                  textDirection: TextDirection.rtl,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF9800),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TajweedRule {
  final String name;
  final String arabicName;
  final String description;
  final List<String> examples;
  final String practiceText;
  final String practiceInstructions;

  TajweedRule({
    required this.name,
    required this.arabicName,
    required this.description,
    required this.examples,
    required this.practiceText,
    required this.practiceInstructions,
  });
} 