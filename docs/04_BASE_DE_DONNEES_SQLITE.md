# 🗄️ BASE DE DONNÉES SQLite - MA'A YEGUE

## 📋 Vue d'Ensemble

Ma'a yegue utilise **deux bases de données SQLite** :

1. **maa_yegue_app.db** - Base principale de l'application
2. **cameroon_languages.db** - Base des langues camerounaises (lecture seule)

---

## 🏗️ ARCHITECTURE DES BASES DE DONNÉES

### Schéma de Connexion

```
UnifiedDatabaseService
        ↓
┌──────────────────────────────────────┐
│  maa_yegue_app.db (Principale)      │
│  - users                             │
│  - daily_limits                      │
│  - user_progress                     │
│  - user_statistics                   │
│  - quizzes (utilisateurs)            │
│  - quiz_questions                    │
│  - user_created_content              │
│  - favorites                         │
│  - payments                          │
│  - subscriptions                     │
│  - newsletter_subscriptions          │
│  - otp_codes                         │
│  - admin_logs                        │
│  - app_metadata                      │
└──────────────────────────────────────┘
        ↓ ATTACH
┌──────────────────────────────────────┐
│  cameroon_languages.db (Attachée)   │
│  - languages                         │
│  - categories                        │
│  - translations                      │
│  - lessons                           │
│  - quizzes (officiels)               │
│  - quiz_questions (officiels)        │
└──────────────────────────────────────┘
```

**Requête d'attachement** :
```sql
ATTACH DATABASE '/path/to/cameroon_languages.db' AS cameroon;
```

**Accès aux tables** :
```sql
-- Table principale
SELECT * FROM users;

-- Table attachée
SELECT * FROM cameroon.translations;

-- Jointure inter-bases
SELECT u.display_name, COUNT(p.progress_id)
FROM users u
LEFT JOIN user_progress p ON u.user_id = p.user_id
LEFT JOIN cameroon.lessons l ON p.content_id = l.lesson_id
GROUP BY u.user_id;
```

---

## 📊 SCHÉMA COMPLET DES TABLES

### 1. TABLE users (Utilisateurs)

**Objectif** : Stocker tous les profils utilisateurs

```sql
CREATE TABLE users (
  user_id TEXT PRIMARY KEY,              -- UUID unique
  firebase_uid TEXT UNIQUE,              -- UID Firebase Auth
  email TEXT,                            -- Email utilisateur
  display_name TEXT,                     -- Nom d'affichage
  role TEXT CHECK(role IN ('guest', 'student', 'teacher', 'admin')) DEFAULT 'student',
  subscription_status TEXT DEFAULT 'free',  -- free, premium, vip, lifetime
  subscription_expires_at INTEGER,       -- Timestamp expiration
  created_at INTEGER NOT NULL,           -- Timestamp création
  updated_at INTEGER NOT NULL,           -- Timestamp màj
  last_login INTEGER,                    -- Timestamp dernière connexion
  is_active INTEGER DEFAULT 1,           -- 1=actif, 0=désactivé
  is_default_admin INTEGER DEFAULT 0,    -- 1=admin par défaut
  auth_provider TEXT DEFAULT 'email',    -- email, google, facebook, apple
  two_factor_enabled INTEGER DEFAULT 0,
  two_factor_enabled_at TEXT,
  two_factor_disabled_at TEXT,
  last_two_factor_verification TEXT,
  backup_codes TEXT,                     -- JSON array
  backup_codes_generated_at TEXT,
  promoted_to_admin_at TEXT,
  demoted_from_admin_at TEXT,
  permissions TEXT,                      -- JSON permissions
  profile_data TEXT,                     -- JSON données supplémentaires
  fcm_token TEXT,                        -- Token notifications push
  fcm_token_updated_at TEXT
);
```

**Indexes** :
```sql
CREATE INDEX idx_users_firebase_uid ON users(firebase_uid);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_email ON users(email);
```

**Exemples de données** :
```sql
-- Étudiant
INSERT INTO users VALUES (
  'user-student-001',
  'firebase-abc123',
  'etudiant@example.com',
  'Jean Dupont',
  'student',
  'premium',
  1735689600000,  -- 01/01/2026
  1704067200000,  -- 01/01/2024
  1704067200000,
  1704067200000,
  1,
  0,
  'email',
  0,
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
);

-- Enseignant
INSERT INTO users VALUES (
  'user-teacher-001',
  'firebase-def456',
  'prof@example.com',
  'Marie Nguimgo',
  'teacher',
  'lifetime',
  NULL,
  1704067200000,
  1704067200000,
  1704067200000,
  1,
  0,
  'google',
  0,
  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL
);
```

