# 🏗️ Architecture Détaillée - Ma'a yegue v2.0

**Document Technique : Architecture et Communication des Modules**  
**Version:** 2.0.0 - Educational Platform Edition  
**Date:** 7 octobre 2025

---

## 📋 Vue d'Ensemble

Ma'a yegue utilise une architecture **Clean Architecture** combinée au pattern **MVVM**, garantissant :
- ✅ **Séparation des responsabilités**
- ✅ **Testabilité maximale**
- ✅ **Maintenabilité long terme**
- ✅ **Scalabilité**
- ✅ **Indépendance des frameworks**

### 🎓 Nouveautés v2.0
- ✅ **Système éducatif complet** (1,800+ lignes de code)
- ✅ **12 rôles utilisateurs** avec hiérarchie
- ✅ **Gestion établissements et classes**
- ✅ **Notation /20 camerounaise**
- ✅ **Calendrier académique**
- ✅ **Outils enseignants et portail parents**
- ✅ **Filtrage contenu par âge**

**📚 Documentation Complète:** Voir [V2_EDUCATIONAL_ADDITIONS.md](V2_EDUCATIONAL_ADDITIONS.md) pour détails techniques complets des additions éducatives.

---

## 🎯 Principes Fondamentaux

### 1. Clean Architecture

```
┌─────────────────────────────────────────────────────────┐
│                  PRESENTATION LAYER                     │
│  ┌─────────┐  ┌──────────┐  ┌────────────────────┐    │
│  │  Views  │  │ViewModels│  │  Widgets/Screens   │    │
│  └────┬────┘  └─────┬────┘  └─────────┬──────────┘    │
├───────┼─────────────┼──────────────────┼───────────────┤
│       │             │                  │               │
│  DOMAIN LAYER       │                  │               │
│  ┌────▼────┐  ┌─────▼────┐  ┌─────────▼──────────┐    │
│  │Entities │  │Use Cases │  │  Repository Intf.  │    │
│  └─────────┘  └──────────┘  └────────────────────┘    │
├──────────────────────┬──────────────────────────────────┤
│                      │                                  │
│  DATA LAYER          │                                  │
│  ┌──────────────────▼────────────────────┐            │
│  │    Repository Implementations         │            │
│  ├───────────────┬───────────────────────┤            │
│  │ Data Sources  │  Models & Mappers     │            │
│  │ Remote | Local│  JSON Serialization   │            │
│  └───────┬───────┴───────────────────────┘            │
├──────────┼──────────────────────────────────────────────┤
│          │   INFRASTRUCTURE LAYER                      │
│  ┌───────▼──────────────────────────────────────┐     │
│  │  Firebase │ SQLite │ APIs │ Platform Services│     │
│  └──────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────┘
```

### 2. MVVM Pattern

```
┌──────────┐         ┌─────────────┐        ┌──────────┐
│   VIEW   │ ◄─────► │  VIEWMODEL  │ ◄────► │  MODEL   │
├──────────┤         ├─────────────┤        ├──────────┤
│ Widgets  │         │ State Mgmt  │        │ Use Cases│
│ Screens  │  Event  │ Logic       │  Data  │ Entities │
│ UI       │ ──────► │ Transform   │ ◄────  │ Repos    │
│          │ ◄────── │             │        │          │
│          │ Binding │ Provider/   │        │          │
│          │         │ ChangeNotif │        │          │
└──────────┘         └─────────────┘        └──────────┘
```

---

## 🔄 Communication Inter-Modules

### Mécanismes de Communication

#### 1. Provider Dependency Injection

**Définition des Providers** (`lib/shared/providers/app_providers.dart`)

```dart
List<SingleChildWidget> get appProviders => [
  // Services Core
  Provider<FirebaseService>(
    create: (_) => FirebaseService(),
  ),
  
  // DataSources
  ProxyProvider<FirebaseService, AuthRemoteDataSource>(
    update: (_, firebaseService, __) =>
        AuthRemoteDataSourceImpl(firebaseService: firebaseService),
  ),
  
  // Repositories
  ProxyProvider2<AuthRemoteDataSource, AuthLocalDataSource, AuthRepository>(
    update: (_, remote, local, __) =>
        AuthRepositoryImpl(
          remoteDataSource: remote,
          localDataSource: local,
        ),
  ),
  
  // Use Cases
  ProxyProvider<AuthRepository, LoginUsecase>(
    update: (_, repository, __) => LoginUsecase(repository),
  ),
  
  // ViewModels
  ChangeNotifierProxyProvider<LoginUsecase, AuthViewModel>(
    create: (context) => AuthViewModel(
      loginUsecase: context.read<LoginUsecase>(),
    ),
    update: (_, __, authViewModel) => authViewModel!,
  ),
];
```

