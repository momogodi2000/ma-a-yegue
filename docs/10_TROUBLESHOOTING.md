# 🔧 GUIDE DE DÉPANNAGE - MA'A YEGUE

## 🎯 Solutions aux Problèmes Courants

Guide complet pour résoudre rapidement les problèmes techniques.

---

## 📱 PROBLÈMES APPLICATION

### ❌ L'application ne démarre pas

#### Symptôme
App crash immédiatement après lancement, écran blanc, ou fermeture automatique.

#### Diagnostic
```bash
# Capturer logs
flutter logs > startup_crash.txt

# Chercher erreur
cat startup_crash.txt | grep -i "error\|exception\|fatal"
```

#### Solutions

**1. Base de données manquante**
```
Erreur: "Error opening database"
ou: "No such file: cameroon_languages.db"

Solution:
cd docs/database-scripts
python create_cameroon_db.py
cp cameroon_languages.db ../../assets/databases/
flutter clean
flutter pub get
flutter run
```

**2. Firebase non configuré**
```
Erreur: "FirebaseException: No Firebase App"

Solution:
1. Vérifier google-services.json dans android/app/
2. Vérifier GoogleService-Info.plist dans ios/Runner/
3. flutter clean && flutter pub get
```

**3. Dépendances corrompues**
```
Solution:
flutter clean
flutter pub cache clean
flutter pub get
```

**4. Permissions manquantes**
```
Vérifier AndroidManifest.xml contient:
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```

---

### ⏱️ L'application est lente

#### Symptôme
Temps de chargement long, UI qui lag, animations saccadées.

#### Diagnostic
```dart
// Profiler opérations
final stopwatch = Stopwatch()..start();
final result = await myOperation();
stopwatch.stop();
print('Operation took: ${stopwatch.elapsedMilliseconds}ms');
```

#### Solutions

**1. Base de données non optimisée**
```dart
// Vérifier indexes
final suggestions = await DatabaseQueryOptimizer.analyzeIndexes();

// Si indexes manquants: les créer
// Puis:
await database.execute('VACUUM');
await database.execute('ANALYZE');
```

**2. Requêtes inefficaces**
```dart
// ❌ Mauvais: N+1 queries
for (var lesson in lessons) {
  final progress = await db.getProgress(userId, 'lesson', lesson.id);
}

// ✅ Bon: Une requête avec JOIN
final lessonsWithProgress = await db.rawQuery('''
  SELECT l.*, p.status, p.score
  FROM cameroon.lessons l
  LEFT JOIN user_progress p ON p.content_id = l.lesson_id
  WHERE p.user_id = ?
''', [userId]);
```

**3. Images non optimisées**
```dart
// Utiliser cached_network_image
CachedNetworkImage(
  imageUrl: imageUrl,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
)

// Compresser images locales
flutter pub run flutter_image_compress:compress assets/images/
```

**4. Trop de widgets rebuilds**
```dart
// Utiliser const quand possible
const Text('Static Text');

// Utiliser keys pour optimiser rebuilds
ListView.builder(
  itemBuilder: (context, index) {
    return ListTile(
      key: ValueKey(items[index].id),  // IMPORTANT
      title: Text(items[index].title),
    );
  },
)
```

---

### 🔐 Problèmes d'Authentification

#### ❌ "Email already in use"

**Cause** : Email déjà enregistré.

**Solutions** :
```
1. Utilisateur a oublié → "Mot de passe oublié"
2. Typo dans email → Vérifier orthographe
3. Compte existant autre provider → Utiliser même provider
```

#### ❌ "Wrong password"

**Solution** :
```
1. Vérifier Caps Lock désactivé
2. Essayer reset password
3. Si problème persiste: contacter support
```

#### ❌ "User not found"

**Cause** : Compte n'existe pas ou supprimé.

**Solution** :
```
1. Vérifier email correct
2. Si sûr d'avoir compte: peut avoir été supprimé
3. Créer nouveau compte
```

#### ❌ "Network error" lors connexion

**Cause** : Pas de connexion internet ou Firebase inaccessible.

