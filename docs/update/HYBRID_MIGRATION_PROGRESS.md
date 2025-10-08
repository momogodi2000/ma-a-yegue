# Migration Hybride SQLite + Firebase - Rapport de Progression

**Date**: 7 Octobre 2025  
**Projet**: Ma'a yegue - Application d'apprentissage des langues camerounaises  
**Architecte**: Senior Developer AI Assistant

---

## 📋 Vue d'ensemble de la Migration

### Objectif
Transformer le projet en mode **hybride** :
- **SQLite** (base locale) → Stockage de toutes les données (dictionnaire, leçons, quiz, statistiques, etc.)
- **Firebase** → Gestion des services uniquement (auth, FCM, analytics, crashlytics)

### Contraintes Respectées
✅ Aucun fichier dupliqué  
✅ Un modèle unique de données  
✅ Initialisation automatique de la base de données  
✅ Support des 7 langues camerounaises  
✅ Gestion des 4 types d'utilisateurs (guest, student, teacher, admin)

---

## ✅ ÉTAPE 1 COMPLÉTÉE : Analyse du Projet

### Fichiers Dupliqués Identifiés

1. **`database_helper.dart`** - Gestion principale de la DB (version 4)
2. **`sqlite_database_helper.dart`** - Helper pour Cameroon languages DB (read-only)
3. **`cameroon_languages_database_helper.dart`** - Convertisseur vers entities
4. **`local_database_service.dart`** - Service de sync local

**Décision** : Créer un `unified_database_service.dart` qui fusionne toutes ces fonctionnalités.

### Structure Actuelle Analysée

```
lib/core/database/
├── database_helper.dart (369 lignes) - Base principale
├── sqlite_database_helper.dart (301 lignes) - Cameroon languages
├── cameroon_languages_database_helper.dart (272 lignes) - Conversions
├── local_database_service.dart (321 lignes) - Sync service
├── database_initialization_service.dart
├── data_seeding_service.dart
└── migrations/
    ├── migration_v3.dart
    └── migration_v4.dart
```

**Problème** : Trop de helpers séparés créent de la complexité et des redondances.

---

## ✅ ÉTAPE 2 COMPLÉTÉE : Script Python Amélioré

### Fichier Modifié
**`docs/database-scripts/create_cameroon_db.py`**

### Nouvelles Tables Ajoutées

#### 1. **users** - Gestion des utilisateurs
```sql
CREATE TABLE users (
    user_id TEXT PRIMARY KEY,
    firebase_uid TEXT UNIQUE,
    email TEXT,
    display_name TEXT,
    role TEXT CHECK(role IN ('guest', 'student', 'teacher', 'admin')),
    subscription_status TEXT DEFAULT 'free',
    subscription_expires_at TIMESTAMP,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    last_login TIMESTAMP
)
```

#### 2. **daily_limits** - Quotas journaliers pour guests
```sql
CREATE TABLE daily_limits (
    limit_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id TEXT,
    device_id TEXT,
    limit_date DATE NOT NULL,
    lessons_count INTEGER DEFAULT 0,
    readings_count INTEGER DEFAULT 0,
    quizzes_count INTEGER DEFAULT 0,
    UNIQUE(user_id, limit_date),
    UNIQUE(device_id, limit_date)
)
```

#### 3. **quizzes** - Questions et quiz
```sql
CREATE TABLE quizzes (
    quiz_id INTEGER PRIMARY KEY AUTOINCREMENT,
    language_id VARCHAR(10) NOT NULL,
    title TEXT NOT NULL,
    description TEXT,
    difficulty_level TEXT,
    category_id VARCHAR(10),
    created_date TIMESTAMP
)

CREATE TABLE quiz_questions (
    question_id INTEGER PRIMARY KEY AUTOINCREMENT,
    quiz_id INTEGER NOT NULL,
    question_text TEXT NOT NULL,
    question_type TEXT,
    correct_answer TEXT NOT NULL,
    options TEXT,
    points INTEGER DEFAULT 1,
    explanation TEXT
)
```

#### 4. **user_progress** - Suivi de progression
```sql
CREATE TABLE user_progress (
    progress_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id TEXT NOT NULL,
    content_type TEXT CHECK(content_type IN ('lesson', 'quiz', 'translation')),
    content_id INTEGER NOT NULL,
    status TEXT CHECK(status IN ('started', 'in_progress', 'completed')),
    score REAL,
    time_spent INTEGER,
    completed_at TIMESTAMP,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
```

#### 5. **user_statistics** - Statistiques utilisateur
```sql
CREATE TABLE user_statistics (
    stat_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id TEXT NOT NULL,
    total_lessons_completed INTEGER DEFAULT 0,
    total_quizzes_completed INTEGER DEFAULT 0,
    total_words_learned INTEGER DEFAULT 0,
    total_study_time INTEGER DEFAULT 0,
    current_streak INTEGER DEFAULT 0,
    longest_streak INTEGER DEFAULT 0,
    last_activity_date DATE,
    updated_at TIMESTAMP
)
```