**Utilisation dans les Vues**

```dart
// Lecture (sans rebuild)
final authViewModel = context.read<AuthViewModel>();

// Écoute (avec rebuild)
final authViewModel = context.watch<AuthViewModel>();

// Sélection spécifique (rebuild optimisé)
final user = context.select((AuthViewModel vm) => vm.currentUser);
```

#### 2. Services Partagés (Core Layer)

```dart
// Services globaux accessibles partout
core/services/
├── firebase_service.dart              # Firebase centralisé
├── ai_service.dart                    # Intelligence artificielle
├── notification_service.dart          # Notifications push
├── storage_service.dart               # Stockage fichiers
├── analytics_service.dart             # Analytics
├── audio_service.dart                 # Lecture audio
├── sync_manager.dart                  # Synchronisation
├── academic_calendar_service.dart     # 🆕 Calendrier académique camerounais
└── content_filter_service.dart        # 🆕 Filtrage contenu par âge
```

**Exemple d'utilisation :**

```dart
// Dans n'importe quel module
class MyViewModel {
  final FirebaseService _firebaseService;
  final AIService _aiService;
  
  MyViewModel(this._firebaseService, this._aiService);
  
  Future<void> doSomething() async {
    // Utiliser Firebase
    final data = await _firebaseService.firestore
        .collection('data')
        .get();
    
    // Utiliser IA
    final translation = await _aiService.translate(
      text: 'Hello',
      targetLanguage: 'ewo',
    );
  }
}
```

#### 3. Event Bus via Streams

```dart
// Authentication state changes
class AuthViewModel extends ChangeNotifier {
  Stream<User?> get authStateChanges => 
      _authRepository.authStateChanges;
}

// Écoute dans autre module
class LessonViewModel {
  void init() {
    authViewModel.authStateChanges.listen((user) {
      if (user == null) {
        // Déconnecter et nettoyer
        _clearLessonData();
      } else {
        // Charger données utilisateur
        _loadUserLessons(user.id);
      }
    });
  }
}
```

#### 4. Router Centralisé (GoRouter)

```dart
// Définition des routes
GoRouter(
  routes: [
    GoRoute(
      path: '/lessons/:lessonId',
      builder: (context, state) {
        final lessonId = state.pathParameters['lessonId'];
        return LessonDetailView(lessonId: lessonId);
      },
    ),
  ],
);

// Navigation
context.go('/lessons/123');
context.push('/quiz/456');
context.pop();

// Navigation avec données
context.go('/payment', extra: {
  'plan': 'premium',
  'amount': 2000,
});
```

---

## 🔌 Intégration des Modules

### Schéma Complet d'Intégration

```
┌─────────────────────────────────────────────────────────────┐
│                      main.dart (Entry Point)                │
│  ┌───────────┐  ┌────────────┐  ┌───────────────────┐     │
│  │ Firebase  │  │  Database  │  │  Provider Setup   │     │
│  │   Init    │  │    Init    │  │   (DI Container)  │     │
│  └─────┬─────┘  └──────┬─────┘  └─────────┬─────────┘     │
└────────┼────────────────┼──────────────────┼───────────────┘
         │                │                  │
         │        ┌───────▼──────────┐       │
         │        │   AppProviders   │◄──────┘
         │        │  (All Services)  │
         │        └────────┬─────────┘
         │                 │
         │       ┌─────────▼──────────┐
         │       │    Router (GoR)    │
         │       │  Auth Guard/Routes │
         │       └─────────┬──────────┘
         │                 │
         └─────────────────┼─────────────────┐
                           │                 │
         ┌─────────────────▼────┐    ┌───────▼────────┐
         │  Authentication      │    │  Guest Access  │
         │  (Login/Register)    │    │  (Limited)     │
         └──────────┬───────────┘    └────────────────┘
                    │
                    │ (After Auth)
                    │
    ┌───────────────┴───────────────┬──────────────┐
    │                               │              │
┌───▼──────┐              ┌─────────▼───┐   ┌─────▼──────┐
│ Student  │              │  Teacher    │   │   Admin    │
│Dashboard │              │  Dashboard  │   │  Dashboard │
└────┬─────┘              └──────┬──────┘   └─────┬──────┘
     │                           │                │
     │  ┌────────────────────────┴────────────┐   │
     │  │                                     │   │
┌────▼──▼─────┐  ┌──────────┐  ┌────────┐  ┌▼───▼──┐
│   Lessons   │  │Dictionary│  │  Quiz  │  │Payment│
├─────────────┤  ├──────────┤  ├────────┤  ├───────┤
│ProgressSvc │  │ AudioSvc │  │ AIEval │  │CamPay │
└──────┬──────┘  └────┬─────┘  └───┬────┘  └───┬───┘
       │              │            │            │
       └──────────────┴────────────┴────────────┘
                      │
              ┌───────▼───────┐
              │  Core Services│
              │ (Shared Layer)│
              └───────────────┘
```

