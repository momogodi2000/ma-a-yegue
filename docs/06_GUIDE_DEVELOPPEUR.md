# 👨‍💻 GUIDE DÉVELOPPEUR - MA'A YEGUE

## 📋 Guide Complet pour Développeurs

Ce document couvre tout ce qu'un développeur doit savoir pour travailler sur Ma'a yegue.

---

## 🚀 DÉMARRAGE RAPIDE

### Prérequis

**Obligatoires** :
- ✅ Flutter SDK 3.8.1+
- ✅ Dart SDK 3.8.1+
- ✅ Android Studio (pour Android)
- ✅ Xcode (pour iOS, Mac uniquement)
- ✅ Python 3.x (pour scripts DB)
- ✅ Git

**Recommandés** :
- ✅ VS Code avec extensions Flutter/Dart
- ✅ SQLite Browser (inspection DB)
- ✅ Postman (test APIs)
- ✅ Firebase CLI

### Installation

```bash
# 1. Cloner le repository
git clone https://github.com/mayegue/mayegue-mobile.git
cd mayegue-mobile

# 2. Installer dépendances
flutter pub get

# 3. Générer base de données
cd docs/database-scripts
python create_cameroon_db.py
cp cameroon_languages.db ../../assets/databases/

# 4. Configuration Firebase
# Placer google-services.json dans android/app/
# Placer GoogleService-Info.plist dans ios/Runner/

# 5. Lancer l'app
cd ../..
flutter run
```

### Premier Lancement

```bash
# Vérifier setup
flutter doctor -v

# Lancer sur émulateur/appareil
flutter devices
flutter run

# Build pour Android
flutter build apk

# Build pour iOS
flutter build ios
```

---

## 🏗️ ARCHITECTURE DU CODE

### Structure des Dossiers

```
lib/
├── core/                       # Code partagé
│   ├── analytics/              # Services analytics
│   ├── config/                 # Configuration
│   ├── constants/              # Constantes
│   ├── database/               # ⭐ Services SQLite
│   │   ├── unified_database_service.dart
│   │   ├── database_query_optimizer.dart
│   │   └── migrations/
│   ├── errors/                 # Gestion erreurs
│   ├── network/                # HTTP client
│   ├── security/               # ⭐ Validation, sécurité
│   ├── services/               # Services communs
│   │   ├── firebase_service.dart
│   │   ├── firebase_request_optimizer.dart
│   │   └── guest_limit_service.dart
│   ├── sync/                   # Synchronisation
│   └── utils/                  # Utilitaires
│
├── features/                   # Modules fonctionnels
│   ├── authentication/         # Connexion/Inscription
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   ├── repositories/
│   │   │   └── services/
│   │   │       └── hybrid_auth_service.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── viewmodels/
│   │       ├── views/
│   │       └── widgets/
│   │
│   ├── guest/                  # Module invité
│   ├── learner/                # Module apprenant
│   ├── teacher/                # Module enseignant
│   ├── admin/                  # Module admin
│   ├── dictionary/             # Dictionnaire
│   ├── lessons/                # Leçons
│   ├── quiz/                   # Quiz
│   ├── payment/                # Paiements
│   └── ...
│
├── shared/                     # Composants partagés
│   ├── themes/                 # Thèmes UI
│   ├── widgets/                # Widgets réutilisables
│   └── providers/              # Providers globaux
│
├── l10n/                       # Localisation (FR/EN)
├── main.dart                   # Point d'entrée
└── firebase_options.dart       # Config Firebase
```

### Principes Clean Architecture

**Séparation en couches** :

```
Presentation (UI)
      ↓
Domain (Logique Métier)
      ↓
Data (Sources de Données)
```

**Règle d'or** : Les dépendances vont toujours vers l'intérieur.

- ✅ Presentation peut utiliser Domain
- ✅ Domain peut utiliser abstractions Data
- ❌ Domain NE PEUT PAS utiliser Presentation
- ❌ Domain NE PEUT PAS utiliser implémentations Data concrètes

---

## 🗄️ TRAVAILLER AVEC SQLITE

