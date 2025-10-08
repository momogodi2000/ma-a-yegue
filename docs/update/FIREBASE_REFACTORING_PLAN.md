# 🔥 Plan de Refactorisation Firebase → SQLite

**Date de création**: 7 Octobre 2025  
**Objectif**: Migrer toutes les opérations de stockage de données de Firestore vers SQLite  
**Statut**: En cours - Étape 4/12

---

## 📋 Résumé de la Migration

### Principe de l'Architecture Hybride

**Firebase** (Services uniquement):
- ✅ **Authentication** (FirebaseAuth) - Login, signup, password reset
- ✅ **Cloud Messaging** (FCM) - Push notifications
- ✅ **Analytics** - Événements, user properties
- ✅ **Crashlytics** - Error reporting
- ✅ **Storage** - Fichiers médias (audio, vidéo, images)
- ✅ **Cloud Functions** - Fonctions serverless (si nécessaire)
- ✅ **Performance** - Monitoring performance

**SQLite** (Stockage de toutes les données):
- ✅ Utilisateurs (profils, rôles, préférences)
- ✅ Progression utilisateur
- ✅ Statistiques utilisateur
- ✅ Limites journalières (guests)
- ✅ Dictionnaire (7 langues)
- ✅ Leçons (70+)
- ✅ Quiz (18+)
- ✅ Favoris
- ✅ Contenus créés par enseignants
- ✅ Abonnements et paiements
- ✅ Toutes autres données

---

## ✅ Fichiers Déjà Refactorés

### 1. Service Firebase Principal
**Fichier**: `lib/core/services/firebase_service.dart`

**Changements effectués**:
- ❌ Supprimé: `import 'package:cloud_firestore/cloud_firestore.dart'`
- ❌ Supprimé: `late final FirebaseFirestore _firestore`
- ❌ Supprimé: `FirebaseFirestore get firestore => _firestore`
- ❌ Supprimé: Configuration Firestore offline persistence
- ✅ Ajouté: `import '../database/unified_database_service.dart'`
- ✅ Ajouté: `final UnifiedDatabaseService _database`
- ✅ Modifié: FCM token sauvegardé dans SQLite via `_database.upsertUser()`
- ✅ Ajouté: Méthodes analytics `logEvent()` et `setUserProperties()`

**Statut**: ✅ Complété

---

## 🔄 Fichiers à Refactorer (par priorité)

### PRIORITÉ 1: Services de Données Principaux

#### 1.1. Quiz Service
**Fichier**: `lib/features/quiz/data/services/quiz_service.dart`

**Problèmes identifiés**:
- Utilise `FirebaseFirestore.instance`
- Méthode `_quizFromFirestore()` pour convertir documents Firestore
- Sauvegarde des scores quiz dans Firestore

**Actions requises**:
- [ ] Remplacer toutes les lectures quiz Firestore par SQLite
- [ ] Utiliser `UnifiedDatabaseService.getQuizById()`
- [ ] Utiliser `UnifiedDatabaseService.getQuizQuestions()`
- [ ] Sauvegarder scores dans `user_progress` table SQLite
- [ ] Supprimer `import 'package:cloud_firestore/cloud_firestore.dart'`
- [ ] Supprimer `_quizFromFirestore()` méthode

#### 1.2. Progress Tracking Service
**Fichier**: `lib/features/lessons/data/services/progress_tracking_service.dart`

**Problèmes identifiés**:
- Utilise `FirebaseFirestore.instance`
- Sauvegarde progression dans Firestore collections

**Actions requises**:
- [ ] Remplacer par `UnifiedDatabaseService.saveProgress()`
- [ ] Utiliser `UnifiedDatabaseService.getProgress()`
- [ ] Utiliser `UnifiedDatabaseService.getUserAllProgress()`
- [ ] Supprimer dépendance Firestore

#### 1.3. Course Service
**Fichier**: `lib/features/lessons/data/services/course_service.dart`

**Problèmes identifiés**:
- Sauvegarde cours dans Firestore
- Lectures depuis Firestore

**Actions requises**:
- [ ] Remplacer par `UnifiedDatabaseService.getLessonsByLanguage()`
- [ ] Remplacer par `UnifiedDatabaseService.getLessonById()`
- [ ] Pour création contenu enseignant: utiliser `user_created_content` table
- [ ] Supprimer dépendance Firestore

