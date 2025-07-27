import 'package:flutter/material.dart';
import '../models/quran_models.dart';

class TafsirScreen extends StatefulWidget {
  final Surah? surah;
  final Ayah? ayah;

  const TafsirScreen({
    super.key,
    this.surah,
    this.ayah,
  });

  @override
  State<TafsirScreen> createState() => _TafsirScreenState();
}

class _TafsirScreenState extends State<TafsirScreen> {
  int _selectedTafsirIndex = 0;
  bool _showAdvancedTafsir = false;

  final List<TafsirSource> _tafsirSources = [
    TafsirSource(
      name: 'التفسير الميسر',
      arabicName: 'التفسير الميسر',
      description: 'تفسير بسيط وواضح مناسب للجميع',
      color: const Color(0xFF4CAF50),
    ),
    TafsirSource(
      name: 'تفسير ابن كثير',
      arabicName: 'تفسير ابن كثير',
      description: 'تفسير شامل ومفصل من أشهر كتب التفسير',
      color: const Color(0xFF2196F3),
    ),
    TafsirSource(
      name: 'تفسير الطبري',
      arabicName: 'تفسير الطبري',
      description: 'أقدم وأشمل كتب التفسير',
      color: const Color(0xFFFF9800),
    ),
    TafsirSource(
      name: 'تفسير القرطبي',
      arabicName: 'تفسير القرطبي',
      description: 'تفسير شامل مع الأحكام الفقهية',
      color: const Color(0xFF9C27B0),
    ),
  ];

