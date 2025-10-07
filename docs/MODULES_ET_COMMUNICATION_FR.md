# 🔄 Modules et Communication - Ma'a yegue

**Analyse Détaillée de Tous les Modules et Leur Communication**

---

## 📦 Liste Complète des Modules

### Vue d'Ensemble

L'application Ma'a yegue comprend **25 modules fonctionnels** organisés selon Clean Architecture :

```
Ma'a yegue Application
├── 🔐 Authentication (26 fichiers) ✅
├── 📚 Lessons (54 fichiers) ✅
├── 📖 Dictionary (42 fichiers) ✅
├── 💳 Payment (30 fichiers) ✅
├── 🎯 Quiz (5 fichiers) ✅
├── 📊 Assessment (7 fichiers) ✅
├── 🤖 AI Integration (12 fichiers) ✅
├── 🎮 Gamification (14 fichiers) ✅
├── 🏆 Games (17 fichiers) ✅
├── 👥 Community (16 fichiers) ✅
├── 📊 Dashboard (22 fichiers) ✅
├── 👤 Profile (1 fichier) ✅
├── 🎓 Certificates (6 fichiers) ✅
├── 🌍 Languages (9 fichiers) ✅
├── 🎨 Culture (11 fichiers) ✅
├── 📱 Onboarding (14 fichiers) ✅
├── 📈 Analytics (5 fichiers) ✅
├── 👨‍🏫 Teacher (8 fichiers) ✅
├── 🎓 Learner (8 fichiers) ✅
├── 👨‍💼 Admin (11 fichiers) ✅
├── 🔍 Translation (1 fichier) ✅
├── 📚 Guides (3 fichiers) ✅
├── 👤 Guest (8 fichiers) ✅
├── 📚 Resources (1 fichier) ✅
└── 🏠 Home (2 fichiers) ✅

TOTAL: 333+ fichiers
```

---

## 🔗 Matrice de Communication Inter-Modules

### Tableau de Dépendances

| Module ↓ \ Utilise → | Auth | Lessons | Dict | Payment | Quiz | AI | Gamif | Analytics |
|----------------------|------|---------|------|---------|------|-------|--------|-----------|
| **Authentication**   | -    | ✅      | ✅   | ✅      | ✅   | ❌    | ✅     | ✅        |
| **Lessons**          | ✅   | -       | ✅   | ✅      | ✅   | ✅    | ✅     | ✅        |
| **Dictionary**       | ✅   | ✅      | -    | ❌      | ❌   | ✅    | ✅     | ✅        |
| **Payment**          | ✅   | ✅      | ❌   | -       | ❌   | ❌    | ❌     | ✅        |
| **Quiz**             | ✅   | ✅      | ✅   | ❌      | -    | ✅    | ✅     | ✅        |
| **AI**               | ✅   | ✅      | ✅   | ❌      | ✅   | -     | ❌     | ✅        |
| **Gamification**     | ✅   | ✅      | ✅   | ❌      | ✅   | ❌    | -      | ✅        |
| **Community**        | ✅   | ✅      | ❌   | ❌      | ❌   | ✅    | ✅     | ✅        |
| **Dashboard**        | ✅   | ✅      | ✅   | ✅      | ✅   | ✅    | ✅     | ✅        |
| **Profile**          | ✅   | ✅      | ❌   | ✅      | ❌   | ❌    | ✅     | ✅        |

---

## 📋 Description Détaillée des Modules

### 1. 🔐 Module Authentication

**Fichiers :** 26  
**Status :** ✅ Complet et Opérationnel  

#### Structure

```
authentication/
├── data/
│   ├── datasources/
│   │   ├── auth_remote_datasource.dart       # Firebase Auth
│   │   └── auth_local_datasource.dart        # Cache local
│   ├── models/
│   │   ├── user_model.dart
│   │   └── auth_response_model.dart
│   └── repositories/
│       └── auth_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── user_entity.dart
│   │   └── auth_response_entity.dart
│   ├── repositories/
│   │   └── auth_repository.dart
│   └── usecases/
│       ├── login_usecase.dart
│       ├── register_usecase.dart
│       ├── logout_usecase.dart
│       ├── google_sign_in_usecase.dart
│       ├── facebook_sign_in_usecase.dart
│       ├── apple_sign_in_usecase.dart
│       ├── phone_auth_usecase.dart
│       └── [8+ autres usecases]
└── presentation/
    ├── viewmodels/
    │   └── auth_viewmodel.dart
    └── views/
        ├── login_view.dart
        ├── register_view.dart
        ├── forgot_password_view.dart
        ├── phone_auth_view.dart
        └── two_factor_auth_view.dart
```

