# ❓ FAQ TECHNIQUE - MA'A YEGUE

## Questions Fréquentes Techniques

Réponses aux questions les plus fréquentes sur l'architecture, l'implémentation et l'utilisation.

---

## 🏗️ ARCHITECTURE

### Q: Pourquoi une architecture hybride?

**R**: L'architecture hybride combine le meilleur de SQLite et Firebase :

**Avantages SQLite** :
- ⚡ Vitesse : 20x plus rapide que Firebase
- 📱 Offline : Fonctionne sans internet
- 💰 Coûts : Gratuit (pas de frais cloud)
- 🔒 Privé : Données restent sur appareil
- 🎯 Contrôle : Total sur les données

**Avantages Firebase** :
- 🔐 Auth robuste : OAuth, 2FA, reset password
- 🔔 Notifications : Push en temps réel
- 📊 Analytics : Comportement utilisateurs
- 💥 Crashlytics : Détection bugs automatique
- ⚡ Performance : Monitoring intégré

**Résultat** : Performance maximale + Services cloud essentiels

### Q: Pourquoi ne pas utiliser uniquement Firebase?

**R**: Firebase Firestore serait:
- ❌ Lent (500-2000ms par requête)
- ❌ Cher (50-100€/mois pour 1000 users)
- ❌ Dépendant du réseau (offline = inutilisable)
- ❌ Coûts croissants avec utilisateurs

Avec SQLite :
- ✅ Rapide (20-100ms)
- ✅ Gratuit (0€)
- ✅ Fonctionne offline
- ✅ Coûts fixes

### Q: Les données sont-elles synchronisées entre appareils?

**R**: **Non, pas actuellement** (Phase 1).

Chaque appareil a sa propre base SQLite locale. Si un utilisateur change d'appareil :
- ✅ Authentification fonctionne (Firebase Auth)
- ✅ Rôle et abonnement conservés (dans users table)
- ❌ Progrès non transféré (local uniquement)
- ❌ Favoris non transférés

**Solution future (Phase 3)** : Synchronisation optionnelle via Firebase.

### Q: Que se passe-t-il en mode offline?

**R**: L'app fonctionne **presque complètement** offline :

**Fonctionne offline** ✅ :
- Dictionnaire (1000+ mots)
- Leçons (lecture, exercices)
- Quiz (tentative, correction)
- Statistiques personnelles
- Favoris
- Navigation complète

**Nécessite connexion** ❌ :
- Connexion/Inscription (Firebase Auth)
- Notifications push
- Paiements
- Changement de rôle

**À la reconnexion** :
- Analytics events sont envoyés (batched)
- Crashlytics reports sont envoyés
- Rien ne se perd

---

## 🗄️ BASE DE DONNÉES

### Q: Comment sont stockés les mots de passe?

**R**: Les mots de passe ne sont **JAMAIS stockés localement**.

**Processus** :
1. Utilisateur entre mot de passe
2. Envoyé à Firebase Auth (HTTPS)
3. Firebase hash avec bcrypt
4. Hash stocké sur serveurs Firebase (sécurisés)
5. App locale ne stocke QUE le token de session

SQLite stocke uniquement :
- Email
- Firebase UID (pas le mot de passe)
- Rôle et préférences

### Q: La base de données SQLite est-elle chiffrée?

**R**: **Oui**, automatiquement par le système d'exploitation.

**Android** :
- Chiffrement complet du disque (depuis Android 6+)
- Clé de chiffrement liée au compte utilisateur
- Impossible d'accéder sans déverrouiller appareil

**iOS** :
- Chiffrement fichiers app automatique
- Protection Data class (NSFileProtectionComplete)
- Keychain pour données ultra-sensibles

**Chiffrement supplémentaire** :
Si nécessaire, plugin `sqflite_sqlcipher` peut être ajouté pour chiffrement database-level.

### Q: Que faire si la base de données est corrompue?

**R**: Plusieurs niveaux de protection:

**Niveau 1: Détection**
```dart
// Vérifier intégrité au démarrage
final check = await db.rawQuery('PRAGMA integrity_check');
if (check.first['integrity_check'] != 'ok') {
  // Corruption détectée
  await handleCorruption();
}
```

**Niveau 2: Réparation automatique**
```dart
// Tenter réparation
await db.execute('PRAGMA wal_checkpoint(FULL)');
await db.execute('REINDEX');
```

