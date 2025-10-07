import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/database/unified_database_service.dart';
import '../../../profile/presentation/views/profile_view.dart';

class HomePage extends StatefulWidget {
  final String nomUtilisateur;

  const HomePage({super.key, required this.nomUtilisateur});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentCarouselIndex = 0;

  // Real data from database
  Map<String, dynamic> _userStats = {};
  List<Map<String, dynamic>> _recentLessons = [];
  List<Map<String, dynamic>> _featuredLanguages = [];
  bool _isLoading = true;

  final List<Map<String, String>> _carouselItems = [
    {
      'image': 'https://images.unsplash.com/photo-1552664730-d307ca884978',
      'title': 'Apprends les langues du Cameroun',
      'subtitle': 'Plus de 280 langues traditionnelles à découvrir',
    },
    {
      'image': 'https://images.unsplash.com/photo-1503676260728-1c00da094a0b',
      'title': 'Cours interactifs avec des experts',
      'subtitle': 'Professeurs natifs certifiés',
    },
    {
      'image': 'https://images.unsplash.com/photo-1509062522246-3755977927d7',
      'title': 'Obtiens ton certificat',
      'subtitle': 'Certifications reconnues à chaque niveau',
    },
    {
      'image': 'https://images.unsplash.com/photo-1522202176988-66273c2fd55f',
      'title': 'Communauté active',
      'subtitle': 'Rejoins des milliers d\'apprenants',
    },
    {
      'image': 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3',
      'title': 'Mode hors-ligne',
      'subtitle': 'Apprends même sans connexion internet',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    try {
      final db = UnifiedDatabaseService.instance;

      // Get featured languages from the database
      final featuredLanguages = await db.getAllLanguages();

      // Get recent lessons
      final recentLessons = await db.getLessonsByLanguage('EWO');

      // Create mock user stats for now (will be replaced with real user data later)
      final userStats = {
        'current_level': 3,
        'total_xp': 1250,
        'current_streak': 7,
        'completed_lessons': 15,
        'total_lessons': 50,
      };

      setState(() {
        _userStats = userStats;
        _recentLessons = recentLessons.take(4).toList();
        _featuredLanguages = featuredLanguages.take(6).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Ma'a yegue"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadHomeData),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Section with Carousel
                  _buildHeroCarousel(),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome Message with User Stats
                        _buildWelcomeSection(),

                        const SizedBox(height: 30),

                        // User Progress Section
                        if (_userStats.isNotEmpty) _buildUserProgressSection(),

                        const SizedBox(height: 30),

                        // Stats Section
                        _buildStatsSection(),

                        const SizedBox(height: 30),

                        // Recent Lessons Section
                        if (_recentLessons.isNotEmpty)
                          _buildRecentLessonsSection(),

                        const SizedBox(height: 30),

                        // Featured Languages Section
                        if (_featuredLanguages.isNotEmpty)
                          _buildFeaturedLanguagesSection(),

                        const SizedBox(height: 30),

                        const Text(
                          "📚 Accès rapide",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 15),

                        // Quick Access Grid
                        _buildQuickAccessGrid(),

                        const SizedBox(height: 30),

                        // Features Section
                        _buildFeaturesSection(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHeroCarousel() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 250,
            viewportFraction: 1.0,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 5),
            autoPlayAnimationDuration: const Duration(milliseconds: 800),
            autoPlayCurve: Curves.fastOutSlowIn,
            onPageChanged: (index, reason) {
              setState(() {
                _currentCarouselIndex = index;
              });
            },
          ),
          items: _carouselItems.map((item) {
            return Builder(
              builder: (BuildContext context) {
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: item['image']!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 40,
                      left: 20,
                      right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item['subtitle']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          }).toList(),
        ),
        Positioned(
          bottom: 10,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: _carouselItems.asMap().entries.map((entry) {
              return Container(
                width: 8.0,
                height: 8.0,
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentCarouselIndex == entry.key
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.4),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildWelcomeSection() {
    final currentLevel = _userStats['current_level'] ?? 1;
    final totalXP = _userStats['total_xp'] ?? 0;
    final streak = _userStats['current_streak'] ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.deepPurple, Colors.purpleAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "👋 Bienvenue ${widget.nomUtilisateur} !",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Apprends et redécouvre les langues maternelles du Cameroun 🇨🇲",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              _buildMiniStat("Niveau $currentLevel", Icons.star, Colors.amber),
              const SizedBox(width: 15),
              _buildMiniStat("$totalXP XP", Icons.emoji_events, Colors.orange),
              const SizedBox(width: 15),
              _buildMiniStat(
                "$streak jours",
                Icons.local_fire_department,
                Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserProgressSection() {
    final completedLessons = _userStats['completed_lessons'] ?? 0;
    final totalLessons = _userStats['total_lessons'] ?? 1;
    final progress = (completedLessons / totalLessons * 100).round();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "📊 Votre Progression",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Leçons complétées",
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "$completedLessons / $totalLessons",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.deepPurple.withValues(alpha: 0.1),
                ),
                child: Center(
                  child: Text(
                    "$progress%",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: Colors.grey[300],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentLessonsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "📖 Leçons Récentes",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => context.go('/lessons'),
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _recentLessons.length,
            itemBuilder: (context, index) {
              final lesson = _recentLessons[index];
              return Container(
                width: 200,
                margin: const EdgeInsets.only(right: 15),
                child: _buildLessonCard(lesson),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLessonCard(Map<String, dynamic> lesson) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go('/lesson/${lesson['id']}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lesson['title'] ?? 'Leçon',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                lesson['language'] ?? 'Langue',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
              const Spacer(),
              const Row(
                children: [
                  Icon(
                    Icons.play_circle_fill,
                    color: Colors.deepPurple,
                    size: 16,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Continuer',
                    style: TextStyle(
                      color: Colors.deepPurple,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedLanguagesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "🌍 Langues Populaires",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => context.go('/languages'),
              child: const Text('Voir tout'),
            ),
          ],
        ),
        const SizedBox(height: 15),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.2,
          ),
          itemCount: _featuredLanguages.length,
          itemBuilder: (context, index) {
            final language = _featuredLanguages[index];
            return _buildLanguageCard(language);
          },
        ),
      ],
    );
  }

  Widget _buildLanguageCard(Map<String, dynamic> language) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => context.go('/language/${language['id']}'),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                language['flag'] ?? '🏳️',
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 4),
              Text(
                language['name'] ?? 'Langue',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
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
  }

  Widget _buildQuickAccessGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 15,
      mainAxisSpacing: 15,
      children: [
        _buildCard(context, Icons.menu_book, "Catalogue", Colors.blue, () {
          context.go('/catalog');
        }),
        _buildCard(context, Icons.task, "Tâches", Colors.orange, () {
          context.go('/tasks');
        }),
        _buildCard(context, Icons.chat, "Chat IA", Colors.green, () {
          context.go('/ai-chat');
        }),
        _buildCard(context, Icons.person, "Profil", Colors.purple, () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProfilPage(nomUtilisateur: widget.nomUtilisateur),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(child: _buildStatCard("280+", "Langues", Icons.language)),
        const SizedBox(width: 15),
        Expanded(child: _buildStatCard("1000+", "Leçons", Icons.school)),
        const SizedBox(width: 15),
        Expanded(child: _buildStatCard("500+", "Professeurs", Icons.people)),
      ],
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 30, color: Colors.deepPurple),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "✨ Pourquoi Ma'a yegue ?",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        _buildFeatureItem(
          Icons.verified,
          "Certification officielle",
          "Obtiens des certificats reconnus pour chaque niveau complété",
        ),
        _buildFeatureItem(
          Icons.psychology,
          "IA personnalisée",
          "Assistant intelligent adapté à ton niveau d'apprentissage",
        ),
        _buildFeatureItem(
          Icons.offline_bolt,
          "Mode hors-ligne",
          "Accède aux leçons de base même sans connexion internet",
        ),
        _buildFeatureItem(
          Icons.leaderboard,
          "Suivi de progression",
          "Tableau de bord complet pour suivre tes progrès",
        ),
      ],
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.deepPurple.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.deepPurple, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            gradient: LinearGradient(
              colors: [color.withValues(alpha: 0.7), color],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 40, color: Colors.white),
                const SizedBox(height: 10),
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