#### Dépendances

**Entrantes (Qui utilise ce module) :**
- 🎯 Tous les modules (vérification authentification)
- 📊 Dashboard (affichage selon rôle)
- 👤 Profile (gestion compte)
- 💳 Payment (vérification identité)

**Sortantes (Ce module utilise) :**
- 🔥 FirebaseService
- 📶 NetworkInfo
- 🔄 SyncManager
- 📊 AnalyticsService

#### Points de Communication

```dart
// 1. Diffusion état authentification
authViewModel.authStateChanges.listen((user) {
  if (user != null) {
    // Notifier tous les modules
    dashboardViewModel.onUserLogin(user);
    profileViewModel.loadProfile(user.id);
    lessonsViewModel.loadUserProgress(user.id);
    gamificationViewModel.loadUserStats(user.id);
  }
});

// 2. Vérification accès dans autres modules
if (!authViewModel.isAuthenticated) {
  context.go('/login');
  return;
}

// 3. Obtenir utilisateur actuel
final currentUser = authViewModel.currentUser;
final userId = currentUser?.id ?? '';
final userRole = currentUser?.role ?? 'guest';
```

---

### 2. 📚 Module Lessons

**Fichiers :** 54  
**Status :** ✅ Complet et Opérationnel  

#### Structure

```
lessons/
├── data/
│   ├── models/
│   │   ├── course_model.dart
│   │   ├── lesson_model.dart
│   │   ├── lesson_content_model.dart
│   │   └── [10+ autres models]
│   ├── repositories/
│   │   └── lesson_repository_impl.dart
│   └── services/
│       ├── course_service.dart              # Gestion cours
│       ├── level_management_service.dart    # Gestion niveaux
│       └── progress_tracking_service.dart   # Suivi progression
├── domain/
│   ├── entities/
│   │   ├── course.dart
│   │   ├── lesson.dart
│   │   ├── lesson_content.dart
│   │   ├── learning_progress_entity.dart
│   │   ├── user_level_entity.dart
│   │   └── [21+ autres entities]
│   └── usecases/
│       ├── get_courses_usecase.dart
│       ├── complete_lesson_usecase.dart
│       └── [10+ autres usecases]
└── presentation/
    ├── viewmodels/
    │   ├── lesson_viewmodel.dart
    │   ├── course_viewmodel.dart
    │   └── progress_viewmodel.dart
    └── views/
        ├── courses_view.dart
        ├── lesson_detail_view.dart
        ├── lesson_player_view.dart
        └── [12+ autres views]
```

#### Services Clés

##### A. CourseService

**Responsabilités :**
- Gestion CRUD des cours
- Synchronisation Firebase ↔ SQLite
- Organisation par langue et niveau
- Gestion des inscriptions

**Méthodes principales :**

```dart
class CourseService {
  // Créer un cours
  Future<Course> createCourse(Course course) async {
    // 1. Valider données
    // 2. Sauvegarder dans SQLite
    // 3. Synchroniser vers Firebase
    // 4. Retourner cours créé
  }
  
  // Récupérer cours par langue
  Future<List<Course>> getCoursesByLanguage(String languageCode) async {
    // 1. Essayer cache SQLite
    // 2. Si vide, fetcher Firebase
    // 3. Mettre à jour cache
    // 4. Retourner résultats
  }
  
  // Inscrire étudiant
  Future<void> enrollStudent(String courseId, String userId) async {
    // 1. Vérifier prérequis
    // 2. Vérifier abonnement (via PaymentService)
    // 3. Enregistrer inscription
    // 4. Débloquer premier cours
    // 5. Notifier étudiant
  }
}
```

##### B. LevelManagementService

**Responsabilités :**
- Gestion des niveaux utilisateur (A1-C2)
- Progression automatique
- Déblocage de contenu
- Recommandations personnalisées

**Algorithme de progression :**

