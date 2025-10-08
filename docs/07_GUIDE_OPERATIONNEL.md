# ⚙️ GUIDE OPÉRATIONNEL - MA'A YEGUE

## 📋 Guide pour l'Exploitation Quotidienne

Ce document couvre toutes les opérations courantes pour maintenir Ma'a yegue en production.

---

## 🚀 LANCEMENT DE L'APPLICATION

### Démarrage Production

```bash
# 1. Vérifier environnement
flutter doctor -v

# 2. Nettoyer builds précédents
flutter clean

# 3. Obtenir dépendances
flutter pub get

# 4. Vérifier aucune erreur
flutter analyze

# 5. Exécuter tests critiques
flutter test test/integration/

# 6. Build production
flutter build apk --release    # Android
flutter build ios --release    # iOS

# 7. Déployer sur stores
# (Voir section Déploiement)
```

### Vérification Post-Démarrage

**Checklist dans les 30 premières minutes** :

- [ ] App se lance sans crash
- [ ] Firebase services connectés
- [ ] Base de données initialisée
- [ ] Dictionnaire accessible
- [ ] Authentification fonctionne
- [ ] Paiements fonctionnels
- [ ] Notifications reçues
- [ ] Analytics enregistre événements
- [ ] Crashlytics actif

**Commandes de vérification** :
```dart
// Dans code ou console debug
final db = UnifiedDatabaseService.instance;

// Vérifier langues
final languages = await db.getAllLanguages();
print('Languages: ${languages.length}'); // Doit être 7

// Vérifier traductions
final translations = await db.searchTranslations('bonjour');
print('Translations: ${translations.length}'); // > 0

// Vérifier Firebase
print('Firebase connected: ${FirebaseService().isAuthenticated}');
```

---

## 👥 GESTION DES UTILISATEURS

### Créer le Premier Administrateur

**Méthode 1 : Via Script SQL Direct**

```bash
# 1. Localiser base de données
adb shell run-as com.maa_yegue.app

# 2. Ouvrir base
cd databases
sqlite3 maa_yegue_app.db

# 3. Créer admin
INSERT INTO users VALUES (
  'admin-001',
  'firebase-uid-admin',
  'admin@maayegue.com',
  'Administrateur Principal',
  'admin',
  'lifetime',
  NULL,
  strftime('%s', 'now') * 1000,
  strftime('%s', 'now') * 1000,
  NULL,
  1,
  1,  -- is_default_admin
  'email',
  0, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
);

# 4. Vérifier
SELECT * FROM users WHERE role = 'admin';

# 5. Quitter
.quit
```

**Méthode 2 : Via Code Temporaire**

```dart
// Ajouter dans main.dart temporairement
void _createFirstAdmin() async {
  final db = UnifiedDatabaseService.instance;
  
  await db.upsertUser({
    'user_id': 'admin-principal',
    'firebase_uid': 'firebase-admin-uid',
    'email': 'admin@maayegue.com',
    'display_name': 'Admin Principal',
    'role': 'admin',
    'subscription_status': 'lifetime',
    'is_default_admin': 1,
    'created_at': DateTime.now().millisecondsSinceEpoch,
    'updated_at': DateTime.now().millisecondsSinceEpoch,
  });
  
  debugPrint('✅ Premier admin créé');
}

// Appeler une fois au démarrage
// Puis supprimer le code
```

**Méthode 3 : Via Firebase Auth + Promotion**

```bash
# 1. S'inscrire normalement dans l'app avec email admin

# 2. Obtenir user_id depuis Firebase Console

# 3. Promouvoir en admin via SQL
sqlite3 maa_yegue_app.db
UPDATE users SET role = 'admin', is_default_admin = 1 WHERE firebase_uid = 'user-firebase-uid';
```

### Promouvoir un Utilisateur

**Student → Teacher** :
```dart
// Via AdminService
final result = await AdminService.updateUserRole(
  userId: 'user-student-123',
  newRole: 'teacher',
);

// Log l'action
await db.insert('admin_logs', {
  'action': 'role_change',
  'user_id': 'user-student-123',
  'admin_id': currentAdminId,
  'details': json.encode({
    'old_role': 'student',
    'new_role': 'teacher',
    'reason': 'Active contributor, requested teacher access',
  }),
  'timestamp': DateTime.now().toIso8601String(),
});
```