### Service Principal : UnifiedDatabaseService

**Singleton** :
```dart
final db = UnifiedDatabaseService.instance;
```

### Opérations CRUD

#### Create (Créer)

```dart
// Créer utilisateur
await db.upsertUser({
  'user_id': 'user-123',
  'email': 'test@example.com',
  'display_name': 'Test User',
  'role': 'student',
  'created_at': DateTime.now().millisecondsSinceEpoch,
  'updated_at': DateTime.now().millisecondsSinceEpoch,
});

// Créer progrès
await db.saveProgress(
  userId: 'user-123',
  contentType: 'lesson',
  contentId: 1,
  status: 'completed',
  score: 85.5,
);

// Créer leçon (enseignant)
final lessonId = await db.createLesson({
  'creator_id': 'teacher-456',
  'language_id': 'EWO',
  'title': 'Ma Nouvelle Leçon',
  'content': 'Contenu de la leçon...',
  'level': 'beginner',
  'status': 'draft',
});
```

#### Read (Lire)

```dart
// Obtenir utilisateur
final user = await db.getUserById('user-123');

// Obtenir statistiques
final stats = await db.getUserStatistics('user-123');

// Obtenir toutes les langues
final languages = await db.getAllLanguages();

// Rechercher traductions
final results = await db.searchTranslations(
  'bonjour',
  languageId: 'EWO',
  limit: 50,
);

// Obtenir leçons par langue
final lessons = await db.getLessonsByLanguage('EWO', level: 'beginner');

// Obtenir progrès utilisateur
final progress = await db.getUserAllProgress('user-123');
```

#### Update (Mettre à jour)

```dart
// Mettre à jour utilisateur
await db.upsertUser({
  'user_id': 'user-123',
  'display_name': 'Nouveau Nom',
  'updated_at': DateTime.now().millisecondsSinceEpoch,
});

// Incrémenter statistique
await db.incrementStatistic('user-123', 'total_lessons_completed');
await db.incrementStatistic('user-123', 'experience_points', incrementBy: 100);

// Mettre à jour statut contenu
await db.updateContentStatus(contentId: 45, status: 'published');

// Mettre à jour rôle
await db.updateUserRole('user-123', 'teacher');
```

#### Delete (Supprimer)

```dart
// Supprimer favori
await db.removeFavorite(
  userId: 'user-123',
  contentType: 'lesson',
  contentId: 5,
);

// Supprimer contenu utilisateur
await db.deleteUserContent(contentId: 45);

// Note: Utilisateurs ne sont JAMAIS supprimés,
// mais désactivés (is_active = 0)
```

### Requêtes Complexes

**Jointure multi-tables** :
```dart
final database = await db.database;

final result = await database.rawQuery('''
  SELECT 
    u.display_name,
    s.level,
    s.experience_points,
    COUNT(p.progress_id) as activities,
    l.language_name as favorite_language
  FROM users u
  LEFT JOIN user_statistics s ON u.user_id = s.user_id
  LEFT JOIN user_progress p ON u.user_id = p.user_id
  LEFT JOIN cameroon.languages l ON p.language_id = l.language_id
  WHERE u.user_id = ?
  GROUP BY u.user_id, l.language_id
  ORDER BY COUNT(p.progress_id) DESC
  LIMIT 1
''', [userId]);
```

### Transactions

**Pour opérations atomiques** :
```dart
final database = await db.database;

await database.transaction((txn) async {
  // Toutes ces opérations réussissent ensemble ou échouent ensemble
  
  await txn.insert('payments', paymentData);
  
  await txn.insert('subscriptions', subscriptionData);
  
  await txn.update(
    'users',
    {'subscription_status': 'premium'},
    where: 'user_id = ?',
    whereArgs: [userId],
  );
  
  // Si une erreur survient : rollback automatique
});
```

---

## 🔥 TRAVAILLER AVEC FIREBASE

### Service Firebase Unifié

