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

  final List<String> _filters = ['الكل', 'السور', 'الآيات', 'الكلمات', 'التفسير', 'التجويد'];
  bool _showAdvancedSearch = false;
  RangeValues _juzRange = const RangeValues(1, 30);
  bool _searchInTafsir = false;
  bool _searchInTajweed = false;
  String _selectedRecitationQuality = 'الكل';
  final List<String> _recitationQualities = ['الكل', 'ممتاز', 'جيد جداً', 'جيد', 'مقبول'];

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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'البحث في القرآن',
          style: TextStyle(color: Theme.of(context).appBarTheme.titleTextStyle?.color),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        iconTheme: IconThemeData(color: Theme.of(context).appBarTheme.iconTheme?.color),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).appBarTheme.iconTheme?.color),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showAdvancedSearch ? Icons.expand_less : Icons.expand_more, 
              color: Theme.of(context).appBarTheme.iconTheme?.color,
            ),
            onPressed: () {
              setState(() {
                _showAdvancedSearch = !_showAdvancedSearch;
              });
            },
            tooltip: 'بحث متقدم',
          ),
          IconButton(
            icon: Icon(Icons.mic, color: Theme.of(context).appBarTheme.iconTheme?.color),
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
                  style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                  decoration: InputDecoration(
                    hintText: 'ابحث في القرآن الكريم...',
                    hintStyle: TextStyle(color: Theme.of(context).hintColor),
                    prefixIcon: Icon(Icons.search, color: Theme.of(context).iconTheme.color?.withOpacity(0.7)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Theme.of(context).iconTheme.color?.withOpacity(0.7)),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Theme.of(context).cardTheme.color,
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
                                ? Theme.of(context).primaryColor 
                                : Theme.of(context).cardTheme.color,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected 
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(context).dividerColor,
                            ),
                          ),
                          child: Text(
                            filter,
                            style: TextStyle(
                              color: isSelected 
                                  ? Theme.of(context).colorScheme.onPrimary 
                                  : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
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
          
          // واجهة البحث المتقدم
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _showAdvancedSearch ? 220 : 0,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // نطاق البحث في الأجزاء
                    Text(
                      'نطاق الأجزاء: ${_juzRange.start.round()} - ${_juzRange.end.round()}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleMedium?.color,
                      ),
                    ),
                    RangeSlider(
                      values: _juzRange,
                      min: 1,
                      max: 30,
                      divisions: 29,
                      labels: RangeLabels(
                        _juzRange.start.round().toString(),
                        _juzRange.end.round().toString(),
                      ),
                      onChanged: (values) {
                        setState(() {
                          _juzRange = values;
                        });
                      },
                      activeColor: Theme.of(context).primaryColor,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // خيارات إضافية
                    Row(
                      children: [
                        Expanded(
                          child: CheckboxListTile(
                            title: Text(
                              'البحث في التفسير', 
                              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                            ),
                            value: _searchInTafsir,
                            onChanged: (value) {
                              setState(() {
                                _searchInTafsir = value ?? false;
                              });
                            },
                            activeColor: Theme.of(context).primaryColor,
                            checkColor: Theme.of(context).colorScheme.onPrimary,
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        Expanded(
                          child: CheckboxListTile(
                            title: Text(
                              'البحث في التجويد', 
                              style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
                            ),
                            value: _searchInTajweed,
                            onChanged: (value) {
                              setState(() {
                                _searchInTajweed = value ?? false;
                              });
                            },
                            activeColor: Theme.of(context).primaryColor,
                            checkColor: Theme.of(context).colorScheme.onPrimary,
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // جودة القراءة
                    Text(
                      'جودة القراءة:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _recitationQualities.map((quality) {
                        return ChoiceChip(
                          label: Text(quality),
                          selected: _selectedRecitationQuality == quality,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedRecitationQuality = quality;
                              });
                            }
                          },
                          selectedColor: Theme.of(context).primaryColor,
                          backgroundColor: Theme.of(context).cardTheme.color,
                          labelStyle: TextStyle(
                            color: _selectedRecitationQuality == quality 
                                ? Theme.of(context).colorScheme.onPrimary 
                                : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
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
            color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'ابحث في القرآن الكريم',
            style: TextStyle(
              color: Theme.of(context).textTheme.titleLarge?.color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 8),
          Text(
            'اكتب كلمة أو آية للبحث',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
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
                Text(
                  'اقتراحات سريعة:',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.titleMedium?.color,
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
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Text(
          suggestion,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
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
            color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد نتائج لـ "$_searchQuery"',
            style: TextStyle(
              color: Theme.of(context).textTheme.titleLarge?.color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            textDirection: TextDirection.rtl,
          ),
          const SizedBox(height: 8),
          Text(
            'جرب كلمات أخرى أو تحقق من الإملاء',
            style: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
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
        color: Theme.of(context).cardTheme.color,
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
            color: Theme.of(context).colorScheme.onPrimary,
            size: 20,
          ),
        ),
        title: Text(
          result.title,
          style: TextStyle(
            color: Theme.of(context).textTheme.titleMedium?.color,
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
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                fontSize: 14,
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                result.content,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
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
          icon: Icon(Icons.more_vert, color: Theme.of(context).iconTheme.color),
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
            PopupMenuItem(
              value: 'view',
              child: Text(
                'عرض',
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
              ),
            ),
            PopupMenuItem(
              value: 'play',
              child: Text(
                'تشغيل',
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
              ),
            ),
            PopupMenuItem(
              value: 'share',
              child: Text(
                'مشاركة',
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
              ),
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
        return Theme.of(context).primaryColor;
      case 'آية':
        return Theme.of(context).colorScheme.secondary;
      case 'كلمة':
        return Theme.of(context).colorScheme.tertiary;
      case 'التفسير':
        return Theme.of(context).colorScheme.primary;
      case 'التجويد':
        return Theme.of(context).colorScheme.secondary;
      default:
        return Theme.of(context).primaryColor;
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
        backgroundColor: Theme.of(context).primaryColor,
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
        backgroundColor: Theme.of(context).colorScheme.secondary,
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
        backgroundColor: Theme.of(context).colorScheme.tertiary,
      ),
    );
  }

  void _showVoiceSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        title: Text(
          'البحث الصوتي',
          style: TextStyle(color: Theme.of(context).textTheme.titleLarge?.color),
          textDirection: TextDirection.rtl,
        ),
        content: Text(
          'سيتم إضافة ميزة البحث الصوتي قريباً',
          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
          textDirection: TextDirection.rtl,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'حسناً',
              style: TextStyle(color: Theme.of(context).primaryColor),
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