### Flux de Données Typique

#### Exemple : Complétion d'une Leçon

```
1. User clique "Terminer leçon" dans LessonView
                │
                ▼
2. LessonView appelle LessonViewModel.completeLesson()
                │
                ▼
3. LessonViewModel appelle CompleteLessonUseCase
                │
                ▼
4. UseCase valide et appelle LessonRepository
                │
                ├──► 5a. LessonRepository → Firebase (remote)
                │    └─► Sauvegarde dans Firestore
                │
                └──► 5b. LessonRepository → SQLite (local)
                     └─► Sauvegarde en cache local
                │
                ▼
6. Repository retourne résultat au UseCase
                │
                ▼
7. UseCase notifie ProgressTrackingService
                │
                ├──► Mise à jour progression
                ├──► Calcul nouveaux points XP
                └──► Vérification badges
                │
                ▼
8. GamificationService attribue récompenses
                │
                ├──► +50 XP
                ├──► Badge si applicable
                └──► Mise à jour leaderboard
                │
                ▼
9. ViewModel met à jour state et notifyListeners()
                │
                ▼
10. View se reconstruit avec nouvelles données
                │
                ▼
11. UI affiche félicitations et nouveau contenu
```

---

## 📦 Modules et Leurs Dépendances

### Module Authentication

#### Dépendances Entrantes
- Tous les modules (vérification utilisateur)
- Router (guards de navigation)
- Dashboard (affichage selon rôle)

#### Dépendances Sortantes
- FirebaseService (auth, firestore)
- NetworkInfo (vérification connectivité)
- StorageService (cache utilisateur)

#### Communication

```dart
// Autres modules écoutent les changements d'auth
authViewModel.authStateChanges.listen((user) {
  if (user != null) {
    // Charger données utilisateur
    dashboardViewModel.loadUserData(user.id);
    lessonsViewModel.loadProgress(user.id);
    profileViewModel.loadProfile(user.id);
  } else {
    // Nettoyer et rediriger
    _clearAllData();
    context.go('/login');
  }
});
```

### Module Lessons

#### Dépendances Entrantes
- Quiz (validation progression)
- Gamification (attribution XP)
- Analytics (statistiques)
- Certificates (génération certificats)

#### Dépendances Sortantes
- ProgressTrackingService
- LevelManagementService
- CourseService
- FirebaseService
- Database (SQLite)

#### Communication

```dart
// Lesson → Quiz : Déblocage quiz
lessonViewModel.onLessonComplete(lessonId).then((_) {
  quizViewModel.unlockQuiz(lessonId);
});

// Lesson → Gamification : Attribution points
lessonViewModel.onLessonComplete(lessonId).then((_) {
  gamificationService.awardPoints(
    userId: currentUserId,
    points: 50,
    reason: 'Lesson completed',
  );
});

// Lesson → Analytics : Enregistrement métrique
analyticsService.trackLessonCompletion(
  lessonId: lessonId,
  duration: duration,
  score: score,
);
```

### Module Payment

#### Dépendances Entrantes
- Profile (affichage statut abonnement)
- Lessons (déverrouillage contenu premium)
- AI (limite utilisation selon plan)
- Dashboard (accès fonctionnalités)

#### Dépendances Sortantes
- CamPayService
- NouPayService
- StripeService
- FirebaseService (enregistrement transactions)
- NotificationService (confirmations)

#### Communication