**Solution** :
```
1. Vérifier connexion internet
2. Essayer data mobile si sur WiFi (ou inverse)
3. Vérifier status Firebase: https://status.firebase.google.com
4. Réessayer dans quelques minutes
```

---

### 💳 Problèmes de Paiement

#### ❌ Paiement reste "pending"

**Diagnostic** :
```sql
SELECT * FROM payments WHERE status = 'pending' ORDER BY created_at DESC LIMIT 10;
```

**Solutions** :

**1. Webhook pas reçu**
```
Cause: Gateway pas envoyé webhook ou échec réseau

Solution:
- Vérifier logs gateway (Campay/Stripe dashboard)
- Obtenir statut réel transaction
- Mettre à jour manuellement si payé:

UPDATE payments SET 
  status = 'completed',
  completed_at = strftime('%s', 'now') * 1000
WHERE payment_id = 'pay-xxx';

-- Activer abonnement
```

**2. Validation échouée**
```
Cause: Montant incorrect, signature invalide

Solution:
- Vérifier montant matches
- Vérifier API keys correctes
- Vérifier environnement (test vs prod)
```

**3. Utilisateur a fermé avant fin**
```
Cause: Utilisateur a quitté processus

Solution:
- Laisser pendant 24h
- Si toujours pending: marquer abandoned
- Notifier utilisateur avec lien pour compléter
```

#### ❌ Abonnement actif mais accès refusé

**Diagnostic** :
```sql
-- Vérifier abonnement
SELECT * FROM subscriptions WHERE user_id = 'user-xxx' AND status = 'active';

-- Vérifier statut utilisateur
SELECT subscription_status, subscription_expires_at FROM users WHERE user_id = 'user-xxx';
```

**Solution** :
```dart
// Synchroniser statut
final subscription = await db.getUserActiveSubscription(userId);

if (subscription != null) {
  await db.upsertUser({
    'user_id': userId,
    'subscription_status': 'premium',
    'subscription_expires_at': subscription['end_date'],
    'updated_at': DateTime.now().millisecondsSinceEpoch,
  });
}
```

---

## 🗄️ PROBLÈMES BASE DE DONNÉES

### ❌ "Database is locked"

**Cause** : Multiple transactions simultanées.

**Solutions** :

**1. Augmenter timeout**
```dart
await openDatabase(
  path,
  options: OpenDatabaseOptions(
    version: 1,
    busyTimeout: Duration(seconds: 10),  // Défaut: 5s
  ),
);
```

**2. Éviter longues transactions**
```dart
// ❌ Mauvais
await db.transaction((txn) async {
  for (int i = 0; i < 10000; i++) {
    await txn.insert('table', data[i]);  // TRÈS LENT
  }
});

// ✅ Bon
await db.transaction((txn) async {
  final batch = txn.batch();
  for (int i = 0; i < 10000; i++) {
    batch.insert('table', data[i]);
  }
  await batch.commit();  // RAPIDE
});
```

**3. Fermer connexions inutiles**
```dart
// Utiliser singleton (déjà fait)
final db = UnifiedDatabaseService.instance;
// NE PAS créer nouvelles instances
```

### ❌ "No such table: ..."

**Cause** : Table pas créée ou mauvaise base de données.

**Solutions** :

**1. DB non initialisée**
```dart
// Forcer initialisation
await UnifiedDatabaseService.instance.database;
```

**2. Mauvaise base (main vs cameroon)**
```dart
// ❌ Erreur: Table "languages" dans DB principale
await db.query('languages');  // N'existe pas

// ✅ Correct: Table dans DB cameroon (attachée)
await db.rawQuery('SELECT * FROM cameroon.languages');
```

**3. Migration pas exécutée**
```dart
// Vérifier version DB
final version = await db.getMetadata('db_version');
print('DB Version: $version');

// Si version ancienne: app devrait migrer automatiquement
// Si pas migré: supprimer DB et réinitialiser
await db.deleteDatabase();
// Redémarrer app
```

### ❌ Base de données trop grande

**Symptôme** : DB > 500 MB, app utilise beaucoup d'espace.

**Solutions** :