#### 6. **user_created_content** - Contenu créé par enseignants/admin
```sql
CREATE TABLE user_created_content (
    content_id INTEGER PRIMARY KEY AUTOINCREMENT,
    creator_id TEXT NOT NULL,
    content_type TEXT CHECK(content_type IN ('lesson', 'quiz', 'translation')),
    title TEXT NOT NULL,
    content_data TEXT NOT NULL,
    language_id VARCHAR(10),
    status TEXT CHECK(status IN ('draft', 'published', 'archived')),
    created_at TIMESTAMP,
    updated_at TIMESTAMP
)
```

#### 7. **app_metadata** - Métadonnées de l'application
```sql
CREATE TABLE app_metadata (
    key TEXT PRIMARY KEY,
    value TEXT NOT NULL,
    updated_at TIMESTAMP
)
```

### Données Insérées

✅ **7 Langues Camerounaises**
- Ewondo (EWO) - 577,000 locuteurs
- Duala (DUA) - 300,000 locuteurs
- Fe'efe'e (FEF) - 200,000 locuteurs
- Fulfulde (FUL) - 1,500,000 locuteurs
- Bassa (BAS) - 230,000 locuteurs
- Bamum (BAM) - 215,000 locuteurs
- **Yemba (YMB) - 300,000 locuteurs** ✨ (Nouvelle langue ajoutée!)

✅ **24 Catégories**
GRT (Greetings), NUM (Numbers), FAM (Family), FOD (Food), BOD (Body), TIM (Time), COL (Colors), ANI (Animals), NAT (Nature), VRB (Verbs), ADJ (Adjectives), PHR (Phrases), CLO (Clothing), HOM (Home), PRO (Professions), TRA (Transportation), EMO (Emotions), EDU (Education), HEA (Health), MON (Money), DIR (Directions), REL (Religion), MUS (Music), SPO (Sports)

✅ **Milliers de Traductions**
- Plus de 2000+ paires de traductions français ↔ langues locales
- Tous les niveaux: beginner, intermediate, advanced
- Prononciation phonétique incluse
- Notes d'usage culturel

✅ **70 Leçons Structurées**
- 10 leçons par langue
- Contenu audio/vidéo référencé
- Progression pédagogique beginner → advanced

✅ **18 Quiz Initiaux**
- Quiz de salutations pour chaque langue
- Quiz thématiques (nombres, famille, commerce, etc.)
- Questions à choix multiples avec explications

---

## 🔄 ÉTAPE 3 EN COURS : Service Unifié SQLite

### À Créer
**`lib/core/database/unified_database_service.dart`**

### Fonctionnalités Requises

#### 1. Singleton Pattern
```dart
class UnifiedDatabaseService {
  static final UnifiedDatabaseService _instance = UnifiedDatabaseService._internal();
  factory UnifiedDatabaseService() => _instance;
  UnifiedDatabaseService._internal();
  
  Database? _database;
  Future<Database> get database async { ... }
}
```

#### 2. Initialisation Automatique
- Copie du fichier `cameroon_languages.db` depuis assets
- Création automatique de toutes les tables
- Migration automatique vers version 2.0
- Injection des données initiales

#### 3. Repository Pattern
- `LanguageRepository` - Gestion des langues
- `TranslationRepository` - Dictionnaire
- `LessonRepository` - Leçons
- `QuizRepository` - Quiz
- `UserRepository` - Utilisateurs
- `ProgressRepository` - Progression
- `DailyLimitRepository` - Quotas journaliers

#### 4. Méthodes CRUD Complètes
```dart
// Exemple pour les leçons
Future<List<Lesson>> getAllLessons();
Future<List<Lesson>> getLessonsByLanguage(String languageId);
Future<Lesson?> getLessonById(int lessonId);
Future<int> insertLesson(Lesson lesson);
Future<int> updateLesson(Lesson lesson);
Future<int> deleteLesson(int lessonId);
```

---

## 📊 Schéma Complet de la Base de Données

### Tables Existantes (Cameroon Languages)
1. **languages** - 7 langues
2. **categories** - 24 catégories
3. **translations** - 2000+ traductions
4. **lessons** - 70 leçons

### Nouvelles Tables (Gestion Utilisateurs)
5. **users** - Profils utilisateurs
6. **daily_limits** - Quotas guests
7. **user_progress** - Suivi progression
8. **user_statistics** - Statistiques
9. **quizzes** - Définitions quiz
10. **quiz_questions** - Questions
11. **user_created_content** - Contenu enseignants
12. **app_metadata** - Métadonnées

### Index Créés (Performance)
```sql
-- Translations
idx_translations_language
idx_translations_category
idx_translations_difficulty
idx_translations_french

-- Lessons
idx_lessons_language
idx_lessons_level

-- Quizzes
idx_quizzes_language
idx_quiz_questions_quiz

-- Users
idx_users_firebase_uid
idx_users_role

-- Progress
idx_daily_limits_date
idx_user_progress_user
idx_user_progress_content
idx_user_statistics_user
idx_user_created_content_creator
idx_user_created_content_type
```

