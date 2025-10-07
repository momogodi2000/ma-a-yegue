# Documentation des Fonctionnalités - Ma'a yegue App

## Vue d'Ensemble

L'application Ma'a yegue propose un écosystème complet d'apprentissage des langues camerounaises, organisé autour de **25+ modules fonctionnels** intégrés. Chaque fonctionnalité est conçue pour offrir une expérience utilisateur fluide et pédagogique, avec support pour **22 langues camerounaises** et un système éducatif complet.

## 👤 1. Authentification (`features/authentication/`)

### Description
Système d'authentification multi-fournisseurs permettant une connexion sécurisée et flexible.

### Fonctionnalités
- **Connexion multi-méthodes** : Email/Mot de passe, Google, Facebook, numéro de téléphone (SMS)
- **Inscription guidée** : Processus d'onboarding avec validation des informations
- **Récupération de mot de passe** : Réinitialisation sécurisée via email
- **Gestion des rôles** : 12 rôles utilisateurs (Visitor, Student, Parent, Teacher, Substitute Teacher, Educational Counselor, Vice Director, School Director, Inspector, MINEDUC Official, Admin, Super Admin)
- **Hiérarchie 10 niveaux** : Permissions granulaires basées sur les niveaux
- **Double authentification (2FA)** : Sécurité renforcée pour comptes sensibles
- **Gestion de session** : Tokens JWT avec expiration automatique

### Architecture
```
authentication/
├── data/
│   ├── datasources/
│   │   ├── auth_remote_datasource.dart    # Firebase Auth
│   │   └── user_local_datasource.dart     # Cache local
│   ├── models/
│   │   ├── user_model.dart                # Modèle utilisateur
│   │   └── auth_response.dart             # Réponses auth
│   └── repositories/
│       └── auth_repository_impl.dart      # Implémentation
├── domain/
│   ├── entities/
│   │   └── user.dart                      # Entité User
│   ├── repositories/
│   │   └── auth_repository.dart           # Interface
│   └── usecases/
│       ├── login_usecase.dart             # Cas d'usage connexion
│       ├── register_usecase.dart          # Cas d'usage inscription
│       └── logout_usecase.dart            # Cas d'usage déconnexion
└── presentation/
    ├── viewmodels/
    │   └── auth_viewmodel.dart            # Gestion état auth
    ├── views/
    │   ├── login_view.dart                # Vue connexion
    │   ├── register_view.dart             # Vue inscription
    │   ├── forgot_password_view.dart      # Vue mot de passe oublié
    │   └── phone_auth_view.dart           # Vue auth téléphone
    └── widgets/
        ├── auth_form.dart                 # Formulaire réutilisable
        └── social_login_buttons.dart      # Boutons réseaux sociaux
```

### Flux Utilisateur
1. **Splash Screen** → Vérification état authentification
2. **Connexion/Inscription** → Validation credentials
3. **Onboarding** → Configuration profil utilisateur
4. **Redirection rôle** → Dashboard approprié

## 📚 2. Leçons (`features/lessons/`)

### Description
Système de cours structuré offrant un apprentissage progressif des langues camerounaises.

### Fonctionnalités
- **Cours organisés** : Structure hiérarchique (Module → Chapitre → Leçon)
- **Contenu multimédia** : Texte, audio, vidéo, images
- **Exercices interactifs** : QCM, saisie texte, reconnaissance vocale
- **Progression personnalisée** : Adaptation au niveau de l'apprenant
- **Mode hors ligne** : Téléchargement des leçons

### Types de Contenu
- **Leçons théoriques** : Vocabulaire, grammaire, culture
- **Exercices pratiques** : Traduction, conjugaison, prononciation
- **Contenu culturel** : Histoires, proverbes, traditions
- **Évaluations** : Tests de validation des acquis

### Modèle de Données
```dart
class Lesson {
  final String id;
  final String title;
  final String description;
  final String languageId;
  final int level; // 1-10
  final List<ContentBlock> content;
  final List<Exercise> exercises;
  final Duration estimatedDuration;
  final bool isDownloaded;
}

class ContentBlock {
  final ContentType type; // text, audio, video, image
  final String content;
  final String? mediaUrl;
  final Map<String, dynamic> metadata;
}
```

## 📖 3. Dictionnaire (`features/dictionary/`)

### Description
Dictionnaire intelligent avec recherche avancée et prononciation guidée.

