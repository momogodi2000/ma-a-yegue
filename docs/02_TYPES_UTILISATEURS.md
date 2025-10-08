# 👥 TYPES D'UTILISATEURS - MA'A YEGUE

## 📋 Vue d'Ensemble

L'application Ma'a yegue supporte **4 types d'utilisateurs** avec des rôles et permissions distincts :

1. **👤 Invité (Guest)** - Visiteur non authentifié
2. **🎓 Apprenant (Student/Learner)** - Utilisateur authentifié standard
3. **👨‍🏫 Enseignant (Teacher)** - Créateur de contenu
4. **👨‍💼 Administrateur (Admin)** - Gestionnaire de plateforme

---

## 1. 👤 UTILISATEUR INVITÉ (GUEST)

### 🎯 Caractéristiques

**Authentification** : ❌ NON REQUISE  
**Stockage de données** : Limité (device_id uniquement)  
**Persistance** : Limites quotidiennes trackées par appareil  

### ✅ Accès et Permissions

#### Dictionnaire
- ✅ **Accès COMPLET** à tous les mots du dictionnaire
- ✅ **1000+ traductions** disponibles
- ✅ **7 langues** accessibles
- ✅ **Recherche illimitée** dans le dictionnaire
- ✅ **Toutes catégories** (greetings, numbers, family, etc.)
- ✅ **Prononciation et exemples** inclus

#### Leçons
- ⚠️ **Accès LIMITÉ** : 5 leçons par jour
- ✅ Peut consulter toutes les leçons disponibles
- ❌ Progrès non sauvegardé
- ❌ Pas de statistiques

#### Lectures
- ⚠️ **Accès LIMITÉ** : 5 lectures par jour
- ✅ Contenu culturel accessible
- ❌ Historique non sauvegardé

#### Quiz
- ⚠️ **Accès LIMITÉ** : 5 quiz par jour
- ✅ Peut tenter les quiz
- ❌ Résultats non sauvegardés
- ❌ Pas de classement

### 🔢 Système de Limites Quotidiennes

#### Comment ça fonctionne ?

**Tracking par Device ID** :
```
Appareil → Génération ID unique → Stockage dans SQLite
                                   ↓
                            Table: daily_limits
                                   ↓
                        Colonnes: device_id, limit_date,
                                  lessons_count, readings_count, quizzes_count
```

**Exemple de flux** :
```
09:00 - Invité ouvre app → device_id = "android_abc123"
09:15 - Consulte leçon 1 → lessons_count = 1
10:30 - Consulte leçon 2 → lessons_count = 2
14:20 - Consulte leçon 3 → lessons_count = 3
16:45 - Consulte leçon 4 → lessons_count = 4
18:00 - Consulte leçon 5 → lessons_count = 5
19:00 - Tente leçon 6 → ❌ LIMITE ATTEINTE

MINUIT - Réinitialisation automatique
00:00 - Nouveau jour → lessons_count = 0
```

#### Réinitialisation

- **Fréquence** : Quotidienne (à minuit, heure locale)
- **Automatique** : Basée sur la date (`limit_date`)
- **Par type** : Leçons, lectures, quiz = compteurs séparés

#### Contournement des Limites

Pour débloquer l'accès illimité :
```
Invité → Créer un compte → Devient Apprenant (Student)
                           ↓
                    Limites supprimées ✅
```

### 🛠️ Implémentation Technique

#### Service Principal
**Fichier** : `lib/core/services/guest_limit_service.dart`

**Méthodes clés** :
```dart
// Vérifier si peut accéder
canAccessLesson() → bool
canAccessReading() → bool
canAccessQuiz() → bool

// Incrémenter compteur
incrementLessonCount()
incrementReadingCount()
incrementQuizCount()

// Obtenir ID appareil
getDeviceId() → String

// Obtenir limites du jour
_getTodayLimits() → Map<String, dynamic>
```

#### Table SQLite
```sql
CREATE TABLE daily_limits (
  limit_id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT,           -- NULL pour invités
  device_id TEXT,         -- ID unique de l'appareil
  limit_date TEXT,        -- Format: YYYY-MM-DD
  lessons_count INTEGER DEFAULT 0,
  readings_count INTEGER DEFAULT 0,
  quizzes_count INTEGER DEFAULT 0,
  created_at INTEGER,
  UNIQUE(device_id, limit_date)
);
```

