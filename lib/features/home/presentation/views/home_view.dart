import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../profile/presentation/views/profile_view.dart';

class HomePage extends StatefulWidget {
  final String nomUtilisateur;

  const HomePage({super.key, required this.nomUtilisateur});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentCarouselIndex = 0;

  final List<Map<String, String>> _carouselItems = [
    {
      'image': 'https://images.unsplash.com/photo-1552664730-d307ca884978',
      'title': 'Apprends les langues du Cameroun',
      'subtitle': 'Plus de 280 langues traditionnelles à découvrir'
    },
    {
      'image': 'https://images.unsplash.com/photo-1503676260728-1c00da094a0b',
      'title': 'Cours interactifs avec des experts',
      'subtitle': 'Professeurs natifs certifiés'
    },
    {
      'image': 'https://images.unsplash.com/photo-1509062522246-3755977927d7',
      'title': 'Obtiens ton certificat',
      'subtitle': 'Certifications reconnues à chaque niveau'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Ma'a yegue"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: SingleChildScrollView(
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
                  // Welcome Message
                  Container(
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
                    child: Text(
                      "👋 Bienvenue ${widget.nomUtilisateur} !\nApprends et redécouvre les langues maternelles du Cameroun 🇨🇲",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Stats Section
                  _buildStatsSection(),
                  
                  const SizedBox(height: 30),
                  
                  const Text(
                    "📚 Accès rapide",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),
                  
                  // Quick Access Grid
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    children: [
                      _buildCard(context, Icons.menu_book, "Catalogue", Colors.blue, () {}),
                      _buildCard(context, Icons.task, "Tâches", Colors.orange, () {}),
                      _buildCard(context, Icons.chat, "Chat IA", Colors.green, () {}),
                      _buildCard(context, Icons.person, "Profil", Colors.purple, () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ProfilPage(nomUtilisateur: widget.nomUtilisateur),
                          ),
                        );
                      }),
                    ],
                  ),
                  
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

  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard("280+", "Langues", Icons.language),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatCard("1000+", "Leçons", Icons.school),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatCard("500+", "Professeurs", Icons.people),
        ),
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
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
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
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
      BuildContext context, IconData icon, String label, Color color, VoidCallback onTap) {
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