### Désactiver un Compte

```dart
// Ne PAS supprimer, mais désactiver
await db.upsertUser({
  'user_id': 'user-problematic-456',
  'is_active': 0,  // Désactivé
  'updated_at': DateTime.now().millisecondsSinceEpoch,
});

// Log
await db.insert('admin_logs', {
  'action': 'user_deactivate',
  'user_id': 'user-problematic-456',
  'admin_id': currentAdminId,
  'details': json.encode({'reason': 'Spam, inappropriate behavior'}),
  'timestamp': DateTime.now().toIso8601String(),
});
```

---

## 📊 MONITORING QUOTIDIEN

### Firebase Console (Matin)

**À vérifier chaque matin** (5 minutes) :

1. **Crashlytics** :
   ```
   - Nouveaux crashes? → Investiguer immédiatement
   - Taux crash-free users > 99%? → ✅
   - Crash récurrent? → Créer ticket
   ```

2. **Analytics** :
   ```
   - Utilisateurs actifs hier vs avant-hier
   - Événements inhabituels? (pics, chutes)
   - Nouvelles audiences à créer?
   ```

3. **Performance** :
   ```
   - Temps démarrage app < 2s? → ✅
   - Temps réponse API < 500ms? → ✅
   - FPS > 60? → ✅
   ```

4. **Authentication** :
   ```
   - Nouveaux utilisateurs
   - Taux de succès login > 95%?
   - Tentatives échouées suspectes?
   ```

### Base de Données SQLite (Hebdomadaire)

**Requêtes de monitoring** :

```sql
-- 1. Nombre d'utilisateurs actifs (7 derniers jours)
SELECT COUNT(DISTINCT user_id)
FROM user_progress
WHERE updated_at > strftime('%s', 'now', '-7 days') * 1000;

-- 2. Top 10 utilisateurs par XP
SELECT u.display_name, s.experience_points, s.level
FROM users u
JOIN user_statistics s ON u.user_id = s.user_id
ORDER BY s.experience_points DESC
LIMIT 10;

-- 3. Contenu le plus populaire (7 derniers jours)
SELECT content_type, content_id, COUNT(*) as views
FROM user_progress
WHERE created_at > strftime('%s', 'now', '-7 days') * 1000
GROUP BY content_type, content_id
ORDER BY views DESC
LIMIT 10;

-- 4. Taux de complétion par leçon
SELECT 
  l.title,
  l.language_id,
  COUNT(CASE WHEN p.status = 'completed' THEN 1 END) as completed,
  COUNT(*) as started,
  ROUND(COUNT(CASE WHEN p.status = 'completed' THEN 1 END) * 100.0 / COUNT(*), 2) as completion_rate
FROM cameroon.lessons l
LEFT JOIN user_progress p ON p.content_id = l.lesson_id AND p.content_type = 'lesson'
GROUP BY l.lesson_id
ORDER BY completion_rate DESC;

-- 5. Langues les plus étudiées
SELECT 
  l.language_name,
  COUNT(DISTINCT p.user_id) as learners,
  COUNT(p.progress_id) as activities
FROM cameroon.languages l
LEFT JOIN user_progress p ON p.language_id = l.language_id
GROUP BY l.language_id
ORDER BY learners DESC;
```

---

## 💾 BACKUP ET RESTAURATION

### Backup Automatique (Recommandé)

**Script de backup** : `scripts/backup_database.sh`

```bash
#!/bin/bash

# Variables
APP_PACKAGE="com.maa_yegue.app"
BACKUP_DIR="./backups"
DATE=$(date +%Y%m%d_%H%M%S)

# Créer dossier backup
mkdir -p $BACKUP_DIR

# Pull database depuis appareil
adb pull /data/data/$APP_PACKAGE/databases/maa_yegue_app.db \
  $BACKUP_DIR/maa_yegue_app_$DATE.db

# Compresser
gzip $BACKUP_DIR/maa_yegue_app_$DATE.db

# Nettoyer anciens backups (> 30 jours)
find $BACKUP_DIR -name "*.db.gz" -mtime +30 -delete

echo "✅ Backup créé: maa_yegue_app_$DATE.db.gz"
```