```dart
Future<UserLevel> updateLevel({
  required String userId,
  required String languageCode,
  required int pointsEarned,
  required List<String> completedLessons,
}) async {
  // 1. Récupérer niveau actuel
  var level = await getUserLevel(userId, languageCode);
  
  // 2. Ajouter points
  level.currentPoints += pointsEarned;
  
  // 3. Vérifier si peut level up
  if (level.currentPoints >= level.pointsToNextLevel) {
    // 3a. Vérifier prérequis (minimum leçons)
    final minLessons = getLevelRequirement(level.currentLevel);
    
    if (completedLessons.length >= minLessons) {
      // 3b. Level up!
      level = await _levelUp(level);
      
      // 3c. Débloquer nouveau contenu
      await _unlockNewCourses(userId, level.nextLevel);
      
      // 3d. Attribuer badge
      await gamificationService.awardBadge(
        userId: userId,
        badgeType: 'level_${level.currentLevel}',
      );
      
      // 3e. Envoyer notification
      await notificationService.send(
        userId: userId,
        title: 'Niveau supérieur atteint !',
        body: 'Félicitations, vous êtes maintenant ${level.currentLevel}',
      );
    }
  }
  
  // 4. Sauvegarder
  await _saveUserLevel(level);
  
  return level;
}
```

##### C. ProgressTrackingService

**Responsabilités :**
- Enregistrement temps passé
- Calcul des scores
- Statistiques détaillées
- Synchronisation temps réel

**Workflow :**

```dart
Future<void> recordLessonProgress({
  required String userId,
  required String lessonId,
  required String languageCode,
  required int timeSpentSeconds,
  required int score,
}) async {
  final db = await DatabaseHelper.database;
  
  // 1. Mettre à jour ou créer progression
  await db.insert(
    'lesson_progress',
    {
      'user_id': userId,
      'lesson_id': lessonId,
      'language_code': languageCode,
      'time_spent_seconds': timeSpentSeconds,
      'last_score': score,
      'best_score': max(currentBestScore, score),
      'attempts_count': attemptsCount + 1,
      'last_accessed': DateTime.now().millisecondsSinceEpoch,
      'needs_sync': 1,
    },
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
  
  // 2. Synchroniser avec Firebase (async)
  _syncToFirebase(userId, lessonId);
  
  // 3. Mettre à jour progression globale
  await _updateOverallProgress(userId, languageCode);
  
  // 4. Vérifier milestones
  await _checkMilestones(userId, languageCode);
}
```

#### Communication avec Autres Modules

**Lessons → Quiz :**

```dart
// Débloquer quiz après complétion leçon
lessonViewModel.completeLesson(lessonId).then((_) {
  quizViewModel.unlockQuiz(lessonId);
  
  // Notifier utilisateur
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Quiz débloqué !'),
      content: Text('Testez vos connaissances'),
      actions: [
        TextButton(
          onPressed: () => context.push('/quiz/$lessonId'),
          child: Text('Commencer'),
        ),
      ],
    ),
  );
});
```

**Lessons → Gamification :**

```dart
// Attribution automatique de points
class LessonViewModel extends ChangeNotifier {
  Future<void> completeLesson(String lessonId) async {
    // 1. Marquer leçon comme complétée
    await _progressService.markComplete(lessonId);
    
    // 2. Attribuer points XP
    await _gamificationService.awardPoints(
      userId: _userId,
      points: 50,
      reason: 'Lesson completed',
      lessonId: lessonId,
    );
    
    // 3. Vérifier badges
    final badges = await _gamificationService.checkNewBadges(_userId);
    
    if (badges.isNotEmpty) {
      _showBadgeUnlockedAnimation(badges);
    }
    
    notifyListeners();
  }
}
```

**Lessons → AI :**

```dart
// Génération contenu personnalisé
final recommendedExercises = await aiService.generateExercises(
  topic: currentLesson.topic,
  languageCode: currentLesson.languageCode,
  userLevel: userLevel,
  weaknesses: userWeaknesses,  // Basé sur historique
);

// Intégrer exercices dans leçon
lessonContent.additionalExercises = recommendedExercises;
```

**Lessons → Certificates :**