**Niveau 3: Réinitialisation**
```dart
// Si réparation échoue: réinitialiser
await db.deleteDatabase();  // Supprime DB corrompue
// Au prochain démarrage: DB réinitialisée depuis assets
```

**Niveau 4: Backup**
- Si backup récent disponible: restaurer
- Perte minimale de données

### Q: Comment ajouter une nouvelle table?

**R**: Procédure en 5 étapes:

```dart
// 1. Incrémenter version
static const int _databaseVersion = 3;

// 2. Ajouter table dans _onCreate
Future<void> _onCreate(Database db, int version) async {
  // ... tables existantes
  
  await db.execute('''
    CREATE TABLE ma_nouvelle_table (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nom TEXT NOT NULL,
      description TEXT,
      created_at INTEGER NOT NULL
    )
  ''');
  
  // Index
  await db.execute('CREATE INDEX idx_nouvelle_table_nom ON ma_nouvelle_table(nom)');
}

// 3. Ajouter migration pour utilisateurs existants
Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 3) {
    // Créer table pour users avec DB v2
    await db.execute('''CREATE TABLE ma_nouvelle_table (...)''');
  }
}

// 4. Ajouter méthodes CRUD
Future<int> insertIntoNewTable(Map<String, dynamic> data) async {
  final db = await database;
  return await db.insert('ma_nouvelle_table', data);
}

// 5. Tester
flutter test test/unit/database/
```

---

## 🔥 FIREBASE

### Q: Firebase coûte-t-il cher avec cette architecture?

**R**: **NON, quasi-gratuit** !

**Usage actuel** :
- Auth : < 50K MAU (gratuit)
- Firestore : Minimal (métadonnées seulement)
- Analytics : Illimité (gratuit)
- Crashlytics : Illimité (gratuit)
- Messaging : Illimité (gratuit)
- Functions : ~10K invocations/jour

**Coût estimé** : < 1€/mois pour 1000 utilisateurs actifs

**Comparaison** :
- **100% Firebase** : 50-100€/mois
- **Hybrid (actuel)** : < 1€/mois
- **Économie** : **99%** 💰

### Q: Que se passe-t-il si Firebase tombe en panne?

**R**: L'app **continue à fonctionner** avec limitations:

**Continue de fonctionner** ✅ :
- Dictionnaire
- Leçons
- Quiz
- Progrès (sauvegardé localement)
- Statistiques
- Navigation

**Ne fonctionne pas** ❌ :
- Nouvelle connexion/inscription
- Notifications push
- Nouveaux paiements
- Analytics en temps réel

**À la reconnexion Firebase** :
- Tous les événements sont envoyés (queued)
- Rien n'est perdu

### Q: Puis-je désactiver Firebase complètement?

**R**: **Techniquement oui, mais déconseillé**.

**Si Firebase désactivé** :
- ❌ Plus d'authentification (users existants OK, nouveaux NON)
- ❌ Plus de notifications
- ❌ Plus d'analytics
- ❌ Plus de crash reporting

**Alternative** : Implémenter auth custom + services alternatifs.

**Recommandation** : Garder Firebase pour ces services essentiels.

---

## 👥 UTILISATEURS

### Q: Comment un invité devient-il apprenant?

**R**: Flux de conversion:

```
Invité (Guest)
    ↓
Clique "S'inscrire"
    ↓
Remplit formulaire (email, password, nom)
    ↓
Firebase Auth crée compte
    ↓
SQLite crée profil avec role='student'
    ↓
Redirigé vers dashboard apprenant
    ↓
Limites quotidiennes supprimées ✅
Progrès sauvegardé ✅
Statistiques trackées ✅
```

**Aucune perte de données** : Si invité avait consulté contenu, pas de progression sauvegardée (car pas authentifié), mais après inscription, il peut reprendre librement.

### Q: Comment gérer les comptes multiples (même utilisateur)?

**R**: Firebase Auth empêche doublons par email.

**Scénario** :
```
Utilisateur A: email@example.com
Essaie de créer 2ème compte: email@example.com
→ Firebase retourne erreur: "email-already-in-use"
→ Inscription refusée
```

**Si utilisateur oublie qu'il a compte** :
- Utiliser "Mot de passe oublié"
- Email de reset envoyé
- Récupère son compte