### Fonctionnalités
- **Recherche intelligente** : Recherche par mot, traduction, catégorie
- **Prononciation IPA** : Transcription phonétique internationale
- **Exemples contextuels** : Phrases d'usage avec traduction
- **Favoris personnels** : Mots sauvegardés pour révision
- **Suggestions automatiques** : Autocomplétion lors de la saisie

### Structure des Entrées
```dart
class DictionaryEntry {
  final String id;
  final String word;
  final String translation;
  final String languageId;
  final String ipaPronunciation;
  final List<String> examples;
  final String category; // nom, verbe, adjectif, etc.
  final int difficulty; // 1-5
  final String? audioUrl;
  final Map<String, dynamic> culturalContext;
}
```

### Fonctionnalités Avancées
- **Recherche floue** : Tolérance aux fautes de frappe
- **Filtrage par langue** : Recherche dans une langue spécifique
- **Historique** : Mots récemment consultés
- **Statistiques** : Mots les plus recherchés

## 🤖 4. Intelligence Artificielle (`features/ai/`)

### Description
Assistant IA complet utilisant **Google Gemini AI** spécialisé dans l'apprentissage des langues camerounaises.

### Fonctionnalités Principales
- **Chat Conversationnel** : Conversations en temps réel en français et langues camerounaises
- **Traduction Contextuelle** : Traduction intelligente entre français et 22 langues locales
- **Évaluation de Prononciation** : Analyse audio et feedback détaillé
- **Génération de Contenu** : Création automatique de leçons, exercices et quiz
- **Recommandations Personnalisées** : Suggestions basées sur progression utilisateur
- **Analyse de Progression** : Évaluation IA des performances et points d'amélioration

### Services IA Disponibles
```dart
abstract class AiRepository {
  // Chat conversationnel
  Future<AiResponseEntity> sendMessage({
    required String conversationId,
    required String message,
    required String userId,
  });

  // Traduction avec contexte
  Future<TranslationEntity> translateText({
    required String sourceText,
    required String sourceLanguage,
    required String targetLanguage,
  });

  // Évaluation prononciation
  Future<PronunciationAssessmentEntity> assessPronunciation({
    required String word,
    required String language,
    required String audioUrl,
  });

  // Génération de contenu pédagogique
  Future<ContentGenerationEntity> generateContent({
    required String type,
    required String topic,
    required String language,
    required String difficulty,
  });

  // Recommandations personnalisées
  Future<List<AiLearningRecommendationEntity>> getPersonalizedRecommendations(
    String userId
  );

  // Analyse de progression
  Future<ProgressAnalysisEntity> analyzeUserProgress({
    required String userId,
    required String language,
    required String timeRange,
  });
}
```

### Interfaces Utilisateur
- **Tab Chat** : Conversation avec l'assistant IA
- **Tab Traduction** : Interface de traduction rapide
- **Tab Prononciation** : Enregistrement et évaluation vocale
- **Tab Génération** : Création de contenu personnalisé
- **Tab Recommandations** : Suggestions d'apprentissage

### Cas d'Usage
- **Tuteur Personnel** : Réponses aux questions sur grammaire et vocabulaire
- **Exercices Dynamiques** : Génération d'exercices adaptés au niveau
- **Coach de Prononciation** : Feedback immédiat sur la prononciation
- **Traducteur Culturel** : Traductions contextuelles avec notes culturelles
- **Planification d'Apprentissage** : Recommandations de parcours personnalisés

## 💳 5. Paiements (`features/payment/`)

### Description
Système de monétisation avec intégration de passerelles de paiement camerounaises.

### Fonctionnalités
- **Abonnements flexibles** : Freemium, Premium mensuel/annuel
- **Paiements multiples** : CamPay (MTN, Orange), NouPai
- **Historique transparent** : Suivi des transactions
- **Remboursements** : Gestion des annulations
- **Facturation automatique** : Renouvellement des abonnements

### Plans d'Abonnement
```dart
enum SubscriptionPlan {
  free,        // Accès limité, contenu de base
  premium,     // Accès complet, sans publicité
  teacher,     // Outils pédagogiques avancés
  school,      // Licence multi-utilisateurs pour établissements
  lifetime,    // Accès perpétuel unique
}
```

### Méthodes de Paiement Supportées
- **CamPay** : MTN Mobile Money, Orange Money (XAF)
- **NouPai** : Alternative Mobile Money camerounaise
- **Stripe** : Cartes bancaires internationales (Visa, MasterCard)