```dart
// Payment → Lessons : Déblocage contenu
paymentViewModel.onSubscriptionSuccess(plan).then((_) {
  lessonViewModel.unlockPremiumContent();
  profileViewModel.updateSubscription(plan);
});

// Vérification accès dans autres modules
if (await paymentService.hasActiveSubscription()) {
  // Autoriser accès premium
} else {
  // Afficher écran upgrade
  context.push('/subscription-plans');
}
```

### Module AI

#### Dépendances Entrantes
- Lessons (génération contenu)
- Dictionary (traductions)
- Quiz (corrections automatiques)
- Assessment (évaluation prononciation)

#### Dépendances Sortantes
- GeminiAIService (API Google)
- AudioService (analyse audio)
- FirebaseService (historique conversations)

#### Communication

```dart
// Lessons → AI : Génération exercices
final exercises = await aiService.generateExercises(
  topic: 'Salutations',
  languageCode: 'ewo',
  level: 'beginner',
  count: 5,
);

// Dictionary → AI : Traduction contextuelle
final translation = await aiService.translateWithContext(
  text: 'Je vais bien',
  sourceLanguage: 'fr',
  targetLanguage: 'ewo',
  context: 'informal greeting',
);

// Assessment → AI : Évaluation prononciation
final audioFile = await recordAudio();
final evaluation = await aiService.evaluatePronunciation(
  audioFile: audioFile,
  expectedText: 'Mbolo',
  languageCode: 'ewo',
);
```

---

## 🗄️ Gestion des Données

### Architecture de Données

```
┌─────────────────────────────────────────────┐
│           Application Layer                 │
│  (ViewModels, Use Cases)                   │
└──────────────┬──────────────────────────────┘
               │
    ┌──────────▼──────────┐
    │   Repository Layer   │
    │  (Data Orchestration)│
    └──┬────────────────┬──┘
       │                │
┌──────▼──────┐   ┌────▼──────────┐
│   Remote    │   │     Local     │
│ Data Source │   │  Data Source  │
├─────────────┤   ├───────────────┤
│  Firebase   │   │    SQLite     │
│  Firestore  │   │     Hive      │
│   Storage   │   │  SharedPrefs  │
│     API     │   │     Cache     │
└─────────────┘   └───────────────┘
```

### Stratégie de Cache

#### 1. Cache-First Strategy (Offline-First)

```dart
// Exemple : Charger leçons
Future<List<Lesson>> getLessons(String userId) async {
  try {
    // 1. Essayer cache local d'abord
    final cachedLessons = await _localDataSource.getLessons(userId);
    
    if (cachedLessons.isNotEmpty) {
      // Retourner cache immédiatement
      return cachedLessons;
    }
  } catch (e) {
    debugPrint('Cache error: $e');
  }
  
  // 2. Fetcher du serveur si cache vide
  if (await _networkInfo.isConnected) {
    try {
      final remoteLessons = await _remoteDataSource.getLessons(userId);
      
      // 3. Mettre à jour cache
      await _localDataSource.saveLessons(remoteLessons);
      
      return remoteLessons;
    } catch (e) {
      debugPrint('Remote error: $e');
      // Fallback sur cache même si vide
      return [];
    }
  }
  
  // 4. Pas de connexion, retourner cache
  return cachedLessons ?? [];
}
```

#### 2. Synchronisation Background

```dart
// Sync Manager
class GeneralSyncManager {
  Future<void> syncAll() async {
    await Future.wait([
      _syncLessonsProgress(),
      _syncDictionaryContributions(),
      _syncQuizAttempts(),
      _syncGamificationData(),
    ]);
  }
  
  Future<void> _syncLessonsProgress() async {
    final db = await DatabaseHelper.database;
    
    // Récupérer données non synchronisées
    final pending = await db.query(
      'lesson_progress',
      where: 'needs_sync = 1',
    );
    
    for (final record in pending) {
      try {
        // Sync vers Firebase
        await _firestore
            .collection('lesson_progress')
            .doc(record['id'] as String)
            .set(record);
        
        // Marquer comme synchronisé
        await db.update(
          'lesson_progress',
          {'needs_sync': 0},
          where: 'id = ?',
          whereArgs: [record['id']],
        );
      } catch (e) {
        debugPrint('Sync failed for ${record['id']}: $e');
      }
    }
  }
}
```

### Gestion des Conflits