**Différents providers (même email)** :
```
email@example.com via Email/Password : Compte 1
email@example.com via Google : Peut être compte séparé

Solution: Firebase Account Linking (à implémenter si nécessaire)
```

### Q: Comment promouvoir un utilisateur en enseignant?

**R**: Via interface admin ou code:

```dart
// Méthode 1: Interface Admin
Admin Dashboard → Users → Select User → Change Role → Teacher

// Méthode 2: Code
await AdminService.updateUserRole(
  userId: 'user-123',
  newRole: 'teacher',
);

// Méthode 3: SQL Direct (dev uniquement)
UPDATE users SET role = 'teacher' WHERE user_id = 'user-123';
```

**Vérifications avant promotion** :
- Utilisateur actif (> 30 jours)
- Bon comportement (pas de violations)
- Demande explicite ou recommandation
- Comprend responsabilités enseignant

---

## 📱 DÉVELOPPEMENT

### Q: Comment débugger la base de données sur appareil?

**R**: Plusieurs méthodes:

**Méthode 1: ADB Pull**
```bash
# Extraire DB de l'appareil
adb pull /data/data/com.maa_yegue.app/databases/maa_yegue_app.db

# Ouvrir avec DB Browser
```

**Méthode 2: Code Debug**
```dart
// Ajouter temporairement dans code
final db = await UnifiedDatabaseService.instance.database;
final users = await db.query('users');
debugPrint('Users in DB: ${users.length}');
users.forEach((user) => debugPrint(user.toString()));
```

**Méthode 3: Android Studio Device File Explorer**
```
View → Tool Windows → Device File Explorer
Navigate to: /data/data/com.maa_yegue.app/databases/
Right-click → Save As
```

### Q: Comment tester avec différents rôles utilisateur?

**R**: Créer utilisateurs de test:

```dart
// Dans code test ou script
final db = UnifiedDatabaseService.instance;

// Invité (pas besoin de créer, par défaut)

// Étudiant
await db.upsertUser({
  'user_id': 'test-student',
  'email': 'student@test.com',
  'display_name': 'Test Student',
  'role': 'student',
  'subscription_status': 'free',
  'created_at': DateTime.now().millisecondsSinceEpoch,
  'updated_at': DateTime.now().millisecondsSinceEpoch,
});

// Enseignant
await db.upsertUser({
  'user_id': 'test-teacher',
  'email': 'teacher@test.com',
  'display_name': 'Test Teacher',
  'role': 'teacher',
  'created_at': DateTime.now().millisecondsSinceEpoch,
  'updated_at': DateTime.now().millisecondsSinceEpoch,
});

// Admin
await db.upsertUser({
  'user_id': 'test-admin',
  'email': 'admin@test.com',
  'display_name': 'Test Admin',
  'role': 'admin',
  'is_default_admin': 1,
  'created_at': DateTime.now().millisecondsSinceEpoch,
  'updated_at': DateTime.now().millisecondsSinceEpoch,
});
```

**Puis connecter avec ces comptes** (créer aussi dans Firebase Auth pour connexion réelle).

### Q: Comment ajouter une nouvelle langue?

**R**: Processus complet:

```
ÉTAPE 1: Script Python
─────────────────────────────────────────
Modifier docs/database-scripts/create_cameroon_db.py:

# Ajouter dans insert_languages()
('NEW', 'Nouvelle Langue', 'Famille', 'Région', 50000, 'Description', 'new'),

# Ajouter traductions dans insert_translations()
('Bonjour', 'NEW', 'Salut', 'GRT', 'sa-LOOT', None, 'beginner'),
# ... minimum 100 traductions essentielles

# Ajouter leçons dans insert_lessons() (minimum 10)
# Ajouter quiz dans insert_quizzes() (minimum 5)

ÉTAPE 2: Générer DB
─────────────────────────────────────────
cd docs/database-scripts
python create_cameroon_db.py
cp cameroon_languages.db ../../assets/databases/

ÉTAPE 3: Constantes App
─────────────────────────────────────────
Modifier lib/core/constants/language_constants.dart:

static const String nouvelleLangue = 'nouvelle_langue';

static const List<String> cameroonianLanguages = [
  ewondo, duala, feefe, fulfulde, bassa, bamum, yemba,
  nouvelleLangue,  // AJOUTER
];

ÉTAPE 4: Metadata
─────────────────────────────────────────
UPDATE app_metadata SET value = '8' WHERE key = 'total_languages';

ÉTAPE 5: Test et Deploy
─────────────────────────────────────────
flutter clean
flutter pub get
flutter test
flutter build apk --release
```

