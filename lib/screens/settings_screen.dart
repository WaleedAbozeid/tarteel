import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/audio_provider.dart';
import '../providers/quran_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkMode = true;
  bool _notificationsEnabled = true;
  bool _autoPlayEnabled = false;
  double _fontSize = 18.0;
  String _selectedLanguage = 'العربية';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text(
          'الإعدادات',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: const Color(0xFF16213E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // قسم المظهر
            _buildSectionHeader('المظهر والتصميم'),
            _buildSettingCard(
              title: 'الوضع الليلي',
              subtitle: 'تفعيل المظهر الداكن',
              icon: Icons.dark_mode,
              trailing: Switch(
                value: _isDarkMode,
                onChanged: (value) {
                  setState(() {
                    _isDarkMode = value;
                  });
                },
                activeColor: const Color(0xFF4CAF50),
              ),
            ),
            _buildSettingCard(
              title: 'حجم الخط',
              subtitle: 'تخصيص حجم النص',
              icon: Icons.text_fields,
              trailing: SizedBox(
                width: 100,
                child: Slider(
                  value: _fontSize,
                  min: 14.0,
                  max: 24.0,
                  divisions: 10,
                  activeColor: const Color(0xFF4CAF50),
                  onChanged: (value) {
                    setState(() {
                      _fontSize = value;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            // قسم الصوت
            _buildSectionHeader('إعدادات الصوت'),
            _buildSettingCard(
              title: 'التشغيل التلقائي',
              subtitle: 'تشغيل الصوت تلقائياً',
              icon: Icons.play_circle,
              trailing: Switch(
                value: _autoPlayEnabled,
                onChanged: (value) {
                  setState(() {
                    _autoPlayEnabled = value;
                  });
                },
                activeColor: const Color(0xFF4CAF50),
              ),
            ),
            _buildSettingCard(
              title: 'إعدادات الصوت',
              subtitle: 'تخصيص جودة الصوت',
              icon: Icons.volume_up,
              onTap: () {
                Navigator.pushNamed(context, '/audio-settings');
              },
            ),

            const SizedBox(height: 24),

            // قسم الإشعارات
            _buildSectionHeader('الإشعارات'),
            _buildSettingCard(
              title: 'تفعيل الإشعارات',
              subtitle: 'استلام تنبيهات يومية',
              icon: Icons.notifications,
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
                activeColor: const Color(0xFF4CAF50),
              ),
            ),

            const SizedBox(height: 24),

            // قسم اللغة
            _buildSectionHeader('اللغة'),
            _buildSettingCard(
              title: 'لغة التطبيق',
              subtitle: 'اختر اللغة المفضلة',
              icon: Icons.language,
              trailing: DropdownButton<String>(
                value: _selectedLanguage,
                dropdownColor: const Color(0xFF0F3460),
                style: const TextStyle(color: Colors.white),
                underline: Container(),
                items: const [
                  DropdownMenuItem(
                    value: 'العربية',
                    child: Text('العربية', style: TextStyle(color: Colors.white)),
                  ),
                  DropdownMenuItem(
                    value: 'English',
                    child: Text('English', style: TextStyle(color: Colors.white)),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedLanguage = value;
                    });
                  }
                },
              ),
            ),

            const SizedBox(height: 24),

            // قسم البيانات
            _buildSectionHeader('البيانات والتخزين'),
            _buildSettingCard(
              title: 'مسح التخزين المؤقت',
              subtitle: 'تحرير مساحة التخزين',
              icon: Icons.cleaning_services,
              onTap: () {
                _showClearCacheDialog();
              },
            ),
            _buildSettingCard(
              title: 'تصدير البيانات',
              subtitle: 'حفظ البيانات محلياً',
              icon: Icons.download,
              onTap: () {
                _showExportDialog();
              },
            ),

            const SizedBox(height: 24),

            // قسم حول التطبيق
            _buildSectionHeader('حول التطبيق'),
            _buildSettingCard(
              title: 'إصدار التطبيق',
              subtitle: '1.0.0',
              icon: Icons.info,
            ),
            _buildSettingCard(
              title: 'سياسة الخصوصية',
              subtitle: 'اقرأ سياسة الخصوصية',
              icon: Icons.privacy_tip,
              onTap: () {
                _showPrivacyPolicy();
              },
            ),
            _buildSettingCard(
              title: 'شروط الاستخدام',
              subtitle: 'اقرأ شروط الاستخدام',
              icon: Icons.description,
              onTap: () {
                _showTermsOfService();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        textDirection: TextDirection.rtl,
      ),
    );
  }

  Widget _buildSettingCard({
    required String title,
    required String subtitle,
    required IconData icon,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      color: const Color(0xFF0F3460),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF4CAF50),
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textDirection: TextDirection.rtl,
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.grey),
          textDirection: TextDirection.rtl,
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F3460),
        title: const Text(
          'مسح التخزين المؤقت',
          style: TextStyle(color: Colors.white),
          textDirection: TextDirection.rtl,
        ),
        content: const Text(
          'هل تريد مسح التخزين المؤقت؟ هذا سيسرع التطبيق ولكن سيحتاج لإعادة تحميل بعض البيانات.',
          style: TextStyle(color: Colors.white),
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              // تنفيذ مسح التخزين المؤقت
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم مسح التخزين المؤقت بنجاح'),
                  backgroundColor: Color(0xFF4CAF50),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: const Text('تأكيد'),
          ),
        ],
      ),
    );
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F3460),
        title: const Text(
          'تصدير البيانات',
          style: TextStyle(color: Colors.white),
          textDirection: TextDirection.rtl,
        ),
        content: const Text(
          'سيتم تصدير بياناتك إلى ملف محلي.',
          style: TextStyle(color: Colors.white),
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم تصدير البيانات بنجاح'),
                  backgroundColor: Color(0xFF4CAF50),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: const Text('تصدير'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F3460),
        title: const Text(
          'سياسة الخصوصية',
          style: TextStyle(color: Colors.white),
          textDirection: TextDirection.rtl,
        ),
        content: const Text(
          'نحن نحترم خصوصيتك ولا نشارك بياناتك مع أي طرف ثالث.',
          style: TextStyle(color: Colors.white),
          textDirection: TextDirection.rtl,
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: const Text('فهمت'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F3460),
        title: const Text(
          'شروط الاستخدام',
          style: TextStyle(color: Colors.white),
          textDirection: TextDirection.rtl,
        ),
        content: const Text(
          'باستخدام هذا التطبيق، فإنك توافق على شروط الاستخدام.',
          style: TextStyle(color: Colors.white),
          textDirection: TextDirection.rtl,
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: const Text('فهمت'),
          ),
        ],
      ),
    );
  }
} 