---

### 2. TABLE daily_limits (Limites Quotidiennes)

**Objectif** : Tracker les limites pour utilisateurs invités

```sql
CREATE TABLE daily_limits (
  limit_id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT,                          -- NULL pour invités
  device_id TEXT,                        -- ID unique appareil
  limit_date TEXT NOT NULL,              -- Format: YYYY-MM-DD
  lessons_count INTEGER DEFAULT 0,       -- Nombre de leçons consultées
  readings_count INTEGER DEFAULT 0,      -- Nombre de lectures
  quizzes_count INTEGER DEFAULT 0,       -- Nombre de quiz tentés
  created_at INTEGER NOT NULL,
  UNIQUE(user_id, limit_date),
  UNIQUE(device_id, limit_date),
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
```

**Index** :
```sql
CREATE INDEX idx_daily_limits_date ON daily_limits(limit_date);
CREATE INDEX idx_daily_limits_device ON daily_limits(device_id);
```

**Exemples** :
```sql
-- Invité ayant consulté 3 leçons aujourd'hui
INSERT INTO daily_limits VALUES (
  1,
  NULL,
  'android_abc123xyz',
  '2025-10-07',
  3,  -- lessons
  1,  -- readings
  2,  -- quizzes
  1728345600000
);

-- Nettoyage automatique des anciennes limites (>30 jours)
DELETE FROM daily_limits 
WHERE limit_date < DATE('now', '-30 days');
```

---

### 3. TABLE user_progress (Progrès Utilisateur)

**Objectif** : Suivre la progression pour chaque contenu

```sql
CREATE TABLE user_progress (
  progress_id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT NOT NULL,
  content_type TEXT CHECK(content_type IN ('lesson', 'quiz', 'translation', 'reading')) NOT NULL,
  content_id INTEGER NOT NULL,           -- ID de la leçon/quiz/etc.
  language_id TEXT,                      -- Langue concernée
  status TEXT CHECK(status IN ('started', 'in_progress', 'completed')) DEFAULT 'started',
  score REAL,                            -- Score (0-100)
  time_spent INTEGER DEFAULT 0,          -- Temps en secondes
  attempts INTEGER DEFAULT 0,            -- Nombre de tentatives
  completed_at INTEGER,                  -- Timestamp complétion
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
```

**Indexes** :
```sql
CREATE INDEX idx_user_progress_user ON user_progress(user_id);
CREATE INDEX idx_user_progress_content ON user_progress(content_type, content_id);
```

**Exemples** :
```sql
-- Leçon complétée avec succès
INSERT INTO user_progress VALUES (
  1,
  'user-student-001',
  'lesson',
  1,  -- lesson_id
  'EWO',
  'completed',
  85.5,  -- 85.5% score
  1800,  -- 30 minutes
  2,     -- 2 tentatives
  1728345600000,
  1728259200000,
  1728345600000
);

-- Quiz en cours
INSERT INTO user_progress VALUES (
  2,
  'user-student-001',
  'quiz',
  3,
  'DUA',
  'in_progress',
  NULL,
  600,  -- 10 minutes
  1,
  NULL,  -- Pas encore complété
  1728345600000,
  1728345600000
);
```

---

### 4. TABLE user_statistics (Statistiques)

**Objectif** : Agréger les statistiques globales de l'utilisateur

```sql
CREATE TABLE user_statistics (
  stat_id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT NOT NULL UNIQUE,
  total_lessons_completed INTEGER DEFAULT 0,
  total_quizzes_completed INTEGER DEFAULT 0,
  total_words_learned INTEGER DEFAULT 0,
  total_readings_completed INTEGER DEFAULT 0,
  total_study_time INTEGER DEFAULT 0,    -- En secondes
  current_streak INTEGER DEFAULT 0,      -- Jours consécutifs
  longest_streak INTEGER DEFAULT 0,      -- Record
  last_activity_date TEXT,               -- Format: YYYY-MM-DD
  level INTEGER DEFAULT 1,               -- Niveau utilisateur
  experience_points INTEGER DEFAULT 0,   -- XP total
  updated_at INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
```

**Index** :
```sql
CREATE INDEX idx_user_statistics_user ON user_statistics(user_id);
```

**Calculs automatiques** :
```dart
// Quand leçon complétée
await db.incrementStatistic(userId, 'total_lessons_completed');
await db.incrementStatistic(userId, 'total_study_time', incrementBy: timeSpent);

// Quand quiz complété
await db.incrementStatistic(userId, 'total_quizzes_completed');
final xp = (score * 10).round();
await db.incrementStatistic(userId, 'experience_points', incrementBy: xp);

// Niveau = XP ÷ 1000
final level = (experience_points / 1000).floor() + 1;
```