```dart
import 'package:maa_yegue/core/services/firebase_service.dart';

final firebase = FirebaseService();

// Initialiser (au démarrage app)
await firebase.initialize();

// Log événement
await firebase.logEvent(
  name: 'lesson_start',
  parameters: {'lesson_id': '1', 'language': 'ewondo'},
);

// Définir propriétés utilisateur
await firebase.setUserProperties(
  userId: userId,
  userRole: 'student',
  subscriptionStatus: 'premium',
);

// Obtenir token FCM
final fcmToken = await firebase.messaging.getToken();

// S'abonner à topic
await firebase.messaging.subscribeToTopic('ewondo_updates');
```

### Auth avec Firebase

```dart
import 'package:maa_yegue/features/authentication/data/services/hybrid_auth_service.dart';

// Inscription
final result = await HybridAuthService.signUpWithEmail(
  email: 'user@example.com',
  password: 'SecurePass123!',
  displayName: 'Jean Dupont',
  role: 'student',
);

if (result['success']) {
  final userId = result['user_id'];
  final role = result['role'];
  // Rediriger vers dashboard approprié
}

// Connexion
final loginResult = await HybridAuthService.signInWithEmail(
  email: 'user@example.com',
  password: 'SecurePass123!',
);

// Déconnexion
await HybridAuthService.signOut();

// Reset password
await HybridAuthService.sendPasswordResetEmail('user@example.com');
```

---

## 🎨 DÉVELOPPEMENT UI

### Thèmes

**Fichiers** :
- `lib/shared/themes/app_theme.dart`
- `lib/shared/themes/colors.dart`

**Utilisation** :
```dart
// Couleurs
import 'package:maa_yegue/shared/themes/colors.dart';

Container(
  color: AppColors.primary,
  child: Text(
    'Texte',
    style: TextStyle(color: AppColors.textPrimary),
  ),
)

// Thème
MaterialApp(
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  themeMode: ThemeMode.system,
)
```

### Widgets Réutilisables

**Fichier** : `lib/shared/widgets/`

**Widgets disponibles** :
```dart
// Bouton personnalisé
CustomButton(
  text: 'Continuer',
  onPressed: () {},
  backgroundColor: AppColors.primary,
)

// Carte de contenu
ContentCard(
  title: 'Leçon 1',
  subtitle: 'Salutations',
  onTap: () {},
)

// Input de formulaire
CustomTextField(
  label: 'Email',
  controller: emailController,
  validator: (value) => InputValidator.validateEmail(value),
)

// Indicateur de chargement
LoadingIndicator()

// Message d'erreur
ErrorMessage(message: 'Une erreur est survenue')
```

### Navigation

**Routeur** : `lib/core/router.dart` (go_router)

```dart
// Navigation simple
context.go('/lessons');

// Navigation avec paramètres
context.go('/lesson/45');

// Navigation avec query
context.go('/search?query=bonjour&lang=ewondo');

// Retour
context.pop();

// Remplacer route
context.pushReplacement('/dashboard');
```

**Routes définies** :
```dart
'/': HomePage
'/auth/login': LoginView
'/auth/register': RegisterView
'/guest/dashboard': GuestDashboardView
'/student/dashboard': StudentDashboardView
'/teacher/dashboard': TeacherDashboardView
'/admin/dashboard': AdminDashboardView
'/dictionary': DictionaryView
'/lessons': LessonsListView
'/lesson/:id': LessonDetailView
'/quiz/:id': QuizView
'/profile': ProfileView
```

---

## 🧪 TESTS

### Structure des Tests

```
test/
├── unit/                       # Tests unitaires
│   ├── database/
│   │   └── unified_database_service_test.dart
│   ├── services/
│   │   ├── guest_limit_service_test.dart
│   │   ├── student_service_test.dart
│   │   ├── teacher_service_test.dart
│   │   └── admin_service_test.dart
│   └── validators_test.dart
│
├── integration/                # Tests d'intégration
│   ├── hybrid_architecture_test.dart
│   ├── app_integration_test.dart
│   └── performance_test.dart
│
├── widget/                     # Tests widgets
│   └── authentication/
│       └── login_view_test.dart
│
└── test_config.dart            # Configuration tests
```