**1. Nettoyer données anciennes**
```sql
-- Supprimer progrès ancien (> 6 mois)
DELETE FROM user_progress 
WHERE completed_at < strftime('%s', 'now', '-180 days') * 1000;

-- Supprimer limites invités (> 30 jours)
DELETE FROM daily_limits 
WHERE limit_date < DATE('now', '-30 days');
```

**2. VACUUM**
```sql
VACUUM;
-- Peut réduire taille de 30-50%
```

**3. Archiver données**
```dart
// Exporter anciennes données vers fichier
// Puis supprimer de DB active
```

---

## 🌐 PROBLÈMES RÉSEAU

### ❌ "Network request failed"

**Diagnostic** :
```dart
// Tester connectivité
final connectivity = await Connectivity().checkConnectivity();
print('Connection: $connectivity');  // wifi, mobile, none

// Tester Firebase
try {
  await Firebase.initializeApp();
  print('✅ Firebase accessible');
} catch (e) {
  print('❌ Firebase inaccessible: $e');
}
```

**Solutions** :

**1. Pas de connexion**
```
- Vérifier WiFi/Data activés
- Essayer réseau différent
- Vérifier pas de firewall bloquant
```

**2. Firebase status**
```
- Vérifier https://status.firebase.google.com
- Si rouge: attendre résolution Google
- Si vert: problème local (reboot appareil)
```

**3. Timeout trop court**
```dart
// Augmenter timeout Dio
final dio = Dio(BaseOptions(
  connectTimeout: Duration(seconds: 30),  // Défaut: 10s
  receiveTimeout: Duration(seconds: 30),
));
```

### ❌ Notifications push non reçues

**Diagnostic** :
```dart
// 1. Vérifier token FCM
final token = await FirebaseMessaging.instance.getToken();
print('FCM Token: $token');

// 2. Vérifier permissions
final settings = await FirebaseMessaging.instance.requestPermission();
print('Permissions: ${settings.authorizationStatus}');
```

**Solutions** :

**1. Permissions refusées**
```
Android: Settings → Apps → Ma'a yegue → Notifications → Enable
iOS: Settings → Notifications → Ma'a yegue → Allow Notifications
```

**2. Token pas sauvegardé**
```dart
// Regénérer et sauvegarder
final token = await FirebaseMessaging.instance.getToken();
await db.upsertUser({
  'user_id': userId,
  'fcm_token': token,
  'fcm_token_updated_at': DateTime.now().toIso8601String(),
});
```

**3. Topic pas souscrit**
```dart
// Souscrire à topic
await FirebaseMessaging.instance.subscribeToTopic('all_users');
await FirebaseMessaging.instance.subscribeToTopic('ewondo_learners');
```

**4. Tester notification manuelle**
```
Firebase Console → Cloud Messaging → Send test message
Enter FCM token → Test
```

---

## 🏗️ PROBLÈMES DE BUILD

### ❌ Build échoue (Android)

#### Erreur: "Execution failed for task ':app:processDebugResources'"

**Cause** : Problème resources ou Gradle.

**Solution** :
```bash
# Nettoyer complètement
flutter clean
cd android
./gradlew clean
cd ..

# Supprimer .gradle
rm -rf android/.gradle
rm -rf android/app/.gradle

# Rebuild
flutter pub get
flutter build apk
```

#### Erreur: "Unsupported class file major version 65"

**Cause** : Version Java incompatible.

**Solution** :
```
Vérifier Java version:
java -version

Doit être Java 11 ou 17 (pas 21+)

Changer dans android/app/build.gradle.kts:
compileOptions {
    sourceCompatibility = JavaVersion.VERSION_11
    targetCompatibility = JavaVersion.VERSION_11
}
```

#### Erreur: "Duplicate class found"

**Cause** : Dépendances conflictuelles.

**Solution** :
```kotlin
// android/app/build.gradle.kts
configurations.all {
    exclude(group = "org.jetbrains.kotlin", module = "kotlin-stdlib-jdk7")
    exclude(group = "org.jetbrains.kotlin", module = "kotlin-stdlib-jdk8")
}
```

### ❌ Build échoue (iOS)

#### Erreur: "CocoaPods not installed"