### 📱 Interface Utilisateur

#### Indicateurs de Limites

L'interface affiche toujours le quota restant :
```
┌─────────────────────────────────────┐
│  📚 Leçons du Jour: 3/5 restantes  │
│  📖 Lectures: 5/5 restantes         │
│  🎯 Quiz: 2/5 restants              │
│                                     │
│  [Créer un compte pour illimité]   │
└─────────────────────────────────────┘
```

#### Message de Limite Atteinte

```
┌────────────────────────────────────────────┐
│  ⚠️ Limite Quotidienne Atteinte           │
│                                            │
│  Vous avez utilisé vos 5 leçons du jour.  │
│                                            │
│  Pour un accès illimité :                 │
│  • Créez un compte gratuit                │
│  • Revenez demain (réinitialisation)      │
│                                            │
│  [S'inscrire Gratuitement]  [Retour]      │
└────────────────────────────────────────────┘
```

### 🎯 Stratégie de Conversion

L'objectif des limites invité est de **convertir les visiteurs en utilisateurs inscrits**.

**Funnel de conversion** :
```
100 Invités
    ↓
80 utilisent dictionnaire (80%)
    ↓
40 essaient leçons (40%)
    ↓
20 atteignent limite (20%)
    ↓
10 s'inscrivent (10% conversion)
```

---

## 2. 🎓 APPRENANT (STUDENT/LEARNER)

### 🎯 Caractéristiques

**Authentification** : ✅ REQUISE  
**Stockage de données** : Complet (SQLite)  
**Persistance** : Permanente (progrès sauvegardé)  

### ✅ Accès et Permissions

#### Tout ce que l'invité a, SANS limites

- ✅ Dictionnaire **illimité**
- ✅ Leçons **illimitées**
- ✅ Lectures **illimitées**
- ✅ Quiz **illimités**

#### Plus les fonctionnalités suivantes :

#### Suivi de Progrès
- ✅ Progression sauvegardée pour chaque leçon
- ✅ Résultats de quiz enregistrés
- ✅ Historique complet d'apprentissage
- ✅ Reprendre où on s'est arrêté

#### Statistiques Personnelles
- ✅ Nombre de leçons complétées
- ✅ Nombre de quiz réussis
- ✅ Nombre de mots appris
- ✅ Temps d'étude total
- ✅ Série d'apprentissage (streak)
- ✅ Points d'expérience (XP)
- ✅ Niveau actuel

#### Favoris et Collections
- ✅ Marquer traductions favorites
- ✅ Sauvegarder leçons préférées
- ✅ Collection de quiz favoris
- ✅ Accès rapide aux favoris

#### Profil Personnalisé
- ✅ Photo de profil
- ✅ Nom d'affichage
- ✅ Préférences d'apprentissage
- ✅ Langues en cours d'étude

### 💰 Modèle Freemium

#### Compte Gratuit (Free)
- ✅ Accès au dictionnaire complet
- ✅ Leçons de base (premiers niveaux)
- ✅ Quiz gratuits
- ⚠️ Publicités (si implémentées)
- ❌ Pas de certificats
- ❌ Pas de contenu premium

#### Compte Premium (Abonnement)
- ✅ **TOUT** le contenu gratuit
- ✅ Leçons avancées
- ✅ Quiz premium
- ✅ Contenu exclusif enseignants
- ✅ Certificats de complétion
- ✅ Pas de publicités
- ✅ Support prioritaire

### 🛠️ Implémentation Technique

#### Service Principal
**Fichier** : `lib/features/learner/data/services/student_service.dart`

**Méthodes clés** :
```dart
// Vérifier abonnement
hasActiveSubscription(userId) → bool

// Obtenir leçons disponibles
getAvailableLessons(userId, languageId) → List

// Sauvegarder progrès
saveLessonProgress(userId, lessonId, status, score)

// Obtenir statistiques
getStatistics(userId) → Map

// Gérer favoris
addToFavorites(userId, contentType, contentId)
removeFromFavorites(userId, contentType, contentId)
isFavorite(userId, contentType, contentId) → bool

// Marquer mot appris
markWordAsLearned(userId, wordId)

// Mettre à jour série
updateStreak(userId)
```