**Cron job (Linux/Mac)** :
```bash
# Éditer crontab
crontab -e

# Backup quotidien à 2h du matin
0 2 * * * /path/to/backup_database.sh
```

### Backup Manuel

**Windows** :
```powershell
# Pull DB depuis appareil
adb pull /data/data/com.maa_yegue.app/databases/maa_yegue_app.db backup_$(Get-Date -Format "yyyyMMdd_HHmmss").db

# Ou copier assets
Copy-Item assets\databases\cameroon_languages.db backups\cameroon_languages_backup.db
```

### Restauration

**Restaurer depuis backup** :
```bash
# 1. Arrêter app
adb shell am force-stop com.maa_yegue.app

# 2. Push backup vers appareil
adb push backup_20251007_120000.db /data/data/com.maa_yegue.app/databases/maa_yegue_app.db

# 3. Fixer permissions
adb shell chmod 660 /data/data/com.maa_yegue.app/databases/maa_yegue_app.db

# 4. Relancer app
adb shell am start -n com.maa_yegue.app/.MainActivity
```

---

## 🗄️ MAINTENANCE BASE DE DONNÉES

### Nettoyage Hebdomadaire

```sql
-- 1. Supprimer limites invités anciennes (>30 jours)
DELETE FROM daily_limits 
WHERE limit_date < DATE('now', '-30 days');

-- 2. Archiver progrès anciens complétés (>90 jours)
-- (Optionnel: exporter d'abord vers table archive)
DELETE FROM user_progress 
WHERE status = 'completed' 
  AND completed_at < strftime('%s', 'now', '-90 days') * 1000;

-- 3. Nettoyer logs admin anciens (>180 jours)
DELETE FROM admin_logs 
WHERE timestamp < DATE('now', '-180 days');

-- 4. Nettoyer OTP codes expirés
DELETE FROM otp_codes 
WHERE expires_at < datetime('now');
```

### Optimisation Mensuelle

```bash
# Lancer script d'optimisation
flutter run lib/scripts/optimize_database.dart
```

```dart
// scripts/optimize_database.dart
void main() async {
  final db = UnifiedDatabaseService.instance;
  
  // VACUUM - Récupère espace
  print('🔄 Running VACUUM...');
  await DatabaseQueryOptimizer.vacuumDatabase();
  
  // ANALYZE - Optimise requêtes
  print('📊 Running ANALYZE...');
  await DatabaseQueryOptimizer.analyzeDatabase();
  
  // Vérifier indexes
  print('🔍 Checking indexes...');
  final indexSuggestions = await DatabaseQueryOptimizer.analyzeIndexes();
  
  if (indexSuggestions.isEmpty) {
    print('✅ All indexes present');
  } else {
    print('⚠️ Missing indexes:');
    indexSuggestions.forEach(print);
  }
  
  // Stats finales
  final stats = await DatabaseQueryOptimizer.getDatabaseStatistics();
  print('📊 Database Statistics:');
  print(stats);
  
  print('✅ Optimization complete!');
}
```

### Surveillance Espace Disque

```dart
// Vérifier taille DB
final size = await DatabaseQueryOptimizer.getDatabaseSize();
print('DB Size: ${(size / 1024 / 1024).toStringAsFixed(2)} MB');

// Si > 100 MB: considérer nettoyage ou archivage
```

---

## 📱 GESTION DES VERSIONS

### Versioning Sémantique

**Format** : `MAJOR.MINOR.PATCH+BUILD`

**Exemple** : `2.1.5+23`
- `2` : Version majeure (changements breaking)
- `1` : Version mineure (nouvelles fonctionnalités)
- `5` : Patch (corrections bugs)
- `23` : Build number (auto-incrémenté)