### Écrire un Test Unitaire

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:maa_yegue/core/database/unified_database_service.dart';

void main() {
  // Setup SQLite pour tests
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Mon Test Group', () {
    late UnifiedDatabaseService db;

    setUp(() async {
      db = UnifiedDatabaseService.instance;
      await db.deleteDatabase();  // DB propre pour chaque test
    });

    tearDown(() async {
      await db.close();
    });

    test('Description du test', () async {
      // Arrange
      const userId = 'test-user-1';
      await db.upsertUser({
        'user_id': userId,
        'email': 'test@example.com',
        'role': 'student',
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      });

      // Act
      final user = await db.getUserById(userId);

      // Assert
      expect(user, isNotNull);
      expect(user?['email'], equals('test@example.com'));
      expect(user?['role'], equals('student'));
    });
  });
}
```

### Exécuter les Tests

```bash
# Tous les tests
flutter test

# Tests spécifiques
flutter test test/unit/database/

# Test unique
flutter test test/unit/services/guest_limit_service_test.dart

# Avec couverture
flutter test --coverage

# Voir couverture HTML
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Mocks et Stubs

```dart
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Générer mocks
@GenerateMocks([FirebaseService, UnifiedDatabaseService])
void main() {}

// Utiliser dans tests
test('Test avec mock', () {
  final mockDb = MockUnifiedDatabaseService();
  
  when(mockDb.getUserById(any))
      .thenAnswer((_) async => {'user_id': 'test', 'role': 'student'});
  
  // Utiliser mockDb dans le test
});
```

---

## 🔧 DÉVELOPPEMENT PAR MODULE

### Créer un Nouveau Module

**Étape 1 : Structure de base**

```bash
mkdir -p lib/features/mon_module/{data,domain,presentation}/{datasources,models,repositories,services,entities,usecases,viewmodels,views,widgets}
```

**Étape 2 : Entité (Domain)**

```dart
// lib/features/mon_module/domain/entities/mon_entity.dart
class MonEntity {
  final String id;
  final String name;
  final DateTime createdAt;

  const MonEntity({
    required this.id,
    required this.name,
    required this.createdAt,
  });
}
```

**Étape 3 : Repository Interface (Domain)**

```dart
// lib/features/mon_module/domain/repositories/mon_repository.dart
abstract class MonRepository {
  Future<Either<Failure, MonEntity>> get getMonEntity(String id);
  Future<Either<Failure, bool>> saveMonEntity(MonEntity entity);
}
```

**Étape 4 : UseCase (Domain)**

```dart
// lib/features/mon_module/domain/usecases/get_mon_entity_usecase.dart
class GetMonEntityUseCase {
  final MonRepository repository;

  GetMonEntityUseCase(this.repository);

  Future<Either<Failure, MonEntity>> call(String id) {
    return repository.getMonEntity(id);
  }
}
```

**Étape 5 : DataSource (Data)**

```dart
// lib/features/mon_module/data/datasources/mon_local_datasource.dart
class MonLocalDataSource {
  final _db = UnifiedDatabaseService.instance;

  Future<Map<String, dynamic>?> getMonData(String id) async {
    final database = await _db.database;
    final results = await database.query(
      'mon_table',
      where: 'id = ?',
      whereArgs: [id],
    );
    return results.isNotEmpty ? results.first : null;
  }
}
```

**Étape 6 : Repository Implementation (Data)**

```dart
// lib/features/mon_module/data/repositories/mon_repository_impl.dart
class MonRepositoryImpl implements MonRepository {
  final MonLocalDataSource localDataSource;

  MonRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, MonEntity>> getMonEntity(String id) async {
    try {
      final data = await localDataSource.getMonData(id);
      if (data == null) {
        return Left(CacheFailure('Entity not found'));
      }
      
      final entity = MonEntity(
        id: data['id'],
        name: data['name'],
        createdAt: DateTime.fromMillisecondsSinceEpoch(data['created_at']),
      );
      
      return Right(entity);
    } catch (e) {
      return Left(CacheFailure('Failed to get entity: $e'));
    }
  }
}
```