**Solution** :
```bash
# Installer CocoaPods
sudo gem install cocoapods

# Installer pods
cd ios
pod install
cd ..

# Rebuild
flutter build ios
```

#### Erreur: "Signing requires a development team"

**Solution** :
```
1. Ouvrir ios/Runner.xcworkspace dans Xcode
2. Sélectionner target Runner
3. Signing & Capabilities
4. Team: Sélectionner votre Apple Developer team
5. Rebuild depuis Xcode ou Flutter
```

---

## 🔥 PROBLÈMES FIREBASE

### ❌ "FirebaseException: PERMISSION_DENIED"

**Cause** : Firestore rules trop restrictives.

**Solution** :
```javascript
// firestore.rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Temporaire pour debug (ATTENTION: pas pour prod)
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
    
    // Après debug: règles strictes
    match /users/{userId} {
      allow read: if request.auth.uid == userId;
      allow write: if request.auth.uid == userId;
    }
  }
}
```

### ❌ Analytics events non visibles dans console

**Cause** : Délai de propagation ou DebugView pas activé.

**Solutions** :

**1. Activer DebugView**
```bash
# Android
adb shell setprop debug.firebase.analytics.app com.maa_yegue.app

# iOS
flutter run --dart-define=FIREBASE_ANALYTICS_DEBUG_MODE=true
```

**2. Attendre**
```
Analytics events apparaissent dans console après:
- DebugView: Temps réel
- Dashboard: 24-48 heures
```

**3. Vérifier events envoyés**
```dart
import 'package:flutter/foundation.dart';

if (kDebugMode) {
  print('📊 Logging event: lesson_start');
}

await FirebaseAnalytics.instance.logEvent(
  name: 'lesson_start',
  parameters: {'lesson_id': '1'},
);
```

### ❌ Crashlytics ne reporte pas crashes

**Solutions** :

**1. Activer en debug**
```dart
// main.dart
if (kDebugMode) {
  await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
}
```

**2. Forcer crash test**
```dart
// Ajouter bouton debug pour tester
FirebaseCrashlytics.instance.crash();  // Force crash
```

**3. Vérifier configuration**
```
Firebase Console → Crashlytics → Ensure SDK setup correctly
```

---

## 📊 PROBLÈMES DE DONNÉES

### ❌ Limites invité ne se réinitialisent pas

**Diagnostic** :
```sql
-- Vérifier limites actuelles
SELECT * FROM daily_limits WHERE device_id = 'device-xxx' ORDER BY limit_date DESC LIMIT 7;
```

**Cause** : Date système incorrecte ou bug calcul date.

**Solution** :
```dart
// Vérifier calcul date
final today = DateTime.now().toIso8601String().split('T')[0];
print('Today: $today');  // Doit être YYYY-MM-DD

// Si bug: nettoyer et recréer
await db.database.then((database) async {
  await database.delete('daily_limits', where: 'device_id = ?', whereArgs: [deviceId]);
});
```

### ❌ Progrès non sauvegardé

**Diagnostic** :
```dart
// Vérifier si utilisateur authentifié
final user = await HybridAuthService.getCurrentUser();
if (user == null) {
  print('❌ User not authenticated - progress NOT saved');
} else {
  print('✅ User authenticated - progress saved');
}
```

**Cause** : Utilisateur invité (pas authentifié).

**Solution** :
```
Invités ne peuvent pas sauvegarder progrès.
→ Encourager inscription pour sauvegarder progrès.
→ Message UI: "Inscrivez-vous pour sauvegarder votre progrès!"
```

### ❌ Statistiques incorrectes

**Diagnostic** :
```sql
-- Vérifier cohérence
SELECT 
  u.user_id,
  s.total_lessons_completed,
  (SELECT COUNT(*) FROM user_progress WHERE user_id = u.user_id AND content_type = 'lesson' AND status = 'completed') as actual_completed
FROM users u
LEFT JOIN user_statistics s ON u.user_id = s.user_id
WHERE u.user_id = 'user-xxx';

-- Si différence: recalculer
```

