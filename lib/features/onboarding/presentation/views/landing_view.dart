import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../../core/constants/routes.dart';
import '../../../../shared/widgets/forms/custom_button.dart';

/// Landing page for guests/visitors after accepting terms and conditions
class LandingView extends StatefulWidget {
  const LandingView({super.key});

  @override
  State<LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends State<LandingView>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final PageController _pageController = PageController();
  final PageController _updatePageController = PageController();
  int _currentPage = 0;
  int _currentUpdatePage = 0;
  String _appVersion = '1.0.0';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _animationController.forward();
  }

  Future<void> _loadAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      setState(() {
        _appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
      });
    } catch (e) {
      // Keep default version if error
    }
  }

  final List<Map<String, dynamic>> _languages = [
    {
      'name': 'Ewondo',
      'group': 'Beti-Pahuin',
      'region': 'Centre',
      'greeting': 'Mboté!',
      'color': Colors.green,
      'icon': Icons.nature_people,
    },
    {
      'name': 'Duala',
      'group': 'Bantu Côtier',
      'region': 'Littoral',
      'greeting': 'Mboló!',
      'color': Colors.blue,
      'icon': Icons.water,
    },
    {
      'name': 'Bafang',
      'group': 'Grassfields',
      'region': 'Ouest',
      'greeting': 'Mbɔ́tɛ!',
      'color': Colors.orange,
      'icon': Icons.landscape,
    },
    {
      'name': 'Fulfulde',
      'group': 'Niger-Congo',
      'region': 'Nord',
      'greeting': 'Jaaraama!',
      'color': Colors.purple,
      'icon': Icons.pets,
    },
    {
      'name': 'Bassa',
      'group': 'A40 Bantu',
      'region': 'Centre-Littoral',
      'greeting': 'Mbote!',
      'color': Colors.teal,
      'icon': Icons.home,
    },
    {
      'name': 'Bamum',
      'group': 'Grassfields',
      'region': 'Ouest',
      'greeting': 'Ndap!',
      'color': Colors.red,
      'icon': Icons.account_balance,
    },
  ];

  final List<Map<String, dynamic>> _testimonials = [
    {
      'name': 'Marie Nkomo',
      'location': 'Paris, France',
      'language': 'Ewondo',
      'message':
          'Ma’a yegue m\'a permis de reconnecter avec mes racines. Mes enfants parlent maintenant Ewondo !',
      'rating': 5,
      'avatar': Icons.person,
    },
    {
      'name': 'Jean-Pierre Douala',
      'location': 'Toronto, Canada',
      'language': 'Duala',
      'message':
          'Fantastique pour apprendre le Duala. L\'IA s\'adapte parfaitement à mon rythme d\'apprentissage.',
      'rating': 5,
      'avatar': Icons.person_2,
    },
    {
      'name': 'Fatima Adamou',
      'location': 'Berlin, Allemagne',
      'language': 'Fulfulde',
      'message':
          'Enfin une app qui respecte notre culture ! Mon Fulfulde s\'améliore chaque jour.',
      'rating': 5,
      'avatar': Icons.person_3,
    },
  ];

  final List<Map<String, dynamic>> _benefits = [
    {
      'icon': Icons.family_restroom,
      'title': 'Préservation Culturelle',
      'description':
          'Transmettez vos langues ancestrales aux générations futures',
    },
    {
      'icon': Icons.psychology_alt,
      'title': 'IA Personnalisée',
      'description':
          'Apprentissage adaptatif basé sur votre progression et style',
    },
    {
      'icon': Icons.groups,
      'title': 'Communauté Active',
      'description':
          'Connectez-vous avec d\'autres apprenants et locuteurs natifs',
    },
    {
      'icon': Icons.verified,
      'title': 'Contenu Authentique',
      'description': 'Créé avec des experts linguistiques camerounais',
    },
  ];

  final List<Map<String, dynamic>> _recentUpdates = [
    {
      'version': '1.0.0',
      'date': 'Octobre 2025',
      'icon': Icons.rocket_launch,
      'title': 'Lancement Initial',
      'features': [
        '🎉 6 langues camerounaises disponibles',
        '🤖 IA personnalisée pour l\'apprentissage',
        '🎵 Prononciation audio authentique',
        '📚 Plus de 500 leçons interactives',
        '👥 Système de communauté intégré',
      ],
    },
    {
      'version': '1.1.0',
      'date': 'À venir',
      'icon': Icons.update,
      'title': 'Améliorations Prévues',
      'features': [
        '🎮 Mode gamification avancé',
        '📹 Leçons vidéo avec locuteurs natifs',
        '🏆 Système de badges et récompenses',
        '💬 Chat en temps réel avec tuteurs',
        '📊 Analytics de progression détaillés',
      ],
    },
  ];

  final List<Map<String, dynamic>> _appHighlights = [
    {
      'title': 'Interface Intuitive',
      'description': 'Design moderne et facile à utiliser',
      'icon': Icons.touch_app,
      'color': Colors.blue,
    },
    {
      'title': 'Mode Hors Ligne',
      'description': 'Apprenez même sans connexion',
      'icon': Icons.offline_bolt,
      'color': Colors.orange,
    },
    {
      'title': 'Suivi de Progression',
      'description': 'Statistiques détaillées de votre apprentissage',
      'icon': Icons.trending_up,
      'color': Colors.green,
    },
    {
      'title': 'Certificats',
      'description': 'Obtenez des certificats validés',
      'icon': Icons.workspace_premium,
      'color': Colors.purple,
    },
  ];

  @override
  void dispose() {
    _animationController.dispose();
    _pageController.dispose();
    _updatePageController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    context.go(Routes.login);
  }

  void _onRegisterPressed() {
    context.go(Routes.register);
  }

  void _onExploreAsGuest() {
    // Navigate to dashboard with guest mode
    context.go(Routes.dashboard);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Hero Section
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green, Colors.teal],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        // Header
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Column(
                            children: [
                              Icon(
                                Icons.language,
                                size: 80,
                                color: Colors.white,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Ma’a yegue',
                                style: TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Découvrez les langues traditionnelles du Cameroun',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Languages showcase
                        Container(
                          height: 300,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              const Text(
                                'Explorez 6 langues authentiques',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Expanded(
                                child: PageView.builder(
                                  controller: _pageController,
                                  onPageChanged: (index) {
                                    setState(() {
                                      _currentPage = index;
                                    });
                                  },
                                  itemCount: _languages.length,
                                  itemBuilder: (context, index) {
                                    final language = _languages[index];
                                    return _buildLanguageCard(language);
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Page indicator
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  _languages.length,
                                  (index) => Container(
                                    width: 8,
                                    height: 8,
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _currentPage == index
                                          ? Colors.white
                                          : Colors.white54,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),

                // Value Proposition Section
                Container(
                  padding: const EdgeInsets.all(24),
                  color: Colors.white,
                  child: Column(
                    children: [
                      const Text(
                        'Pourquoi choisir Ma’a yegue ?',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'La première plateforme dédiée à la préservation et l\'apprentissage des langues camerounaises',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Benefits Grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _benefits.length,
                        itemBuilder: (context, index) =>
                            _buildBenefitCard(_benefits[index]),
                      ),
                    ],
                  ),
                ),

                // Statistics Section
                Container(
                  padding: const EdgeInsets.all(24),
                  color: Colors.green.shade50,
                  child: Column(
                    children: [
                      const Text(
                        'Rejoignez notre communauté grandissante',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          _buildStatItem('15,000+', 'Utilisateurs actifs'),
                          _buildStatItem('6', 'Langues disponibles'),
                          _buildStatItem('500+', 'Leçons créées'),
                        ],
                      ),
                    ],
                  ),
                ),

                // Culture Module Preview Section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade700, Colors.deepPurple.shade900],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.museum,
                        size: 64,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Découvrez le Module Culture',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Explorez l\'histoire, les traditions et le patrimoine culturel camerounais',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      
                      // Culture Features
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          _buildCultureFeature(Icons.history_edu, 'Histoire Riche'),
                          _buildCultureFeature(Icons.celebration, 'Traditions'),
                          _buildCultureFeature(Icons.music_note, 'Musique & Art'),
                          _buildCultureFeature(Icons.restaurant, 'Gastronomie'),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Explore as Guest Button
                      ElevatedButton.icon(
                        onPressed: () => context.go(Routes.culture),
                        icon: const Icon(Icons.explore, size: 28),
                        label: const Text(
                          'Explorer en tant qu\'Invité',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.deepPurple,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 8,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Aucune inscription requise pour explorer la culture camerounaise',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white70,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // App Highlights Section
                Container(
                  padding: const EdgeInsets.all(24),
                  color: Colors.white,
                  child: Column(
                    children: [
                      const Text(
                        'Fonctionnalités Principales',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 24),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.1,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _appHighlights.length,
                        itemBuilder: (context, index) =>
                            _buildHighlightCard(_appHighlights[index]),
                      ),
                    ],
                  ),
                ),

                // Recent Updates Section
                Container(
                  padding: const EdgeInsets.all(24),
                  color: Colors.green.shade50,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.new_releases, color: Colors.green),
                          const SizedBox(width: 8),
                          const Text(
                            'Nouveautés & Mises à Jour',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 280,
                        child: PageView.builder(
                          controller: _updatePageController,
                          onPageChanged: (index) {
                            setState(() {
                              _currentUpdatePage = index;
                            });
                          },
                          itemCount: _recentUpdates.length,
                          itemBuilder: (context, index) =>
                              _buildUpdateCard(_recentUpdates[index]),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _recentUpdates.length,
                          (index) => Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentUpdatePage == index
                                  ? Colors.green
                                  : Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Testimonials Section
                Container(
                  padding: const EdgeInsets.all(24),
                  color: Colors.white,
                  child: Column(
                    children: [
                      const Text(
                        'Ce que disent nos utilisateurs',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 200,
                        child: PageView.builder(
                          itemCount: _testimonials.length,
                          itemBuilder: (context, index) =>
                              _buildTestimonialCard(_testimonials[index]),
                        ),
                      ),
                    ],
                  ),
                ),

                // CTA Section
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Column(
                    children: [
                      // Features preview
                      Row(
                        children: [
                          _buildFeatureItem(
                              Icons.school, 'Leçons\nInteractives'),
                          _buildFeatureItem(Icons.mic, 'Prononciation\nGuide'),
                          _buildFeatureItem(
                              Icons.psychology, 'IA\nPersonnalisée'),
                          _buildFeatureItem(Icons.groups, 'Communauté\nActive'),
                        ],
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Commencez votre voyage linguistique dès maintenant',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Primary actions
                      CustomButton(
                        text: 'Créer un Compte Gratuit',
                        onPressed: _onRegisterPressed,
                        backgroundColor: Colors.green,
                      ),
                      const SizedBox(height: 12),
                      CustomButton(
                        text: 'Se Connecter',
                        onPressed: _onLoginPressed,
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        isOutlined: true,
                      ),
                      const SizedBox(height: 12),

                      // Guest option
                      TextButton(
                        onPressed: _onExploreAsGuest,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.visibility, color: Colors.grey),
                            SizedBox(width: 8),
                            Text(
                              'Explorer en tant qu\'invité',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Cultural message
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.favorite, color: Colors.green, size: 24),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Préservons ensemble notre héritage linguistique pour les générations futures',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // App Version Footer
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: Colors.grey,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Version $_appVersion',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '© 2025 Ma\'a yegue - Tous droits réservés',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Préservation du patrimoine linguistique camerounais',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageCard(Map<String, dynamic> language) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
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
          Icon(
            language['icon'] as IconData,
            size: 48,
            color: language['color'] as Color,
          ),
          const SizedBox(height: 12),
          Text(
            language['name'] as String,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: language['color'] as Color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${language['group']} • ${language['region']}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: (language['color'] as Color).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              language['greeting'] as String,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: language['color'] as Color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String label) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.green, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitCard(Map<String, dynamic> benefit) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            benefit['icon'] as IconData,
            color: Colors.green,
            size: 32,
          ),
          const SizedBox(height: 12),
          Text(
            benefit['title'] as String,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              benefit['description'] as String,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String number, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            number,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestimonialCard(Map<String, dynamic> testimonial) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(
                  testimonial['avatar'] as IconData,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      testimonial['name'] as String,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      '${testimonial['location']} • ${testimonial['language']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  testimonial['rating'] as int,
                  (index) => const Icon(
                    Icons.star,
                    color: Colors.orange,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            testimonial['message'] as String,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.green,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightCard(Map<String, dynamic> highlight) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (highlight['color'] as Color).withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            highlight['icon'] as IconData,
            color: highlight['color'] as Color,
            size: 40,
          ),
          const SizedBox(height: 12),
          Text(
            highlight['title'] as String,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: highlight['color'] as Color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            highlight['description'] as String,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateCard(Map<String, dynamic> update) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.3), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  update['icon'] as IconData,
                  color: Colors.green,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      update['title'] as String,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Text(
                      'Version ${update['version']} • ${update['date']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: (update['features'] as List).length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    (update['features'] as List)[index],
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      height: 1.4,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCultureFeature(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