```dart
// Génération certificat après cours complet
courseViewModel.completeCourse(courseId).then((_) async {
  final certificate = await certificateService.generate(
    userId: userId,
    courseId: courseId,
    courseName: course.title,
    completionDate: DateTime.now(),
    score: finalScore,
  );
  
  // Naviguer vers certificat
  context.push('/certificates/${certificate.id}');
});
```

---

### 3. 📖 Module Dictionary

**Fichiers :** 42  
**Status :** ✅ Complet et Opérationnel  

#### Structure

```
dictionary/
├── data/
│   ├── datasources/
│   │   ├── dictionary_remote_datasource.dart   # Firebase
│   │   └── dictionary_local_datasource.dart    # SQLite
│   ├── models/
│   │   ├── dictionary_entry_model.dart
│   │   ├── word_model.dart
│   │   └── translation_model.dart
│   ├── repositories/
│   │   └── dictionary_repository_impl.dart
│   └── services/
│       ├── dictionary_service.dart
│       ├── offline_dictionary_service.dart
│       └── contribution_service.dart
├── domain/
│   ├── entities/
│   │   ├── dictionary_entry_entity.dart
│   │   ├── word_entity.dart
│   │   └── [20+ autres entities]
│   └── usecases/
│       ├── search_words_usecase.dart
│       ├── add_favorite_usecase.dart
│       └── contribute_word_usecase.dart
└── presentation/
    ├── viewmodels/
    │   └── dictionary_viewmodel.dart
    └── views/
        ├── dictionary_view.dart
        ├── word_detail_view.dart
        └── [7+ autres views]
```

#### Fonctionnalités Principales

1. **Recherche Avancée**

```dart
Future<List<DictionaryEntry>> searchWords({
  required String query,
  required String languageCode,
  String? partOfSpeech,
  DifficultyLevel? level,
}) async {
  // 1. Recherche locale (cache)
  var localResults = await _localDataSource.search(
    query: query,
    languageCode: languageCode,
  );
  
  // 2. Si connexion, chercher aussi remote
  if (await _networkInfo.isConnected) {
    final remoteResults = await _remoteDataSource.search(
      query: query,
      languageCode: languageCode,
    );
    
    // 3. Merger et dédupliquer
    localResults = _mergeResults(localResults, remoteResults);
    
    // 4. Mettre à jour cache
    await _updateCache(remoteResults);
  }
  
  // 5. Filtrer selon critères
  if (partOfSpeech != null) {
    localResults = localResults
        .where((e) => e.partOfSpeech == partOfSpeech)
        .toList();
  }
  
  return localResults;
}
```

2. **Mode Offline**

```dart
class OfflineDictionaryService {
  // Télécharger dictionnaire pour offline
  Future<void> downloadForOffline(String languageCode) async {
    // 1. Fetcher toutes les entrées
    final entries = await _firestore
        .collection('dictionary_entries')
        .where('languageCode', isEqualTo: languageCode)
        .get();
    
    // 2. Sauvegarder localement
    final db = await DatabaseHelper.database;
    
    for (final doc in entries.docs) {
      await db.insert(
        'dictionary_entries',
        doc.data(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    // 3. Télécharger fichiers audio
    for (final entry in entries.docs) {
      final audioUrls = entry.data()['audioFileReferences'];
      for (final url in audioUrls) {
        await _downloadAudio(url);
      }
    }
  }
}
```

3. **Contribution Communautaire**

```dart
Future<void> contributeWord({
  required String word,
  required String languageCode,
  required Map<String, String> translations,
  File? audioFile,
}) async {
  // 1. Créer entrée
  final entry = DictionaryEntry(
    id: uuid.v4(),
    canonicalForm: word,
    languageCode: languageCode,
    translations: translations,
    contributorId: currentUserId,
    reviewStatus: ReviewStatus.pending,
    qualityScore: 0.0,
  );
  
  // 2. Upload audio si fourni
  String? audioUrl;
  if (audioFile != null) {
    audioUrl = await storageService.uploadAudio(
      languageCode: languageCode,
      word: word,
      file: audioFile,
    );
    entry.audioFileReferences.add(audioUrl);
  }
  
  // 3. Sauvegarder
  await _repository.addEntry(entry);
  
  // 4. Notifier modérateurs
  await notificationService.notifyModerators(
    type: 'new_contribution',
    entryId: entry.id,
  );
  
  // 5. Attribuer points contributeur
  await gamificationService.awardPoints(
    userId: currentUserId,
    points: 30,
    reason: 'Dictionary contribution',
  );
}
```