**Solution** : Recalculer statistiques
```dart
Future<void> recalculateUserStatistics(String userId) async {
  final database = await db.database;
  
  // Compter leçons complétées
  final lessonsResult = await database.rawQuery(
    'SELECT COUNT(*) as count FROM user_progress WHERE user_id = ? AND content_type = "lesson" AND status = "completed"',
    [userId],
  );
  final lessonsCount = Sqflite.firstIntValue(lessonsResult) ?? 0;
  
  // Compter quiz complétés
  final quizzesResult = await database.rawQuery(
    'SELECT COUNT(*) as count FROM user_progress WHERE user_id = ? AND content_type = "quiz" AND status = "completed"',
    [userId],
  );
  final quizzesCount = Sqflite.firstIntValue(quizzesResult) ?? 0;
  
  // Calculer temps total
  final timeResult = await database.rawQuery(
    'SELECT SUM(time_spent) as total FROM user_progress WHERE user_id = ?',
    [userId],
  );
  final totalTime = Sqflite.firstIntValue(timeResult) ?? 0;
  
  // Mettre à jour
  await db.upsertUserStatistics(userId, {
    'total_lessons_completed': lessonsCount,
    'total_quizzes_completed': quizzesCount,
    'total_study_time': totalTime,
  });
  
  print('✅ Statistics recalculated for $userId');
}
```

---

## 🖥️ PROBLÈMES SPÉCIFIQUES ANDROID

### ❌ "Cleartext HTTP traffic not permitted"

**Cause** : Android bloque HTTP (non-HTTPS) par défaut.

**Solution** :
```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<application
    android:usesCleartextTraffic="true"  <!-- Ajouter si nécessaire -->
    ...>
```

**Meilleure solution** : Utiliser HTTPS partout.

### ❌ App ne s'installe pas ("App not installed")

**Solutions** :

**1. Signature différente**
```bash
# Désinstaller ancienne version
adb uninstall com.maa_yegue.app

# Réinstaller
flutter install
```

**2. Espace insuffisant**
```bash
# Vérifier espace
adb shell df /data

# Si plein: nettoyer ou utiliser autre appareil
```

**3. Version Android incompatible**
```
App requiert Android 7+ (API 24)
Vérifier version appareil: Settings → About Phone → Android Version
```

### ❌ "INSTALL_FAILED_UPDATE_INCOMPATIBLE"

**Solution** :
```bash
# Désinstaller complètement
adb uninstall com.maa_yegue.app

# Réinstaller
flutter run
```

---

## 🍎 PROBLÈMES SPÉCIFIQUES iOS

### ❌ "Runner.app could not be found"

**Solution** :
```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter build ios
```

### ❌ "Code signing error"

**Solution** :
```
1. Ouvrir ios/Runner.xcworkspace dans Xcode
2. Signing & Capabilities
3. Team: Select your team
4. Automatic signing: Enable
5. Clean build folder (Cmd+Shift+K)
6. Build (Cmd+B)
```

---

## 🧪 PROBLÈMES DE TESTS

### ❌ Tests échouent: "MissingPluginException"

**Cause** : Plugin natif pas initialisé dans tests.

**Solution** :
```dart
// test/test_config.dart
void initializeTestEnvironment() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  // Mock pour SQLite
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  
  // Autres initialisations
}

// Dans chaque test file
void main() {
  setUpAll(() {
    initializeTestEnvironment();
  });
  
  // tests...
}
```

### ❌ Tests très lents

**Cause** : DB pas supprimée entre tests, accumulation données.

**Solution** :
```dart
setUp(() async {
  await db.deleteDatabase();  // DB propre pour chaque test
});

tearDown() async {
  await db.close();
});
```

---

## 🔄 PROBLÈMES DE MIGRATION

### ❌ Migration échoue après update app

**Symptôme** : App crash après mise à jour.

**Diagnostic** :
```dart
// Vérifier version DB
final version = await db.getMetadata('db_version');
print('Current DB version: $version');
print('Expected version: $_databaseVersion');
```

**Solution** :

**Option A : Forcer migration manuelle**
```dart
final database = await db.database;
// Exécuter migration manuellement
await _migrateV2ToV3(database);
```