#### 1.4. Level Management Service
**Fichier**: `lib/features/lessons/data/services/level_management_service.dart`

**Problèmes identifiés**:
- Reçoit `FirebaseFirestore` dans constructeur
- Sauvegarde niveaux utilisateur dans Firestore

**Actions requises**:
- [ ] Modifier constructeur: remplacer `FirebaseFirestore` par `UnifiedDatabaseService`
- [ ] Sauvegarder niveaux dans `user_statistics` table
- [ ] Utiliser `incrementStatistic()` pour progression
- [ ] Supprimer dépendance Firestore

---

### PRIORITÉ 2: Services de Paiement

#### 2.1. Payment Remote Datasource
**Fichier**: `lib/features/payment/data/datasources/payment_remote_datasource.dart`

**Problèmes identifiés**:
- Sauvegarde paiements dans Firestore
- Sauvegarde abonnements dans Firestore
- Utilise `firebaseService.firestore`

**Actions requises**:
- [ ] Créer table `payments` dans SQLite (voir schema ci-dessous)
- [ ] Créer table `subscriptions` dans SQLite
- [ ] Remplacer `PaymentModel.toFirestore()` par `PaymentModel.toSQLite()`
- [ ] Remplacer `PaymentModel.fromFirestore()` par `PaymentModel.fromSQLite()`
- [ ] Ajouter méthodes dans `UnifiedDatabaseService`:
  - `savePayment(Map<String, dynamic> paymentData)`
  - `getPaymentById(String paymentId)`
  - `getUserPayments(String userId)`
  - `saveSubscription(Map<String, dynamic> subscriptionData)`
  - `getUserActiveSubscription(String userId)`
  - `updateSubscriptionStatus(String subscriptionId, String status)`

**Nouveau schema SQLite à ajouter**:
```sql
CREATE TABLE IF NOT EXISTS payments (
  payment_id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  amount REAL NOT NULL,
  currency TEXT DEFAULT 'XAF',
  status TEXT NOT NULL, -- pending, completed, failed, refunded
  payment_method TEXT, -- stripe, mobile_money, etc.
  transaction_id TEXT,
  description TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);

CREATE TABLE IF NOT EXISTS subscriptions (
  subscription_id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  plan_type TEXT NOT NULL, -- monthly, yearly, lifetime
  status TEXT NOT NULL, -- active, expired, cancelled
  start_date TEXT NOT NULL,
  end_date TEXT,
  auto_renew INTEGER DEFAULT 0,
  payment_id TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(user_id),
  FOREIGN KEY (payment_id) REFERENCES payments(payment_id)
);

CREATE INDEX IF NOT EXISTS idx_payments_user ON payments(user_id);
CREATE INDEX IF NOT EXISTS idx_payments_status ON payments(status);
CREATE INDEX IF NOT EXISTS idx_subscriptions_user ON subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_subscriptions_status ON subscriptions(status);
```

#### 2.2. Payment Models
**Fichiers**: 
- `lib/features/payment/data/models/payment_model.dart`
- `lib/features/payment/data/models/subscription_model.dart`

**Actions requises**:
- [ ] Garder les modèles mais remplacer méthodes:
  - `fromFirestore()` → `fromSQLite()`
  - `toFirestore()` → `toSQLite()`
- [ ] Ajuster les types de données (Timestamp → String ISO8601)

---

### PRIORITÉ 3: Utilitaires et Scripts

#### 3.1. Language Seeder
**Fichier**: `lib/core/utils/language_seeder.dart`

**Problèmes identifiés**:
- Seed langues dans Firestore
- Utilisé uniquement pour initialisation

**Actions requises**:
- [ ] **SUPPRIMER CE FICHIER** - Les langues sont maintenant dans SQLite via script Python
- [ ] Vérifier si utilisé quelque part et supprimer les références
- [ ] Les 7 langues sont déjà dans `cameroon_languages.db`

#### 3.2. Seed Languages Script
**Fichier**: `lib/scripts/seed_languages.dart`

**Actions requises**:
- [ ] **SUPPRIMER CE FICHIER** - Remplacé par script Python
- [ ] Toutes les données seed sont dans `create_cameroon_db.py`

---

### PRIORITÉ 4: Sync et Offline

#### 4.1. Sync Manager
**Fichier**: `lib/core/sync/sync_manager.dart`

**Problèmes identifiés**:
- Référence `toFirestore()` et `fromFirestore()`
- Gère conflits entre local et remote