**Étape 7 : ViewModel (Presentation)**

```dart
// lib/features/mon_module/presentation/viewmodels/mon_viewmodel.dart
class MonViewModel extends ChangeNotifier {
  final GetMonEntityUseCase getMonEntityUseCase;

  MonEntity? _entity;
  bool _isLoading = false;
  String? _error;

  MonEntity? get entity => _entity;
  bool get isLoading => _isLoading;
  String? get error => _error;

  MonViewModel(this.getMonEntityUseCase);

  Future<void> loadEntity(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getMonEntityUseCase(id);

    result.fold(
      (failure) {
        _error = 'Erreur de chargement';
        _isLoading = false;
        notifyListeners();
      },
      (entity) {
        _entity = entity;
        _isLoading = false;
        notifyListeners();
      },
    );
  }
}
```

**Étape 8 : View (Presentation)**

```dart
// lib/features/mon_module/presentation/views/mon_view.dart
class MonView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MonViewModel(getMonEntityUseCase),
      child: Consumer<MonViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.isLoading) {
            return LoadingIndicator();
          }

          if (viewModel.error != null) {
            return ErrorMessage(message: viewModel.error!);
          }

          return Scaffold(
            appBar: AppBar(title: Text(viewModel.entity?.name ?? '')),
            body: // ... contenu
          );
        },
      ),
    );
  }
}
```

---

## 🔐 SÉCURITÉ ET VALIDATION

### Validator

**Fichier** : `lib/core/security/input_validator.dart`

```dart
// Valider email
final emailResult = InputValidator.validateEmail('user@example.com');
if (!emailResult.isValid) {
  showError(emailResult.error);
  return;
}
final cleanEmail = emailResult.sanitized;

// Valider mot de passe
final passwordResult = InputValidator.validatePassword('Pass123!');
if (!passwordResult.isValid) {
  showError(passwordResult.error);
  return;
}

// Vérifier force mot de passe
final strength = InputValidator.checkPasswordStrength('Pass123!');
// weak, medium, strong, veryStrong

// Sanitizer texte (anti-XSS)
final cleanText = InputValidator.sanitizeText(userInput);

// Valider nom d'affichage
final nameResult = InputValidator.validateDisplayName('Jean Dupont');

// Valider titre leçon
final titleResult = InputValidator.validateLessonTitle('Ma Leçon');

// Valider contenu leçon
final contentResult = InputValidator.validateLessonContent('Contenu...');

// Valider rôle
final roleResult = InputValidator.validateRole('student');

// Valider code langue
final langResult = InputValidator.validateLanguageCode('EWO');
```

### Prévenir SQL Injection

✅ **TOUJOURS** utiliser requêtes paramétrées :
```dart
// Sécurisé
await db.query('users', where: 'email = ?', whereArgs: [email]);

// Encore plus sécurisé avec validation
final emailResult = InputValidator.validateEmail(email);
if (emailResult.isValid) {
  await db.query('users', where: 'email = ?', whereArgs: [emailResult.sanitized]);
}
```

❌ **JAMAIS** :
```dart
// DANGEREUX - Ne pas faire
await db.rawQuery("SELECT * FROM users WHERE email = '$email'");
```

---

## 📊 OPTIMISATION PERFORMANCES

### Cache Optimizer

**Fichier** : `lib/core/database/database_query_optimizer.dart`

```dart
// Données statiques avec cache
final languages = await DatabaseQueryOptimizer.getCachedLanguages();
final categories = await DatabaseQueryOptimizer.getCachedCategories();

// Stats utilisateur avec cache (5 min validité)
final stats = await DatabaseQueryOptimizer.getCachedUserStatistics(userId);

// Invalider cache après mise à jour
DatabaseQueryOptimizer.invalidateUserStatsCache(userId);

// Profiler requête
final result = await DatabaseQueryOptimizer.profileQuery(
  'search_translations',
  () => db.searchTranslations(query),
);
```

### Batch Operations