**Fichier** : `pubspec.yaml`
```yaml
version: 2.1.5+23
```

**Android** : `android/app/build.gradle.kts`
```kotlin
defaultConfig {
    versionCode = 23
    versionName = "2.1.5"
}
```

### Changelog

**Fichier** : `docs/CHANGELOG.md`

```markdown
## [2.1.5] - 2025-10-07

### Ajouté
- Architecture hybride SQLite + Firebase
- Optimisation performances (20x plus rapide)
- Module invité avec limites quotidiennes
- 1000+ traductions pour 7 langues

### Modifié
- Toutes les données maintenant dans SQLite
- Firebase utilisé uniquement pour services
- Interface utilisateur rafraîchie

### Corrigé
- Bug connexion avec Google
- Crash lors de recherche vide
- Limites invités non réinitialisées

### Sécurité
- Validation stricte toutes entrées
- Protection SQL injection
- Chiffrement paiements
```

---

## 🔄 MISE À JOUR DE L'APPLICATION

### Mise à Jour Standard (Sans Changement DB)

```bash
# 1. Increment version
# pubspec.yaml: 2.1.5+23 → 2.1.6+24

# 2. Update changelog
# docs/CHANGELOG.md

# 3. Build
flutter build apk --release

# 4. Test sur staging

# 5. Deploy
# Upload vers Play Store / App Store
```

### Mise à Jour avec Changement DB

**Exemple** : Ajouter colonne `phone_number` à `users`

```bash
# 1. Modifier schema
# lib/core/database/unified_database_service.dart

# Incrémenter version DB
static const int _databaseVersion = 3;  // Était 2

# Ajouter migration
Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 3) {
    await _migrateV2ToV3(db);
  }
}

Future<void> _migrateV2ToV3(Database db) async {
  await db.execute('ALTER TABLE users ADD COLUMN phone_number TEXT');
  
  await db.update('app_metadata',
    {'value': '3'},
    where: 'key = ?',
    whereArgs: ['db_version'],
  );
}

# 2. Tester migration sur DB test
flutter test test/unit/database/migration_test.dart

# 3. Increment version app
# 2.1.6 → 2.2.0 (changement mineur)

# 4. Build et deploy
```

### Rollback Version

**Si version déployée a problème critique** :

```bash
# 1. Build version précédente stable
git checkout v2.1.5
flutter build apk --release

# 2. Déployer en urgence
# Upload vers stores avec priorité

# 3. Notifier utilisateurs
# Via Firebase Messaging + email

# 4. Investiguer problème
# Crashlytics, logs, user reports

# 5. Fix et redeploy
git checkout develop
# Fix issues
git merge fix/critical-issue
flutter build apk --release
```

---

## 🎯 MODÉRATION DE CONTENU

### Approuver Contenu Enseignant

**Via Interface Admin** :

```
1. Dashboard Admin → "Contenu à Modérer"
2. Liste contenu status: draft
3. Pour chaque item:
   - Prévisualiser contenu
   - Vérifier qualité (grammaire, pertinence)
   - Vérifier approprié (pas spam, offensif)
   - Si OK: Cliquer "Approuver" → status: published
   - Si NON: Cliquer "Rejeter" → status: archived + commentaire
```

**Via Code** :
```dart
// Approuver
await AdminService.approveContent(contentId: 45);

// Rejeter
await AdminService.rejectContent(contentId: 46);

// Supprimer (définitif)
await AdminService.deleteContent(contentId: 47);
```

### Critères de Qualité

**Leçons** :
- ✅ Titre clair et descriptif
- ✅ Contenu structuré (intro, corps, conclusion)
- ✅ Exemples pertinents
- ✅ Langue correcte et grammaticale
- ✅ Niveau approprié au public cible
- ❌ Pas de fautes d'orthographe majeures
- ❌ Pas de contenu offensant/inapproprié
- ❌ Pas de spam/publicité

**Quiz** :
- ✅ Questions claires
- ✅ Réponses correctes vérifiées
- ✅ Explications fournies
- ✅ Difficulté cohérente avec niveau
- ❌ Pas d'ambiguïté dans questions
- ❌ Pas de réponses multiples correctes (sauf si matching)