**Option B : Réinitialiser DB (perte données)**
```dart
await db.deleteDatabase();
// App recrée DB à la version actuelle
// ATTENTION: Perte de toutes les données utilisateur
```

**Prévention** :
- Toujours tester migrations avant prod
- Backup DB avant mise à jour majeure
- Rollout progressif pour détecter problèmes tôt

---

## 🎨 PROBLÈMES UI

### ❌ Images ne chargent pas

**Solutions** :

**1. Vérifier path**
```dart
// ❌ Mauvais
Image.asset('logo.png');

// ✅ Bon
Image.asset('assets/logo/logo.jpg');
```

**2. Vérifier pubspec.yaml**
```yaml
flutter:
  assets:
    - assets/logo/
    - assets/databases/
```

**3. Rebuild après modification pubspec**
```bash
flutter pub get
flutter run
```

### ❌ Texte tronqué ou overflow

**Solution** :
```dart
// Utiliser Flexible ou Expanded
Row(
  children: [
    Expanded(  // ou Flexible
      child: Text(
        'Long text here that might overflow...',
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
    ),
  ],
)
```

---

## 🚨 PROBLÈMES CRITIQUES

### 🔥 URGENCE: App crashe pour tous les utilisateurs

**PROCÉDURE D'URGENCE** :

```
MINUTE 0-5: ASSESSMENT
──────────────────────────────────────
1. Ouvrir Crashlytics immédiatement
2. Identifier crash et pourcentage affecté
3. Noter versions affectées
4. Alerter équipe (Slack/SMS)

MINUTE 5-15: MITIGATION IMMÉDIATE
──────────────────────────────────────
Option A: Remote Config
  firebase console → Remote Config
  → Set "maintenance_mode" = true
  → Publish
  → App affiche écran maintenance au lieu de crasher

Option B: Rollback Store
  Google Play Console → Production
  → Halt rollout
  → Promote previous version

MINUTE 15-120: FIX
──────────────────────────────────────
1. git checkout develop
2. git pull
3. Reproduire crash localement
4. Identifier cause (stack trace)
5. Développer fix
6. Tester exhaustivement (20+ fois)
7. Code review rapide (2 personnes)
8. Merge hotfix

MINUTE 120-180: DEPLOY
──────────────────────────────────────
1. Increment version (ex: 2.1.5 → 2.1.6)
2. flutter build appbundle --release
3. Upload vers Play Store (emergency track)
4. Rollout: 10% → monitor 30min → 50% → 100%

POST-INCIDENT (J+1):
──────────────────────────────────────
1. Post-mortem meeting
2. Documenter incident
3. Identifier cause racine
4. Mettre en place préventions
5. Améliorer tests
6. Update runbooks
```

---

## 🔍 OUTILS DE DIAGNOSTIC

### Commandes Utiles

```bash
# Flutter
flutter doctor -v            # Vérifier environnement
flutter devices              # Lister appareils
flutter logs                 # Voir logs en temps réel
flutter analyze              # Analyser code
flutter test                 # Lancer tests
flutter clean                # Nettoyer build

# Android
adb devices                  # Lister appareils
adb logcat                   # Logs système
adb shell pm list packages   # Lister apps installées
adb uninstall com.maa_yegue.app  # Désinstaller
adb install app.apk          # Installer APK

# Git
git status                   # État working directory
git log --oneline -10        # 10 derniers commits
git diff                     # Changements non committed
git stash                    # Mettre changements de côté

# Database
sqlite3 maa_yegue_app.db     # Ouvrir DB
.tables                      # Lister tables
.schema users                # Voir schema
SELECT * FROM users LIMIT 5; # Query
```

### Scripts de Diagnostic

**Fichier** : `scripts/diagnose.dart`