**Exemple** :
```sql
INSERT INTO user_statistics VALUES (
  1,
  'user-student-001',
  24,    -- leçons complétées
  18,    -- quiz complétés
  245,   -- mots appris
  12,    -- lectures complétées
  55800, -- 15h 30m d'étude
  7,     -- série actuelle: 7 jours
  12,    -- record: 12 jours
  '2025-10-07',
  3,     -- Niveau 3
  2450,  -- 2450 XP
  1728345600000
);
```

---

### 5. TABLE quizzes (Quiz Utilisateurs)

**Objectif** : Stocker quiz créés par enseignants

```sql
CREATE TABLE quizzes (
  quiz_id INTEGER PRIMARY KEY AUTOINCREMENT,
  language_id TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  difficulty_level TEXT CHECK(difficulty_level IN ('beginner', 'intermediate', 'advanced')),
  category_id TEXT,
  creator_id TEXT,                       -- teacher_id ou admin_id
  is_official INTEGER DEFAULT 0,         -- 1=officiel, 0=utilisateur
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  FOREIGN KEY (creator_id) REFERENCES users(user_id) ON DELETE SET NULL
);
```

**Table associée** : `quiz_questions`

```sql
CREATE TABLE quiz_questions (
  question_id INTEGER PRIMARY KEY AUTOINCREMENT,
  quiz_id INTEGER NOT NULL,
  question_text TEXT NOT NULL,
  question_type TEXT CHECK(question_type IN ('multiple_choice', 'true_false', 'fill_blank', 'matching')) NOT NULL,
  correct_answer TEXT NOT NULL,
  options TEXT,                          -- JSON: ["option1", "option2", ...]
  points INTEGER DEFAULT 1,
  explanation TEXT,                      -- Explication de la bonne réponse
  order_index INTEGER DEFAULT 0,
  FOREIGN KEY (quiz_id) REFERENCES quizzes(quiz_id) ON DELETE CASCADE
);
```

**Exemples** :
```sql
-- Quiz créé par enseignant
INSERT INTO quizzes VALUES (
  1,
  'EWO',
  'Quiz: Salutations en Ewondo',
  'Testez vos connaissances des salutations de base',
  'beginner',
  'GRT',
  'user-teacher-001',
  0,  -- Non officiel
  1728259200000,
  1728259200000
);

-- Question choix multiple
INSERT INTO quiz_questions VALUES (
  1,
  1,  -- quiz_id
  'Comment dit-on "Bonjour" en Ewondo?',
  'multiple_choice',
  'Mbolo',
  '["Mbolo", "Mwa boma", "Kweni", "Jam waali"]',
  1,
  'Mbolo est la salutation standard en Ewondo, utilisée à tout moment de la journée.',
  1
);

-- Question vrai/faux
INSERT INTO quiz_questions VALUES (
  2,
  1,
  '"Akiba" signifie "Merci" en Ewondo',
  'true_false',
  'true',
  '["true", "false"]',
  1,
  'Akiba est bien l\'expression de gratitude en Ewondo.',
  2
);
```

---

### 6. TABLE user_created_content (Contenu Utilisateurs)

**Objectif** : Stocker tout le contenu créé par enseignants/admins

```sql
CREATE TABLE user_created_content (
  content_id INTEGER PRIMARY KEY AUTOINCREMENT,
  creator_id TEXT NOT NULL,
  content_type TEXT CHECK(content_type IN ('lesson', 'quiz', 'translation', 'reading')) NOT NULL,
  title TEXT NOT NULL,
  content_data TEXT NOT NULL,            -- Contenu principal (peut être JSON)
  language_id TEXT,
  category_id TEXT,
  status TEXT CHECK(status IN ('draft', 'published', 'archived')) DEFAULT 'draft',
  difficulty_level TEXT,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  FOREIGN KEY (creator_id) REFERENCES users(user_id) ON DELETE CASCADE
);
```

**Indexes** :
```sql
CREATE INDEX idx_user_content_creator ON user_created_content(creator_id);
CREATE INDEX idx_user_content_type ON user_created_content(content_type);
```

**Workflow des statuts** :
```
draft (brouillon)
    ↓
   Édition par créateur
    ↓
published (publié) → Visible par tous
    ↓
   (optionnel)
    ↓
archived (archivé) → Caché mais conservé
```

