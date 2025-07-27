import 'package:flutter/material.dart';
import '../models/quran_models.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<SearchResult> _searchResults = [];
  bool _isSearching = false;
  String _selectedFilter = 'الكل';

  final List<String> _filters = ['الكل', 'السور', 'الآيات', 'الكلمات'];

  // بيانات وهمية للبحث
  final List<SearchResult> _allData = [
    SearchResult(
      type: 'سورة',
      title: 'الفاتحة',
      subtitle: 'سورة الفاتحة - 7 آيات',
      content: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
      surahNumber: 1,
      ayahNumber: null,
    ),
    SearchResult(
      type: 'آية',
      title: 'الآية 1 من سورة الفاتحة',
      subtitle: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
      content: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
      surahNumber: 1,
      ayahNumber: 1,
    ),
    SearchResult(
      type: 'آية',
      title: 'الآية 2 من سورة الفاتحة',
      subtitle: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
      content: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
      surahNumber: 1,
      ayahNumber: 2,
    ),
    SearchResult(
      type: 'سورة',
      title: 'الإخلاص',
      subtitle: 'سورة الإخلاص - 4 آيات',
      content: 'قُلْ هُوَ اللَّهُ أَحَدٌ اللَّهُ الصَّمَدُ',
      surahNumber: 112,
      ayahNumber: null,
    ),
    SearchResult(
      type: 'آية',
      title: 'الآية 1 من سورة الإخلاص',
      subtitle: 'قُلْ هُوَ اللَّهُ أَحَدٌ',
      content: 'قُلْ هُوَ اللَّهُ أَحَدٌ',
      surahNumber: 112,
      ayahNumber: 1,
    ),
    SearchResult(
      type: 'كلمة',
      title: 'اللَّهُ',
      subtitle: 'وردت في عدة آيات',
      content: 'اللَّهُ - اسم الجلالة',
      surahNumber: null,
      ayahNumber: null,
    ),
    SearchResult(
      type: 'كلمة',
      title: 'الرَّحْمَٰنِ',
      subtitle: 'وردت في عدة آيات',
      content: 'الرَّحْمَٰنِ - من أسماء الله الحسنى',
      surahNumber: null,
      ayahNumber: null,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _performSearch();
    });
  }

  void _performSearch() {
    if (_searchQuery.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // محاكاة البحث
    Future.delayed(const Duration(milliseconds: 500), () {
      final filteredData = _allData.where((result) {
        final matchesFilter = _selectedFilter == 'الكل' || 
                            (_selectedFilter == 'السور' && result.type == 'سورة') ||
                            (_selectedFilter == 'الآيات' && result.type == 'آية') ||
                            (_selectedFilter == 'الكلمات' && result.type == 'كلمة');
        
        final matchesQuery = result.title.contains(_searchQuery) ||
                           result.subtitle.contains(_searchQuery) ||
                           result.content.contains(_searchQuery);
        
        return matchesFilter && matchesQuery;
      }).toList();

      setState(() {
        _searchResults = filteredData;
        _isSearching = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text(
          'البحث في القرآن',
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
            icon: const Icon(Icons.mic, color: Colors.white),
            onPressed: () {
              _showVoiceSearchDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط البحث
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // حقل البحث
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'ابحث في القرآن الكريم...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: const Color(0xFF0F3460),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  textDirection: TextDirection.rtl,
                ),
                
                const SizedBox(height: 12),
                
                // فلاتر البحث
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _filters.length,
                    itemBuilder: (context, index) {
                      final filter = _filters[index];
                      final isSelected = filter == _selectedFilter;
                      
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedFilter = filter;
                            _performSearch();
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? const Color(0xFF4CAF50) 
                                : const Color(0xFF0F3460),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected 
                                  ? const Color(0xFF4CAF50)
                                  : Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            filter,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.grey,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            textDirection: TextDirection.rtl,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // نتائج البحث
          Expanded(
            child: _isSearching
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  )
                : _searchQuery.isEmpty
                    ? _buildEmptyState()
                    : _searchResults.isEmpty
                        ? _buildNoResults()
                        : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'ابحث في القرآن الكريم',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 8),
          const Text(
            'اكتب كلمة أو آية للبحث',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 24),
          
          // اقتراحات سريعة
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Text(
                  'اقتراحات سريعة:',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textDirection: TextDirection.rtl,
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildQuickSuggestion('الفاتحة'),
                    _buildQuickSuggestion('الإخلاص'),
                    _buildQuickSuggestion('اللَّهُ'),
                    _buildQuickSuggestion('الرَّحْمَٰنِ'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSuggestion(String suggestion) {
    return GestureDetector(
      onTap: () {
        _searchController.text = suggestion;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF0F3460),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: Text(
          suggestion,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
          ),
          textDirection: TextDirection.rtl,
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد نتائج لـ "$_searchQuery"',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 8),
          const Text(
            'جرب كلمات أخرى أو تحقق من الإملاء',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
            textDirection: TextDirection.rtl,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        return _buildSearchResultCard(result);
      },
    );
  }

  Widget _buildSearchResultCard(SearchResult result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F3460),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getTypeColor(result.type).withOpacity(0.3),
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTypeColor(result.type),
          child: Icon(
            _getTypeIcon(result.type),
            color: Colors.white,
            size: 20,
          ),
        ),
        title: Text(
          result.title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textDirection: TextDirection.rtl,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              result.subtitle,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF16213E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                result.content,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontFamily: 'Amiri',
                ),
                textDirection: TextDirection.rtl,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onSelected: (value) {
            switch (value) {
              case 'view':
                _viewResult(result);
                break;
              case 'play':
                _playResult(result);
                break;
              case 'share':
                _shareResult(result);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Text('عرض'),
            ),
            const PopupMenuItem(
              value: 'play',
              child: Text('تشغيل'),
            ),
            const PopupMenuItem(
              value: 'share',
              child: Text('مشاركة'),
            ),
          ],
        ),
        onTap: () {
          _viewResult(result);
        },
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'سورة':
        return const Color(0xFF4CAF50);
      case 'آية':
        return const Color(0xFF2196F3);
      case 'كلمة':
        return const Color(0xFFFF9800);
      default:
        return const Color(0xFF4CAF50);
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'سورة':
        return Icons.book;
      case 'آية':
        return Icons.text_fields;
      case 'كلمة':
        return Icons.search;
      default:
        return Icons.search;
    }
  }

  void _viewResult(SearchResult result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'عرض: ${result.title}',
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );
  }

  void _playResult(SearchResult result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تشغيل: ${result.title}',
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: const Color(0xFF2196F3),
      ),
    );
  }

  void _shareResult(SearchResult result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'مشاركة: ${result.title}',
          textDirection: TextDirection.rtl,
        ),
        backgroundColor: const Color(0xFFFF9800),
      ),
    );
  }

  void _showVoiceSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0F3460),
        title: const Text(
          'البحث الصوتي',
          style: TextStyle(color: Colors.white),
          textDirection: TextDirection.rtl,
        ),
        content: const Text(
          'سيتم إضافة ميزة البحث الصوتي قريباً',
          style: TextStyle(color: Colors.white),
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'حسناً',
              style: TextStyle(color: Color(0xFF4CAF50)),
            ),
          ),
        ],
      ),
    );
  }
}

class SearchResult {
  final String type;
  final String title;
  final String subtitle;
  final String content;
  final int? surahNumber;
  final int? ayahNumber;

  SearchResult({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.content,
    this.surahNumber,
    this.ayahNumber,
  });
} 