**Actions requises**:
- [ ] **DÉCISION ARCHITECTURE**: En mode 100% SQLite, le sync n'est plus nécessaire
- [ ] **Option 1**: Supprimer complètement le sync manager
- [ ] **Option 2**: Garder pour future feature de backup cloud
- [ ] Pour l'instant: **Désactiver le sync** et documenter

#### 4.2. Offline Sync Service
**Fichier**: `lib/core/sync/offline_sync_service.dart`

**Actions requises**:
- [ ] Même décision que sync_manager
- [ ] SQLite est déjà offline-first
- [ ] **Recommandation**: Supprimer ou désactiver

---

### PRIORITÉ 5: Widgets et UI

#### 5.1. Newsletter Subscription Widget
**Fichier**: `lib/shared/widgets/newsletter_subscription_widget.dart`

**Problèmes identifiés**:
- Sauvegarde emails newsletter dans Firestore
- Utilise `firebaseService.firestore`

**Actions requises**:
- [ ] Créer table `newsletter_subscriptions` dans SQLite:
```sql
CREATE TABLE IF NOT EXISTS newsletter_subscriptions (
  email TEXT PRIMARY KEY,
  subscribed_at TEXT NOT NULL,
  is_active INTEGER DEFAULT 1,
  user_id TEXT,
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);
```
- [ ] Ajouter méthodes dans `UnifiedDatabaseService`:
  - `subscribeToNewsletter(String email, {String? userId})`
  - `unsubscribeFromNewsletter(String email)`
  - `isEmailSubscribed(String email)`

#### 5.2. App Providers
**Fichier**: `lib/shared/providers/app_providers.dart`

**Problèmes identifiés**:
- Passe `firestore` à certains providers

**Actions requises**:
- [ ] Identifier tous les providers qui reçoivent `firestore`
- [ ] Remplacer par `UnifiedDatabaseService.instance`
- [ ] Vérifier les dépendances

---

## 🗑️ Fichiers à Supprimer

Ces fichiers ne sont plus nécessaires dans l'architecture hybride:

- [ ] `lib/core/utils/language_seeder.dart` - Remplacé par script Python
- [ ] `lib/scripts/seed_languages.dart` - Remplacé par script Python
- [ ] `lib/core/sync/sync_manager.dart` - Pas de sync Firestore
- [ ] `lib/core/sync/offline_sync_service.dart` - SQLite est déjà offline

**Note**: Vérifier d'abord les dépendances avant suppression!

---

## 🧪 Fichiers de Test à Mettre à Jour

#### Test Firebase Connectivity
**Fichier**: `test/test_firebase_connectivity.dart`

**Actions requises**:
- [ ] Supprimer test Firestore (lignes 98-116)
- [ ] Garder tests Auth, FCM, Analytics, Crashlytics
- [ ] Ajouter tests SQLite connectivity

#### Test Config
**Fichier**: `test/test_config.dart`

**Actions requises**:
- [ ] Supprimer méthode `_clearFirestoreData()`
- [ ] Ajouter méthode `_clearSQLiteData()` pour tests
- [ ] Utiliser `UnifiedDatabaseService` pour cleanup

---

## 📦 Dépendances à Modifier

### pubspec.yaml

**À supprimer**:
```yaml
cloud_firestore: ^4.17.5  # ❌ Plus nécessaire
```

**À garder**:
```yaml
firebase_core: ^2.32.0          # ✅ Base Firebase
firebase_auth: ^4.20.0          # ✅ Authentication
firebase_storage: ^11.7.7       # ✅ Fichiers médias
firebase_messaging: ^14.7.10    # ✅ Push notifications
firebase_analytics: ^10.8.0     # ✅ Analytics
firebase_crashlytics: ^3.4.9    # ✅ Error reporting
firebase_performance: ^0.9.4+7  # ✅ Performance
cloud_functions: ^4.6.7         # ✅ Cloud Functions (si utilisé)
sqflite: ^2.3.0                 # ✅ SQLite local
```

**Actions**:
- [ ] Retirer `cloud_firestore` de `pubspec.yaml`
- [ ] Exécuter `flutter pub get`
- [ ] Vérifier qu'aucune erreur de compilation

---

## 🎯 Plan d'Action Étape par Étape