#### Communication

**Dictionary → AI :**

```dart
// Traduction assistée par IA
final aiTranslation = await aiService.translate(
  text: word,
  sourceLanguage: 'fr',
  targetLanguage: languageCode,
  context: 'dictionary_entry',
);

// Vérification qualité
final qualityScore = await aiService.assessQuality(
  entry: dictionaryEntry,
);
```

**Dictionary → Lessons :**

```dart
// Vocabulaire intégré dans leçons
final lessonVocabulary = await dictionaryService.getWordsForLesson(
  lessonId: lessonId,
  languageCode: languageCode,
);

// Afficher définitions dans contexte
lesson.enrichWithDictionary(lessonVocabulary);
```

**Dictionary → Audio Service :**

```dart
// Lecture prononciation
await audioService.playPronunciation(
  audioUrl: dictionaryEntry.audioFileReferences.first,
);

// Enregistrement contribution
final audioFile = await audioService.recordPronunciation(
  maxDuration: Duration(seconds: 5),
);

await dictionaryService.addAudioPronunciation(
  entryId: entry.id,
  audioFile: audioFile,
);
```

---

### 4. 💳 Module Payment

**Fichiers :** 30  
**Status :** ✅ Complet et Opérationnel  

#### Structure

```
payment/
├── data/
│   ├── datasources/
│   │   ├── campay_datasource.dart
│   │   ├── noupay_datasource.dart
│   │   ├── stripe_datasource.dart
│   │   └── payment_local_datasource.dart
│   ├── models/
│   │   ├── payment_model.dart
│   │   ├── subscription_model.dart
│   │   └── transaction_model.dart
│   ├── repositories/
│   │   └── payment_repository_impl.dart
│   └── services/
│       ├── campay_service.dart
│       ├── noupay_service.dart
│       └── stripe_service.dart
├── domain/
│   ├── entities/
│   │   ├── payment_entity.dart
│   │   ├── subscription_plan_entity.dart
│   │   └── [9+ autres entities]
│   └── usecases/
│       ├── initiate_payment_usecase.dart
│       ├── verify_payment_usecase.dart
│       └── manage_subscription_usecase.dart
└── presentation/
    ├── viewmodels/
    │   └── payment_viewmodel.dart
    └── views/
        ├── subscription_plans_view.dart
        ├── payment_view.dart
        ├── payment_processing_view.dart
        └── payment_history_view.dart
```

#### Flux de Paiement

```
1. User sélectionne plan
         │
         ▼
2. PaymentViewModel.initiatePayment()
         │
         ├─► Plan Free → Activation immédiate
         │
         └─► Plan Payant
              │
              ▼
3. Sélection méthode paiement
              │
    ┌─────────┴─────────┬─────────┐
    │                   │         │
    ▼                   ▼         ▼
CamPay              NouPay    Stripe
(Mobile Money)      (Local)   (Card)
    │                   │         │
    └─────────┬─────────┴─────────┘
              │
              ▼
4. Traitement gateway
              │
              ▼
5. Webhook callback
              │
              ▼
6. Vérification paiement
              │
              ▼
7. Activation abonnement
              │
              ├─► Firestore: Update subscription
              ├─► SQLite: Update local
              ├─► Notification: Confirmation
              └─► Analytics: Track purchase
              │
              ▼
8. Déblocage contenu
              │
              ├─► Lessons: Unlock premium
              ├─► AI: Enable features
              └─► Profile: Update badge
```

#### Intégration

**Payment → Lessons :**

```dart
class LessonViewModel {
  Future<bool> canAccessLesson(Lesson lesson) async {
    // Leçon gratuite
    if (!lesson.isPremium) return true;
    
    // Vérifier abonnement
    final subscription = await paymentService.getCurrentSubscription();
    
    return subscription.plan != SubscriptionPlan.free &&
           subscription.status == SubscriptionStatus.active;
  }
}
```

**Payment → Profile :**

