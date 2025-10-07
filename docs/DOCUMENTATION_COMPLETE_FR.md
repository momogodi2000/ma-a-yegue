# 📚 Documentation Complète - Ma'a yegue

**Application Mobile d'Apprentissage des Langues Camerounaises**

---

## 📖 Table des Matières

1. [Vue d'Ensemble](#vue-densemble)
2. [Installation et Configuration](#installation-et-configuration)
3. [Architecture Technique](#architecture-technique)
4. [Modules Fonctionnels](#modules-fonctionnels)
5. [Guide Développeur](#guide-développeur)
6. [Guide Utilisateur](#guide-utilisateur)
7. [Déploiement](#déploiement)
8. [Maintenance](#maintenance)

---

## 🎯 Vue d'Ensemble

### Description

**Ma'a yegue** (signifiant "Nos langues" en Ewondo) est une application mobile innovante dédiée à l'apprentissage et à la préservation des langues traditionnelles camerounaises. L'application offre une expérience d'apprentissage complète avec 22 langues camerounaises, alimentée par l'intelligence artificielle et une approche pédagogique moderne.

### Objectifs Principaux

1. **Préserver** les langues camerounaises menacées de disparition
2. **Faciliter** l'apprentissage des langues maternelles
3. **Connecter** les communautés linguistiques
4. **Promouvoir** la culture camerounaise

### Public Cible

- 🎓 **Apprenants** : Camerounais souhaitant apprendre leur langue maternelle
- 👨‍🏫 **Enseignants** : Professeurs de langues traditionnelles
- 🌍 **Diaspora** : Camerounais à l'étranger
- 📚 **Chercheurs** : Linguistes et anthropologues
- 🏛️ **Institutions** : Écoles et universités

---

## 🚀 Installation et Configuration

### Prérequis

```yaml
Flutter SDK: ≥3.5.0 <4.0.0
Dart SDK: ≥3.5.0 <4.0.0
Android: API 21+ (Android 5.0+)
iOS: 12.0+
Web: Chrome, Firefox, Safari (latest)
```

### Technologies Principales

- **Framework** : Flutter 3.5+ / Dart 3.5+
- **Architecture** : Clean Architecture + MVVM
- **State Management** : Provider
- **Backend** : Firebase Suite (Auth, Firestore, Storage, Analytics, Crashlytics, Messaging, Performance, Functions)
- **AI** : Google Gemini AI
- **Database Local** : SQLite + Hive
- **Paiements** : CamPay, NouPai, Stripe
- **Navigation** : GoRouter

### Installation

```bash
# 1. Cloner le repository
git clone https://github.com/votre-repo/mayegue-mobile.git
cd mayegue-mobile

# 2. Installer les dépendances
flutter pub get

# 3. Configurer Firebase
# Placer google-services.json dans android/app/
# Placer GoogleService-Info.plist dans ios/Runner/

# 4. Configurer les variables d'environnement
cp .env.example .env
# Éditer .env avec vos clés API

# 5. Lancer l'application
flutter run
```

### Configuration Firebase

#### 1. Créer un projet Firebase

1. Aller sur [Firebase Console](https://console.firebase.google.com/)
2. Créer un nouveau projet
3. Ajouter des applications Android et iOS

#### 2. Activer les services

- ✅ Authentication (Email, Google, Facebook, Phone)
- ✅ Cloud Firestore
- ✅ Firebase Storage
- ✅ Cloud Functions
- ✅ Analytics
- ✅ Crashlytics
- ✅ Performance Monitoring

#### 3. Configuration Firestore

```javascript
// Règles de sécurité Firestore (firestore.rules)
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Règles d'authentification
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Règles pour les cours
    match /courses/{courseId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role in ['teacher', 'admin'];
    }
    
    // Autres règles...
  }
}
```

### Configuration des Paiements

#### CamPay

```dart
// Obtenir une clé API sur https://campay.com
CAMPAY_API_KEY=votre_cle_api
CAMPAY_USERNAME=votre_username
CAMPAY_PASSWORD=votre_password
```

#### NouPay

```dart
NOUPAY_API_KEY=votre_cle_api
NOUPAY_MERCHANT_ID=votre_merchant_id
```

#### Stripe

```dart
STRIPE_PUBLISHABLE_KEY=pk_live_xxx
STRIPE_SECRET_KEY=sk_live_xxx
```

### Configuration Google Gemini AI

```env
GEMINI_API_KEY=votre_cle_api_gemini
```

**Obtenir une clé sur** : [Google AI Studio](https://makersuite.google.com/app/apikey)

**Fonctionnalités IA activées** :
- Chat conversationnel multilingue
- Traduction contextuelle (22 langues camerounaises)
- Évaluation de prononciation
- Génération de contenu pédagogique
- Recommandations personnalisées
- Analyse de progression

**Configuration dans l'app** :
```dart
// lib/core/services/ai_service.dart
final geminiService = GeminiAIService(
  dioClient,
  dotenv.env['GEMINI_API_KEY']!,
);
```

---

## 🏗️ Architecture Technique

### Principes Architecturaux

L'application suit les principes de **Clean Architecture** combinés au pattern **MVVM (Model-View-ViewModel)**.

```
┌─────────────────────────────────────────┐
│     PRESENTATION (Views + ViewModels)   │
│     - Widgets Flutter                   │
│     - State Management (Provider)       │
├─────────────────────────────────────────┤
│     DOMAIN (Business Logic)             │
│     - Entities                          │
│     - Use Cases                         │
│     - Repository Interfaces             │
├─────────────────────────────────────────┤
│     DATA (Data Management)              │
│     - Repository Implementations        │
│     - Data Sources (Remote + Local)     │
│     - Models                            │
├─────────────────────────────────────────┤
│     INFRASTRUCTURE                      │
│     - Firebase                          │
│     - SQLite                            │
│     - APIs externes                     │
└─────────────────────────────────────────┘
```

### Structure des Dossiers

```
lib/
├── core/                       # Noyau application
│   ├── config/                # Configuration
│   ├── constants/             # Constantes
│   ├── database/              # Base de données locale
│   ├── error_handling/        # Gestion erreurs
│   ├── network/               # Services réseau
│   ├── services/              # Services partagés
│   └── router.dart            # Navigation
│
├── features/                   # Modules fonctionnels
│   ├── authentication/        # Authentification
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── viewmodels/
│   │       └── views/
│   │
│   ├── lessons/              # Système de leçons
│   ├── dictionary/           # Dictionnaire
│   ├── quiz/                 # Quiz et évaluations
│   ├── payment/              # Paiements
│   ├── ai/                   # Intelligence artificielle
│   ├── gamification/         # Gamification
│   ├── community/            # Communauté
│   └── [20+ autres modules]
│
├── shared/                    # Composants partagés
│   ├── widgets/              # Widgets réutilisables
│   ├── themes/               # Thèmes UI
│   └── providers/            # Providers globaux
│
└── main.dart                 # Point d'entrée
```

### Technologies Utilisées

#### Frontend
- **Flutter** 3.5.0+ - Framework UI
- **Provider** - State Management
- **GoRouter** - Navigation
- **Material Design 3** - Design System

#### Backend & Services
- **Firebase Authentication** - Authentification
- **Cloud Firestore** - Base de données NoSQL
- **Firebase Storage** - Stockage fichiers
- **Cloud Functions** - Fonctions serverless
- **SQLite** - Base de données locale

#### Intelligence Artificielle
- **Google Gemini AI** - Chat, traduction, génération contenu
- **Speech Recognition** - Reconnaissance vocale
- **Text-to-Speech** - Synthèse vocale

#### Paiements
- **CamPay** - Mobile Money (Orange, MTN)
- **NouPay** - Paiements locaux
- **Stripe** - Cartes bancaires internationales

#### Analytics & Monitoring
- **Firebase Analytics** - Analyse comportement
- **Crashlytics** - Rapports de crash
- **Performance Monitoring** - Performance app

---

## 📦 Modules Fonctionnels

### 1. Authentication (Authentification)

#### Fonctionnalités

- ✅ Inscription/Connexion Email
- ✅ Connexion Google
- ✅ Connexion Facebook
- ✅ Connexion Apple
- ✅ Authentification téléphone (SMS)
- ✅ Two-Factor Authentication (2FA)
- ✅ Réinitialisation mot de passe
- ✅ Gestion des rôles (Learner, Teacher, Admin)

#### Utilisation

```dart
// Connexion
final authViewModel = context.read<AuthViewModel>();
await authViewModel.signInWithEmailAndPassword(email, password);

// Inscription
await authViewModel.signUpWithEmailAndPassword(email, password, name);

// Connexion Google
await authViewModel.signInWithGoogle();

// Déconnexion
await authViewModel.signOut();
```

### 2. Lessons (Leçons)

#### Fonctionnalités

- ✅ Cours structurés par niveau
- ✅ Leçons interactives
- ✅ Contenus multimédia (vidéo, audio, images)
- ✅ Progression automatique
- ✅ Système de niveaux (A1 à C2)
- ✅ Recommandations personnalisées
- ✅ Mode offline

#### Structure Cours

```
Cours
├── Niveau Débutant (A1-A2)
│   ├── Module 1: Alphabet et prononciation
│   ├── Module 2: Salutations basiques
│   └── Module 3: Nombres et temps
├── Niveau Intermédiaire (B1-B2)
│   ├── Module 4: Conversations quotidiennes
│   ├── Module 5: Grammaire avancée
│   └── Module 6: Expression culturelle
└── Niveau Avancé (C1-C2)
    ├── Module 7: Littérature traditionnelle
    ├── Module 8: Dialectes régionaux
    └── Module 9: Maîtrise linguistique
```

### 3. Dictionary (Dictionnaire)

#### Fonctionnalités

- ✅ 4000+ mots dans 22 langues
- ✅ Recherche instantanée
- ✅ Prononciation audio
- ✅ Exemples de phrases
- ✅ Traductions multiples
- ✅ Favoris et historique
- ✅ Mode offline
- ✅ Contribution communautaire

#### Langues Disponibles

1. Ewondo
2. Duala
3. Bamileke (Fe'efe'e)
4. Fulfulde
5. Bassa
6. Bakweri
7. Hausa
8. Kanuri
9. Bafia
10. Baka
11. Banganté
12. Bandé
13. Yemba
14. Bamoun
15. Ngemba
16. Bafut
17. Kom
18. Meta'
19. Mbum
20. Tupuri
21. Guiziga
22. Mafa

### 4. Quiz & Assessment (Quiz et Évaluations)

#### Types de Questions

- **QCM** - Questions à choix multiples
- **Vrai/Faux** - Questions binaires
- **Réponse courte** - Texte libre
- **Audio** - Reconnaissance vocale
- **Image** - Association image-mot

#### Système de Scoring

```
Score = (Réponses correctes / Total questions) × 100
Temps bonus = max(0, (Temps alloué - Temps utilisé) × 0.5)
Score final = Score + Temps bonus
```

### 5. Payment (Paiements)

#### Plans d'Abonnement

##### Plan Gratuit (Free)
- **Prix :** 0 XAF
- **Durée :** Illimité
- **Inclus :**
  - 3 langues au choix
  - Leçons de base (niveau A1)
  - Dictionnaire limité (500 mots)
  - Accès communauté

##### Plan Premium
- **Prix :** 2,000 XAF/mois ou 20,000 XAF/an
- **Inclus :**
  - Toutes les 22 langues
  - Tous les niveaux (A1-C2)
  - Dictionnaire complet (4000+ mots)
  - Exercices illimités
  - Téléchargement offline
  - Support prioritaire

##### Plan Pro
- **Prix :** 5,000 XAF/mois ou 50,000 XAF/an
- **Inclus :**
  - Tout du Premium +
  - Assistant IA illimité
  - Cours avec enseignant
  - Certificats officiels
  - Contenu exclusif
  - Pas de publicité

#### Méthodes de Paiement

##### 1. Mobile Money (CamPay)
- Orange Money
- MTN Mobile Money
- Express Union Mobile

##### 2. Paiements Locaux (NouPay)
- Virements bancaires locaux
- Points de paiement physiques

##### 3. International (Stripe)
- Visa, Mastercard
- American Express

### 6. AI Integration (Intelligence Artificielle)

#### Fonctionnalités IA

##### 1. Chat Conversationnel
```dart
// Exemple d'utilisation
final aiService = context.read<GeminiAIService>();
final response = await aiService.chat(
  "Comment dit-on 'bonjour' en Ewondo?",
  languageCode: 'ewo',
);
```

##### 2. Traduction Intelligente
- Traduction contextuelle
- Détection automatique de la langue
- Suggestions alternatives
- Conservation du contexte culturel

##### 3. Évaluation Prononciation
- Analyse audio en temps réel
- Score de précision (0-100)
- Feedback correctif détaillé
- Comparaison avec natifs

##### 4. Génération de Contenu
- Exercices personnalisés selon niveau
- Leçons adaptatives
- Quiz automatiques thématiques
- Histoires culturelles

##### 5. Recommandations Personnalisées
- Parcours d'apprentissage optimal
- Contenu basé sur intérêts
- Correction des faiblesses
- Objectifs adaptatifs

### 7. Gamification

#### Système de Points

```
Action                          Points
────────────────────────────────────────
Leçon complétée                 +50 XP
Quiz réussi (>80%)             +100 XP
Série de 7 jours               +200 XP
Contribution dictionnaire       +30 XP
Aide communauté                 +20 XP
Niveau complété               +1000 XP
```

#### Badges

##### Badges de Progression
- 🏅 **Débutant** - Première leçon
- 🥉 **Apprenti** - 10 leçons
- 🥈 **Initié** - 50 leçons
- 🥇 **Expert** - 100 leçons
- 👑 **Maître** - Tous les niveaux

##### Badges Spéciaux
- 🔥 **Série de feu** - 30 jours consécutifs
- 🌟 **Perfectionniste** - 10 quiz à 100%
- 🦸 **Contributeur** - 100 contributions
- 🎯 **Précis** - 95% de précision moyenne

#### Classements (Leaderboards)

- **Global** - Top 100 mondial
- **Pays** - Top 50 Cameroun
- **Langue** - Top 20 par langue
- **Amis** - Classement personnel

### 8. Community (Communauté)

#### Forums

- **Forum général** - Discussions générales
- **Forum par langue** - Discussions spécifiques
- **Aide & Questions** - Support communautaire
- **Partage de ressources** - Contenu partagé

#### Groupes d'Étude

- Création de groupes privés/publics
- Chat de groupe
- Partage de progression
- Défis de groupe
- Sessions d'étude planifiées

#### Messagerie

- Messages privés
- Chat en temps réel
- Partage de fichiers
- Appels audio/vidéo (futur)

### 9. Culture

#### Contenu Culturel

- **Contes traditionnels** - Histoires audio/texte
- **Proverbes** - Sagesse populaire
- **Chansons** - Musique traditionnelle
- **Recettes** - Cuisine camerounaise
- **Artisanat** - Techniques traditionnelles
- **Festivals** - Événements culturels

### 10. Certificates (Certificats)

#### Types de Certificats

##### Certificat de Complétion
- Délivré automatiquement
- Gratuit
- Format PDF
- Partage social

##### Certificat Officiel
- Validation par enseignant
- Payant (2,000 XAF)
- Reconnaissance officielle
- QR Code de vérification
- Apostille possible

---

## 👨‍💻 Guide Développeur

### Contribuer au Projet

#### 1. Fork et Clone

```bash
git clone https://github.com/votre-username/mayegue-mobile.git
cd mayegue-mobile
git remote add upstream https://github.com/original/mayegue-mobile.git
```

#### 2. Créer une Branche

```bash
git checkout -b feature/nom-fonctionnalite
```

#### 3. Standards de Code

##### Naming Conventions

```dart
// Classes - PascalCase
class AuthViewModel extends ChangeNotifier {}

// Variables - camelCase
final authViewModel = context.read<AuthViewModel>();

// Constantes - lowerCamelCase ou UPPER_CASE
const int maxRetries = 3;
const String API_KEY = 'xxx';

// Fichiers - snake_case
auth_view_model.dart
user_repository_impl.dart
```

##### Code Style

```dart
// Utiliser const quand possible
const Text('Hello')

// Préférer final pour variables non modifiées
final name = 'John';

// Documentation des classes publiques
/// Service d'authentification utilisateur
class AuthService {}

// Gestion d'erreurs explicite
try {
  await api.call();
} on NetworkException {
  // Gérer erreur réseau
} catch (e) {
  debugPrint('Erreur: $e');
}
```

#### 4. Tests

```dart
// Test unitaire
test('Login should return user on success', () async {
  final result = await loginUsecase(email, password);
  expect(result.isRight(), true);
});

// Test widget
testWidgets('Login button should be visible', (tester) async {
  await tester.pumpWidget(MyApp());
  expect(find.text('Login'), findsOneWidget);
});
```

#### 5. Commit Messages

```
type(scope): description

Types:
- feat: Nouvelle fonctionnalité
- fix: Correction de bug
- docs: Documentation
- style: Formatage
- refactor: Refactoring
- test: Tests
- chore: Maintenance

Exemples:
feat(auth): add Google sign-in
fix(lesson): correct progress calculation
docs(readme): update installation steps
```

### Architecture des Modules

#### Créer un Nouveau Module

```bash
mkdir -p lib/features/mon_module/{data,domain,presentation}
mkdir -p lib/features/mon_module/data/{datasources,models,repositories}
mkdir -p lib/features/mon_module/domain/{entities,repositories,usecases}
mkdir -p lib/features/mon_module/presentation/{viewmodels,views,widgets}
```

#### Template de Module

```dart
// Entity (domain/entities/)
class MyEntity {
  final String id;
  final String name;
  
  MyEntity({required this.id, required this.name});
}

// Repository Interface (domain/repositories/)
abstract class MyRepository {
  Future<Either<Failure, MyEntity>> getData();
}

// Use Case (domain/usecases/)
class GetDataUseCase {
  final MyRepository repository;
  
  GetDataUseCase(this.repository);
  
  Future<Either<Failure, MyEntity>> call() {
    return repository.getData();
  }
}

// Model (data/models/)
class MyModel extends MyEntity {
  MyModel({required super.id, required super.name});
  
  factory MyModel.fromJson(Map<String, dynamic> json) {
    return MyModel(
      id: json['id'],
      name: json['name'],
    );
  }
}

// Repository Implementation (data/repositories/)
class MyRepositoryImpl implements MyRepository {
  final MyRemoteDataSource remoteDataSource;
  
  MyRepositoryImpl(this.remoteDataSource);
  
  @override
  Future<Either<Failure, MyEntity>> getData() async {
    try {
      final result = await remoteDataSource.getData();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

// ViewModel (presentation/viewmodels/)
class MyViewModel extends ChangeNotifier {
  final GetDataUseCase getDataUseCase;
  
  MyEntity? _data;
  bool _isLoading = false;
  
  MyViewModel(this.getDataUseCase);
  
  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();
    
    final result = await getDataUseCase();
    result.fold(
      (failure) => debugPrint(failure.message),
      (data) => _data = data,
    );
    
    _isLoading = false;
    notifyListeners();
  }
}

// View (presentation/views/)
class MyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<MyViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          body: viewModel._isLoading
              ? CircularProgressIndicator()
              : Text(viewModel._data?.name ?? ''),
        );
      },
    );
  }
}
```

### Base de Données

#### SQLite

```dart
// Définir table
await db.execute('''
  CREATE TABLE ma_table (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    created_at INTEGER NOT NULL
  )
''');

// Insérer
await db.insert('ma_table', {
  'id': '1',
  'name': 'Test',
  'created_at': DateTime.now().millisecondsSinceEpoch,
});

// Lire
final results = await db.query('ma_table', where: 'id = ?', whereArgs: ['1']);

// Mettre à jour
await db.update('ma_table', {'name': 'Updated'}, where: 'id = ?', whereArgs: ['1']);

// Supprimer
await db.delete('ma_table', where: 'id = ?', whereArgs: ['1']);
```

#### Firestore

```dart
// Référence collection
final collection = FirebaseFirestore.instance.collection('users');

// Créer document
await collection.doc(userId).set({
  'name': 'John',
  'email': 'john@example.com',
  'createdAt': FieldValue.serverTimestamp(),
});

// Lire document
final doc = await collection.doc(userId).get();
final data = doc.data();

// Mettre à jour
await collection.doc(userId).update({'name': 'Jane'});

// Supprimer
await collection.doc(userId).delete();

// Requête
final snapshot = await collection
    .where('age', isGreaterThan: 18)
    .orderBy('name')
    .limit(10)
    .get();

// Stream temps réel
collection.doc(userId).snapshots().listen((snapshot) {
  print(snapshot.data());
});
```

---

## 👤 Guide Utilisateur

### Premiers Pas

#### 1. Télécharger l'Application

- **Android** : Google Play Store
- **iOS** : Apple App Store

#### 2. Créer un Compte

1. Ouvrir l'application
2. Appuyer sur "S'inscrire"
3. Choisir une méthode :
   - Email/Mot de passe
   - Google
   - Facebook
   - Téléphone
4. Compléter le profil
5. Sélectionner langue maternelle

#### 3. Choisir une Langue à Apprendre

1. Parcourir les 22 langues disponibles
2. Sélectionner une langue
3. Passer le test de niveau (optionnel)
4. Commencer le parcours

### Utiliser l'Application

#### Apprendre une Leçon

1. Aller dans "Cours"
2. Sélectionner un cours
3. Choisir une leçon
4. Suivre le contenu interactif
5. Compléter les exercices
6. Obtenir le score et feedback

#### Utiliser le Dictionnaire

1. Appuyer sur l'icône dictionnaire
2. Rechercher un mot
3. Voir traduction et prononciation
4. Écouter l'audio
5. Ajouter aux favoris (optionnel)

#### Passer un Quiz

1. Aller dans "Quiz"
2. Sélectionner un quiz
3. Répondre aux questions
4. Voir le résultat
5. Réviser les erreurs

#### Utiliser l'IA

1. Ouvrir "Assistant IA"
2. Choisir une fonction :
   - Chat pour questions
   - Traduction
   - Évaluation prononciation
3. Interagir avec l'assistant
4. Recevoir feedback personnalisé

### Trucs et Astuces

#### Maximiser l'Apprentissage

1. **Pratiquer quotidiennement** - 15-30 min/jour
2. **Utiliser le mode offline** - Télécharger contenus
3. **Rejoindre la communauté** - Échanger avec autres apprenants
4. **Participer aux défis** - Gagner badges et XP
5. **Utiliser l'IA** - Poser questions illimitées

#### Gagner des Points

- Compléter leçons quotidiennes
- Maintenir série de jours
- Réussir quiz avec haut score
- Contribuer au dictionnaire
- Aider autres utilisateurs

---

## 🚀 Déploiement

### Environnements

#### Development
```bash
flutter run --flavor dev
```

#### Staging
```bash
flutter run --flavor staging
```

#### Production
```bash
flutter build apk --release --flavor prod
flutter build ios --release --flavor prod
```

### Build Android (APK)

```bash
# Build APK
flutter build apk --release

# Build App Bundle (pour Play Store)
flutter build appbundle --release

# Fichiers générés :
# build/app/outputs/flutter-apk/app-release.apk
# build/app/outputs/bundle/release/app-release.aab
```

### Build iOS (IPA)

```bash
# Build iOS
flutter build ios --release

# Créer archive dans Xcode :
1. Ouvrir ios/Runner.xcworkspace dans Xcode
2. Product > Archive
3. Distribute App
4. Choisir méthode (App Store, Ad Hoc, etc.)
```

### Publication

#### Google Play Store

1. Créer compte Google Play Developer (25$)
2. Créer nouvelle application
3. Compléter fiche produit
4. Préparer assets :
   - Icône (512x512)
   - Screenshots
   - Feature graphic
   - Description
5. Upload App Bundle
6. Soumettre pour review

#### Apple App Store

1. Créer compte Apple Developer (99$/an)
2. Créer App ID dans Developer Portal
3. Créer app dans App Store Connect
4. Compléter métadonnées
5. Upload via Xcode ou Transporter
6. Soumettre pour review

---

## 🔧 Maintenance

### Monitoring

#### Firebase Crashlytics

```dart
// Enregistrer erreur personnalisée
await FirebaseCrashlytics.instance.recordError(
  error,
  stackTrace,
  reason: 'Description',
);

// Enregistrer log
FirebaseCrashlytics.instance.log('Message de log');
```

#### Firebase Analytics

```dart
// Enregistrer événement
await FirebaseAnalytics.instance.logEvent(
  name: 'lesson_completed',
  parameters: {
    'lesson_id': lessonId,
    'duration': duration,
    'score': score,
  },
);
```

### Mise à Jour

#### Process de Mise à Jour

1. Créer branche release
2. Incrémenter version dans `pubspec.yaml`
3. Mettre à jour CHANGELOG.md
4. Tester en profondeur
5. Build et déploiement
6. Monitoring post-release

#### Versioning

```yaml
# pubspec.yaml
version: 1.2.3+10
#        │ │ │  │
#        │ │ │  └─ Build number (Android/iOS)
#        │ │ └──── Patch (bug fixes)
#        │ └────── Minor (new features)
#        └──────── Major (breaking changes)
```

### Support

#### Canaux de Support

- **Email** : support@maayegue.com
- **WhatsApp** : +237 XXX XXX XXX
- **Discord** : discord.gg/maayegue
- **FAQ** : Dans l'application

---

## 📞 Contact & Ressources

### Liens Utiles

- **Site Web** : https://maayegue.com
- **GitHub** : https://github.com/maayegue/mobile
- **Documentation** : https://docs.maayegue.com
- **Status Page** : https://status.maayegue.com

### Équipe

- **Direction** : [Nom]
- **Développement** : [Équipe Dev]
- **Design** : [Équipe Design]
- **Linguistes** : [Équipe Linguistique]

---

*Documentation mise à jour le 7 octobre 2025*
*Version 1.0.0*