```dart
// Insertion en lot (20x plus rapide)
await DatabaseQueryOptimizer.batchInsertTranslations([
  {'french_text': 'Mot1', 'translation': 'Trans1', ...},
  {'french_text': 'Mot2', 'translation': 'Trans2', ...},
  // ... 100 items
]);

// Mise à jour progrès en lot
await DatabaseQueryOptimizer.batchUpdateProgress(userId, [
  {'content_type': 'lesson', 'content_id': 1, 'status': 'completed'},
  {'content_type': 'lesson', 'content_id': 2, 'status': 'completed'},
  // ... multiple items
]);
```

### Pagination

```dart
// Charger page par page au lieu de tout
final page1 = await DatabaseQueryOptimizer.getPaginatedLessons(
  languageId: 'EWO',
  page: 1,
  pageSize: 20,
);

// Page suivante
final page2 = await DatabaseQueryOptimizer.getPaginatedLessons(
  languageId: 'EWO',
  page: 2,
  pageSize: 20,
);

// Nombre total pour pagination UI
final total = await DatabaseQueryOptimizer.getTotalLessonsCount(
  languageId: 'EWO',
);
```

---

## 🐛 DEBUGGING

### Logs

**Utiliser debugPrint** :
```dart
import 'package:flutter/foundation.dart';

debugPrint('✅ Opération réussie');
debugPrint('⚠️ Avertissement: $message');
debugPrint('❌ Erreur: $error');
debugPrint('📊 Statistiques: $stats');
```

**Production** : `debugPrint` est automatiquement désactivé en release.

### Inspecter Base de Données

**Méthode 1 : SQLite Browser**
```bash
# Copier DB depuis appareil
adb pull /data/data/com.maa_yegue.app/databases/maa_yegue_app.db

# Ouvrir avec DB Browser
```

**Méthode 2 : Code Debug**
```dart
// Ajouter dans code temporairement
final database = await UnifiedDatabaseService.instance.database;
final path = await database.getPath();
debugPrint('Database path: $path');

// Voir stats
final stats = await DatabaseQueryOptimizer.getDatabaseStatistics();
debugPrint('DB Stats: $stats');
```

### Flutter DevTools

```bash
# Lancer DevTools
flutter pub global activate devtools
flutter pub global run devtools

# Connecter à app en cours
# URL affiché dans console après flutter run
```

**Fonctionnalités utiles** :
- 🔍 Inspector : Inspecter widget tree
- ⚡ Performance : Identifier lags
- 📊 Memory : Détecter fuites mémoire
- 🌐 Network : Voir requêtes HTTP
- 📝 Logging : Voir tous les logs

---

## 📝 CONVENTIONS DE CODE

### Nommage

**Fichiers** :
- snake_case : `user_profile_view.dart`
- Suffixes : `_view.dart`, `_viewmodel.dart`, `_service.dart`, `_model.dart`

**Classes** :
- PascalCase : `UserProfileView`, `StudentService`
- Suffixes descriptifs : `View`, `ViewModel`, `Service`, `Model`, `Entity`

**Variables** :
- camelCase : `userId`, `displayName`, `isLoading`
- Privé : préfixe `_` : `_database`, `_isInitialized`

**Constantes** :
- camelCase : `maxGuestLessons`, `apiBaseUrl`
- SCREAMING_SNAKE_CASE pour constantes statiques : `MAX_RETRIES`

**Fonctions** :
- camelCase : `getUserById()`, `saveLessonProgress()`
- Verbes d'action : `create...()`, `update...()`, `delete...()`, `get...()`

### Commentaires

**Documentation des classes** :
```dart
/// Service pour la gestion des leçons
///
/// Permet de:
/// - Créer de nouvelles leçons
/// - Modifier leçons existantes
/// - Supprimer leçons
/// - Récupérer leçons par critères
class LessonService {
  // ...
}
```