**Traductions** :
- ✅ Traduction correcte vérifiée
- ✅ Prononciation fournie
- ✅ Catégorie appropriée
- ❌ Pas de doublons
- ❌ Pas de traductions erronées

---

## 💰 GESTION DES PAIEMENTS

### Vérifier Paiements Pendants

```sql
-- Paiements en attente > 24h (suspect)
SELECT 
  p.payment_id,
  p.user_id,
  u.email,
  p.amount,
  p.payment_method,
  datetime(p.created_at / 1000, 'unixepoch') as created
FROM payments p
JOIN users u ON p.user_id = u.user_id
WHERE p.status = 'pending'
  AND p.created_at < strftime('%s', 'now', '-1 day') * 1000
ORDER BY p.created_at DESC;
```

**Actions** :
- Vérifier statut avec gateway de paiement
- Si succès non enregistré : mettre à jour manuellement
- Si échec : marquer failed et notifier utilisateur

### Activer Abonnement Manuellement

```dart
// Si paiement vérifié manuellement
await db.upsertSubscription({
  'subscription_id': 'sub-manual-001',
  'user_id': 'user-123',
  'plan_type': 'monthly',
  'status': 'active',
  'start_date': DateTime.now().millisecondsSinceEpoch,
  'end_date': DateTime.now().add(Duration(days: 30)).millisecondsSinceEpoch,
  'payment_id': 'pay-verified-001',
  'auto_renew': 1,
  'created_at': DateTime.now().millisecondsSinceEpoch,
  'updated_at': DateTime.now().millisecondsSinceEpoch,
});

// Mettre à jour utilisateur
await db.upsertUser({
  'user_id': 'user-123',
  'subscription_status': 'premium',
  'subscription_expires_at': DateTime.now().add(Duration(days: 30)).millisecondsSinceEpoch,
  'updated_at': DateTime.now().millisecondsSinceEpoch,
});
```

### Remboursements

```dart
// Marquer paiement comme remboursé
await db.updatePaymentStatus(
  paymentId: 'pay-123',
  status: 'refunded',
);

// Révoquer abonnement
await db.upsertSubscription({
  'subscription_id': 'sub-123',
  'status': 'cancelled',
  'updated_at': DateTime.now().millisecondsSinceEpoch,
});

// Log action
await db.insert('admin_logs', {
  'action': 'refund_processed',
  'user_id': 'user-123',
  'admin_id': currentAdminId,
  'details': json.encode({
    'payment_id': 'pay-123',
    'amount': 2000,
    'reason': 'User requested refund within 7 days',
  }),
  'timestamp': DateTime.now().toIso8601String(),
});
```

---

## 🔔 GESTION DES NOTIFICATIONS

### Envoyer Notification Globale

**Via Firebase Console** :

1. Firebase Console → Cloud Messaging
2. "New notification"
3. Remplir :
   ```
   Title: Nouvelles Leçons Disponibles!
   Body: 5 nouvelles leçons Ewondo sont maintenant disponibles.
   Target: Topic "ewondo_learners"
   ```
4. Données additionnelles :
   ```json
   {
     "type": "new_content",
     "content_type": "lesson",
     "language": "ewondo",
     "deep_link": "/lessons?lang=ewondo"
   }
   ```
5. Schedule (optionnel) ou Send now

### Envoyer Notification Ciblée

**Via Cloud Function** :

```javascript
// functions/index.js
exports.sendNotificationToUser = functions.https.onCall(async (data, context) => {
  // Vérifier admin
  if (!context.auth || context.auth.token.role !== 'admin') {
    throw new functions.https.HttpsError('permission-denied');
  }

  const { userId, title, body } = data;

  // Obtenir FCM token depuis SQLite (via API)
  const fcmToken = await getUserFCMToken(userId);

  // Envoyer notification
  await admin.messaging().send({
    token: fcmToken,
    notification: { title, body },
    data: { type: 'admin_message' },
  });

  return { success: true };
});
```