```dart
// Affichage badge abonnement
Widget _buildSubscriptionBadge(Subscription subscription) {
  return Container(
    padding: EdgeInsets.all(8),
    decoration: BoxDecoration(
      color: _getPlanColor(subscription.plan),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Icon(_getPlanIcon(subscription.plan)),
        SizedBox(width: 8),
        Text(subscription.plan.displayName),
      ],
    ),
  );
}
```

---

### 5. 🎯 Module Quiz

**Fichiers :** 5  
**Status :** ✅ Complet et Opérationnel  

#### Communication

**Quiz → Lessons :**

```dart
// Validation progression après quiz
quizViewModel.submitQuiz(quizId).then((result) async {
  if (result.passed) {
    // Marquer leçon comme complétée
    await lessonViewModel.markAsCompleted(result.lessonId);
    
    // Débloquer prochaine leçon
    final nextLesson = await lessonViewModel.getNextLesson();
    if (nextLesson != null) {
      showDialog(
        context: context,
        builder: (context) => NextLessonDialog(lesson: nextLesson),
      );
    }
  }
});
```

**Quiz → Gamification :**

```dart
// Bonus pour quiz parfait
if (quizResult.percentage == 100) {
  await gamificationService.awardPoints(
    userId: userId,
    points: 200,  // Double points
    reason: 'Perfect quiz score',
  );
  
  await gamificationService.awardBadge(
    userId: userId,
    badgeType: 'perfectionist',
  );
}
```

**Quiz → Certificates :**

```dart
// Certificat après réussite cours complet
if (courseProgress.isComplete && courseProgress.averageScore >= 70) {
  final certificate = await certificateService.generate(
    userId: userId,
    courseId: courseId,
    finalScore: courseProgress.averageScore,
  );
  
  context.push('/certificates/${certificate.id}');
}
```

---

### 6. 🤖 Module AI Integration

**Fichiers :** 12  
**Status :** ✅ Complet et Opérationnel  

#### Services IA

```
ai/
├── data/
│   ├── datasources/
│   │   └── ai_remote_datasource.dart      # Gemini API
│   ├── models/
│   │   ├── chat_message_model.dart
│   │   └── ai_response_model.dart
│   └── repositories/
│       └── ai_repository_impl.dart
├── domain/
│   ├── entities/
│   │   ├── chat_entity.dart
│   │   ├── translation_entity.dart
│   │   └── pronunciation_score_entity.dart
│   └── usecases/
│       ├── chat_usecase.dart
│       ├── translate_usecase.dart
│       ├── evaluate_pronunciation_usecase.dart
│       └── generate_content_usecase.dart
└── presentation/
    ├── viewmodels/
    │   └── ai_viewmodel.dart
    └── views/
        └── ai_view.dart
```

#### Cas d'Utilisation

**AI → Lessons (Génération Contenu) :**

```dart
Future<List<Exercise>> generatePersonalizedExercises({
  required String userId,
  required String languageCode,
  required String topic,
  required LearningLevel level,
}) async {
  // 1. Analyser historique utilisateur
  final userHistory = await analyticsService.getUserLearningHistory(userId);
  
  // 2. Identifier faiblesses
  final weaknesses = _identifyWeaknesses(userHistory);
  
  // 3. Générer prompt IA
  final prompt = '''
Génère 5 exercices personnalisés pour :
- Langue: $languageCode
- Sujet: $topic
- Niveau: $level
- Faiblesses à travailler: ${weaknesses.join(', ')}

Format JSON avec: question, options[], correctAnswer, explanation
''';
  
  // 4. Appeler Gemini
  final response = await geminiService.generateContent(prompt);
  
  // 5. Parser et retourner
  return _parseExercises(response.text);
}
```

**AI → Dictionary (Traduction) :**

```dart
Future<Translation> translateWithAI({
  required String text,
  required String sourceLang,
  required String targetLang,
  String? context,
}) async {
  final prompt = '''
Traduire avec précision culturelle :
Texte: "$text"
De: $sourceLang
Vers: $targetLang
${context != null ? 'Contexte: $context' : ''}

Fournir :
1. Traduction littérale
2. Traduction naturelle
3. Explications culturelles
4. Exemples d'usage
''';
  
  final response = await geminiService.chat(prompt);
  
  return Translation.fromAIResponse(response);
}
```

**AI → Assessment (Évaluation Prononciation) :**