```dart
class ConflictResolutionService {
  Future<T> resolveConflict<T>({
    required T localVersion,
    required T remoteVersion,
    required DateTime localTimestamp,
    required DateTime remoteTimestamp,
    required ConflictStrategy strategy,
  }) async {
    switch (strategy) {
      case ConflictStrategy.serverWins:
        return remoteVersion;
        
      case ConflictStrategy.clientWins:
        return localVersion;
        
      case ConflictStrategy.mostRecent:
        return localTimestamp.isAfter(remoteTimestamp)
            ? localVersion
            : remoteVersion;
            
      case ConflictStrategy.merge:
        // Logique de merge personnalisée
        return _mergeVersions(localVersion, remoteVersion);
    }
  }
}
```

---

## 🔐 Sécurité et Authentification

### Flux d'Authentification

```
┌──────────┐
│  User    │
└────┬─────┘
     │ 1. Credentials
     ▼
┌────────────────┐
│  Login View    │
└────┬───────────┘
     │ 2. signIn()
     ▼
┌────────────────┐
│ Auth ViewModel │
└────┬───────────┘
     │ 3. execute()
     ▼
┌────────────────┐
│  Login UseCase │
└────┬───────────┘
     │ 4. signIn()
     ▼
┌────────────────┐
│Auth Repository │
└────┬───────────┘
     │ 5. authenticate()
     ▼
┌────────────────┐
│  Firebase Auth │
│  Remote DS     │
└────┬───────────┘
     │ 6. User + Token
     ▼
┌────────────────┐
│  Local Storage │
│  (Cache User)  │
└────┬───────────┘
     │ 7. Success
     ▼
┌────────────────┐
│ Update UI      │
│ Navigate Home  │
└────────────────┘
```

### Protection des Routes

```dart
// Guard d'authentification
redirect: (context, state) {
  final authViewModel = context.read<AuthViewModel>();
  final isLoggedIn = authViewModel.isAuthenticated;
  final isOnAuthPage = state.matchedLocation.startsWith('/auth');
  
  if (!isLoggedIn && !isOnAuthPage) {
    // Rediriger vers login
    return '/auth/login';
  }
  
  if (isLoggedIn && isOnAuthPage) {
    // Déjà connecté, rediriger dashboard
    return '/dashboard';
  }
  
  // Autoriser
  return null;
}

// Guard de rôle
redirect: (context, state) {
  final user = context.read<AuthViewModel>().currentUser;
  
  if (state.matchedLocation.startsWith('/admin')) {
    if (user?.role != 'admin') {
      return '/unauthorized';
    }
  }
  
  if (state.matchedLocation.startsWith('/teacher')) {
    if (user?.role != 'teacher' && user?.role != 'admin') {
      return '/unauthorized';
    }
  }
  
  return null;
}
```

### Sécurisation des Données

#### 1. Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper function
    function isAuthenticated() {
      return request.auth != null;
    }
    
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }
    
    function hasRole(role) {
      return isAuthenticated() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == role;
    }
    
    // Users
    match /users/{userId} {
      allow read: if isAuthenticated();
      allow write: if isOwner(userId);
    }
    
    // Courses
    match /courses/{courseId} {
      allow read: if isAuthenticated();
      allow create, update: if hasRole('teacher') || hasRole('admin');
      allow delete: if hasRole('admin');
    }
    
    // Lesson Progress
    match /lesson_progress/{progressId} {
      allow read, write: if isAuthenticated() && 
        resource.data.userId == request.auth.uid;
    }
    
    // Payments
    match /payments/{paymentId} {
      allow read: if isAuthenticated() && 
        resource.data.userId == request.auth.uid;
      allow write: if false; // Only via Cloud Functions
    }
  }
}
```

#### 2. Storage Security Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // User avatars
    match /avatars/{userId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId
                   && request.resource.size < 5 * 1024 * 1024 // 5MB max
                   && request.resource.contentType.matches('image/.*');
    }
    
    // Course media (only teachers/admins)
    match /courses/{courseId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        (request.auth.token.role == 'teacher' || 
         request.auth.token.role == 'admin');
    }
    
    // Audio pronunciations
    match /audio/{languageCode}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
        request.auth.token.role in ['teacher', 'admin', 'contributor'];
    }
  }
}
```

#### 3. Validation Côté Client

