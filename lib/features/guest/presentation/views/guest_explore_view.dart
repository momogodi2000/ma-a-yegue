import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/forms/custom_button.dart';
import '../../../../core/constants/supported_languages.dart';
import '../viewmodels/guest_dashboard_viewmodel.dart';

/// Guest exploration view showcasing language features without registration
class GuestExploreView extends StatefulWidget {
  const GuestExploreView({super.key});

  @override
  State<GuestExploreView> createState() => _GuestExploreViewState();
}

class _GuestExploreViewState extends State<GuestExploreView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _selectedLanguageIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // Initialize ViewModel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GuestDashboardViewModel>().initialize();
    });
  }

  // Removed unused static fallback languages; using SupportedLanguages instead

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorer les Langues'),
        backgroundColor: Colors.green,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.explore), text: 'Découvrir'),
            Tab(icon: Icon(Icons.translate), text: 'Vocabulaire'),
            Tab(icon: Icon(Icons.museum), text: 'Culture'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDiscoverTab(),
          _buildVocabularyTab(),
          _buildCultureTab(),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          border: Border(top: BorderSide(color: Colors.orange.shade200)),
        ),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.orange),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Mode invité : fonctionnalités limitées',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            CustomButton(
              text: 'Débloquer',
              onPressed: () => context.go('/register'),
              backgroundColor: Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoverTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choisissez une langue à découvrir',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Language selection cards
          SizedBox(
            height: 200,
            child: PageView.builder(
              itemCount: SupportedLanguages.languages.length,
              onPageChanged: (index) {
                setState(() {
                  _selectedLanguageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final language = SupportedLanguages.languages.values
                    .toList()[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: language.color,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        language.name,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        language.greeting,
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                language.region,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              const Icon(Icons.people, color: Colors.white),
                              const SizedBox(height: 4),
                              Text(
                                '${language.speakers} locuteurs',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 24),

          // Quick start section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Premiers pas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                _buildQuickStartItem(
                  Icons.volume_up,
                  'Écoutez la prononciation',
                  'Apprenez les sons authentiques',
                ),
                _buildQuickStartItem(
                  Icons.translate,
                  'Mots de base',
                  'Découvrez le vocabulaire essentiel',
                ),
                _buildQuickStartItem(
                  Icons.quiz,
                  'Mini-quiz',
                  'Testez vos connaissances',
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'Commencer l\'exploration',
                  onPressed: () {
                    // Navigate to basic lesson for selected language
                    _showGuestLessonDialog();
                  },
                  backgroundColor: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVocabularyTab() {
    final selectedLanguage = SupportedLanguages.languages.values
        .toList()[_selectedLanguageIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Vocabulaire de base - ${selectedLanguage.name}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Basic words list from GuestContentService
          FutureBuilder<List<Map<String, dynamic>>>(
            future: context.read<GuestDashboardViewModel>().getBasicWords(
              languageCode: selectedLanguage.code,
            ),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 48,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Erreur de chargement: ${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final words = snapshot.data ?? [];
              if (words.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.translate_outlined,
                          size: 48,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Aucun mot disponible',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Revenez plus tard pour découvrir de nouveaux mots',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return Column(
                children: words.map<Widget>((word) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: selectedLanguage.color,
                        child: const Icon(Icons.volume_up, color: Colors.white),
                      ),
                      title: Text(word['word'] ?? ''),
                      subtitle: Text(word['translation'] ?? ''),
                      trailing: const Icon(Icons.favorite_border),
                      onTap: () {
                        _showGuestFeatureDialog('prononciation');
                      },
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 24),

          // More vocabulary teaser
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Column(
              children: [
                const Icon(Icons.lock, color: Colors.blue, size: 32),
                const SizedBox(height: 8),
                const Text(
                  'Plus de 500 mots disponibles',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Créez un compte pour accéder au dictionnaire complet',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'Voir tout le vocabulaire',
                  onPressed: () => context.go('/register'),
                  backgroundColor: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCultureTab() {
    final selectedLanguage = SupportedLanguages.languages.values
        .toList()[_selectedLanguageIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Culture - ${selectedLanguage.name}',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Cultural info card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.museum, color: selectedLanguage.color),
                      const SizedBox(width: 8),
                      const Text(
                        'Contexte culturel',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    selectedLanguage.culturalInfo,
                    style: const TextStyle(fontSize: 16, height: 1.4),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Traditions preview
          const Text(
            'Traditions et coutumes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          _buildCultureItem(
            '🎵',
            'Musique traditionnelle',
            'Découvrez les rythmes ancestraux',
          ),
          _buildCultureItem(
            '🍽️',
            'Cuisine locale',
            'Plats typiques de la région',
          ),
          _buildCultureItem(
            '🎭',
            'Contes et légendes',
            'Histoires transmises oralement',
          ),
          _buildCultureItem(
            '🎪',
            'Fêtes traditionnelles',
            'Célébrations communautaires',
          ),

          const SizedBox(height: 24),

          // Premium culture content
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple.shade200),
            ),
            child: Column(
              children: [
                const Icon(Icons.auto_stories, color: Colors.purple, size: 32),
                const SizedBox(height: 8),
                const Text(
                  'Contenu culturel enrichi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Histoires audio, vidéos documentaires, interviews d\'anciens',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'Accéder au contenu complet',
                  onPressed: () => context.go('/register'),
                  backgroundColor: Colors.purple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStartItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.green),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  description,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCultureItem(String emoji, String title, String description) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Text(emoji, style: const TextStyle(fontSize: 24)),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          _showGuestFeatureDialog('contenu culturel');
        },
      ),
    );
  }

  void _showGuestLessonDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leçon de démonstration'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.school, size: 48, color: Colors.green),
            SizedBox(height: 16),
            Text(
              'Vous pouvez essayer 3 leçons gratuites en mode invité.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Créez un compte pour accéder à toutes les leçons et sauvegarder votre progression.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/demo-lessons');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Essayer'),
          ),
        ],
      ),
    );
  }

  void _showGuestFeatureDialog(String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Fonctionnalité : $feature'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.lock_outline, size: 48, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              'Cette fonctionnalité nécessite un compte utilisateur.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Créez votre compte gratuit pour débloquer toutes les fonctionnalités.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Plus tard'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/register');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('S\'inscrire'),
          ),
        ],
      ),
    );
  }
}
