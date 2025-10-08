# 🚀 Guide de Démarrage Rapide - Ma'a yegue v2.0

## Installation et Lancement Rapide

### 1. Pré-requis
```powershell
# Vérifier Flutter
flutter doctor -v

# Vérifier que vous avez:
# - Flutter SDK 3.8.1+
# - Android SDK ou Xcode
# - Git
```

### 2. Installation
```powershell
# Cloner le projet (si pas déjà fait)
cd E:\project\mayegue-mobile

# Installer les dépendances
flutter pub get

# Nettoyer le projet
flutter clean
```

### 3. Lancement

```powershell
# Voir les devices disponibles
flutter devices

# Lancer sur Android
flutter run

# Lancer sur iOS (Mac uniquement)
flutter run -d ios

# Lancer sur Web
flutter run -d chrome
```

---

## 🔧 Résolution Problème Android

Si `flutter run` ne lance pas sur Android:

```powershell
# Solution Rapide #1
flutter clean
flutter pub get
adb kill-server
adb start-server
flutter run

# Solution Rapide #2
flutter build apk --debug
adb install build/app/outputs/flutter-apk/app-debug.apk

# Solution Rapide #3 (Mode Verbose)
flutter run -v
# Examiner les logs pour identifier le problème
```

---

## 📝 Tester les Modules

### Tester Module Guest
```dart
// Dans Flutter DevTools ou code:
import 'package:maa_yegue/features/guest/data/services/guest_dictionary_service.dart';
import 'package:maa_yegue/features/guest/data/services/guest_limit_service.dart';

// Récupérer langues
final languages = await GuestDictionaryService.getAvailableLanguages();
print('Langues: ${languages.length}'); // Should be 7

// Vérifier limites
final remaining = await GuestLimitService.getRemainingLimits();
print('Remaining lessons: ${remaining['lessons']}'); // Should be 5
```

### Tester Module Student
```dart
import 'package:maa_yegue/features/learner/data/services/student_service.dart';

// Créer un étudiant test
final userId = 'test-student-123';

// Sauvegarder progression leçon
await StudentService.saveLessonProgress(
  userId: userId,
  lessonId: 1,
  status: 'completed',
  score: 90.0,
  timeSpent: 300,
);

// Voir statistiques
final stats = await StudentService.getStatistics(userId);
print('Lessons completed: ${stats['total_lessons_completed']}');
print('XP: ${stats['experience_points']}');
```

### Tester Module Teacher
```dart
import 'package:maa_yegue/features/teacher/data/services/teacher_service.dart';

// Créer une leçon
final result = await TeacherService.createLesson(
  teacherId: 'teacher-123',
  languageId: 'EWO',
  title: 'Ma Première Leçon',
  content: 'Contenu de la leçon...',
  level: 'beginner',
  status: 'draft',
);

print('Lesson created: ${result['success']}');
print('Lesson ID: ${result['lesson_id']}');
```

### Tester Module Admin
```dart
import 'package:maa_yegue/features/admin/data/services/admin_service.dart';

// Voir statistiques plateforme
final platformStats = await AdminService.getPlatformStatistics();
print('Total users: ${platformStats['total_users']}');
print('Total students: ${platformStats['total_students']}');
print('Total teachers: ${platformStats['total_teachers']}');

// Voir top étudiants
final topStudents = await AdminService.getTopStudents(limit: 10);
for (var student in topStudents) {
  print('${student['display_name']}: ${student['total_xp']} XP');
}
```

---

## 🗄️ Base de Données

### Vérifier que la DB est Bien Initialisée

```dart
import 'package:maa_yegue/core/database/unified_database_service.dart';

final db = UnifiedDatabaseService.instance;

// Vérifier version
final version = await db.getMetadata('db_version');
print('DB Version: $version'); // Should be '2'

// Vérifier langues
final languages = await db.getAllLanguages();
print('Languages count: ${languages.length}'); // Should be 7

// Vérifier traductions
final translations = await db.getTranslationsByLanguage('EWO');
print('Ewondo translations: ${translations.length}');
```