**Durée totale** : 2-4 heures (selon volume traductions)

---

## 🔐 AUTHENTIFICATION & SÉCURITÉ

### Q: Comment réinitialiser le mot de passe d'un utilisateur?

**R**: L'utilisateur le fait lui-même:

```
1. Écran connexion → "Mot de passe oublié"
2. Entre son email
3. Firebase envoie email avec lien
4. Clique sur lien
5. Entre nouveau mot de passe
6. Peut se reconnecter
```

**Si l'utilisateur ne reçoit pas l'email** :
```
Vérifications:
1. Email correct? (pas de typo)
2. Dossier spam?
3. Firebase Auth activé?

Solution admin:
Depuis Firebase Console:
Authentication → Users → Sélectionner user → 
Actions → Send password reset email
```

### Q: Comment désactiver un compte abusif?

**R**: Via admin:

```dart
// Méthode 1: Désactiver (réversible)
await db.upsertUser({
  'user_id': 'user-abusive',
  'is_active': 0,  // Désactivé
  'updated_at': DateTime.now().millisecondsSinceEpoch,
});

// Méthode 2: Supprimer de Firebase Auth
await FirebaseAuth.instance.deleteUser(firebaseUid);

// Log l'action
await db.insert('admin_logs', {
  'action': 'user_deactivated',
  'user_id': 'user-abusive',
  'admin_id': currentAdminId,
  'details': json.encode({'reason': 'Terms violation, spam content'}),
  'timestamp': DateTime.now().toIso8601String(),
});
```

**Réactiver plus tard** :
```dart
await db.upsertUser({
  'user_id': 'user-abusive',
  'is_active': 1,  // Réactivé
  'updated_at': DateTime.now().millisecondsSinceEpoch,
});
```

### Q: L'app est-elle conforme RGPD?

**R**: **Oui**, avec l'architecture hybride:

**Données stockées localement** :
- ✅ Utilisateur contrôle ses données (sur son appareil)
- ✅ Pas de tracking tiers excessif
- ✅ Données pas vendues (jamais)
- ✅ Export données possible (compliance)
- ✅ Suppression compte = suppression données

**Firebase (services uniquement)** :
- ✅ Firebase est RGPD-compliant
- ✅ Données Firebase = identifiants auth uniquement
- ✅ Analytics anonymisés
- ✅ Pas de PII (Personally Identifiable Info) en analytics

**Procédure droit à l'oubli** :
```dart
// Export données utilisateur
final userData = await exportUserData(userId);
// Envoyer par email

// Puis supprimer
await db.deleteUser(userId);
await FirebaseAuth.instance.deleteUser(firebaseUid);
```

---

## 💳 PAIEMENTS

### Q: Où sont stockées les données de carte bancaire?

**R**: **JAMAIS dans l'app**.

**Processus sécurisé** :
```
1. Utilisateur entre carte sur formulaire Stripe
2. Données envoyées DIRECTEMENT à Stripe (PCI-compliant)
3. Stripe retourne TOKEN
4. App stocke uniquement le TOKEN (pas la carte)
5. Paiements futurs utilisent le TOKEN
```

**Stocké dans SQLite** :
- ✅ ID transaction
- ✅ Montant
- ✅ Date
- ✅ Statut (pending/completed/failed)
- ❌ Numéro carte (JAMAIS)
- ❌ CVV (JAMAIS)
- ❌ Détails bancaires (JAMAIS)

### Q: Comment gérer un paiement bloqué en "pending"?

**R**: Vérification manuelle:

```sql
-- 1. Trouver paiement
SELECT * FROM payments 
WHERE status = 'pending' 
  AND created_at < strftime('%s', 'now', '-1 day') * 1000;

-- 2. Vérifier avec gateway
# Ouvrir dashboard Campay/Stripe
# Rechercher transaction_id
# Vérifier statut réel

-- 3a. Si paiement réussi mais non enregistré
UPDATE payments 
SET status = 'completed', 
    completed_at = strftime('%s', 'now') * 1000,
    updated_at = strftime('%s', 'now') * 1000
WHERE payment_id = 'pay-xxx';

-- Activer abonnement
-- (via code ou SQL)

-- 3b. Si paiement échoué
UPDATE payments 
SET status = 'failed',
    updated_at = strftime('%s', 'now') * 1000
WHERE payment_id = 'pay-xxx';

-- Notifier utilisateur
```

### Q: Comment faire un remboursement?

**R**: Processus en 4 étapes:

```
1. VÉRIFIER ÉLIGIBILITÉ
   - Demande < 7 jours après paiement?
   - Raison valide?
   - Abonnement utilisé minimalement?

2. APPROUVER REMBOURSEMENT
   - Depuis dashboard gateway (Campay/Stripe)
   - Initier remboursement
   - Noter ID remboursement

3. METTRE À JOUR SQLite
   await db.updatePaymentStatus(
     paymentId: 'pay-123',
     status: 'refunded',
   );
   
   await db.upsertSubscription({
     'subscription_id': 'sub-123',
     'status': 'cancelled',
     'updated_at': DateTime.now().millisecondsSinceEpoch,
   });

4. NOTIFIER UTILISATEUR
   - Email confirmation remboursement
   - FCM notification dans app
```

---

## 📊 PERFORMANCES

### Q: L'app est lente, comment optimiser?

**R**: Diagnostic en 5 étapes:

**1. Identifier le goulot** :
```dart
// Profiler requêtes
final result = await DatabaseQueryOptimizer.profileQuery(
  'slow_operation',
  () => mySlowOperation(),
);
// Affiche: "Query took 1500ms"
```

**2. Vérifier indexes** :
```dart
final suggestions = await DatabaseQueryOptimizer.analyzeIndexes();
// Si suggestions: créer indexes manquants
```

**3. Optimiser requêtes** :
```dart
// ❌ Mauvais: N+1 queries
for (var user in users) {
  final stats = await db.getUserStatistics(user['user_id']);
}

// ✅ Bon: Une seule requête avec JOIN
final usersWithStats = await database.rawQuery('''
  SELECT u.*, s.* 
  FROM users u
  LEFT JOIN user_statistics s ON u.user_id = s.user_id
''');
```

**4. Utiliser cache** :
```dart
// Données statiques
final languages = await DatabaseQueryOptimizer.getCachedLanguages();
```

**5. Pagination** :
```dart
// Au lieu de tout charger
final page = await DatabaseQueryOptimizer.getPaginatedLessons(
  languageId: 'EWO',
  page: currentPage,
  pageSize: 20,
);
```

### Q: Comment réduire la taille de l'app?

**R**: Plusieurs optimisations:

**1. Images** :
```yaml
# pubspec.yaml
flutter:
  assets:
    - assets/images/
  
# Utiliser WebP au lieu de PNG/JPEG
# Compresser images avant ajout
```

**2. Code** :
```bash
# Build avec obfuscation
flutter build apk --release --obfuscate --split-debug-info=./debug-info/

# Réduction: 20-30% taille APK
```

**3. Dépendances** :
```yaml
# Retirer packages inutilisés
# Utiliser imports spécifiques:

# ❌ Mauvais
import 'package:firebase_core/firebase_core.dart';

# ✅ Bon (si seulement Firebase.initializeApp utilisé)
import 'package:firebase_core/firebase_core.dart' show Firebase;
```

**4. Assets** :
```
# Ne pas inclure fichiers de dev dans assets
# Vérifier pubspec.yaml assets section
# Utiliser .gitignore pour gros fichiers
```

### Q: Combien d'utilisateurs l'app peut-elle gérer?

**R**: **Dépend de l'appareil**, mais:

**SQLite capacité** :
- Millions de lignes par table
- 100K+ utilisateurs sur appareil milieu de gamme
- 1M+ utilisateurs sur appareil haut de gamme

**Limitations pratiques** :
- Espace disque appareil (100MB-1GB pour DB)
- RAM (query cache)
- CPU (requêtes complexes)

**Optimisations si volume élevé** :
```dart
// Archivage données anciennes
// Nettoyage agressif
// Compression données
// Pagination stricte
// Cache plus important
```