**Appeler depuis app** :
```dart
final functions = FirebaseFunctions.instance;
final result = await functions.httpsCallable('sendNotificationToUser').call({
  'userId': 'user-123',
  'title': 'Bienvenue!',
  'body': 'Ton compte teacher est activé',
});
```

---

## 📊 RAPPORTS ET ANALYTICS

### Rapport Hebdomadaire Automatique

**Script** : `scripts/generate_weekly_report.dart`

```dart
void main() async {
  final db = UnifiedDatabaseService.instance;
  
  print('📊 RAPPORT HEBDOMADAIRE MA\'A YEGUE');
  print('Date: ${DateTime.now().toIso8601String()}');
  print('═' * 50);
  
  // Utilisateurs
  final platformStats = await AdminService.getPlatformStatistics();
  print('👥 UTILISATEURS');
  print('Total: ${platformStats['total_users']}');
  print('Students: ${platformStats['total_students']}');
  print('Teachers: ${platformStats['total_teachers']}');
  
  // Engagement
  print('\n🎯 ENGAGEMENT');
  print('Leçons complétées: ${platformStats['total_lessons_completed']}');
  print('Quiz tentés: ${platformStats['total_quizzes_completed']}');
  print('Mots appris: ${platformStats['total_words_learned']}');
  
  // Contenu
  final contentStats = await AdminService.getContentStatistics();
  print('\n📚 CONTENU');
  print('Traductions: ${contentStats['official_translations']}');
  print('Leçons officielles: ${contentStats['official_lessons']}');
  print('Leçons utilisateurs: ${contentStats['user_created_lessons']}');
  
  // Top étudiants
  final topStudents = await AdminService.getTopStudents(limit: 5);
  print('\n🏆 TOP 5 ÉTUDIANTS');
  topStudents.forEach((student) {
    print('${student['display_name']}: ${student['total_xp']} XP');
  });
  
  print('\n✅ Rapport généré avec succès');
}
```

**Exécuter** :
```bash
dart run lib/scripts/generate_weekly_report.dart > reports/week_$(date +%U).txt
```

### Export Données Utilisateurs (RGPD)

**Si utilisateur demande ses données** :

```dart
Future<Map<String, dynamic>> exportUserData(String userId) async {
  final db = UnifiedDatabaseService.instance;
  
  return {
    'user_profile': await db.getUserById(userId),
    'statistics': await db.getUserStatistics(userId),
    'progress': await db.getUserAllProgress(userId),
    'favorites': await db.getUserFavorites(userId),
    'created_content': await db.getUserCreatedContent(userId),
    'payments': await db.getUserPayments(userId),
    'subscriptions': // ... obtenir abonnements
    'generated_at': DateTime.now().toIso8601String(),
  };
}

// Convertir en JSON
final data = await exportUserData('user-123');
final jsonString = json.encode(data);

// Envoyer par email ou permettre téléchargement
```

---

## 🚨 GESTION DES INCIDENTS

### Incident Critique (App Crash)

**Procédure** :

```
1. IDENTIFIER (< 5 min)
   - Ouvrir Firebase Crashlytics
   - Identifier crash le plus fréquent
   - Noter stack trace et % utilisateurs affectés

2. ÉVALUER (< 10 min)
   - Severity: Critique (> 10% users) / Majeur (1-10%) / Mineur (< 1%)
   - Impact: Bloque app? Feature spécifique?
   - Versions affectées?

3. CONTOURNER (< 30 min si critique)
   - Si critique: Remote Config pour désactiver feature
   - Notifier utilisateurs (FCM)
   - Post sur réseaux sociaux si nécessaire

4. CORRIGER (< 2h si critique)
   - Créer branche hotfix/crash-xxx
   - Reproduire localement
   - Corriger problème
   - Tester exhaustivement
   - Merge vers main

5. DÉPLOYER (< 1h)
   - Build release
   - Upload vers stores en priorité
   - Activer rollout progressif (10% → 50% → 100%)

6. VÉRIFIER (< 24h)
   - Crashlytics: crash rate diminue?
   - User feedback positif?
   - Si OK: Rollout complet
   - Si NON: Rollback et réinvestiguer

7. POST-MORTEM
   - Documenter cause
   - Mesures préventives
   - Améliorer tests
```