### Fonctionnalités de Sécurité
- Validation webhook pour vérification des paiements
- Chiffrement des données de transaction
- Historique détaillé avec références de transaction
- Système de remboursement automatisé

### Intégration CamPay
```dart
class CamPayService {
  Future<PaymentResponse> initiatePayment({
    required double amount,
    required String currency,
    required String description,
    required String userPhone,
  });

  Future<PaymentStatus> checkPaymentStatus(String transactionId);

  Future<void> processRefund(String transactionId, double amount);
}
```

## 🎮 6. Gamification (`features/gamification/`)

### Description
Système de récompenses et motivation pour encourager l'apprentissage continu.

### Fonctionnalités
- **Badges progressifs** : 8 niveaux de maîtrise
- **Points d'expérience** : Système de scoring
- **Classements** : Compétition sociale
- **Défis quotidiens** : Objectifs journaliers
- **Réalisations culturelles** : Succès spécifiques au Cameroun

### Système de Badges
```dart
class Badge {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final BadgeRarity rarity; // common, rare, epic, legendary
  final Map<String, dynamic> criteria;
}

enum BadgeRarity {
  common,    // Accessible
  rare,      // Difficile
  epic,      // Très difficile
  legendary, // Exceptionnel
}
```

### Réalisations Camerounaises
- **"Premier Pas"** : Première leçon complétée
- **"Langue Maternelle"** : Maîtrise d'une langue
- **"Ambassadeur"** : Partage avec 10 amis
- **"Sage"** : 1000 mots appris
- **"Trésor National"** : Contribution culturelle

## 🌐 7. Communauté (`features/community/`)

### Description
Plateforme sociale pour connecter les apprenants et partager les connaissances.

### Fonctionnalités
- **Forums thématiques** : Discussion par langue et sujet
- **Système de mentorat** : Connexion enseignants-élèves
- **Profils utilisateurs** : Présentation des progrès et spécialités
- **Événements communautaires** : Challenges collectifs
- **Modération** : Système de signalement et validation

### Structure Sociale
```dart
class CommunityPost {
  final String id;
  final String authorId;
  final String title;
  final String content;
  final String languageId;
  final PostType type; // question, discussion, resource
  final List<String> tags;
  final DateTime createdAt;
  final int likesCount;
  final int repliesCount;
}

class Mentorship {
  final String mentorId;
  final String menteeId;
  final String languageId;
  final MentorshipStatus status;
  final List<Session> sessions;
}
```

## 📊 8. Tableaux de Bord (`features/dashboard/`)

### Description
Interfaces personnalisées selon le rôle de l'utilisateur.

### Tableaux de Bord par Rôle

#### Apprenant (`LearnerDashboard`)
- **Progression globale** : Graphiques d'avancement
- **Leçons recommandées** : Suggestions IA
- **Statistiques personnelles** : Temps passé, mots appris
- **Objectifs quotidiens** : Challenges du jour
- **Badges récents** : Réalisations débloquées

#### Enseignant (`TeacherDashboard`)
- **Gestion des élèves** : Suivi des progrès
- **Création de contenu** : Outils pédagogiques
- **Analytics de classe** : Statistiques collectives
- **Communication** : Messagerie avec élèves
- **Évaluations** : Création et correction de tests

#### Administrateur (`AdminDashboard`)
- **Métriques globales** : Utilisation de l'app
- **Gestion utilisateurs** : Modération et support
- **Configuration système** : Paramètres globaux
- **Analytics financiers** : Revenus et abonnements
- **Maintenance** : Logs et monitoring

## 🎯 9. Évaluation (`features/assessment/`)

### Description
Système d'évaluation pour mesurer les progrès et valider les acquis.

### Types d'Évaluations
- **Tests de positionnement** : Évaluation du niveau initial
- **Évaluations formatives** : Exercices pendant l'apprentissage
- **Tests sommative** : Validation de fin de module
- **Évaluations certificatives** : Attestation de compétence

### Moteur d'Évaluation
```dart
class AssessmentEngine {
  Future<AssessmentResult> evaluate({
    required Assessment assessment,
    required Map<String, dynamic> answers,
    required User user,
  });

  Future<List<Question>> generateAdaptiveQuestions({
    required String languageId,
    required int userLevel,
    required AssessmentType type,
  });
}

class AssessmentResult {
  final double score;
  final int correctAnswers;
  final int totalQuestions;
  final Duration timeSpent;
  final List<Feedback> detailedFeedback;
  final Recommendation nextSteps;
}
```