```dart
import 'package:maa_yegue/core/database/unified_database_service.dart';

Future<void> runDiagnostics() async {
  print('🔍 DIAGNOSTIC MA\'A YEGUE');
  print('═' * 60);
  
  try {
    // 1. Base de données
    print('\n🗄️ Base de Données:');
    final db = UnifiedDatabaseService.instance;
    final database = await db.database;
    print('✅ DB accessible: ${database.path}');
    
    final integrityCheck = await database.rawQuery('PRAGMA integrity_check');
    print('Intégrité: ${integrityCheck.first['integrity_check']}');
    
    final version = await db.getMetadata('db_version');
    print('Version: $version');
    
    // 2. Langues
    print('\n🌍 Langues:');
    final languages = await db.getAllLanguages();
    print('Total langues: ${languages.length}');
    languages.forEach((lang) => print('  - ${lang['language_name']} (${lang['language_id']})'));
    
    // 3. Statistiques
    print('\n📊 Statistiques:');
    final platformStats = await db.getPlatformStatistics();
    print('Total utilisateurs: ${platformStats['total_users']}');
    print('Total traductions: ${platformStats['total_translations']}');
    print('Total leçons: ${platformStats['total_lessons']}');
    
    // 4. Performance
    print('\n⚡ Performance:');
    final cacheStats = DatabaseQueryOptimizer.getCacheStats();
    print('Cache items: ${cacheStats['cached_items']}');
    
    print('\n✅ Diagnostic terminé - Aucun problème détecté');
  } catch (e, stack) {
    print('\n❌ ERREUR DÉTECTÉE:');
    print(e);
    print(stack);
  }
}

void main() async {
  await runDiagnostics();
}
```

**Exécuter** :
```bash
dart run scripts/diagnose.dart
```

---

## 📞 ESCALADE PROBLÈMES

### Niveau 1: Self-Service (0-30 min)

```
1. Consulter cette documentation
2. Rechercher erreur exacte sur Google/StackOverflow
3. Vérifier GitHub Issues similaires
4. Essayer solutions proposées
```

### Niveau 2: Support Équipe (30 min - 2h)

```
1. Créer ticket GitHub avec:
   - Description problème
   - Steps to reproduce
   - Logs pertinents
   - Configuration (OS, Flutter version)
   
2. Notifier sur Slack #tech-support

3. Si urgent: Appeler tech lead
```

### Niveau 3: External Support (> 2h)

```
1. Flutter GitHub Issues
2. Firebase Support (si problème Firebase)
3. Plugin maintainer (si problème plugin)
4. Stack Overflow (question détaillée)
```

---

## ✅ CHECKLIST DÉPANNAGE

Avant de déclarer un problème "non résolu", vérifier:

### Général
- [ ] `flutter clean` effectué
- [ ] `flutter pub get` exécuté
- [ ] App redémarrée
- [ ] Appareil redémarré
- [ ] Flutter et dépendances à jour
- [ ] `flutter doctor` sans erreurs

### Base de Données
- [ ] Fichier cameroon_languages.db présent
- [ ] PRAGMA integrity_check = ok
- [ ] Indexes créés
- [ ] Version DB correcte

### Firebase
- [ ] google-services.json présent (Android)
- [ ] Firebase initialisé dans code
- [ ] Firebase status page verte
- [ ] Connexion internet fonctionnelle

### Build
- [ ] Gradle sync réussi (Android)
- [ ] Pods installés (iOS)
- [ ] Signing configuré
- [ ] Permissions dans manifests

### Tests
- [ ] Tests unitaires passent
- [ ] Tests intégration passent
- [ ] Testé sur émulateur
- [ ] Testé sur appareil réel

Si tout coché et problème persiste: Créer ticket détaillé.

---

## ✅ RÉSUMÉ

Ce guide couvre les **problèmes les plus fréquents** et leurs solutions.

**Taux de résolution attendu** : 
- 80% des problèmes résolus par flutter clean + pub get
- 15% résolus par solutions documentées ici
- 5% nécessitent investigation approfondie

**Temps moyen de résolution** :
- Problème simple : 5-10 minutes
- Problème moyen : 30-60 minutes  
- Problème complexe : 2-4 heures

Pour problèmes non couverts, consulter équipe technique ou créer GitHub Issue.

---

**Document créé** : 7 Octobre 2025  
**Dernière mise à jour** : 7 Octobre 2025  
**Fichiers liés** :
- `09_FAQ_TECHNIQUE.md`
- `06_GUIDE_DEVELOPPEUR.md`
- `07_GUIDE_OPERATIONNEL.md`