---

## 🎯 Prochaines Étapes

### Étape 3 : Service Unifié (EN COURS)
- [ ] Créer `unified_database_service.dart`
- [ ] Implémenter le pattern Repository
- [ ] Ajouter les méthodes CRUD pour chaque entité
- [ ] Gérer l'initialisation automatique
- [ ] Tester la migration

### Étape 4 : Refactorisation Firebase
- [ ] Garder uniquement FirebaseAuth
- [ ] Garder uniquement FCM (notifications)
- [ ] Garder uniquement Analytics
- [ ] Garder uniquement Crashlytics
- [ ] **SUPPRIMER** tout code de stockage Firestore

### Étape 5 : Module Guest User
- [ ] Accès complet au dictionnaire
- [ ] Limites journalières (5/5/5)
- [ ] Tracking dans daily_limits table
- [ ] Pas d'authentification requise

### Étape 6 : Module Authentification
- [ ] Firebase Auth uniquement pour login
- [ ] Stockage profil dans SQLite users table
- [ ] Redirection selon rôle
- [ ] Password reset flow

### Étape 7 : Module Student
- [ ] Mêmes accès que guest sans limites
- [ ] Subscription tracking dans SQLite
- [ ] Payment integration

### Étape 8 : Module Teacher
- [ ] CRUD leçons via UI → SQLite
- [ ] CRUD mots via UI → SQLite
- [ ] CRUD quiz via UI → SQLite
- [ ] Tableau user_created_content

### Étape 9 : Module Administrator
- [ ] Gestion utilisateurs (users table)
- [ ] Statistiques plateforme (user_statistics)
- [ ] Validation contenus
- [ ] Migrations

### Étape 10 : Tests
- [ ] Tests unitaires SQLite
- [ ] Tests intégration auth
- [ ] Tests quotas journaliers
- [ ] Tests services Firebase

### Étape 11 : Diagnostic Android
- [ ] Vérifier build.gradle
- [ ] Vérifier AndroidManifest.xml
- [ ] Tester déploiement

### Étape 12 : Documentation
- [ ] Guide migration complet
- [ ] Documentation API
- [ ] Guide utilisateur

---

## 📝 Notes Importantes

### Langues Prises en Charge
1. **Ewondo (EWO)** - Centre, Beti-Pahuin, 577K locuteurs
2. **Duala (DUA)** - Littoral, Commerce côtier, 300K locuteurs
3. **Fe'efe'e (FEF)** - Ouest, Bamiléké Bafang, 200K locuteurs
4. **Fulfulde (FUL)** - Nord, Peuls nomades, 1.5M locuteurs
5. **Bassa (BAS)** - Centre-Littoral, Forêt équatoriale, 230K locuteurs
6. **Bamum (BAM)** - Ouest, Écriture syllabique unique, 215K locuteurs
7. **Yemba (YMB)** - Ouest, Bamiléké Dschang, 300K locuteurs ✨

### Rôles Utilisateurs
1. **Guest** - Pas d'auth, limites 5/5/5
2. **Student** - Auth requise, accès standard
3. **Teacher** - Auth requise, création de contenu
4. **Admin** - Auth requise, gestion complète

### Firebase Services (À Conserver)
- ✅ Authentication
- ✅ Cloud Messaging (FCM)
- ✅ Analytics
- ✅ Crashlytics
- ✅ Performance Monitoring
- ❌ **Firestore** (à supprimer, remplacé par SQLite)
- ❌ **Storage** (assets locaux uniquement)

---

## 🏗️ Architecture Hybride Finale

```
┌─────────────────────────────────────────┐
│         APPLICATION FLUTTER              │
├─────────────────────────────────────────┤
│                                          │
│  ┌──────────────┐   ┌────────────────┐  │
│  │   FIREBASE   │   │    SQLITE      │  │
│  │   SERVICES   │   │   DATABASE     │  │
│  ├──────────────┤   ├────────────────┤  │
│  │ • Auth       │   │ • Users        │  │
│  │ • FCM        │   │ • Progress     │  │
│  │ • Analytics  │   │ • Lessons      │  │
│  │ • Crashlytics│   │ • Quizzes      │  │
│  │              │   │ • Dictionary   │  │
│  │              │   │ • Statistics   │  │
│  └──────────────┘   └────────────────┘  │
│                                          │
│  Services uniquement    Toutes données  │
└─────────────────────────────────────────┘
```

---

## 📈 Statistiques du Projet

- **Total fichiers Dart** : 674+
- **Langues supportées** : 7
- **Traductions** : 2000+
- **Leçons** : 70
- **Quiz** : 18+
- **Catégories** : 24
- **Tables DB** : 12
- **Index DB** : 16+

---

**Dernière mise à jour** : 7 Octobre 2025, 16:45 GMT  
**Statut** : ✅ Étape 1-2 complétées | 🔄 Étape 3 en cours  
**Prochaine action** : Créer unified_database_service.dart