**Exemples** :
```sql
-- Leçon créée par enseignant (brouillon)
INSERT INTO user_created_content VALUES (
  1,
  'user-teacher-001',
  'lesson',
  'Introduction aux salutations Ewondo',
  '{"sections": [{"type": "intro", "content": "..."}, ...]}',
  'EWO',
  'GRT',
  'draft',
  'beginner',
  1728259200000,
  1728259200000
);

-- Traduction ajoutée (publiée)
INSERT INTO user_created_content VALUES (
  2,
  'user-teacher-002',
  'translation',
  'Ordinateur',
  '{"french": "Ordinateur", "translation": "Kəmputa", "pronunciation": "kəm-poo-tah"}',
  'EWO',
  'EDU',
  'published',
  'intermediate',
  1728259200000,
  1728259200000
);
```

---

### 7. TABLE favorites (Favoris)

**Objectif** : Marque-pages utilisateur pour contenu

```sql
CREATE TABLE favorites (
  favorite_id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT NOT NULL,
  content_type TEXT CHECK(content_type IN ('translation', 'lesson', 'quiz')) NOT NULL,
  content_id INTEGER NOT NULL,
  created_at INTEGER NOT NULL,
  UNIQUE(user_id, content_type, content_id),
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
```

**Index** :
```sql
CREATE INDEX idx_favorites_user ON favorites(user_id);
```

**Utilisation** :
```dart
// Ajouter favori
await db.addFavorite(
  userId: 'user-001',
  contentType: 'translation',
  contentId: 45,
);

// Vérifier si favori
final isFav = await db.isFavorite(
  userId: 'user-001',
  contentType: 'translation',
  contentId: 45,
);

// Obtenir tous les favoris
final favorites = await db.getUserFavorites('user-001');
```

---

### 8. TABLE payments (Paiements)

**Objectif** : Historique complet des transactions

```sql
CREATE TABLE payments (
  payment_id TEXT PRIMARY KEY,           -- UUID unique
  user_id TEXT NOT NULL,
  amount REAL NOT NULL,                  -- Montant (ex: 2000.00)
  currency TEXT DEFAULT 'XAF',           -- XAF (Franc CFA)
  status TEXT CHECK(status IN ('pending', 'completed', 'failed', 'refunded')) DEFAULT 'pending',
  payment_method TEXT,                   -- campay, noupai, stripe
  transaction_id TEXT,                   -- ID transaction externe
  reference TEXT,                        -- Référence paiement
  subscription_id TEXT,                  -- ID abonnement associé
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  completed_at INTEGER,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);
```

**Indexes** :
```sql
CREATE INDEX idx_payments_user ON payments(user_id);
CREATE INDEX idx_payments_status ON payments(status);
```

**Cycle de vie d'un paiement** :
```
pending (en attente)
    ↓
Traitement par gateway
    ↓
completed (succès) OU failed (échec)
    ↓
Si completed: Activation abonnement
    ↓
(optionnel futur)
    ↓
refunded (remboursé)
```

**Exemples** :
```sql
-- Paiement réussi
INSERT INTO payments VALUES (
  'pay-uuid-001',
  'user-student-001',
  2000.00,
  'XAF',
  'completed',
  'campay',
  'CAMPAY-TXN-123456',
  'REF-001',
  'sub-001',
  1728259200000,
  1728345600000,
  1728345600000
);

-- Paiement en attente
INSERT INTO payments VALUES (
  'pay-uuid-002',
  'user-student-002',
  20000.00,
  'XAF',
  'pending',
  'stripe',
  NULL,
  'REF-002',
  'sub-002',
  1728345600000,
  1728345600000,
  NULL
);
```

---

### 9. TABLE subscriptions (Abonnements)

**Objectif** : Gérer les abonnements actifs

```sql
CREATE TABLE subscriptions (
  subscription_id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  plan_type TEXT NOT NULL,               -- monthly, yearly, lifetime
  status TEXT CHECK(status IN ('active', 'expired', 'cancelled', 'pending')) DEFAULT 'pending',
  start_date INTEGER NOT NULL,
  end_date INTEGER NOT NULL,
  payment_id TEXT,
  auto_renew INTEGER DEFAULT 1,          -- 1=auto-renouvellement, 0=non
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
  FOREIGN KEY (payment_id) REFERENCES payments(payment_id) ON DELETE SET NULL
);
```

**Indexes** :
```sql
CREATE INDEX idx_subscriptions_user ON subscriptions(user_id);
CREATE INDEX idx_subscriptions_status ON subscriptions(status);
```

**Vérification expiration** :
```sql
-- Abonnements actifs
SELECT * FROM subscriptions 
WHERE status = 'active' 
  AND end_date > strftime('%s', 'now') * 1000;

-- Abonnements expirés à mettre à jour
UPDATE subscriptions 
SET status = 'expired' 
WHERE status = 'active' 
  AND end_date < strftime('%s', 'now') * 1000;
```