**Pour millions d'utilisateurs** :
- Considérer backend API
- SQLite = cache local uniquement
- PostgreSQL côté serveur

---

## 🐛 DEBUGGING

### Q: L'app crash au démarrage, comment debugger?

**R**: Procédure debug:

```bash
# 1. Lancer avec logs verbeux
flutter run -v

# 2. Capturer logs
flutter logs > crash_logs.txt

# 3. Chercher erreur
# Regarder pour:
# - "FATAL EXCEPTION"
# - "Error"
# - "Exception"

# 4. Stack trace
# Identifier fichier et ligne exacte

# 5. Crashlytics
# Vérifier si autres utilisateurs ont même crash

# 6. Reproduire localement
# Mettre breakpoint
# Step-by-step debugging

# 7. Fix et test
# Corriger problème
# Tester 10+ fois pour confirmer
```

**Crashes communs au démarrage** :
```
- Base de données asset manquant
  → Vérifier assets/databases/cameroon_languages.db

- Firebase pas initialisé
  → Vérifier google-services.json présent

- Permission manquante
  → Vérifier AndroidManifest.xml

- Dépendance native manquante
  → flutter clean && flutter pub get
```

### Q: Flutter analyze montre des warnings, sont-ils importants?

**R**: Dépend du type:

**Erreurs (ERROR)** : ❌ **BLOQUANT**
```
Doivent être corrigées AVANT commit
Exemple: undefined_identifier, type_mismatch
```

**Avertissements (WARNING)** : ⚠️ **IMPORTANT**
```
Doivent être corrigées AVANT merge
Exemple: unused_import, unused_field
```

**Info (INFO)** : ℹ️ **OPTIONNEL**
```
Bonnes pratiques, peuvent être ignorées si justifié
Exemple: prefer_const_declarations, avoid_print (en dev)
```

**Commande** :
```bash
flutter analyze

# Filtrer seulement erreurs
flutter analyze 2>&1 | Select-String "error -"

# Filtrer warnings
flutter analyze 2>&1 | Select-String "warning -"
```

**Objectif** : **0 erreurs, 0 warnings** avant production.

---

## 📦 DÉPLOIEMENT

### Q: Pourquoi le build prend-il autant de temps?

**R**: Plusieurs facteurs:

**Normal** :
- Premier build : 5-10 min (télécharge dépendances)
- Builds suivants : 1-2 min (incremental)

**Lent (> 10 min)** :
```
Causes possibles:
1. Cache corrompu
   → Solution: flutter clean

2. Trop de dépendances
   → Solution: Nettoyer pubspec.yaml

3. Appareil lent
   → Solution: Build sur machine plus puissante

4. Antivirus scan
   → Solution: Exclure dossiers Flutter du scan
```

**Optimiser builds** :
```bash
# Désactiver obfuscation en debug
flutter build apk --debug  # Rapide

# Utiliser build cache
flutter build apk --release --build-number=X  # Réutilise si même version
```

### Q: Comment déployer sur Google Play Store?

**R**: Processus complet:

```
ÉTAPE 1: Préparation
─────────────────────────────────────────
1. Créer compte Google Play Developer (25$ one-time)
2. Créer app dans console
3. Remplir informations (nom, description, screenshots)
4. Configurer signing key

ÉTAPE 2: Build
─────────────────────────────────────────
# App Bundle (recommandé)
flutter build appbundle --release

# Fichier généré:
# build/app/outputs/bundle/release/app-release.aab

ÉTAPE 3: Upload
─────────────────────────────────────────
1. Play Console → App → Releases → Production
2. Create new release
3. Upload app-release.aab
4. Remplir release notes
5. Review et rollout

ÉTAPE 4: Rollout Progressif
─────────────────────────────────────────
1. Démarrer avec 10% utilisateurs
2. Monitorer crashes/feedback (24h)
3. Si stable: augmenter à 50% (24h)
4. Si stable: 100%

ÉTAPE 5: Post-Release
─────────────────────────────────────────
- Monitorer reviews
- Répondre questions utilisateurs
- Fixer bugs prioritaires
```

---

## 🧪 TESTS

### Q: Pourquoi les tests sont importants?

**R**: Les tests **préviennent les régressions** et **économisent du temps**.