```dart
Future<PronunciationScore> evaluatePronunciation({
  required File audioFile,
  required String expectedText,
  required String languageCode,
}) async {
  // 1. Convertir audio en base64
  final audioBytes = await audioFile.readAsBytes();
  final audioBase64 = base64Encode(audioBytes);
  
  // 2. Appeler Gemini avec audio
  final prompt = '''
Évalue la prononciation de l'audio fourni.
Mot/Phrase attendu(e): "$expectedText"
Langue: $languageCode

Fournir :
- Score précision (0-100)
- Phonèmes correctement prononcés
- Phonèmes à améliorer
- Conseils spécifiques
''';
  
  // 3. Analyser
  final response = await geminiVisionService.analyzeAudio(
    prompt: prompt,
    audio: audioBase64,
  );
  
  // 4. Parser résultat
  return PronunciationScore.fromAI(response);
}
```

---

### 7. 🎮 Module Gamification

**Fichiers :** 14  
**Status :** ✅ Complet et Opérationnel  

#### Structure

```
gamification/
├── data/
│   ├── models/
│   │   ├── badge_model.dart
│   │   ├── achievement_model.dart
│   │   └── leaderboard_model.dart
│   ├── repositories/
│   │   └── gamification_repository_impl.dart
│   └── services/
│       ├── points_service.dart
│       ├── badge_service.dart
│       └── leaderboard_service.dart
├── domain/
│   ├── entities/
│   │   ├── badge_entity.dart
│   │   ├── achievement_entity.dart
│   │   └── xp_entity.dart
│   └── usecases/
│       ├── award_points_usecase.dart
│       ├── unlock_badge_usecase.dart
│       └── update_leaderboard_usecase.dart
└── presentation/
    ├── viewmodels/
    │   └── gamification_viewmodel.dart
    └── views/
        ├── gamification_view.dart
        ├── leaderboard_view.dart
        └── achievements_view.dart
```

#### Système de Points

```dart
class PointsService {
  // Attribution points
  Future<void> awardPoints({
    required String userId,
    required int points,
    required String reason,
    Map<String, dynamic>? metadata,
  }) async {
    // 1. Enregistrer transaction
    await _recordPointsTransaction(
      userId: userId,
      points: points,
      reason: reason,
      metadata: metadata,
    );
    
    // 2. Mettre à jour total
    final newTotal = await _updateTotalPoints(userId, points);
    
    // 3. Vérifier déblocages
    await _checkUnlocks(userId, newTotal);
    
    // 4. Mettre à jour leaderboard
    await _updateLeaderboard(userId, newTotal);
    
    // 5. Notifier utilisateur
    await notificationService.send(
      userId: userId,
      title: '+$points XP',
      body: reason,
    );
  }
  
  // Calcul multiplicateurs
  int calculatePointsWithMultipliers({
    required int basePoints,
    required String userId,
  }) async {
    var points = basePoints;
    
    // Bonus série
    final streak = await _getStreak(userId);
    if (streak >= 7) points = (points * 1.5).round();
    if (streak >= 30) points = (points * 2.0).round();
    
    // Bonus Premium
    final subscription = await paymentService.getCurrentSubscription();
    if (subscription.plan == SubscriptionPlan.pro) {
      points = (points * 1.2).round();
    }
    
    // Bonus événement spécial
    if (await _isSpecialEvent()) {
      points = (points * 2.0).round();
    }
    
    return points;
  }
}
```

#### Leaderboard

```dart
class LeaderboardService {
  // Classement global
  Future<List<LeaderboardEntry>> getGlobalLeaderboard({
    int limit = 100,
  }) async {
    return await _firestore
        .collection('leaderboard_global')
        .orderBy('totalPoints', descending: true)
        .limit(limit)
        .get()
        .then((snapshot) => snapshot.docs
            .map((doc) => LeaderboardEntry.fromFirestore(doc))
            .toList());
  }
  
  // Classement par langue
  Future<List<LeaderboardEntry>> getLanguageLeaderboard({
    required String languageCode,
    int limit = 50,
  }) async {
    return await _firestore
        .collection('leaderboard_$languageCode')
        .orderBy('points', descending: true)
        .limit(limit)
        .get()
        .then((snapshot) => snapshot.docs
            .map((doc) => LeaderboardEntry.fromFirestore(doc))
            .toList());
  }
  
  // Position utilisateur
  Future<int> getUserRank(String userId, {String? languageCode}) async {
    final collection = languageCode != null
        ? 'leaderboard_$languageCode'
        : 'leaderboard_global';
    
    final higherRanked = await _firestore
        .collection(collection)
        .where('points', isGreaterThan: userPoints)
        .count()
        .get();
    
    return higherRanked.count + 1;
  }
}
```