#### Tables SQLite Utilisées

```sql
-- Profil utilisateur
users (user_id, email, display_name, role, subscription_status, ...)

-- Statistiques
user_statistics (user_id, total_lessons_completed, experience_points, ...)

-- Progrès
user_progress (user_id, content_type, content_id, status, score, ...)

-- Favoris
favorites (user_id, content_type, content_id, created_at)

-- Abonnements
subscriptions (user_id, plan_type, status, start_date, end_date, ...)

-- Paiements
payments (user_id, amount, status, payment_method, ...)
```

### 📊 Suivi de Progrès

#### Statuts de Progression

1. **started** : Leçon/Quiz commencé mais non terminé
2. **in_progress** : En cours (> 25% complété)
3. **completed** : Terminé avec succès (> 70% score)

#### Calcul de l'Expérience (XP)

```dart
// Quiz complété
XP = score * 10
// Exemple: Score 85% = 850 XP

// Leçon complétée
XP = 100 (base) + bonus_vitesse

// Série quotidienne
XP = streak_days * 50
// Exemple: 7 jours consécutifs = 350 XP bonus

// Niveau = XP ÷ 1000
// Exemple: 2500 XP = Niveau 2
```

### 🎯 Parcours Apprenant Typique

```
Jour 1:
- S'inscrit (free account)
- Choisit langue (Ewondo)
- Complète leçon 1 → +100 XP
- Tente quiz 1 → +85 XP (85% score)
- Total: 185 XP

Jour 2:
- Complète leçon 2 → +100 XP
- Série 2 jours → +100 XP bonus
- Total: 385 XP

Jour 7:
- Série 7 jours → +350 XP bonus
- Niveau 1 → Niveau 2 (1000+ XP)

Jour 30:
- Souscrit abonnement premium
- Accès contenu avancé
- Certificat disponible
```

---

## 3. 👨‍🏫 ENSEIGNANT (TEACHER)

### 🎯 Caractéristiques

**Authentification** : ✅ REQUISE  
**Rôle** : Créateur de contenu pédagogique  
**Validation** : Approbation admin possible (optionnel)  

### ✅ Accès et Permissions

#### Tout ce que l'apprenant a, PLUS :

#### Création de Contenu

**Leçons** :
- ✅ Créer nouvelles leçons
- ✅ Éditer leçons existantes (siennes)
- ✅ Définir niveau (débutant/intermédiaire/avancé)
- ✅ Ajouter audio/vidéo
- ✅ Organiser par ordre
- ✅ Publier/Archiver/Supprimer

**Quiz** :
- ✅ Créer nouveaux quiz
- ✅ Ajouter questions multiples
- ✅ Types : choix multiple, vrai/faux, remplir blancs
- ✅ Définir réponses correctes
- ✅ Ajouter explications
- ✅ Attribuer points par question

**Traductions (Mots du Dictionnaire)** :
- ✅ Ajouter nouveaux mots
- ✅ Définir catégorie (greetings, family, etc.)
- ✅ Ajouter prononciation
- ✅ Inclure notes d'usage
- ✅ Définir niveau de difficulté

#### Gestion de Contenu

- ✅ Voir tout son contenu créé
- ✅ Filtrer par type (leçon/quiz/traduction)
- ✅ Filtrer par statut (brouillon/publié/archivé)
- ✅ Modifier/Supprimer son contenu
- ✅ Statistiques de son contenu

#### Statistiques

- ✅ Nombre de leçons créées
- ✅ Nombre de quiz créés
- ✅ Nombre de traductions ajoutées
- ✅ Nombre de publications
- ✅ Contenu populaire (si analytics activés)

### 🛠️ Implémentation Technique

#### Service Principal
**Fichier** : `lib/features/teacher/data/services/teacher_service.dart`