  final Map<String, List<TafsirText>> _tafsirData = {
    'الفاتحة': [
      TafsirText(
        ayahNumber: 1,
        ayahText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        tafsirMuyassar: 'أبدأ قراءتي متبركاً باسم الله تعالى، الذي له الرحمة الواسعة الشاملة لجميع خلقه، والرحمة الخاصة بالمؤمنين.',
        tafsirIbnKathir: 'هذه الآية تسمى البسملة، وهي آية من القرآن الكريم، وتبدأ بها كل سورة ما عدا سورة التوبة.',
        tafsirTabari: 'معنى البسملة: أبدأ باسم الله، والله هو المعبود بحق، والرحمن الرحيم من أسماء الله الحسنى.',
        tafsirQurtubi: 'البسملة آية من القرآن الكريم، وتستحب في بداية كل عمل، وهي من أسباب البركة.',
      ),
      TafsirText(
        ayahNumber: 2,
        ayahText: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
        tafsirMuyassar: 'الثناء الكامل لله تعالى وحده، الذي خلق جميع المخلوقات ورباها بنعمه.',
        tafsirIbnKathir: 'الحمد لله: الثناء على الله بصفاته الحسنى وأفعاله الجميلة، ورب العالمين: خالق جميع المخلوقات ومدبر أمورها.',
        tafsirTabari: 'الحمد: الثناء بالكلام الجميل، والعالمين: جميع المخلوقات من الإنس والجن والملائكة وغيرهم.',
        tafsirQurtubi: 'الحمد لله: إثبات المحامد كلها لله تعالى، ورب العالمين: المالك المدبر لجميع المخلوقات.',
      ),
      TafsirText(
        ayahNumber: 3,
        ayahText: 'الرَّحْمَٰنِ الرَّحِيمِ',
        tafsirMuyassar: 'الذي له الرحمة الواسعة الشاملة لجميع خلقه، والرحمة الخاصة بالمؤمنين.',
        tafsirIbnKathir: 'الرحمن: ذو الرحمة الواسعة لجميع الخلق، والرحيم: ذو الرحمة الخاصة بالمؤمنين.',
        tafsirTabari: 'الرحمن: صيغة مبالغة من الرحمة، والرحيم: صيغة مبالغة أيضاً، وكلاهما يدل على كثرة الرحمة.',
        tafsirQurtubi: 'الرحمن: اسم خاص بالله تعالى، والرحيم: صفة مشتركة بين الله وخلقه، لكن رحمة الله أعظم.',
      ),
      TafsirText(
        ayahNumber: 4,
        ayahText: 'مَالِكِ يَوْمِ الدِّينِ',
        tafsirMuyassar: 'المالك المتصرف في يوم القيامة، الذي يحاسب الناس على أعمالهم.',
        tafsirIbnKathir: 'مالك يوم الدين: المالك المتصرف في يوم القيامة، والدين: الجزاء والحساب.',
        tafsirTabari: 'مالك: المالك المتصرف، ويوم الدين: يوم القيامة الذي يحاسب فيه الناس.',
        tafsirQurtubi: 'مالك يوم الدين: المالك المتصرف في يوم الجزاء والحساب، والدين: الجزاء والثواب.',
      ),
      TafsirText(
        ayahNumber: 5,
        ayahText: 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
        tafsirMuyassar: 'إياك وحدك نعبد، وإياك وحدك نستعين على جميع أمورنا.',
        tafsirIbnKathir: 'إياك نعبد: نخصك بالعبادة وحدك، وإياك نستعين: نطلب العون منك وحده.',
        tafsirTabari: 'إياك: ضمير منفصل للخطاب، نعبد: نطيع ونخضع، نستعين: نطلب العون.',
        tafsirQurtubi: 'إياك نعبد: نخصك بالعبادة دون سواك، وإياك نستعين: نطلب العون منك وحده.',
      ),
      TafsirText(
        ayahNumber: 6,
        ayahText: 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
        tafsirMuyassar: 'أرشدنا إلى الطريق المستقيم، وهو الإسلام والهداية.',
        tafsirIbnKathir: 'اهدنا: أرشدنا ووفقنا، الصراط المستقيم: الطريق الواضح الذي لا اعوجاج فيه، وهو الإسلام.',
        tafsirTabari: 'اهدنا: أرشدنا ووفقنا، الصراط: الطريق، المستقيم: الذي لا ميل فيه.',
        tafsirQurtubi: 'اهدنا: أرشدنا ووفقنا، الصراط المستقيم: الطريق الواضح الذي يوصل إلى الجنة.',
      ),
      TafsirText(
        ayahNumber: 7,
        ayahText: 'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
        tafsirMuyassar: 'طريق الذين أنعمت عليهم من الأنبياء والصالحين، غير طريق المغضوب عليهم من اليهود، وغير طريق الضالين من النصارى.',
        tafsirIbnKathir: 'صراط الذين أنعمت عليهم: طريق الأنبياء والصديقين والشهداء والصالحين، غير المغضوب عليهم: اليهود، ولا الضالين: النصارى.',
        tafsirTabari: 'الذين أنعمت عليهم: الأنبياء والصالحون، المغضوب عليهم: اليهود، الضالين: النصارى.',
        tafsirQurtubi: 'الذين أنعمت عليهم: الأنبياء والصديقون والشهداء والصالحون، المغضوب عليهم: اليهود، الضالين: النصارى.',
      ),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final surahName = widget.surah?.nameAr ?? 'الفاتحة';
    final tafsirList = _tafsirData[surahName] ?? _tafsirData['الفاتحة']!;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text(
          'تفسير ${surahName}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF16213E),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showAdvancedTafsir ? Icons.lightbulb : Icons.lightbulb_outline,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _showAdvancedTafsir = !_showAdvancedTafsir;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // قائمة مصادر التفسير
          Container(
            height: 100,
            padding: const EdgeInsets.all(16),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _tafsirSources.length,
              itemBuilder: (context, index) {
                final source = _tafsirSources[index];
                final isSelected = index == _selectedTafsirIndex;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTafsirIndex = index;
                    });
                  },
                  child: Container(
                    width: 140,
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected 
                          ? source.color.withOpacity(0.2)
                          : const Color(0xFF0F3460),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected 
                            ? source.color
                            : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          source.arabicName,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          source.name,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // محتوى التفسير
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tafsirList.length,
              itemBuilder: (context, index) {
                final tafsir = tafsirList[index];
                final source = _tafsirSources[_selectedTafsirIndex];
                
                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F3460),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: source.color.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      // رقم الآية والنص
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF16213E),
                              source.color.withOpacity(0.1),
                            ],
                          ),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(16),
                            topRight: Radius.circular(16),
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: source.color,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${tafsir.ayahNumber}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  source.arabicName,
                                  style: TextStyle(
                                    color: source.color,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textDirection: TextDirection.rtl,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              tafsir.ayahText,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                height: 2.0,
                                fontFamily: 'Amiri',
                              ),
                              textAlign: TextAlign.center,
                              textDirection: TextDirection.rtl,
                            ),
                          ],
                        ),
                      ),

                      // التفسير
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getTafsirText(tafsir, _selectedTafsirIndex),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                height: 1.6,
                              ),
                              textDirection: TextDirection.rtl,
                            ),
                            
                            if (_showAdvancedTafsir) ...[
                              const SizedBox(height: 20),
                              const Divider(color: Colors.grey),
                              const SizedBox(height: 16),
                              const Text(
                                'التفاصيل الإضافية:',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                              const SizedBox(height: 12),
                              _buildAdvancedTafsirDetails(tafsir),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _getTafsirText(TafsirText tafsir, int sourceIndex) {
    switch (sourceIndex) {
      case 0:
        return tafsir.tafsirMuyassar;
      case 1:
        return tafsir.tafsirIbnKathir;
      case 2:
        return tafsir.tafsirTabari;
      case 3:
        return tafsir.tafsirQurtubi;
      default:
        return tafsir.tafsirMuyassar;
    }
  }

  Widget _buildAdvancedTafsirDetails(TafsirText tafsir) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTafsirDetail('التفسير الميسر', tafsir.tafsirMuyassar, const Color(0xFF4CAF50)),
        const SizedBox(height: 12),
        _buildTafsirDetail('تفسير ابن كثير', tafsir.tafsirIbnKathir, const Color(0xFF2196F3)),
        const SizedBox(height: 12),
        _buildTafsirDetail('تفسير الطبري', tafsir.tafsirTabari, const Color(0xFFFF9800)),
        const SizedBox(height: 12),
        _buildTafsirDetail('تفسير القرطبي', tafsir.tafsirQurtubi, const Color(0xFF9C27B0)),
      ],
    );
  }

  Widget _buildTafsirDetail(String title, String content, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.4,
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }
}

class TafsirSource {
  final String name;
  final String arabicName;
  final String description;
  final Color color;

  TafsirSource({
    required this.name,
    required this.arabicName,
    required this.description,
    required this.color,
  });
}

class TafsirText {
  final int ayahNumber;
  final String ayahText;
  final String tafsirMuyassar;
  final String tafsirIbnKathir;
  final String tafsirTabari;
  final String tafsirQurtubi;

  TafsirText({
    required this.ayahNumber,
    required this.ayahText,
    required this.tafsirMuyassar,
    required this.tafsirIbnKathir,
    required this.tafsirTabari,
    required this.tafsirQurtubi,
  });
} 