---

### 8. 👥 Module Community

**Fichiers :** 16  
**Status :** ✅ Complet et Opérationnel  

#### Fonctionnalités Sociales

**Forums :**

```dart
// Structure post forum
class ForumPost {
  final String id;
  final String authorId;
  final String title;
  final String content;
  final String languageCode;  // Forum spécifique langue
  final List<String> tags;
  final int likes;
  final int comments;
  final DateTime createdAt;
}

// Créer post
Future<void> createPost({
  required String title,
  required String content,
  required String languageCode,
  List<String> tags = const [],
}) async {
  final post = ForumPost(
    id: uuid.v4(),
    authorId: currentUserId,
    title: title,
    content: content,
    languageCode: languageCode,
    tags: tags,
    createdAt: DateTime.now(),
  );
  
  await _firestore.collection('forum_posts').doc(post.id).set(post.toJson());
  
  // Notifier followers
  await _notifyFollowers(currentUserId, post);
}
```

**Messagerie :**

```dart
// Chat temps réel
Stream<List<Message>> getChatMessages(String chatId) {
  return _firestore
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Message.fromFirestore(doc))
          .toList());
}

// Envoyer message
Future<void> sendMessage({
  required String chatId,
  required String content,
  MessageType type = MessageType.text,
  File? attachment,
}) async {
  String? attachmentUrl;
  
  if (attachment != null) {
    attachmentUrl = await storageService.uploadFile(
      file: attachment,
      path: 'chats/$chatId/${uuid.v4()}',
    );
  }
  
  final message = Message(
    id: uuid.v4(),
    senderId: currentUserId,
    content: content,
    type: type,
    attachmentUrl: attachmentUrl,
    timestamp: DateTime.now(),
  );
  
  await _firestore
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .doc(message.id)
      .set(message.toJson());
}
```

---

## 📊 Schéma Global de Communication

```
┌─────────────────────────────────────────────────────────────┐
│                     MAIN.DART                               │
│              (Initialization & Bootstrap)                    │
└──────────────────────┬──────────────────────────────────────┘
                       │
       ┌───────────────┴───────────────┐
       │                               │
┌──────▼─────────┐           ┌─────────▼────────┐
│  Provider DI   │           │   Firebase Init  │
│   Container    │           │   Database Init  │
└───────┬────────┘           └─────────┬────────┘
        │                              │
        └──────────────┬───────────────┘
                       │
        ┌──────────────▼──────────────┐
        │       App Providers         │
        │  (Tous les services et VMs) │
        └──────────────┬──────────────┘
                       │
        ┌──────────────▼──────────────┐
        │      Router (GoRouter)      │
        │    + Auth Guard + Routes    │
        └──────────────┬──────────────┘
                       │
        ┌──────────────▼──────────────┐
        │   Authentication Check      │
        └──┬──────────────────────┬───┘
           │                      │
    ┌──────▼──────┐        ┌─────▼──────┐
    │  Auth Flow  │        │Guest Access│
    │Login/Register        │  Limited   │
    └──────┬──────┘        └────────────┘
           │
           │ ✅ Authenticated
           │
    ┌──────▼──────────────────────────┐
    │    Role-Based Dashboard         │
    ├─────────┬─────────┬─────────────┤
    │Student  │ Teacher │   Admin     │
    └────┬────┴────┬────┴──────┬──────┘
         │         │           │
         └─────────┴───────────┘
                   │
      ┌────────────┴─────────────┐
      │                          │
┌─────▼─────┐            ┌──────▼──────┐
│  Feature  │            │   Feature   │
│  Modules  │◄──────────►│   Modules   │
└─────┬─────┘            └──────┬──────┘
      │                         │
      └─────────┬───────────────┘
                │
        ┌───────▼────────┐
        │ Core Services  │
        │  Shared Layer  │
        └────────────────┘
```

---

*Document de référence des modules - 7 octobre 2025*