**Méthodes de Création** :
```dart
// Créer une leçon
createLesson({
  teacherId,
  languageId,
  title,
  content,
  level,
  audioUrl,
  videoUrl,
  status,
}) → Map<String, dynamic>

// Créer un quiz
createQuiz({
  teacherId,
  languageId,
  title,
  description,
  difficultyLevel,
  categoryId,
}) → Map<String, dynamic>

// Ajouter question à quiz
addQuizQuestion({
  quizId,
  questionText,
  questionType,
  correctAnswer,
  options,
  points,
  explanation,
}) → Map<String, dynamic>

// Ajouter traduction
addTranslation({
  teacherId,
  languageId,
  frenchText,
  translation,
  categoryId,
  pronunciation,
  usageNotes,
  difficultyLevel,
}) → Map<String, dynamic>
```

**Méthodes de Gestion** :
```dart
// Obtenir son contenu
getCreatedContent(teacherId, contentType, status) → List

// Obtenir leçons créées
getCreatedLessons(teacherId, status) → List

// Obtenir quiz créés
getCreatedQuizzes(teacherId, status) → List

// Publier contenu
publishContent(contentId) → Map

// Archiver contenu
archiveContent(contentId) → Map

// Supprimer contenu
deleteContent(contentId) → Map

// Statistiques enseignant
getTeacherStatistics(teacherId) → Map
```

**Méthodes de Validation** :
```dart
// Valider données leçon
validateLessonData(title, content, languageId, level) → Map

// Valider données quiz
validateQuizData(title, languageId) → Map

// Valider traduction
validateTranslationData(frenchText, translation, languageId) → Map
```

#### Tables SQLite Utilisées

```sql
-- Contenu créé par enseignants
CREATE TABLE user_created_content (
  content_id INTEGER PRIMARY KEY AUTOINCREMENT,
  creator_id TEXT NOT NULL,
  content_type TEXT CHECK(content_type IN ('lesson', 'quiz', 'translation', 'reading')),
  title TEXT NOT NULL,
  content_data TEXT NOT NULL,
  language_id TEXT,
  category_id TEXT,
  status TEXT CHECK(status IN ('draft', 'published', 'archived')) DEFAULT 'draft',
  difficulty_level TEXT,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  FOREIGN KEY (creator_id) REFERENCES users(user_id)
);

-- Quiz créés
CREATE TABLE quizzes (
  quiz_id INTEGER PRIMARY KEY AUTOINCREMENT,
  language_id TEXT NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  difficulty_level TEXT,
  category_id TEXT,
  creator_id TEXT,
  is_official INTEGER DEFAULT 0,
  created_at INTEGER,
  updated_at INTEGER,
  FOREIGN KEY (creator_id) REFERENCES users(user_id)
);

-- Questions de quiz
CREATE TABLE quiz_questions (
  question_id INTEGER PRIMARY KEY AUTOINCREMENT,
  quiz_id INTEGER NOT NULL,
  question_text TEXT NOT NULL,
  question_type TEXT,
  correct_answer TEXT NOT NULL,
  options TEXT,           -- JSON array
  points INTEGER DEFAULT 1,
  explanation TEXT,
  order_index INTEGER DEFAULT 0,
  FOREIGN KEY (quiz_id) REFERENCES quizzes(quiz_id) ON DELETE CASCADE
);
```

### 📝 Workflow Création de Contenu

#### 1. Créer une Leçon

```
Enseignant → Dashboard → "Créer Leçon"
                            ↓
            Formulaire:
            - Titre
            - Contenu (texte riche)
            - Langue cible
            - Niveau (débutant/inter/avancé)
            - Audio (optionnel)
            - Vidéo (optionnel)
                            ↓
            Validation des données
                            ↓
            Sauvegarde SQLite (statut: draft)
                            ↓
            Enseignant peut:
            - Prévisualiser
            - Éditer
            - Publier → accessible par étudiants
            - Archiver → caché
            - Supprimer
```

#### 2. Créer un Quiz

```
Enseignant → "Créer Quiz" → Informations de base
                               ↓
                    Quiz créé (statut: draft)
                               ↓
                    Ajouter Questions:
                    ┌─────────────────────────────────┐
                    │ Question 1                      │
                    │ Type: Choix multiple            │
                    │ Question: "Comment dit-on...?"  │
                    │ Options: [A, B, C, D]          │
                    │ Réponse: A                     │
                    │ Points: 10                     │
                    │ Explication: "Parce que..."    │
                    └─────────────────────────────────┘
                               ↓
                    Répéter pour N questions
                               ↓
                    Publier quiz → disponible
```