### Incident Mineur (Feature Bug)

**Procédure simplifiée** :
```
1. Créer ticket GitHub/Jira
2. Prioriser (P1/P2/P3)
3. Assigner développeur
4. Fix dans prochain sprint
5. Inclure dans prochaine release
```

### Communication Utilisateurs

**Template notification incident** :

```
Titre: Maintenance en cours
Corps: Nous effectuons une maintenance pour améliorer votre expérience. 
      L'app sera de nouveau disponible sous peu. Merci de votre patience!

ou

Titre: Problème résolu
Corps: Le problème affectant les connexions est maintenant résolu. 
      Merci de votre compréhension!
```

---

## 📧 SUPPORT UTILISATEURS

### Outils de Support

**1. Firebase Crashlytics**
- Voir si utilisateur a rencontré crash
- Stack trace pour debug

**2. Firebase Analytics**
- Comportement utilisateur avant problème
- Événements inhabituels

**3. Base de Données**
```sql
-- Historique utilisateur
SELECT * FROM user_progress 
WHERE user_id = 'user-reported-issue'
ORDER BY updated_at DESC 
LIMIT 20;

-- Abonnement actuel
SELECT * FROM subscriptions 
WHERE user_id = 'user-reported-issue' 
  AND status = 'active';
```

### Problèmes Courants

**1. "Je ne peux plus accéder aux leçons"**

Vérification :
```sql
-- Vérifier abonnement
SELECT subscription_status, subscription_expires_at
FROM users 
WHERE user_id = 'user-xxx';

-- Si expiré: proposer renouvellement
-- Si actif mais problème: vérifier paiement
SELECT * FROM payments WHERE user_id = 'user-xxx' ORDER BY created_at DESC LIMIT 1;
```

**2. "Mon progrès a disparu"**

Vérification :
```sql
-- Vérifier progrès existe
SELECT * FROM user_progress WHERE user_id = 'user-xxx';

-- Si vide: possiblement changé d'appareil
-- Si présent: problème affichage UI
```

**3. "Je ne reçois pas les notifications"**

Vérification :
```sql
-- Vérifier FCM token
SELECT fcm_token, fcm_token_updated_at FROM users WHERE user_id = 'user-xxx';

-- Si NULL: demander ré-autoriser notifications
-- Si ancien: regénérer token
```

---

## 🔧 OUTILS D'ADMINISTRATION

### Firebase Console

**Accès** : https://console.firebase.google.com

**Dashboards importants** :
- **Authentication** : Utilisateurs inscrits, méthodes, stats
- **Analytics** : Engagement, rétention, événements
- **Crashlytics** : Crashes, erreurs, tendances
- **Cloud Messaging** : Envoi notifications
- **Remote Config** : Modifier config sans update app

### Scripts Utilitaires

**Localisation** : `scripts/`

**Scripts disponibles** :
```
add_yemba_language.dart       # Ajouter langue Yemba
seed_dictionary.dart           # Injecter données dictionnaire
seed_languages.dart            # Injecter langues
generate_weekly_report.dart    # Rapport hebdomadaire (à créer)
optimize_database.dart         # Optimisation DB (à créer)
export_user_data.dart          # Export RGPD (à créer)
```

**Créer nouveau script** :
```dart
// scripts/mon_script.dart
import 'package:maa_yegue/core/database/unified_database_service.dart';

void main() async {
  // Initialiser
  final db = UnifiedDatabaseService.instance;
  
  // Logique script
  print('🔄 Démarrage script...');
  
  // Operations
  // ...
  
  print('✅ Script terminé');
}
```

**Exécuter** :
```bash
dart run scripts/mon_script.dart
```

---

## 📈 KPIs À SURVEILLER

### Métriques Critiques (Daily)

| Métrique | Seuil Critique | Action si Dépassé |
|----------|----------------|-------------------|
| Crash rate | > 1% | Investigation immédiate |
| Login success rate | < 95% | Vérifier Firebase Auth |
| App startup time | > 3s | Optimiser initialisation |
| DAU (Daily Active Users) | Chute > 20% | Analyser cause |