---

### 10. TABLE app_metadata (Métadonnées App)

**Objectif** : Configuration et versioning

```sql
CREATE TABLE app_metadata (
  key TEXT PRIMARY KEY,
  value TEXT NOT NULL,
  updated_at INTEGER NOT NULL
);
```

**Métadonnées standard** :
```sql
INSERT INTO app_metadata VALUES
('db_version', '2', 1728259200000),
('created_at', '2025-10-07T00:00:00Z', 1728259200000),
('total_languages', '7', 1728259200000),
('supports_offline', 'true', 1728259200000),
('last_backup', '2025-10-07T12:00:00Z', 1728345600000);
```

---

### 11. TABLE admin_logs (Logs Admin)

**Objectif** : Tracer toutes les actions administratives

```sql
CREATE TABLE admin_logs (
  log_id INTEGER PRIMARY KEY AUTOINCREMENT,
  action TEXT NOT NULL,                  -- 'role_change', 'content_moderate', etc.
  user_id TEXT,                          -- Utilisateur affecté
  admin_id TEXT,                         -- Admin ayant effectué l'action
  details TEXT,                          -- JSON avec détails
  timestamp TEXT NOT NULL,               -- ISO8601
  FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
  FOREIGN KEY (admin_id) REFERENCES users(user_id) ON DELETE SET NULL
);
```

**Indexes** :
```sql
CREATE INDEX idx_admin_logs_user ON admin_logs(user_id);
CREATE INDEX idx_admin_logs_admin ON admin_logs(admin_id);
CREATE INDEX idx_admin_logs_timestamp ON admin_logs(timestamp);
```

**Exemples d'actions loggées** :
```sql
-- Changement de rôle
INSERT INTO admin_logs VALUES (
  1,
  'role_change',
  'user-student-001',
  'user-admin-001',
  '{"old_role": "student", "new_role": "teacher", "reason": "Active contributor"}',
  '2025-10-07T14:30:00Z'
);

-- Modération de contenu
INSERT INTO admin_logs VALUES (
  2,
  'content_moderate',
  'user-teacher-002',
  'user-admin-001',
  '{"content_id": 45, "action": "approved", "content_type": "lesson"}',
  '2025-10-07T15:45:00Z'
);

-- Suppression utilisateur
INSERT INTO admin_logs VALUES (
  3,
  'user_delete',
  'user-spam-001',
  'user-admin-001',
  '{"reason": "Spam account", "content_deleted": 5}',
  '2025-10-07T16:00:00Z'
);
```

---

## 📊 BASE CAMEROON LANGUAGES (Lecture Seule)

### Table languages (Langues)

```sql
CREATE TABLE languages (
  language_id VARCHAR(10) PRIMARY KEY,
  language_name VARCHAR(50) NOT NULL,
  language_family VARCHAR(100),
  region VARCHAR(50),
  speakers_count INTEGER,
  description TEXT,
  iso_code VARCHAR(10)
);
```

**Données** :
```
EWO - Ewondo - 577,000 locuteurs
DUA - Duala - 300,000 locuteurs
FEF - Fe'efe'e - 200,000 locuteurs
FUL - Fulfulde - 1,500,000 locuteurs
BAS - Bassa - 230,000 locuteurs
BAM - Bamum - 215,000 locuteurs
YMB - Yemba - 300,000 locuteurs
```

### Table categories (Catégories)

```sql
CREATE TABLE categories (
  category_id VARCHAR(10) PRIMARY KEY,
  category_name VARCHAR(50) NOT NULL,
  description TEXT
);
```

**Les 24 catégories** :
```
GRT - Greetings (Salutations)
NUM - Numbers (Nombres)
FAM - Family (Famille)
FOD - Food (Nourriture)
BOD - Body (Corps)
TIM - Time (Temps)
COL - Colors (Couleurs)
ANI - Animals (Animaux)
NAT - Nature
VRB - Verbs (Verbes)
ADJ - Adjectives (Adjectifs)
PHR - Phrases
CLO - Clothing (Vêtements)
HOM - Home (Maison)
PRO - Professions
TRA - Transportation (Transport)
EMO - Emotions
EDU - Education
HEA - Health (Santé)
MON - Money (Argent)
DIR - Directions
REL - Religion
MUS - Music (Musique)
SPO - Sports
```

### Table translations (Traductions)