#### 3. Ajouter une Traduction

```
Enseignant → "Ajouter Mot" → Formulaire
                                ↓
                Champs:
                - Texte français: "Bonjour"
                - Traduction: "Mbolo"
                - Langue: Ewondo
                - Catégorie: Greetings
                - Prononciation: "mm-BOH-loh"
                - Notes d'usage: "Salutation standard"
                - Difficulté: Débutant
                                ↓
                Validation
                                ↓
                Insertion SQLite
                                ↓
                Disponible immédiatement dans dictionnaire
```

### 📊 Statistiques Enseignant

**Dashboard enseignant affiche** :
```
┌─────────────────────────────────────────┐
│  📊 Mes Statistiques                   │
│                                         │
│  📚 Leçons créées: 12                  │
│  🎯 Quiz créés: 8                      │
│  📝 Traductions ajoutées: 45           │
│                                         │
│  📤 Publié: 18                         │
│  📝 Brouillon: 5                       │
│  📦 Archivé: 2                         │
│                                         │
│  [Créer Nouveau Contenu]               │
└─────────────────────────────────────────┘
```

---

## 4. 👨‍💼 ADMINISTRATEUR (ADMIN)

### 🎯 Caractéristiques

**Authentification** : ✅ REQUISE  
**Rôle** : Gestion complète de la plateforme  
**Permissions** : MAXIMALES  

### ✅ Accès et Permissions

#### Tout ce que l'enseignant a, PLUS :

#### Gestion des Utilisateurs

**Visualisation** :
- ✅ Liste de tous les utilisateurs
- ✅ Filtrer par rôle (guest/student/teacher/admin)
- ✅ Rechercher utilisateurs (email, nom)
- ✅ Voir détails utilisateur complets

**Modification** :
- ✅ Changer rôle utilisateur
  ```
  Student → Teacher (promotion)
  Teacher → Admin (élévation)
  Admin → Student (rétrogradation)
  ```
- ✅ Activer/Désactiver compte
- ✅ Modifier statut abonnement
- ✅ Voir historique utilisateur

**Suppression** :
- ⚠️ Supprimer compte utilisateur
- ⚠️ Anonymiser données (RGPD)

#### Gestion du Contenu

**Modération** :
- ✅ Voir TOUT le contenu (tous enseignants)
- ✅ Approuver contenu enseignant
- ✅ Rejeter/Archiver contenu inapproprié
- ✅ Éditer n'importe quel contenu
- ✅ Supprimer n'importe quel contenu

**Organisation** :
- ✅ Réorganiser ordre des leçons
- ✅ Catégoriser contenu
- ✅ Marquer contenu "officiel"
- ✅ Mettre en avant contenu de qualité

#### Statistiques Plateforme

**Utilisateurs** :
- ✅ Nombre total d'utilisateurs
- ✅ Nouveaux utilisateurs (jour/semaine/mois)
- ✅ Utilisateurs actifs
- ✅ Taux de rétention
- ✅ Taux de conversion (guest → student)

**Contenu** :
- ✅ Nombre de traductions par langue
- ✅ Nombre de leçons par niveau
- ✅ Nombre de quiz disponibles
- ✅ Contenu créé par utilisateurs vs officiel

**Engagement** :
- ✅ Leçons complétées (total)
- ✅ Quiz tentés
- ✅ Mots appris
- ✅ Temps d'étude total plateforme
- ✅ Langues les plus populaires

**Performance** :
- ✅ Top étudiants (par XP)
- ✅ Enseignants les plus actifs
- ✅ Contenu le plus consulté
- ✅ Taux de complétion par leçon

#### Système et Maintenance

- ✅ Voir version base de données
- ✅ Voir métadonnées application
- ✅ Forcer synchronisation (si nécessaire)
- ✅ Exporter données plateforme
- ✅ Logs d'activité admin

### 🛠️ Implémentation Technique

#### Service Principal
**Fichier** : `lib/features/admin/data/services/admin_service.dart`

