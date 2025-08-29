import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/quran_models.dart';
import '../providers/progress_provider.dart';
import '../providers/quran_provider.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String _selectedPeriod = 'هذا الأسبوع';
  final List<String> _periods = ['اليوم', 'هذا الأسبوع', 'هذا الشهر', 'هذا العام'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text(
          'الإحصائيات والتقدم',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF16213E),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {
              _shareStatistics();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // اختيار الفترة الزمنية
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'الفترة:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F3460),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedPeriod,
                        dropdownColor: const Color(0xFF0F3460),
                        style: const TextStyle(color: Colors.white),
                        items: _periods.map((period) {
                          return DropdownMenuItem<String>(
                            value: period,
                            child: Text(
                              period,
                              style: const TextStyle(color: Colors.white),
                              textDirection: TextDirection.rtl,
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPeriod = value!;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // الإحصائيات الرئيسية
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // البطاقات الإحصائية
                  _buildStatisticsCards(),
                  
                  const SizedBox(height: 24),
                  
                  // الرسم البياني للتقدم
                  _buildProgressChart(),
                  
                  const SizedBox(height: 24),
                  
                  // تفاصيل النشاط
                  _buildActivityDetails(),
                  
                  const SizedBox(height: 24),
                  
                  // الإنجازات
                  _buildAchievements(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    final progressProvider = Provider.of<ProgressProvider>(context);
    final quranProvider = Provider.of<QuranProvider>(context);
    
    // حساب إجمالي الآيات المحفوظة
    int totalMemorizedAyahs = 0;
    int totalAyahs = 0;
    
    for (final surah in quranProvider.surahs) {
      final surahId = surah.number.toString();
      final memorizedCount = progressProvider.getMemorizedAyahsCount(surahId);
      totalMemorizedAyahs += memorizedCount;
      totalAyahs += surah.numberOfAyahs;

    }
    
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'أيام التتابع',
                '${progressProvider.streakCount}',
                Icons.calendar_today,
                const Color(0xFF4CAF50),
                'يوم',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'الآيات المحفوظة',
                '$totalMemorizedAyahs',
                Icons.text_fields,
                const Color(0xFF2196F3),
                'آية',
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'السور المقروءة',
                '${progressProvider.readSurahs.length}',
                Icons.book,
                const Color(0xFFFF9800),
                'سورة',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'الهدف اليومي',
                '${progressProvider.todayReadPages}/${progressProvider.dailyGoalPages}',
                Icons.insert_chart,
                const Color(0xFF9C27B0),
                'صفحة',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // شريط تقدم الهدف اليومي
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تقدم الهدف اليومي: ${(progressProvider.dailyGoalProgress * 100).toStringAsFixed(1)}%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progressProvider.dailyGoalProgress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[800],
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
              minHeight: 8,
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'السور المكتملة',
                '8',
                Icons.book,
                const Color(0xFFFF9800),
                'سورة',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                'نقاط التقدم',
                '1,250',
                Icons.star,
                const Color(0xFF9C27B0),
                'نقطة',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, String unit) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F3460),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            unit,
            style: TextStyle(
              color: color.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressChart() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F3460),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تقدم القراءة',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 20),
          
          // رسم بياني مبسط
          Container(
            height: 200,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildBarChart('السبت', 0.8, const Color(0xFF4CAF50)),
                _buildBarChart('الأحد', 0.6, const Color(0xFF2196F3)),
                _buildBarChart('الاثنين', 0.9, const Color(0xFFFF9800)),
                _buildBarChart('الثلاثاء', 0.7, const Color(0xFF9C27B0)),
                _buildBarChart('الأربعاء', 0.5, const Color(0xFFF44336)),
                _buildBarChart('الخميس', 0.8, const Color(0xFF00BCD4)),
                _buildBarChart('الجمعة', 0.4, const Color(0xFF795548)),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // إجمالي التقدم
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF16213E),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'إجمالي التقدم:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                Text(
                  '67%',
                  style: TextStyle(
                    color: const Color(0xFF4CAF50),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(String day, double height, Color color) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 120 * height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
          textDirection: TextDirection.rtl,
        ),
      ],
    );
  }

  Widget _buildActivityDetails() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F3460),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'تفاصيل النشاط',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 16),
          
          _buildActivityItem(
            'القراءة الصباحية',
            '45 دقيقة',
            Icons.wb_sunny,
            const Color(0xFFFF9800),
          ),
          _buildActivityItem(
            'القراءة المسائية',
            '1:20 ساعة',
            Icons.nightlight,
            const Color(0xFF2196F3),
          ),
          _buildActivityItem(
            'المراجعة',
            '30 دقيقة',
            Icons.refresh,
            const Color(0xFF4CAF50),
          ),
          _buildActivityItem(
            'الحفظ',
            '25 دقيقة',
            Icons.school,
            const Color(0xFF9C27B0),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String duration, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textDirection: TextDirection.rtl,
            ),
          ),
          Text(
            duration,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievements() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0F3460),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'الإنجازات',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildAchievementCard(
                  'قارئ نشط',
                  '7 أيام متتالية',
                  Icons.local_fire_department,
                  const Color(0xFFFF9800),
                  true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAchievementCard(
                  'حافظ ممتاز',
                  'حفظ 5 سور',
                  Icons.psychology,
                  const Color(0xFF4CAF50),
                  true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildAchievementCard(
                  'مفسر القرآن',
                  'قراءة 100 آية',
                  Icons.auto_stories,
                  const Color(0xFF2196F3),
                  true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAchievementCard(
                  'مستمع دؤوب',
                  'استماع 5 ساعات',
                  Icons.headphones,
                  const Color(0xFF9C27B0),
                  false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(String title, String description, IconData icon, Color color, bool unlocked) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: unlocked ? const Color(0xFF16213E) : Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: unlocked ? color : Colors.grey.withOpacity(0.5),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: unlocked ? color : Colors.grey,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: unlocked ? Colors.white : Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              color: unlocked ? color : Colors.grey,
              fontSize: 12,
            ),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
          ),
          if (unlocked) ...[
            const SizedBox(height: 4),
            Icon(
              Icons.check_circle,
              color: color,
              size: 16,
            ),
          ],
        ],
      ),
    );
  }

  void _shareStatistics() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'سيتم إضافة ميزة مشاركة الإحصائيات قريباً',
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }
}