```sql
CREATE TABLE translations (
  translation_id INTEGER PRIMARY KEY AUTOINCREMENT,
  french_text TEXT NOT NULL,
  language_id VARCHAR(10),
  translation TEXT NOT NULL,
  category_id VARCHAR(10),
  pronunciation TEXT,
  usage_notes TEXT,
  difficulty_level TEXT,
  created_date TIMESTAMP,
  FOREIGN KEY (language_id) REFERENCES languages(language_id),
  FOREIGN KEY (category_id) REFERENCES categories(category_id)
);
```

**Exemples** :
```sql
-- Salutation simple
('Bonjour', 'EWO', 'Mbolo', 'GRT', 'mm-BOH-loh', NULL, 'beginner'),

-- Phrase complexe avec notes
('Je ne comprends pas', 'EWO', 'Ma si nkoboo te', 'PHR', 
 'mah see n-koh-BOH teh', 
 'Utilisé pour indiquer l\'incompréhension poliment', 
 'intermediate'),

-- Verbe conjugué
('Être', 'EWO', 'Ye', 'VRB', 'yeh', 
 'Verbe d\'état fondamental, utilisé pour les descriptions', 
 'beginner')
```

---

## 🔧 GESTION DES BASES DE DONNÉES

### Initialisation au Démarrage

**Fichier** : `lib/main.dart`

```dart
void main() async {
  // ... autres initialisations
  
  // Initialisation en arrière-plan (non-bloquant)
  _initializeDatabasesInBackground();
}

Future<void> _initializeDatabasesInBackground() async {
  // 1. Copier cameroon_languages.db depuis assets (première fois)
  await DatabaseInitializationService.database;
  
  // 2. Initialiser base principale
  final db = UnifiedDatabaseService.instance;
  await db.database;  // Crée toutes les tables
  
  // 3. Injecter données initiales si nécessaire
  await DataSeedingService.seedDatabase();
}
```

### Création des Tables

**Fichier** : `lib/core/database/unified_database_service.dart`

**Méthode** : `_onCreate(Database db, int version)`

```dart
Future<void> _onCreate(Database db, int version) async {
  // Active foreign keys
  await db.execute('PRAGMA foreign_keys = ON');
  
  // Crée table users
  await db.execute('''CREATE TABLE users (...)''');
  
  // Crée table daily_limits
  await db.execute('''CREATE TABLE daily_limits (...)''');
  
  // ... toutes les autres tables
  
  // Crée tous les indexes
  await _createIndexes(db);
  
  // Insère métadonnées initiales
  await _insertInitialMetadata(db);
}
```

### Migrations de Version

**Quand une mise à jour nécessite des changements de schéma** :

```dart
// Incrémenter version
static const int _databaseVersion = 3;  // Était 2

// Ajouter migration
Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
  if (oldVersion < 3) {
    await _migrateV2ToV3(db);
  }
}

Future<void> _migrateV2ToV3(Database db) async {
  // Exemple: Ajouter colonne à table existante
  await db.execute('''
    ALTER TABLE users 
    ADD COLUMN phone_number TEXT;
  ''');
  
  // Créer nouvelle table
  await db.execute('''
    CREATE TABLE IF NOT EXISTS user_badges (
      badge_id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id TEXT NOT NULL,
      badge_type TEXT NOT NULL,
      earned_at INTEGER NOT NULL,
      FOREIGN KEY (user_id) REFERENCES users(user_id)
    );
  ''');
  
  // Mettre à jour métadonnées
  await db.update('app_metadata', 
    {'value': '3'}, 
    where: 'key = ?', 
    whereArgs: ['db_version']
  );
}
```

---

## 🔍 REQUÊTES OPTIMISÉES

### Exemples de Requêtes Fréquentes

#### 1. Dashboard Utilisateur (Requête Unique)

```sql
SELECT 
  u.user_id,
  u.display_name,
  u.role,
  u.subscription_status,
  s.total_lessons_completed,
  s.total_quizzes_completed,
  s.experience_points,
  s.level,
  s.current_streak,
  COUNT(DISTINCT p.progress_id) as total_activities,
  COUNT(DISTINCT f.favorite_id) as total_favorites
FROM users u
LEFT JOIN user_statistics s ON u.user_id = s.user_id
LEFT JOIN user_progress p ON u.user_id = p.user_id
LEFT JOIN favorites f ON u.user_id = f.user_id
WHERE u.user_id = ?
GROUP BY u.user_id;
```

**Avantage** : Une seule requête au lieu de 5+ requêtes séparées.

#### 2. Leçon avec Progrès Utilisateur