### Phase 1: Services Core (ACTUEL)
- [x] Refactorer `firebase_service.dart`
- [ ] Refactorer `quiz_service.dart`
- [ ] Refactorer `progress_tracking_service.dart`
- [ ] Refactorer `course_service.dart`
- [ ] Refactorer `level_management_service.dart`

### Phase 2: Paiements
- [ ] Ajouter tables `payments` et `subscriptions` au script Python
- [ ] Mettre à jour `UnifiedDatabaseService` avec méthodes paiement
- [ ] Refactorer `payment_remote_datasource.dart`
- [ ] Refactorer `payment_model.dart` et `subscription_model.dart`

### Phase 3: UI et Widgets
- [ ] Refactorer `newsletter_subscription_widget.dart`
- [ ] Refactorer `app_providers.dart`

### Phase 4: Cleanup
- [ ] Supprimer fichiers obsolètes
- [ ] Supprimer dépendance `cloud_firestore`
- [ ] Mettre à jour tests

### Phase 5: Validation
- [ ] Exécuter tous les tests
- [ ] Tester en environnement dev
- [ ] Vérifier aucune référence Firestore restante
- [ ] Build Android APK

---

## 🔍 Commandes de Vérification

### Rechercher toutes les références Firestore restantes:
```powershell
# Dans lib/
Get-ChildItem -Path lib -Recurse -Filter *.dart | Select-String -Pattern "Firestore|firestore|cloud_firestore"

# Vérifier imports
Get-ChildItem -Path lib -Recurse -Filter *.dart | Select-String -Pattern "import.*cloud_firestore"

# Vérifier références .toFirestore() ou .fromFirestore()
Get-ChildItem -Path lib -Recurse -Filter *.dart | Select-String -Pattern "toFirestore|fromFirestore"
```

### Vérifier que l'app compile sans cloud_firestore:
```powershell
flutter pub get
flutter analyze
flutter build apk --debug
```

---

## 📊 Statistiques de Migration

| Catégorie | Fichiers Total | Complétés | Restants | % |
|-----------|----------------|-----------|----------|---|
| Services Core | 5 | 1 | 4 | 20% |
| Paiements | 3 | 0 | 3 | 0% |
| UI/Widgets | 2 | 0 | 2 | 0% |
| Sync/Offline | 2 | 0 | 2 | 0% |
| Utilitaires | 2 | 0 | 2 | 0% |
| Tests | 2 | 0 | 2 | 0% |
| **TOTAL** | **16** | **1** | **15** | **6%** |

---

## ⚠️ Points d'Attention

### 1. Migration des Données Existantes
Si l'app a déjà des utilisateurs avec données dans Firestore:
- Créer un script de migration one-time
- Exporter données Firestore → JSON
- Importer JSON → SQLite
- **Note**: À implémenter si nécessaire

### 2. Authentification Firebase
- ✅ Firebase Auth continue de fonctionner normalement
- ✅ UID Firebase est lié à SQLite via `users.firebase_uid`
- ✅ Workflow: Login Firebase → Récupérer/Créer profil SQLite

### 3. Cloud Storage
- ✅ Firebase Storage garde les fichiers médias (audio, vidéo)
- ✅ URLs stockées dans SQLite (`lessons.audio_url`, `lessons.video_url`)
- ✅ Pas de changement nécessaire

### 4. Notifications Push
- ✅ FCM token sauvegardé dans SQLite (`users.fcm_token`)
- ✅ Firebase Cloud Messaging continue de fonctionner
- ✅ Notifications envoyées via Firebase Console ou Cloud Functions

---

## 📝 Checklist Finale

Avant de marquer l'étape 4 comme complétée:

- [ ] Tous les fichiers PRIORITÉ 1 refactorés
- [ ] Tous les fichiers PRIORITÉ 2 refactorés
- [ ] Tous les fichiers PRIORITÉ 3 refactorés
- [ ] Fichiers obsolètes supprimés
- [ ] `cloud_firestore` retiré de `pubspec.yaml`
- [ ] Aucune référence Firestore dans `lib/`
- [ ] Tests mis à jour
- [ ] `flutter analyze` sans erreurs
- [ ] `flutter build apk` réussit
- [ ] Tests manuels: Auth, Quiz, Lessons, Progress
- [ ] Documentation mise à jour

---

**Dernière mise à jour**: 7 Octobre 2025, 17:30 GMT  
**Responsable**: Senior Developer AI Assistant