## 🎵 10. Jeux (`features/games/`)

### Description
Jeux éducatifs pour rendre l'apprentissage ludique et engageant.

### Jeux Disponibles
- **Memory Game** : Association mots-images
- **Word Puzzle** : Rébus et charades
- **Pronunciation Challenge** : Duel de prononciation
- **Culture Quiz** : Quiz sur la culture camerounaise
- **Speed Translation** : Traduction chronométrée

### Architecture Jeu
```dart
abstract class Game {
  final String id;
  final String name;
  final String description;
  final GameDifficulty difficulty;
  final int pointsReward;

  Future<GameResult> play(BuildContext context);
}

class GameResult {
  final bool completed;
  final int score;
  final Duration timeSpent;
  final List<Achievement> unlockedAchievements;
}
```

## 🌍 11. Langues (`features/languages/`)

### Description
Gestion et présentation des langues camerounaises disponibles.

### Langues Supportées
```dart
const languages = [
  {
    'id': 'ewondo',
    'name': 'Ewondo',
    'region': 'Centre',
    'speakers': '500,000+',
    'difficulty': 'Intermédiaire',
    'flag': '🇨🇲',
  },
  {
    'id': 'duala',
    'name': 'Duala',
    'region': 'Littoral',
    'speakers': '200,000+',
    'difficulty': 'Avancé',
    'flag': '🇨🇲',
  },
  // ... autres langues
];
```

### Fonctionnalités
- **Présentation culturelle** : Histoire et contexte de chaque langue
- **Statistiques communautaires** : Nombre d'apprenants actifs
- **Ressources disponibles** : Leçons, dictionnaire, contenu
- **Niveau de difficulté** : Évaluation subjective de complexité

## 🏠 12. Accueil (`features/home/`)

### Description
Page d'accueil personnalisée avec recommandations et actualités.

### Sections
- **Continuer l'apprentissage** : Reprise de la dernière leçon
- **Recommandations IA** : Contenu personnalisé
- **Défis quotidiens** : Objectifs du jour
- **Actualités communautaires** : Événements récents
- **Statistiques rapides** : Progrès du jour

## 👤 13. Profil (`features/profile/`)

### Description
Gestion complète du profil utilisateur et des préférences.

### Fonctionnalités
- **Informations personnelles** : Édition du profil
- **Préférences d'apprentissage** : Langues, niveau, objectifs
- **Historique d'apprentissage** : Suivi détaillé des progrès
- **Certificats** : Attestations de compétence
- **Paramètres de confidentialité** : Contrôle des données

## 📱 14. Ressources (`features/resources/`)

### Description
Bibliothèque de ressources pédagogiques supplémentaires.

### Types de Ressources
- **Documents PDF** : Guides grammaticaux, vocabulaires
- **Vidéos culturelles** : Documentaires, témoignages
- **Audio** : Enregistrements natifs, podcasts
- **Liens externes** : Ressources web validées
- **Outils pédagogiques** : Générateurs d'exercices

## 🔄 15. Traduction (`features/translation/`)

### Description
Outil de traduction intégré avec historique et favoris.

### Fonctionnalités
- **Traduction temps réel** : Interface de saisie instantanée
- **Historique** : Traductions précédentes sauvegardées
- **Favoris** : Traductions fréquemment utilisées
- **Correction IA** : Suggestions d'amélioration
- **Modes** : Texte, voix, image (futur)

## 🔗 Intégrations Inter-Modules

### Flux de Données
- **Authentification** → **Tous les modules** : Vérification d'accès
- **Leçons** → **Gamification** : Attribution de points
- **Dictionnaire** → **IA** : Enrichissement du contexte
- **Paiements** → **Tous les modules** : Contrôle d'accès premium
- **Communauté** → **Profil** : Mise à jour des statistiques sociales

### Événements Globaux
- **Achievement Unlocked** : Notification push + badge dans le profil
- **Lesson Completed** : Mise à jour progression + recommandations
- **Payment Success** : Activation fonctionnalités premium
- **New Content Available** : Notifications aux abonnés

Cette architecture modulaire assure une cohérence fonctionnelle tout en permettant une évolution indépendante de chaque feature.