**Documentation des méthodes** :
```dart
/// Crée une nouvelle leçon dans la base de données
///
/// Paramètres:
/// - [teacherId]: ID de l'enseignant créateur
/// - [languageId]: Code de la langue (EWO, DUA, etc.)
/// - [title]: Titre de la leçon
/// - [content]: Contenu complet de la leçon
/// - [level]: Niveau (beginner, intermediate, advanced)
///
/// Retourne:
/// - Map avec 'success' et 'lesson_id' si succès
/// - Map avec 'success' false et 'error' si échec
Future<Map<String, dynamic>> createLesson({
  required String teacherId,
  required String languageId,
  required String title,
  required String content,
  required String level,
}) async {
  // ...
}
```

### Formatage

**Utiliser dartfmt** :
```bash
# Formater tous les fichiers
dart format lib/

# Formater fichier spécifique
dart format lib/features/lessons/data/services/lesson_service.dart

# Vérifier sans modifier
dart format --output=none --set-exit-if-changed lib/
```

---

## 🔄 GIT WORKFLOW

### Branches

```
main (production)
  ├── develop (développement)
  │   ├── feature/dictionary-search
  │   ├── feature/quiz-creation
  │   ├── bugfix/login-error
  │   └── hotfix/crash-on-startup
```

### Commits

**Format** :
```
[TYPE] Description courte (50 chars max)

Description détaillée si nécessaire.

- Point 1
- Point 2

Fixes #123
```

**Types** :
- `[FEATURE]` : Nouvelle fonctionnalité
- `[FIX]` : Correction de bug
- `[REFACTOR]` : Refactoring code
- `[DOCS]` : Documentation
- `[TEST]` : Ajout/modification tests
- `[PERF]` : Amélioration performance
- `[SECURITY]` : Correction sécurité

**Exemples** :
```bash
git commit -m "[FEATURE] Add guest daily limits tracking

- Implement daily_limits table
- Add GuestLimitService
- Integrate with guest dashboard
- Add tests

Closes #45"

git commit -m "[FIX] Correct payment status update

Payment status was not updating correctly in SQLite
after webhook received.

Fixes #67"

git commit -m "[PERF] Optimize dictionary search query

- Add index on french_text
- Use full-text search
- Reduce query time from 500ms to 30ms

Performance improvement: 16x faster"
```

### Pull Requests

**Template PR** :
```markdown
## Description
Brève description des changements

## Type de changement
- [ ] Nouvelle fonctionnalité
- [ ] Correction de bug
- [ ] Refactoring
- [ ] Documentation

## Tests
- [ ] Tests unitaires ajoutés/mis à jour
- [ ] Tests d'intégration passent
- [ ] Testé manuellement sur émulateur
- [ ] Testé sur appareil réel

## Checklist
- [ ] Code formaté (dart format)
- [ ] Pas d'erreurs flutter analyze
- [ ] Documentation mise à jour
- [ ] Changements de DB documentés

## Screenshots
(Si changements UI)
```

---

## 🚀 DÉPLOIEMENT

### Build Android

```bash
# Debug APK
flutter build apk --debug

# Release APK
flutter build apk --release

# App Bundle (Google Play)
flutter build appbundle --release

# Fichiers générés
build/app/outputs/flutter-apk/app-release.apk
build/app/outputs/bundle/release/app-release.aab
```

### Build iOS

```bash
# Debug
flutter build ios --debug

# Release
flutter build ios --release

# Fichiers générés
build/ios/iphoneos/Runner.app
```

### Signing Configuration

**Android** : `android/app/build.gradle.kts`
```kotlin
signingConfigs {
    create("release") {
        storeFile = file("keystore.jks")
        storePassword = System.getenv("KEYSTORE_PASSWORD")
        keyAlias = "release"
        keyPassword = System.getenv("KEY_PASSWORD")
    }
}

buildTypes {
    release {
        signingConfig = signingConfigs.getByName("release")
    }
}
```

**Variables d'environnement** :
```bash
export KEYSTORE_PASSWORD=your_password
export KEY_PASSWORD=your_key_password
```

---

## 🔍 OUTILS RECOMMANDÉS

### IDE

**VS Code** (Recommandé)
- Extension : Dart
- Extension : Flutter
- Extension : SQLite Viewer
- Extension : Error Lens

