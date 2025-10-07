import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/routes.dart';
import '../../../../shared/widgets/forms/custom_button.dart';
import '../../../../shared/themes/colors.dart';
import '../../data/services/guest_dictionary_service.dart';

/// Guest dictionary view with access to local SQLite database
class GuestDictionaryView extends StatefulWidget {
  const GuestDictionaryView({super.key});

  @override
  State<GuestDictionaryView> createState() => _GuestDictionaryViewState();
}

class _GuestDictionaryViewState extends State<GuestDictionaryView>
    with TickerProviderStateMixin {
  
  // Controllers
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  // State
  bool _isLoading = true;
  List<Map<String, dynamic>> _languages = [];
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _featuredWords = [];
  List<Map<String, dynamic>> _searchResults = [];
  Map<String, dynamic>? _wordOfTheDay;
  String? _selectedLanguage;
  String? _selectedCategory;
  Map<String, int> _stats = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        GuestDictionaryService.getAvailableLanguages(),
        GuestDictionaryService.getCategories(),
        GuestDictionaryService.getFeaturedContent(),
        GuestDictionaryService.getDictionaryStats(),
      ]);

      final languages = results[0] as List<Map<String, dynamic>>;
      final categories = results[1] as List<Map<String, dynamic>>;
      final featuredContent = results[2] as Map<String, dynamic>;
      final stats = results[3] as Map<String, int>;

      setState(() {
        _languages = languages;
        _categories = categories;
        _featuredWords = featuredContent['featured_words'] ?? [];
        _wordOfTheDay = featuredContent['word_of_the_day'];
        _stats = stats;
        
        // Set default language if available
        if (_languages.isNotEmpty) {
          _selectedLanguage = _languages.first['id'];
        }
      });
    } catch (e) {
      debugPrint('Error loading dictionary data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchWords(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }

    try {
      final results = await GuestDictionaryService.searchWords(
        query,
        languageId: _selectedLanguage,
        limit: 10,
      );
      
      setState(() => _searchResults = results);
    } catch (e) {
      debugPrint('Error searching words: $e');
    }
  }

  Future<void> _loadWordsByCategory(String categoryId) async {
    try {
      final words = await GuestDictionaryService.getWordsByCategory(
        categoryId,
        languageId: _selectedLanguage,
        limit: 15,
      );
      
      setState(() => _featuredWords = words);
    } catch (e) {
      debugPrint('Error loading words by category: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dictionnaire'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            } else {
              context.go(Routes.landing);
            }
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              // Guest limitation notice
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Colors.orange.shade100,
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade900, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Mode Invité - Limité à 25 mots. Inscrivez-vous pour accéder à tout le dictionnaire.',
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go(Routes.register),
                      child: const Text('S\'inscrire', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
              
              // Tabs
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Recherche'),
                  Tab(text: 'Catégories'),
                  Tab(text: 'Mot du jour'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Language selector
                if (_languages.isNotEmpty) _buildLanguageSelector(),
                
                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildSearchTab(),
                      _buildCategoriesTab(),
                      _buildWordOfTheDayTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLanguageSelector() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          const Text('Langue: ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: DropdownButton<String>(
              value: _selectedLanguage,
              isExpanded: true,
              items: _languages.map((lang) {
                return DropdownMenuItem<String>(
                  value: lang['id'],
                  child: Text('${lang['name']} (${lang['iso_code']})'),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedLanguage = value);
                // Reload content for selected language
                _loadInitialData();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search field
          TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Rechercher un mot en français...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: _searchWords,
          ),
          
          const SizedBox(height: 16),
          
          // Search results or featured words
          Expanded(
            child: _searchController.text.isNotEmpty
                ? _buildWordsList(_searchResults, 'Résultats de recherche')
                : _buildWordsList(_featuredWords, 'Mots populaires'),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return GestureDetector(
            onTap: () {
              setState(() => _selectedCategory = category['id']);
              _loadWordsByCategory(category['id']);
              _tabController.animateTo(0); // Switch to search tab
            },
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _getCategoryIcon(category['id']),
                      size: 32,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    if (category['description'] != null)
                      Text(
                        category['description'],
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWordOfTheDayTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (_wordOfTheDay != null) ...[
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Mot du jour',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildWordCard(_wordOfTheDay!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          // Statistics
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Statistiques du dictionnaire',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Langues', '${_stats['languages'] ?? 0}'),
                      _buildStatItem('Mots', '${_stats['translations'] ?? 0}'),
                      _buildStatItem('Catégories', '${_stats['categories'] ?? 0}'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Call to action
          CustomButton(
            text: 'Accéder au dictionnaire complet',
            onPressed: () => context.go(Routes.register),
            backgroundColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildWordsList(List<Map<String, dynamic>> words, String title) {
    if (words.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Aucun mot trouvé',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: words.length,
            itemBuilder: (context, index) {
              return _buildWordCard(words[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildWordCard(Map<String, dynamic> word) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(
          word['french'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              word['translation'],
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.primary,
              ),
            ),
            if (word['pronunciation'] != null) ...[
              const SizedBox(height: 4),
              Text(
                '🔊 ${word['pronunciation']}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
        trailing: Chip(
          label: Text(
            word['difficulty'] ?? 'beginner',
            style: const TextStyle(fontSize: 10),
          ),
          backgroundColor: _getDifficultyColor(word['difficulty']),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String categoryId) {
    switch (categoryId) {
      case 'GRT': return Icons.waving_hand;
      case 'NUM': return Icons.numbers;
      case 'FAM': return Icons.family_restroom;
      case 'FOD': return Icons.restaurant;
      case 'BOD': return Icons.accessibility;
      case 'TIM': return Icons.access_time;
      case 'COL': return Icons.palette;
      case 'ANI': return Icons.pets;
      case 'NAT': return Icons.nature;
      case 'VRB': return Icons.play_arrow;
      case 'ADJ': return Icons.style;
      case 'PHR': return Icons.chat;
      case 'HOM': return Icons.home;
      case 'EDU': return Icons.school;
      case 'HEA': return Icons.medical_services;
      case 'MON': return Icons.monetization_on;
      default: return Icons.translate;
    }
  }

  Color _getDifficultyColor(String? difficulty) {
    switch (difficulty) {
      case 'beginner': return Colors.green.shade100;
      case 'intermediate': return Colors.orange.shade100;
      case 'advanced': return Colors.red.shade100;
      default: return Colors.grey.shade100;
    }
  }
}