**Méthodes de Gestion Utilisateurs** :
```dart
// Obtenir tous les utilisateurs
getAllUsers(role) → List

// Obtenir utilisateurs par rôle
getUsersByRole(role) → List
getAllStudents() → List
getAllTeachers() → List

// Modifier rôle
updateUserRole(userId, newRole) → Map

// Détails utilisateur + stats
getUserDetails(userId) → Map
```

**Méthodes Statistiques** :
```dart
// Stats plateforme complètes
getPlatformStatistics() → Map

// Croissance utilisateurs
getUserGrowthStatistics() → Map

// Stats contenu
getContentStatistics() → Map

// Stats engagement
getEngagementStatistics() → Map

// Stats par langue
getLanguageStatistics() → Map

// Top étudiants
getTopStudents(limit) → List

// Enseignants actifs
getMostActiveTeachers(limit) → List

// Données dashboard admin
getDashboardData() → Map (complet)
```

**Méthodes de Modération** :
```dart
// Obtenir tout le contenu utilisateurs
getAllUserCreatedContent(contentType, status) → List

// Approuver contenu
approveContent(contentId) → Map

// Rejeter contenu
rejectContent(contentId) → Map

// Supprimer contenu
deleteContent(contentId) → Map
```

**Méthodes Système** :
```dart
// Métadonnées DB
getDatabaseMetadata() → Map

// Export données
exportPlatformData() → Map (futur)
```

#### Tables SQLite Utilisées

Toutes les tables + :

```sql
-- Logs administratifs
CREATE TABLE admin_logs (
  log_id INTEGER PRIMARY KEY AUTOINCREMENT,
  action TEXT NOT NULL,
  user_id TEXT,
  admin_id TEXT,
  details TEXT,
  timestamp TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(user_id),
  FOREIGN KEY (admin_id) REFERENCES users(user_id)
);
```

### 📊 Dashboard Administrateur

#### Vue Principale

```
┌────────────────────────────────────────────────────┐
│  🏆 MA'A YEGUE - ADMINISTRATION                   │
├────────────────────────────────────────────────────┤
│                                                    │
│  📊 STATISTIQUES PLATEFORME                       │
│  ┌──────────┬──────────┬──────────┬──────────┐   │
│  │ 1,234    │ 456      │ 89       │ 12       │   │
│  │ Users    │ Students │ Teachers │ Admins   │   │
│  └──────────┴──────────┴──────────┴──────────┘   │
│                                                    │
│  📚 CONTENU                                        │
│  ┌──────────┬──────────┬──────────┬──────────┐   │
│  │ 1,245    │ 156      │ 89       │ 7        │   │
│  │ Mots     │ Leçons   │ Quiz     │ Langues  │   │
│  └──────────┴──────────┴──────────┴──────────┘   │
│                                                    │
│  🎯 ENGAGEMENT                                     │
│  ┌──────────┬──────────┬──────────────────────┐  │
│  │ 3,456    │ 2,134    │ 8,901              │  │
│  │ Leçons   │ Quiz     │ Mots appris        │  │
│  │ Complétés│ Tentés   │                    │  │
│  └──────────┴──────────┴──────────────────────┘  │
│                                                    │
│  📈 CROISSANCE (Ce mois)                          │
│  +45 nouveaux utilisateurs                        │
│  +123 leçons complétées                           │
│                                                    │
│  [Gérer Utilisateurs] [Modérer Contenu]          │
└────────────────────────────────────────────────────┘
```

### 🔐 Création du Premier Admin

#### Méthode 1 : Via Code (Temporaire)

```dart
import 'package:maa_yegue/core/database/unified_database_service.dart';

final db = UnifiedDatabaseService.instance;

await db.upsertUser({
  'user_id': 'admin-principal',
  'firebase_uid': 'admin-principal',
  'email': 'admin@maayegue.com',
  'display_name': 'Administrateur Principal',
  'role': 'admin',
  'subscription_status': 'lifetime',
  'is_default_admin': 1,
  'created_at': DateTime.now().millisecondsSinceEpoch,
  'updated_at': DateTime.now().millisecondsSinceEpoch,
});
```

#### Méthode 2 : Via Firebase Auth + SQLite