```sql
SELECT 
  l.lesson_id,
  l.title,
  l.content,
  l.level,
  l.audio_url,
  p.status,
  p.score,
  p.time_spent,
  p.attempts,
  CASE WHEN f.favorite_id IS NOT NULL THEN 1 ELSE 0 END as is_favorite
FROM cameroon.lessons l
LEFT JOIN user_progress p ON 
  p.user_id = ? AND 
  p.content_type = 'lesson' AND 
  p.content_id = l.lesson_id
LEFT JOIN favorites f ON 
  f.user_id = ? AND 
  f.content_type = 'lesson' AND 
  f.content_id = l.lesson_id
WHERE l.lesson_id = ?;
```

**Avantage** : Toutes les infos en une requête (leçon + progrès + favori).

#### 3. Top 10 Étudiants (Classement)

```sql
SELECT 
  u.display_name,
  s.experience_points,
  s.level,
  s.current_streak,
  s.total_lessons_completed
FROM users u
INNER JOIN user_statistics s ON u.user_id = s.user_id
WHERE u.role = 'student'
ORDER BY s.experience_points DESC
LIMIT 10;
```

#### 4. Statistiques Plateforme

```sql
-- Nombre total utilisateurs par rôle
SELECT role, COUNT(*) as count
FROM users
WHERE is_active = 1
GROUP BY role;

-- Activité des 7 derniers jours
SELECT 
  DATE(created_at / 1000, 'unixepoch') as date,
  COUNT(*) as activities
FROM user_progress
WHERE created_at > strftime('%s', 'now', '-7 days') * 1000
GROUP BY DATE(created_at / 1000, 'unixepoch')
ORDER BY date DESC;

-- Langues les plus étudiées
SELECT 
  l.language_name,
  COUNT(DISTINCT p.user_id) as learners,
  COUNT(p.progress_id) as total_activities
FROM cameroon.languages l
LEFT JOIN user_progress p ON p.language_id = l.language_id
GROUP BY l.language_id
ORDER BY learners DESC;
```

---

## 🚀 OPTIMISATION DES PERFORMANCES

### 1. Indexes Stratégiques

**Indexes créés** (20+) :
```sql
-- Users
CREATE INDEX idx_users_firebase_uid ON users(firebase_uid);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_email ON users(email);

-- Progress
CREATE INDEX idx_user_progress_user ON user_progress(user_id);
CREATE INDEX idx_user_progress_content ON user_progress(content_type, content_id);

-- Translations
CREATE INDEX idx_translations_language ON translations(language_id);
CREATE INDEX idx_translations_category ON translations(category_id);
CREATE INDEX idx_translations_french ON translations(french_text);

-- ... et 15+ autres indexes
```

**Impact** :
- Recherche par user_id : 1ms (sans index: 50ms)
- Recherche dictionnaire : 30ms (sans index: 500ms)
- Requêtes complexes : 80ms (sans index: 2000ms)

### 2. Cache en Mémoire

**Fichier** : `lib/core/database/database_query_optimizer.dart`

**Données cachées** :
- Langues (changent rarement)
- Catégories (statiques)
- Statistiques utilisateur (5 min de validité)

**Code** :
```dart
// Première fois: requête DB
final languages = await getCachedLanguages(); // ~50ms

// Fois suivantes (< 5 min): cache mémoire
final languages = await getCachedLanguages(); // ~1ms
```

### 3. Batch Operations

**Pour insertions multiples** :
```dart
final batch = db.batch();

for (var translation in translations) {
  batch.insert('user_created_content', translation);
}

await batch.commit(noResult: true);  // Plus rapide
```

**Performance** :
- Insertion individuelle : 50ms × 100 = 5000ms
- Batch insertion : 200ms pour 100 items
- **Amélioration** : 25x plus rapide

### 4. Pagination

**Pour grandes listes** :
```dart
// Au lieu de charger 1000 leçons
final allLessons = await db.getAllLessons();  // Lent

// Charger page par page
final page1 = await db.getPaginatedLessons(page: 1, pageSize: 20);  // Rapide
```

### 5. Requêtes Préparées

```dart
// Requête précompilée pour réutilisation
final statement = await db.rawQuery(
  'SELECT * FROM users WHERE user_id = ?',
  [userId]
);
```

### 6. VACUUM et ANALYZE

**Maintenance régulière** :
```dart
// Optimiser et récupérer espace
await db.execute('VACUUM');

// Analyser pour optimiser requêtes
await db.execute('ANALYZE');
```

**Quand exécuter** :
- VACUUM : Une fois par mois
- ANALYZE : Après insertions massives

---

## 🛠️ OUTILS DE GESTION

### 1. Inspection de la Base de Données

**Ouvrir avec SQLite CLI** :
```bash
# Naviguer vers le dossier
cd assets/databases

# Ouvrir DB
sqlite3 cameroon_languages.db

# Commandes utiles
.tables                          # Lister tables
.schema users                    # Voir schéma
SELECT * FROM languages;         # Requête
.quit                            # Quitter
```