### Régénérer la Base de Données Cameroon

```powershell
cd docs/database-scripts
python create_cameroon_db.py

# Le fichier cameroon_languages.db sera créé
# Copier vers:
copy cameroon_languages.db ..\..\assets\databases\cameroon_languages.db

# Ou sur Linux/Mac:
# cp cameroon_languages.db ../../assets/databases/
```

---

## 🧪 Exécuter les Tests

```powershell
# Tous les tests
flutter test

# Tests spécifiques
flutter test test/unit/services/student_service_test.dart
flutter test test/unit/database/unified_database_service_test.dart
flutter test test/integration/hybrid_architecture_test.dart

# Avec coverage
flutter test --coverage
```

---

## 📱 Tester sur Appareil

### Android
```powershell
# Activer débogage USB sur appareil
# Puis:
adb devices
flutter run

# Si problème de connexion:
adb kill-server
adb start-server
flutter run -v
```

### iOS (Mac seulement)
```bash
# Ouvrir simulateur
open -a Simulator

# Lancer
flutter run
```

---

## 🔑 Créer Premier Admin

Une fois l'app lancée, créer le premier administrateur:

```dart
// Option 1: Via code (temporaire)
import 'package:maa_yegue/core/database/unified_database_service.dart';

final db = UnifiedDatabaseService.instance;

await db.upsertUser({
  'user_id': 'admin-first',
  'firebase_uid': 'admin-first',
  'email': 'admin@maayegue.com',
  'display_name': 'Super Admin',
  'role': 'admin',
  'subscription_status': 'lifetime',
  'created_at': DateTime.now().millisecondsSinceEpoch,
  'updated_at': DateTime.now().millisecondsSinceEpoch,
});

// Option 2: Via Firebase Auth puis SQL
// 1. S'inscrire normalement dans l'app
// 2. Aller dans SQLite et changer role de 'student' à 'admin'
```

---

## 🐛 Debugging Courant

### Problème: App crash au démarrage
```powershell
# Vérifier logs
flutter logs

# Vérifier si database est copiée
# Le fichier doit être dans: assets/databases/cameroon_languages.db
```

### Problème: "Database not found"
```powershell
# Vérifier pubspec.yaml
#   assets:
#     - assets/databases/cameroon_languages.db

# Rebuild
flutter clean
flutter pub get
flutter run
```

### Problème: "No users found"
```powershell
# La base users est vide au début
# Créer un compte via l'interface d'inscription
# Ou insérer test user dans SQLite
```

---

## 📊 Monitorer l'Application

### Firebase Console
1. Aller sur console.firebase.google.com
2. Sélectionner projet Ma'a yegue
3. Voir:
   - **Authentication**: Utilisateurs authentifiés
   - **Analytics**: Événements et propriétés
   - **Crashlytics**: Rapports d'erreurs
   - **Cloud Messaging**: Notifications envoyées

### SQLite Database
```powershell
# Sur Android
adb shell
run-as com.example.maa_yegue
cd databases
ls -la

# Copier DB vers PC pour inspecter
adb pull /data/data/com.example.maa_yegue/databases/maa_yegue_app.db ./

# Ouvrir avec DB Browser for SQLite
# https://sqlitebrowser.org/
```

---

## 🎯 Vérification Rapide

Après migration, vérifiez:

```powershell
# 1. Compilation sans erreurs critiques
flutter analyze --no-fatal-infos

# 2. Tests passent
flutter test

# 3. Build réussit
flutter build apk --debug

# 4. App se lance
flutter run
```

Si tout est ✅, la migration est un succès!

---

**Guide créé le**: 7 Octobre 2025  
**Pour**: Ma'a yegue v2.0 - Architecture Hybride