1. S'inscrire normalement dans l'app
2. Ouvrir la base de données SQLite
3. Exécuter :
   ```sql
   UPDATE users 
   SET role = 'admin', 
       is_default_admin = 1 
   WHERE email = 'votre@email.com';
   ```

---

## 📊 COMPARAISON DES RÔLES

| Fonctionnalité | Invité | Apprenant | Enseignant | Admin |
|----------------|--------|-----------|------------|-------|
| **DICTIONNAIRE** |
| Consulter mots | ✅ Tous | ✅ Tous | ✅ Tous | ✅ Tous |
| Recherche | ✅ Illimité | ✅ Illimité | ✅ Illimité | ✅ Illimité |
| Ajouter mots | ❌ | ❌ | ✅ Oui | ✅ Oui |
| **LEÇONS** |
| Consulter | ⚠️ 5/jour | ✅ Illimité | ✅ Illimité | ✅ Illimité |
| Créer | ❌ | ❌ | ✅ Oui | ✅ Oui |
| Modifier | ❌ | ❌ | ✅ Siennes | ✅ Toutes |
| **QUIZ** |
| Tenter | ⚠️ 5/jour | ✅ Illimité | ✅ Illimité | ✅ Illimité |
| Créer | ❌ | ❌ | ✅ Oui | ✅ Oui |
| **PROGRÈS** |
| Sauvegarde | ❌ | ✅ Oui | ✅ Oui | ✅ Oui |
| Statistiques | ❌ | ✅ Oui | ✅ Oui | ✅ Oui |
| Favoris | ❌ | ✅ Oui | ✅ Oui | ✅ Oui |
| **GESTION** |
| Voir utilisateurs | ❌ | ❌ | ❌ | ✅ Oui |
| Modifier rôles | ❌ | ❌ | ❌ | ✅ Oui |
| Stats plateforme | ❌ | ❌ | ⚠️ Siennes | ✅ Toutes |
| Modérer contenu | ❌ | ❌ | ❌ | ✅ Oui |

---

## 🔄 Changement de Rôle

### Promotion : Student → Teacher

**Scénario** : Un étudiant actif demande à devenir enseignant

**Processus** :
```
1. Étudiant soumet demande
2. Admin examine profil
3. Admin approuve
4. Exécution SQL:
   UPDATE users SET role = 'teacher' WHERE user_id = '...';
5. Log action admin
6. Notification à l'utilisateur
7. Interface utilisateur mise à jour
```

**Code** :
```dart
await AdminService.updateUserRole(
  userId: 'student-123',
  newRole: 'teacher',
);
```

### Élévation : Teacher → Admin

**Scénario** : Enseignant de confiance devient admin

**Processus similaire avec validation stricte**

---

## 🎓 Recommandations par Rôle

### Pour Invités
- **Objectif** : Découvrir la plateforme
- **Durée idéale** : 1-3 jours
- **Conversion** : S'inscrire après avoir aimé le contenu

### Pour Apprenants
- **Objectif** : Apprendre efficacement
- **Engagement** : 15-30 min/jour
- **Progression** : 1 niveau/mois

### Pour Enseignants
- **Objectif** : Enrichir la plateforme
- **Contribution** : 2-5 contenus/semaine
- **Qualité** : Contenu validé et apprécié

### Pour Admins
- **Objectif** : Maintenir la qualité
- **Activité** : Modération quotidienne
- **Focus** : Expérience utilisateur optimale

---

## ✅ Résumé

Ma'a yegue supporte **4 types d'utilisateurs** parfaitement adaptés à leurs besoins :

👤 **Invité** : Découverte libre avec limites encourageant l'inscription  
🎓 **Apprenant** : Apprentissage complet avec suivi personnalisé  
👨‍🏫 **Enseignant** : Création de contenu pour enrichir la plateforme  
👨‍💼 **Admin** : Gestion et maintenance de la qualité  

Chaque rôle a ses permissions, ses interfaces et ses fonctionnalités optimisées.

---

**Document créé** : 7 Octobre 2025  
**Dernière mise à jour** : 7 Octobre 2025  
**Fichiers liés** :
- `03_MODULES_FONCTIONNALITES.md`
- `04_BASE_DE_DONNEES_SQLITE.md`
- `05_SERVICES_FIREBASE.md`