**Sans tests** :
```
Développeur ajoute feature A
→ Casse feature B (sans savoir)
→ Deploy en production
→ Utilisateurs rapportent bug
→ Urgence correction
→ Stress, coûts, mauvaise réputation
```

**Avec tests** :
```
Développeur ajoute feature A
→ Lance tests
→ Test feature B échoue
→ Corrige immédiatement
→ Deploy en confiance
→ Utilisateurs satisfaits
```

**ROI tests** :
- 1 heure écrire tests
- Économie de 10+ heures debugging production
- **ROI : 10x**

### Q: Comment écrire un bon test?

**R**: Suivre pattern AAA (Arrange-Act-Assert):

```dart
test('La description de ce qui est testé', () async {
  // ARRANGE: Préparer le contexte
  const userId = 'test-user';
  await db.upsertUser({
    'user_id': userId,
    'role': 'student',
    'created_at': DateTime.now().millisecondsSinceEpoch,
    'updated_at': DateTime.now().millisecondsSinceEpoch,
  });

  // ACT: Effectuer l'action à tester
  final user = await db.getUserById(userId);

  // ASSERT: Vérifier le résultat
  expect(user, isNotNull);
  expect(user?['role'], equals('student'));
});
```

**Bon test** :
- ✅ Nom descriptif
- ✅ Une seule chose testée
- ✅ Indépendant (pas de dépendances autres tests)
- ✅ Répétable (même résultat à chaque fois)
- ✅ Rapide (< 1 seconde)

---

## 🌍 INTERNATIONALISATION

### Q: Comment ajouter une nouvelle langue d'interface (UI)?

**R**: Ma'a yegue supporte FR (français) et EN (anglais).

**Ajouter Espagnol (exemple)** :

```
ÉTAPE 1: Fichier ARB
─────────────────────────────────────────
Créer lib/l10n/app_es.arb:

{
  "@@locale": "es",
  "appTitle": "Ma'a yegue",
  "welcome": "Bienvenido",
  "login": "Iniciar sesión",
  "register": "Registrarse",
  "dictionary": "Diccionario",
  "lessons": "Lecciones",
  ...
}

ÉTAPE 2: Générer Code
─────────────────────────────────────────
flutter pub run intl_utils:generate

# Génère:
# lib/l10n/app_localizations_es.dart

ÉTAPE 3: Ajouter au Router
─────────────────────────────────────────
// lib/main.dart
MaterialApp.router(
  supportedLocales: [
    Locale('fr'),
    Locale('en'),
    Locale('es'),  // AJOUTER
  ],
  ...
)

ÉTAPE 4: Test
─────────────────────────────────────────
# Changer langue appareil en espagnol
# Relancer app
# Vérifier toutes les strings traduites
```

### Q: Comment gérer les traductions des contenus dynamiques?

**R**: Utiliser table `translations` avec langue source:

```sql
-- Contenu multi-langue
CREATE TABLE dynamic_content (
  content_id INTEGER PRIMARY KEY,
  content_key TEXT UNIQUE,  -- Ex: "welcome_message"
  language_code TEXT,        -- fr, en, es
  content_text TEXT,
  updated_at INTEGER
);

-- Insérer
INSERT INTO dynamic_content VALUES
(1, 'welcome_message', 'fr', 'Bienvenue sur Ma''a yegue!', ...),
(2, 'welcome_message', 'en', 'Welcome to Ma''a yegue!', ...),
(3, 'welcome_message', 'es', 'Bienvenido a Ma''a yegue!', ...);

-- Récupérer selon langue
SELECT content_text FROM dynamic_content 
WHERE content_key = 'welcome_message' 
  AND language_code = 'fr';
```

---

## 🔧 OUTILS ET SCRIPTS

### Q: Quels scripts utilitaires sont disponibles?

**R**: Scripts dans `scripts/` et `lib/scripts/`:

**Disponibles** :
```
📄 add_yemba_language.dart      - Ajouter langue Yemba
📄 seed_dictionary.dart          - Injecter dictionnaire
📄 seed_languages.dart           - Injecter langues
📄 diagnose_and_launch.ps1       - Diagnostic Android
```

**À créer (templates fournis dans docs)** :
```
📄 weekly_cleanup.dart           - Nettoyage hebdo
📄 monthly_optimization.dart     - Optimisation mensuelle
📄 generate_report.dart          - Génération rapports
📄 export_user_data.dart         - Export RGPD
📄 backup_database.dart          - Backup automatique
```