### Métriques Importantes (Weekly)

| Métrique | Objectif | Action |
|----------|----------|--------|
| Nouveaux utilisateurs | Croissance constante | Campagnes marketing si stagnation |
| Taux de rétention J7 | > 40% | Améliorer onboarding si < 40% |
| Leçons complétées | Croissance constante | Ajouter nouveau contenu |
| Conversion guest → student | > 10% | Optimiser funnel conversion |

### Métriques Business (Monthly)

| Métrique | Objectif |
|----------|----------|
| Revenus mensuels | Croissance 10% MoM |
| LTV (Lifetime Value) | > 20,000 XAF |
| CAC (Customer Acquisition Cost) | < 5,000 XAF |
| Churn rate | < 5% |

---

## 🗓️ CALENDRIER MAINTENANCE

### Quotidien (5-10 min)

- [ ] Vérifier Crashlytics (nouveaux crashes?)
- [ ] Vérifier analytics (anomalies?)
- [ ] Répondre tickets support urgents

### Hebdomadaire (30 min)

- [ ] Nettoyer données anciennes (limites invités, logs)
- [ ] Modérer contenu nouveau enseignants
- [ ] Générer rapport hebdomadaire
- [ ] Vérifier paiements pendants
- [ ] Review top issues GitHub

### Mensuel (2-3h)

- [ ] VACUUM base de données
- [ ] Analyser performances DB
- [ ] Audit sécurité léger
- [ ] Mettre à jour dépendances
- [ ] Backup complet bases
- [ ] Review analytics mensuel
- [ ] Planifier nouvelles features

### Trimestriel (1 journée)

- [ ] Audit sécurité complet
- [ ] Review architecture
- [ ] Optimisations majeures
- [ ] Planification roadmap
- [ ] Formation équipe nouvelles features
- [ ] Mise à jour documentation

---

## ✅ CHECKLIST OPÉRATIONNELLE

### Avant Déploiement Production

- [ ] Tous tests passent (unit + integration)
- [ ] Flutter analyze : 0 erreurs
- [ ] Database migrations testées
- [ ] Backup BD production effectué
- [ ] Firebase config production active
- [ ] Crashlytics activé
- [ ] Analytics tracking vérifié
- [ ] Test sur appareils réels (min 3 appareils)
- [ ] Test connexion lente (throttling réseau)
- [ ] Test mode offline
- [ ] Paiements testés (sandbox)
- [ ] Notifications testées
- [ ] Changelog mis à jour
- [ ] Documentation mise à jour
- [ ] Plan rollback prêt
- [ ] Équipe notifiée
- [ ] Fenêtre de déploiement réservée

### Après Déploiement Production

**Première heure** :
- [ ] Crashlytics : Aucun nouveau crash?
- [ ] Analytics : Utilisateurs se connectent?
- [ ] Authentification : Fonctionne?
- [ ] Paiements : Process fonctionne?

**Premier jour** :
- [ ] Feedback utilisateurs (emails, reviews)
- [ ] Taux crash < 1%?
- [ ] Performance normale?
- [ ] Aucun bug critique reporté?

**Première semaine** :
- [ ] Métriques stables ou améliorées?
- [ ] Pas de régression features?
- [ ] User satisfaction positive?

---

## ✅ RÉSUMÉ

**Opérations quotidiennes** : < 15 min/jour  
**Maintenance hebdomadaire** : < 1h/semaine  
**Maintenance mensuelle** : ~3h/mois  
**Incidents** : Procédures documentées  
**Support** : Outils intégrés (Crashlytics, Analytics, SQLite)  
**Rapports** : Automatisables  

L'architecture hybride rend les opérations **simples et efficaces**! ⚡

---

**Document créé** : 7 Octobre 2025  
**Fichiers liés** :
- `08_PROCEDURES_MAINTENANCE.md`
- `09_FAQ_TECHNIQUE.md`
- `10_TROUBLESHOOTING.md`