**Outils GUI recommandés** :
- **DB Browser for SQLite** (Windows/Mac/Linux) - Gratuit
- **SQLiteStudio** - Gratuit et puissant
- **TablePlus** - Interface moderne (payant)

### 2. Export de Données

**Export CSV** :
```sql
.mode csv
.output users_export.csv
SELECT * FROM users;
.output stdout
```

**Export JSON** :
```sql
.mode json
.output users_export.json
SELECT * FROM users;
.output stdout
```

### 3. Backup et Restauration

**Backup** :
```bash
# Copier fichier DB
cp maa_yegue_app.db maa_yegue_app_backup_2025-10-07.db

# Ou depuis app (code Dart)
final dbPath = await getDatabasesPath();
final dbFile = File('$dbPath/maa_yegue_app.db');
await dbFile.copy('$dbPath/backup/maa_yegue_app_backup.db');
```

**Restauration** :
```bash
# Remplacer DB actuelle
cp maa_yegue_app_backup.db maa_yegue_app.db

# Relancer app
flutter run
```

---

## 📈 STATISTIQUES BASE DE DONNÉES

### Taille Estimée

| Base de Données | Contenu | Taille |
|-----------------|---------|--------|
| cameroon_languages.db | 1000+ traductions, 50+ leçons, 20+ quiz | ~3-5 MB |
| maa_yegue_app.db (vide) | Schéma uniquement | ~100 KB |
| maa_yegue_app.db (100 users) | Users + progress + stats | ~2 MB |
| maa_yegue_app.db (1000 users) | Users + progress + stats | ~15 MB |
| maa_yegue_app.db (10,000 users) | Users + progress + stats | ~150 MB |

### Capacité Maximum

**SQLite supporte** :
- 281 TB maximum (théorique)
- Millions de lignes par table
- Milliards de lignes au total

**En pratique pour Ma'a yegue** :
- 1M utilisateurs = ~1.5 GB
- Performant jusqu'à 100K utilisateurs sur mobile
- Au-delà : considérer sharding ou backend

---

## 🔐 SÉCURITÉ BASE DE DONNÉES

### Protection des Données

1. **Chiffrement par l'OS**
   - Android : Chiffrement complet du disque
   - iOS : Chiffrement fichiers app

2. **Accès Restreint**
   - Sandbox application
   - Aucune autre app ne peut lire

3. **Validation des Entrées**
   - Parameterized queries (prévention SQL injection)
   - Sanitization des données
   - Validation types

4. **Transactions Atomiques**
   ```dart
   await db.transaction((txn) async {
     await txn.insert('users', userData);
     await txn.insert('user_statistics', statsData);
     // Si erreur : rollback automatique
   });
   ```

### Prévention SQL Injection

**TOUJOURS utiliser requêtes paramétrées** :

❌ **MAUVAIS** (Vulnérable) :
```dart
final email = userInput;
await db.rawQuery("SELECT * FROM users WHERE email = '$email'");
```

✅ **BON** (Sécurisé) :
```dart
final email = userInput;
await db.query('users', where: 'email = ?', whereArgs: [email]);
```

---

## 📝 CONVENTIONS DE NOMMAGE

### Tables
- **snake_case** : `user_progress`, `daily_limits`
- **Pluriel** pour collections : `users`, `payments`
- **Préfixe** pour tables utilitaires : `app_metadata`

### Colonnes
- **snake_case** : `user_id`, `created_at`
- **Suffixes temporels** : `_at` pour timestamps, `_date` pour dates
- **Booléens** : préfixe `is_` (ex: `is_active`)

### IDs
- **PRIMARY KEY** : Toujours `id` ou `[table]_id`
- **FOREIGN KEY** : Même nom que table référencée + `_id`
- **Format** : TEXT pour UUIDs, INTEGER pour auto-increment

---

## ✅ RÉSUMÉ

**Bases de données** : 2 (principale + langues)  
**Tables totales** : 15+ tables  
**Langues** : 7  
**Traductions** : 1000+  
**Leçons** : 50+ par langue  
**Performance** : < 100ms pour 95% des requêtes  
**Capacité** : Millions d'utilisateurs supportés  
**Sécurité** : Chiffrement OS + requêtes paramétrées  
**Maintenance** : VACUUM mensuel recommandé  

---

**Document créé** : 7 Octobre 2025  
**Fichiers liés** :
- `05_SERVICES_FIREBASE.md`
- `06_GUIDE_DEVELOPPEUR.md`
- `07_GUIDE_OPERATIONNEL.md`