```dart
class Validators {
  // Email
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email requis';
    }
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Email invalide';
    }
    return null;
  }
  
  // Mot de passe
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Mot de passe requis';
    }
    if (value.length < 8) {
      return 'Minimum 8 caractères';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Au moins une majuscule requise';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Au moins un chiffre requis';
    }
    return null;
  }
  
  // Téléphone camerounais
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Numéro requis';
    }
    final phoneRegex = RegExp(r'^(237)?[26][0-9]{8}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'\s+'), ''))) {
      return 'Numéro camerounais invalide';
    }
    return null;
  }
}
```

---

## ⚡ Performance et Optimisation

### Stratégies d'Optimisation

#### 1. Lazy Loading des Modules

```dart
// Chargement différé des features lourdes
GoRoute(
  path: '/ai',
  builder: (context, state) {
    // Charge le module AI seulement quand nécessaire
    return FutureBuilder(
      future: _loadAIModule(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return LoadingScreen();
        }
        return AIView();
      },
    );
  },
);
```

#### 2. Optimisation Images

```dart
// Utiliser cached_network_image
CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (context, url) => Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: Container(color: Colors.white),
  ),
  errorWidget: (context, url, error) => Icon(Icons.error),
  maxHeightDiskCache: 800,
  maxWidthDiskCache: 800,
)
```

#### 3. Pagination

```dart
// Pagination pour listes longues
class LessonsViewModel extends ChangeNotifier {
  final int _pageSize = 20;
  int _currentPage = 0;
  bool _hasMore = true;
  List<Lesson> _lessons = [];
  
  Future<void> loadMoreLessons() async {
    if (!_hasMore) return;
    
    final newLessons = await _repository.getLessons(
      page: _currentPage,
      limit: _pageSize,
    );
    
    _lessons.addAll(newLessons);
    _currentPage++;
    _hasMore = newLessons.length == _pageSize;
    notifyListeners();
  }
}
```

#### 4. Debouncing Recherches

```dart
class DictionaryViewModel extends ChangeNotifier {
  Timer? _debounceTimer;
  
  void search(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }
  
  Future<void> _performSearch(String query) async {
    final results = await _repository.searchWords(query);
    _searchResults = results;
    notifyListeners();
  }
}
```

#### 5. Background Sync

```dart
// Sync périodique en arrière-plan
class BackgroundSyncService {
  static void registerPeriodicSync() {
    Workmanager().registerPeriodicTask(
      'sync-task',
      'sync',
      frequency: Duration(hours: 1),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
    );
  }
  
  static void handleBackgroundTask() async {
    final syncManager = GeneralSyncManager();
    await syncManager.syncAll();
  }
}
```

---

## 🧪 Tests et Qualité

### Structure des Tests

```
test/
├── unit/                          # Tests unitaires
│   ├── usecases/                 # Tests use cases
│   ├── repositories/             # Tests repositories
│   └── services/                 # Tests services
│
├── widget/                        # Tests widgets
│   ├── views/                    # Tests vues
│   └── components/               # Tests composants
│
└── integration/                   # Tests intégration
    ├── auth_flow_test.dart       # Flux authentification
    ├── lesson_flow_test.dart     # Flux leçons
    └── payment_flow_test.dart    # Flux paiements
```

### Exemples de Tests

#### Test Unitaire (Use Case)

```dart
void main() {
  late LoginUsecase loginUsecase;
  late MockAuthRepository mockRepository;
  
  setUp(() {
    mockRepository = MockAuthRepository();
    loginUsecase = LoginUsecase(mockRepository);
  });
  
  test('should return user when login is successful', () async {
    // Arrange
    final email = 'test@example.com';
    final password = 'password123';
    final expectedUser = User(id: '1', email: email);
    
    when(mockRepository.signInWithEmailAndPassword(email, password))
        .thenAnswer((_) async => Right(expectedUser));
    
    // Act
    final result = await loginUsecase(email, password);
    
    // Assert
    expect(result, Right(expectedUser));
    verify(mockRepository.signInWithEmailAndPassword(email, password));
  });
}
```

#### Test Widget