**Android Studio**
- Flutter plugin
- Dart plugin
- Emulateur intégré

### Outils SQLite

- **DB Browser for SQLite** - Interface graphique
- **SQLiteStudio** - Éditeur puissant
- **sqlite3 CLI** - Ligne de commande

### Outils API

- **Postman** - Test APIs REST
- **Firebase Console** - Gestion services
- **FlutterFire CLI** - Configuration Firebase

### Outils Git

- **GitHub Desktop** - Interface Git
- **GitKraken** - Client Git avancé
- **SourceTree** - Alternative gratuite

---

## 📚 RESSOURCES D'APPRENTISSAGE

### Documentation Officielle

- **Flutter** : https://flutter.dev/docs
- **Dart** : https://dart.dev/guides
- **SQLite** : https://www.sqlite.org/docs.html
- **Firebase** : https://firebase.google.com/docs
- **sqflite** : https://pub.dev/packages/sqflite

### Tutoriels Recommandés

- Flutter Clean Architecture
- State Management avec Provider
- SQLite in Flutter
- Firebase Integration

### Communautés

- Stack Overflow (tag: flutter)
- Flutter Discord
- r/FlutterDev (Reddit)
- Flutter Community Slack

---

## ✅ CHECKLIST DÉVELOPPEUR

### Avant de Commencer une Tâche

- [ ] Lire spécifications complètes
- [ ] Comprendre architecture module concerné
- [ ] Identifier dépendances
- [ ] Créer branche git

### Pendant le Développement

- [ ] Écrire code propre et commenté
- [ ] Valider toutes les entrées utilisateur
- [ ] Gérer tous les cas d'erreur
- [ ] Utiliser UnifiedDatabaseService pour données
- [ ] Logger événements Firebase appropriés
- [ ] Tester au fur et à mesure

### Avant de Commit

- [ ] Formater code : `dart format lib/`
- [ ] Analyser : `flutter analyze` → 0 erreurs
- [ ] Tester : `flutter test` → tous passent
- [ ] Vérifier imports inutilisés
- [ ] Documenter changements majeurs
- [ ] Mettre à jour CHANGELOG si nécessaire

### Avant de Merger

- [ ] Rebase sur develop
- [ ] Résoudre conflits
- [ ] Tests d'intégration passent
- [ ] Revue de code approuvée
- [ ] Documentation à jour

---

## 🎯 CONSEILS PRATIQUES

### 1. Hot Reload

```bash
# Pendant flutter run
r  # Hot reload (rapide, préserve état)
R  # Hot restart (complet, reset état)
p  # Afficher rendering grid
o  # Changer orientation
q  # Quitter
```

### 2. Productive Shortcuts

**VS Code** :
- `Ctrl + .` : Quick fix
- `F12` : Aller à définition
- `Alt + F12` : Peek définition
- `Shift + F12` : Trouver références
- `Ctrl + P` : Rechercher fichier

**Android Studio** :
- `Alt + Enter` : Quick fix
- `Ctrl + B` : Aller à définition
- `Ctrl + Alt + B` : Aller à implémentation
- `Alt + F7` : Trouver usages

### 3. Génération Code

```bash
# Générer code pour models
flutter pub run build_runner build

# Nettoyer et régénérer
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (régénère automatiquement)
flutter pub run build_runner watch
```

---

## ✅ RÉSUMÉ

**Architecture** : Clean Architecture + Hybrid (SQLite + Firebase)  
**Langage** : Dart 3.8.1+ avec null-safety  
**Base de données** : SQLite via sqflite  
**Services cloud** : Firebase (8 services)  
**State Management** : Provider  
**Navigation** : go_router  
**Tests** : flutter_test + mockito  
**CI/CD** : À implémenter  

Ce guide vous donne tous les outils pour contribuer efficacement à Ma'a yegue! 🚀

---

**Document créé** : 7 Octobre 2025  
**Fichiers liés** :
- `07_GUIDE_OPERATIONNEL.md`
- `08_PROCEDURES_MAINTENANCE.md`
- `09_FAQ_TECHNIQUE.md`