**Exécution** :
```bash
# Script Dart
dart run scripts/mon_script.dart

# Script PowerShell
./scripts/diagnose_and_launch.ps1

# Script Python
python docs/database-scripts/create_cameroon_db.py
```

### Q: Comment automatiser les tâches répétitives?

**R**: Utiliser cron jobs (Linux/Mac) ou Task Scheduler (Windows):

**Linux/Mac** :
```bash
# Éditer crontab
crontab -e

# Backup quotidien 2h du matin
0 2 * * * cd /path/to/project && dart run scripts/backup_database.dart

# Nettoyage hebdomadaire dimanche 3h
0 3 * * 0 cd /path/to/project && dart run scripts/weekly_cleanup.dart

# Rapport mensuel 1er du mois
0 8 1 * * cd /path/to/project && dart run scripts/generate_monthly_report.dart
```

**Windows Task Scheduler** :
```
1. Ouvrir Task Scheduler
2. Create Basic Task
3. Nom: "Ma'a yegue Daily Backup"
4. Trigger: Daily, 2:00 AM
5. Action: Start a program
   Program: dart
   Arguments: run scripts/backup_database.dart
   Start in: E:\project\mayegue-mobile
6. Finish
```

---

## ✅ BONNES PRATIQUES

### À FAIRE ✅

- ✅ Toujours utiliser `UnifiedDatabaseService` pour données
- ✅ Valider toutes entrées utilisateur
- ✅ Logger événements importants (Firebase Analytics)
- ✅ Utiliser requêtes paramétrées (SQL injection prevention)
- ✅ Gérer tous les cas d'erreur
- ✅ Tester avant de commit
- ✅ Documenter code complexe
- ✅ Backup avant opérations majeures
- ✅ Monitorer Crashlytics quotidiennement
- ✅ Incrémenter version DB si changement schema

### À ÉVITER ❌

- ❌ Stocker données sensibles en clair
- ❌ Requêtes SQL construites par concat (injection!)
- ❌ Ignorer warnings flutter analyze
- ❌ Commit sans tests
- ❌ Deploy vendredi soir (pas de support weekend)
- ❌ Modifier DB production sans backup
- ❌ Hardcoder credentials dans code
- ❌ Utiliser Firebase pour toutes les données
- ❌ Oublier de logger actions admin
- ❌ Négliger feedback utilisateurs

---

## 📞 OBTENIR DE L'AIDE

### Ressources Internes

**Documentation** :
- `docs/` → Tous les guides
- `HYBRID_ARCHITECTURE_MIGRATION_REPORT.md` → Architecture
- `QUICK_SETUP_GUIDE.md` → Installation

**Code** :
- `lib/core/database/unified_database_service.dart` → DB principale
- `lib/core/services/firebase_service.dart` → Firebase
- Commentaires dans code pour explications

### Ressources Externes

**Flutter** :
- https://flutter.dev/docs
- https://stackoverflow.com/questions/tagged/flutter

**SQLite** :
- https://www.sqlite.org/docs.html
- https://github.com/tekartik/sqflite

**Firebase** :
- https://firebase.google.com/docs
- https://firebase.google.com/support

**Communauté** :
- Flutter Discord
- r/FlutterDev
- Stack Overflow

### Support Technique

**Contactez** :
- Email : dev@maayegue.com
- GitHub Issues : https://github.com/mayegue/mayegue-mobile/issues
- Slack : #tech-support (si disponible)

---

## ✅ RÉSUMÉ

Cette FAQ couvre les **questions les plus fréquentes** sur:
- Architecture et choix techniques
- Base de données et optimisation
- Firebase et services cloud
- Authentification et sécurité
- Paiements et abonnements
- Tests et debugging
- Déploiement et maintenance

Pour questions spécifiques non couvertes, consulter les autres documents de `docs/` ou contacter l'équipe technique.

---

**Document créé** : 7 Octobre 2025  
**Dernière mise à jour** : 7 Octobre 2025  
**Prochaine révision** : Trimestrielle  
**Fichiers liés** :
- `10_TROUBLESHOOTING.md`
- `06_GUIDE_DEVELOPPEUR.md`
- `07_GUIDE_OPERATIONNEL.md`