```dart
void main() {
  testWidgets('Login button should trigger login', (tester) async {
    // Arrange
    final mockViewModel = MockAuthViewModel();
    
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthViewModel>.value(
        value: mockViewModel,
        child: MaterialApp(home: LoginView()),
      ),
    );
    
    // Act
    await tester.enterText(find.byKey(Key('email')), 'test@example.com');
    await tester.enterText(find.byKey(Key('password')), 'password');
    await tester.tap(find.text('Connexion'));
    await tester.pump();
    
    // Assert
    verify(mockViewModel.signInWithEmailAndPassword(
      'test@example.com',
      'password',
    )).called(1);
  });
}
```

---

## 📊 Monitoring et Analytics

### Firebase Analytics Events

```dart
// Événements trackés automatiquement
- app_open
- screen_view
- session_start
- first_open
- user_engagement

// Événements personnalisés
analyticsService.trackEvent('lesson_completed', {
  'lesson_id': lessonId,
  'language_code': languageCode,
  'duration_seconds': duration,
  'score': score,
  'completion_rate': completionRate,
});

analyticsService.trackEvent('quiz_submitted', {
  'quiz_id': quizId,
  'score': score,
  'time_spent': timeSpent,
  'passed': passed,
});

analyticsService.trackEvent('payment_completed', {
  'plan': plan,
  'amount': amount,
  'currency': 'XAF',
  'payment_method': method,
});
```

### Crashlytics

```dart
// Configuration dans main.dart
FlutterError.onError = (errorDetails) {
  FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
};

PlatformDispatcher.instance.onError = (error, stack) {
  FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  return true;
};

// Enregistrement manuel
try {
  await riskyOperation();
} catch (e, stackTrace) {
  await FirebaseCrashlytics.instance.recordError(
    e,
    stackTrace,
    reason: 'Failed to perform risky operation',
    information: ['userId: $userId', 'action: $action'],
  );
}
```

---

## 🌍 Internationalisation (i18n)

### Configuration

```dart
// Locales supportées
supportedLocales: [
  Locale('fr', 'FR'), // Français
  Locale('en', 'US'), // Anglais
]

// Fichiers de traduction
l10n/
├── app_fr.arb       # Français (principal)
└── app_en.arb       # Anglais (fallback)
```

### Utilisation

```dart
// Dans les widgets
Text(AppLocalizations.of(context)!.welcome)

// Avec paramètres
AppLocalizations.of(context)!.lessonCompleted(lessonTitle)

// Pluralisation
AppLocalizations.of(context)!.numberOfLessons(count)
```

---

## 🎨 Thèmes et Design System

### Configuration Thèmes

```dart
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.teal,
      brightness: Brightness.light,
    ),
    // Configurations détaillées...
  );
  
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.teal,
      brightness: Brightness.dark,
    ),
    // Configurations détaillées...
  );
}
```

### Composants Réutilisables

```
shared/widgets/
├── buttons/
│   ├── primary_button.dart
│   ├── secondary_button.dart
│   └── icon_button.dart
├── cards/
│   ├── lesson_card.dart
│   ├── course_card.dart
│   └── achievement_card.dart
├── dialogs/
│   ├── confirmation_dialog.dart
│   ├── loading_dialog.dart
│   └── error_dialog.dart
└── inputs/
    ├── custom_text_field.dart
    ├── search_field.dart
    └── dropdown_field.dart
```

---

## 📈 Métriques de Performance

### Objectifs de Performance

- ⚡ **Temps de démarrage** : < 2 secondes
- ⚡ **Temps de navigation** : < 300ms
- ⚡ **Temps de réponse API** : < 1 seconde
- ⚡ **Taille APK** : < 50MB
- ⚡ **Utilisation RAM** : < 150MB
- ⚡ **Consommation batterie** : Minimale

### Outils de Mesure

```bash
# Performance profiling
flutter run --profile
flutter run --release --trace-startup

# Analyse taille bundle
flutter build apk --analyze-size
flutter build ios --analyze-size

# DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

---

## ✅ Checklist Production

### Avant Déploiement

- [ ] Tous les tests passent
- [ ] 0 erreurs flutter analyze
- [ ] Performance testée
- [ ] Sécurité validée
- [ ] Documentation à jour
- [ ] Variables d'environnement configurées
- [ ] Firebase production configuré
- [ ] Paiements testés
- [ ] Certificats SSL valides
- [ ] Politique de confidentialité
- [ ] Conditions d'utilisation
- [ ] Screenshots stores
- [ ] Description stores
- [ ] Icône app finalisée
- [ ] Version incrémentée

---

*Document technique maintenu à jour*  
*Dernière révision : 7 octobre 2025*

