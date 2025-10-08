# 📦 MODULES ET FONCTIONNALITÉS - MA'A YEGUE

## 📋 Vue d'Ensemble des Modules

Ma'a yegue est organisée en **modules fonctionnels** suivant l'architecture Clean Architecture.

---

## 🗂️ STRUCTURE DES MODULES

Chaque module suit cette structure :

```
features/
└── [nom_module]/
    ├── data/
    │   ├── datasources/      # Accès données (SQLite/Firebase)
    │   ├── models/           # Modèles de données
    │   ├── repositories/     # Implémentation repositories
    │   └── services/         # Logique métier
    ├── domain/
    │   ├── entities/         # Entités métier
    │   ├── repositories/     # Interfaces repositories
    │   └── usecases/         # Cas d'utilisation
    └── presentation/
        ├── viewmodels/       # Logique présentation
        ├── views/            # Écrans
        └── widgets/          # Composants UI
```

---

## 1. 📚 MODULE DICTIONNAIRE (Dictionary)

### 🎯 Objectif
Fournir accès au dictionnaire complet des 7 langues camerounaises.

### 📊 Données
- **1000+ traductions** stockées dans SQLite
- **7 langues** : Ewondo, Duala, Fe'efe'e, Fulfulde, Bassa, Bamum, Yemba
- **24 catégories** : Greetings, Numbers, Family, Food, etc.

### ✨ Fonctionnalités

#### 1.1 Recherche de Mots
**Fichier** : `lib/features/dictionary/presentation/views/dictionary_search_view.dart`

**Capacités** :
- ✅ Recherche en texte complet (français ou langue locale)
- ✅ Filtrage par langue
- ✅ Filtrage par catégorie
- ✅ Filtrage par difficulté
- ✅ Résultats instantanés (< 30ms)
- ✅ Suggestions auto-complètes

**Interface** :
```
┌─────────────────────────────────────┐
│  🔍 [Rechercher un mot...        ]  │
│                                     │
│  Langue: [Toutes ▼] Cat: [Toutes ▼]│
│                                     │
│  📝 Résultats (45 trouvés):        │
│  ┌───────────────────────────────┐ │
│  │ Bonjour → Mbolo (Ewondo)      │ │
│  │ 🔊 mm-BOH-loh                 │ │
│  │ Catégorie: Greetings          │ │
│  │ [⭐ Favori] [🔊 Écouter]     │ │
│  └───────────────────────────────┘ │
│  ...plus de résultats...           │
└─────────────────────────────────────┘
```

#### 1.2 Navigation par Catégories
**Fichier** : `lib/features/dictionary/presentation/views/category_view.dart`

**Catégories disponibles** :
```
┌────────────────────────────────────────┐
│  📂 CATÉGORIES DU DICTIONNAIRE        │
├────────────────────────────────────────┤
│  👋 Salutations (Greetings) - 45 mots │
│  🔢 Nombres (Numbers) - 30 mots       │
│  👨‍👩‍👧 Famille (Family) - 38 mots        │
│  🍲 Nourriture (Food) - 67 mots       │
│  🧍 Corps (Body) - 42 mots             │
│  ⏰ Temps (Time) - 35 mots            │
│  🎨 Couleurs (Colors) - 20 mots       │
│  🦁 Animaux (Animals) - 55 mots       │
│  🌳 Nature - 48 mots                   │
│  ⚡ Verbes (Verbs) - 89 mots          │
│  ...et 14 autres catégories            │
└────────────────────────────────────────┘
```

#### 1.3 Mot du Jour
**Fichier** : Intégré dans dashboard

**Fonctionnalité** :
- Un mot aléatoire présenté chaque jour
- Rotation basée sur date système
- Avec prononciation, exemple, notes culturelles

#### 1.4 Favoris
**Fichier** : `lib/features/dictionary/presentation/views/favorites_view.dart`

**Pour utilisateurs authentifiés** :
- ⭐ Marquer mots favoris
- 📂 Collection personnelle
- 🔄 Synchronisation entre sessions
- 📊 Révision facilitée

### 🗄️ Stockage SQLite

**Table principale** : `cameroon.translations`

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

**Indexes** :
```sql
CREATE INDEX idx_translations_language ON translations(language_id);
CREATE INDEX idx_translations_category ON translations(category_id);
CREATE INDEX idx_translations_difficulty ON translations(difficulty_level);
CREATE INDEX idx_translations_french ON translations(french_text);
```

### 🔧 Services Techniques

**Fichier service** : `lib/features/guest/data/services/guest_dictionary_service.dart`

**Méthodes** :
```dart
// Langues disponibles
getAvailableLanguages() → List<Map>

// Catégories
getCategories() → List<Map>

// Recherche
searchWords(query, languageId, limit) → List<Map>

// Mots par catégorie
getWordsByCategory(categoryId, languageId) → List<Map>

// Mot du jour
getWordOfTheDay(languageId) → Map?

// Stats dictionnaire
getDictionaryStats() → Map<String, int>
```

---

## 2. 📖 MODULE LEÇONS (Lessons)

### 🎯 Objectif
Fournir des leçons structurées pour l'apprentissage progressif des langues.

### 📊 Données
- **50+ leçons** officielles par langue
- **3 niveaux** : Débutant, Intermédiaire, Avancé
- **Contenu multimédia** : Texte, audio, vidéo
- **Leçons utilisateurs** : Créées par enseignants

### ✨ Fonctionnalités

#### 2.1 Navigation des Leçons
**Fichier** : `lib/features/lessons/presentation/views/lessons_list_view.dart`

**Organisation** :
```
┌────────────────────────────────────────┐
│  📖 LEÇONS - EWONDO                   │
├────────────────────────────────────────┤
│  🟢 DÉBUTANT                          │
│  ├─ Leçon 1: Salutations ✅           │
│  ├─ Leçon 2: Présentation ✅          │
│  ├─ Leçon 3: Famille 🔄 En cours      │
│  ├─ Leçon 4: Nombres 🔒               │
│  └─ Leçon 5: Couleurs 🔒              │
│                                        │
│  🟡 INTERMÉDIAIRE                     │
│  ├─ Leçon 6: Conversations 🔒         │
│  ├─ Leçon 7: Au marché 🔒             │
│  └─ ...                                │
│                                        │
│  🔴 AVANCÉ                            │
│  ├─ Leçon 12: Proverbes 🔒            │
│  └─ ...                                │
│                                        │
│  Légende: ✅=Complété 🔄=En cours     │
│           🔒=Verrouillé               │
└────────────────────────────────────────┘
```

#### 2.2 Contenu de Leçon
**Fichier** : `lib/features/lessons/presentation/views/lesson_detail_view.dart`

**Structure d'une leçon** :
1. **Introduction** : Objectifs et contexte
2. **Vocabulaire** : Mots clés avec audio
3. **Grammaire** : Règles et structures (si applicable)
4. **Exemples** : Phrases et dialogues
5. **Exercices** : Pratique interactive
6. **Récapitulatif** : Points clés
7. **Quiz** : Évaluation finale

**Éléments interactifs** :
- 🔊 Boutons audio pour prononciation
- 📹 Vidéos explicatives (optionnel)
- ✍️ Exercices de répétition
- 🎯 Mini-quiz intégrés

#### 2.3 Suivi de Progrès
**Fichier** : `lib/features/lessons/data/services/progress_tracking_service.dart`

**Métriques trackées** :
- ⏱️ Temps passé sur chaque leçon
- 📊 Pourcentage de complétion
- 🎯 Score obtenu
- 🔄 Nombre de tentatives
- ✅ Date de complétion

**Statuts possibles** :
- `started` : Leçon commencée (< 25% complété)
- `in_progress` : En cours (25-99% complété)
- `completed` : Terminée (100% + score > 70%)

### 🗄️ Stockage SQLite

**Table principale** : `cameroon.lessons`

```sql
CREATE TABLE lessons (
  lesson_id INTEGER PRIMARY KEY AUTOINCREMENT,
  language_id VARCHAR(10) NOT NULL,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  level TEXT CHECK(level IN ('beginner', 'intermediate', 'advanced')),
  order_index INTEGER NOT NULL,
  audio_url TEXT,
  video_url TEXT,
  created_date TIMESTAMP,
  FOREIGN KEY (language_id) REFERENCES languages(language_id)
);
```

**Table progrès** : `user_progress`

```sql
CREATE TABLE user_progress (
  progress_id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT NOT NULL,
  content_type TEXT CHECK(content_type IN ('lesson', 'quiz', 'translation', 'reading')),
  content_id INTEGER NOT NULL,
  language_id TEXT,
  status TEXT CHECK(status IN ('started', 'in_progress', 'completed')),
  score REAL,
  time_spent INTEGER DEFAULT 0,
  attempts INTEGER DEFAULT 0,
  completed_at INTEGER,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(user_id)
);
```

### 🔧 Services Techniques

```dart
// Obtenir leçons
getLessonsByLanguage(languageId, level, limit) → List

// Obtenir leçon spécifique
getLessonById(lessonId) → Map?

// Démarrer leçon
startLesson(userId, languageCode, lessonId)

// Mettre à jour progrès
updateLessonProgress(userId, lessonId, percentage, timeSpent)

// Compléter leçon
completeLesson(userId, lessonId, finalScore)
```

---

## 3. 🎯 MODULE QUIZ (Quiz)

### 🎯 Objectif
Évaluer et renforcer les connaissances linguistiques.

### 📊 Données
- **20+ quiz** officiels par langue
- **Types de questions** : Choix multiple, Vrai/Faux, Remplir les blancs
- **Niveaux** : Débutant, Intermédiaire, Avancé
- **Quiz personnalisés** : Créés par enseignants

### ✨ Fonctionnalités

#### 3.1 Types de Quiz

**1. Quiz de Leçon** (Associé à une leçon)
- Évalue compréhension de la leçon
- Score minimum requis pour passer (70%)
- Débloquer leçon suivante

**2. Quiz de Révision** (Général)
- Couvre plusieurs leçons
- Renforce mémorisation
- Peut être refait illimité

**3. Quiz de Niveau** (Évaluation)
- Détermine niveau de l'utilisateur
- Quiz plus complexe
- Certificat si réussi

#### 3.2 Types de Questions

**Choix Multiple** :
```
Question: Comment dit-on "Bonjour" en Ewondo?

[A] Mwa boma
[B] Mbolo          ← Réponse correcte
[C] Kweni
[D] Jam waali

[Valider]
```

**Vrai ou Faux** :
```
Affirmation: "Mbolo" est utilisé le matin uniquement.

( ) Vrai
(•) Faux         ← Réponse correcte

Explication: "Mbolo" peut être utilisé toute la journée.
```

**Remplir les Blancs** :
```
Phrase: Je m'appelle Marie se dit "_____ Marie" en Ewondo.

[Ma dzəŋ] ← Réponse

[Vérifier]
```

**Association (Matching)** :
```
Associez les traductions:

1. Père      ●─────○  A. Nga
2. Mère      ●─────○  B. Nkuu
3. Frère     ●─────○  C. Tara
4. Sœur      ●─────○  D. Mbok

Réponses: 1-C, 2-A, 3-B, 4-D
```

#### 3.3 Système de Points

**Attribution des points** :
- Question facile (débutant) : 1 point
- Question moyenne (intermédiaire) : 2 points
- Question difficile (avancé) : 3 points
- Bonus vitesse : +10% si < 30s par question
- Bonus perfect : +20% si 100% correct

**Calcul score final** :
```
Score = (Points obtenus ÷ Points total) × 100
XP gagné = Score × Multiplicateur niveau
```

#### 3.4 Résultats et Feedback

**Écran de résultats** :
```
┌───────────────────────────────────────┐
│  🎉 QUIZ TERMINÉ!                    │
├───────────────────────────────────────┤
│                                       │
│        ⭐⭐⭐⭐⭐                      │
│                                       │
│  Score: 85%                           │
│  +850 XP                              │
│                                       │
│  ✅ Bonnes réponses: 17/20           │
│  ❌ Erreurs: 3                        │
│  ⏱️ Temps: 8m 32s                    │
│                                       │
│  📊 DÉTAILS PAR QUESTION:             │
│  Q1: ✅ Correct (+10 pts)            │
│  Q2: ✅ Correct (+10 pts)            │
│  Q3: ❌ Incorrect (Réponse: A, ...)  │
│  ...                                  │
│                                       │
│  [Revoir Questions] [Continuer]      │
└───────────────────────────────────────┘
```

### 🗄️ Stockage SQLite

**Tables** :
```sql
-- Quiz
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
  updated_at INTEGER
);

-- Questions
CREATE TABLE quiz_questions (
  question_id INTEGER PRIMARY KEY AUTOINCREMENT,
  quiz_id INTEGER NOT NULL,
  question_text TEXT NOT NULL,
  question_type TEXT,
  correct_answer TEXT NOT NULL,
  options TEXT,           -- JSON: ["A", "B", "C", "D"]
  points INTEGER DEFAULT 1,
  explanation TEXT,
  order_index INTEGER DEFAULT 0
);
```

### 🔧 Services

**Fichier** : `lib/features/quiz/data/services/quiz_service.dart`

```dart
// Obtenir quiz
getQuizzesByLanguage(languageId, difficulty) → List

// Obtenir quiz spécifique
getQuizById(quizId) → Map?

// Obtenir questions
getQuizQuestions(quizId) → List

// Soumettre réponses
submitQuizAnswers(userId, quizId, answers) → Map

// Calculer score
calculateQuizScore(answers, correctAnswers) → double
```

---

## 4. 🔐 MODULE AUTHENTIFICATION (Authentication)

### 🎯 Objectif
Gérer l'authentification hybride (Firebase + SQLite).

### ✨ Fonctionnalités

#### 4.1 Inscription (Sign Up)

**Méthodes supportées** :
1. **Email/Mot de passe** ✅
2. **Google** ✅ (configuré)
3. **Facebook** ✅ (configuré)
4. **Apple** ⚠️ (iOS uniquement)

**Flux d'inscription** :
```
Utilisateur remplit formulaire
        ↓
Validation côté client
        ↓
Firebase Auth crée compte ☁️
        ↓
Récupération Firebase UID
        ↓
Création utilisateur dans SQLite 📱
        ↓
Création statistiques initiales
        ↓
Attribution rôle (student par défaut)
        ↓
Redirection vers dashboard
        ↓
Firebase Analytics enregistre signup
```

**Validation inscription** :
- Email valide (regex)
- Mot de passe fort (8+ caractères, majuscule, chiffre, spécial)
- Nom d'affichage (2-50 caractères)
- Conditions d'utilisation acceptées

#### 4.2 Connexion (Sign In)

**Flux de connexion** :
```
Utilisateur entre identifiants
        ↓
Firebase Auth vérifie ☁️
        ↓
Récupération Firebase UID
        ↓
Recherche utilisateur dans SQLite 📱
        ↓
Si existe: Mise à jour last_login
Si n'existe pas: Création automatique
        ↓
Chargement rôle et permissions
        ↓
Redirection selon rôle:
  - student → Dashboard Apprenant
  - teacher → Dashboard Enseignant
  - admin → Dashboard Admin
        ↓
Firebase Analytics enregistre login
```

#### 4.3 Réinitialisation Mot de Passe

**Flux "Mot de passe oublié"** :
```
Utilisateur clique "Mot de passe oublié"
        ↓
Écran: Entrer email
        ↓
Validation email
        ↓
Firebase Auth envoie email ☁️
        ↓
Message: "Email envoyé, vérifiez boîte de réception"
        ↓
Utilisateur clique lien dans email
        ↓
Page web Firebase: Nouveau mot de passe
        ↓
Validation et changement
        ↓
Retour app: Connexion avec nouveau mot de passe
```

**Interface** :
```
┌────────────────────────────────────┐
│  🔑 MOT DE PASSE OUBLIÉ           │
├────────────────────────────────────┤
│                                    │
│  Entrez votre email pour recevoir │
│  un lien de réinitialisation.     │
│                                    │
│  📧 Email:                         │
│  [________________________]        │
│                                    │
│  [Envoyer le Lien]                │
│                                    │
│  ← Retour à la connexion           │
└────────────────────────────────────┘
```

### 🗄️ Stockage

**Firebase Auth** :
- Identifiants (email/mot de passe)
- Tokens JWT
- Session management
- OAuth tokens (Google/Facebook)

**SQLite** :
- Profil utilisateur complet
- Rôle et permissions
- Statut d'abonnement
- Préférences
- Dates importantes (création, dernière connexion)

**Table** : `users`
```sql
CREATE TABLE users (
  user_id TEXT PRIMARY KEY,
  firebase_uid TEXT UNIQUE,
  email TEXT,
  display_name TEXT,
  role TEXT CHECK(role IN ('guest', 'student', 'teacher', 'admin')),
  subscription_status TEXT DEFAULT 'free',
  subscription_expires_at INTEGER,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  last_login INTEGER,
  is_active INTEGER DEFAULT 1,
  auth_provider TEXT DEFAULT 'email',
  fcm_token TEXT
);
```

### 🔧 Services

**Fichier** : `lib/features/authentication/data/services/hybrid_auth_service.dart`

```dart
// Inscription
signUpWithEmail(email, password, displayName, role) → Map

// Connexion
signInWithEmail(email, password) → Map

// Connexion OAuth
signInWithGoogle() → Map
signInWithFacebook() → Map

// Déconnexion
signOut() → Map

// Réinitialisation
sendPasswordResetEmail(email) → Map

// Utilisateur actuel
getCurrentUser() → Map?

// Rôle utilisateur
getUserRole(userId) → String?

// Mise à jour profil
updateUserProfile(userId, displayName, photoUrl) → Map

// Mise à jour abonnement
updateSubscriptionStatus(userId, status, expiresAt)
```

---

## 5. 💳 MODULE PAIEMENT (Payment)

### 🎯 Objectif
Gérer les abonnements et paiements de manière sécurisée.

### 📊 Données
- **Transactions** : Historique complet dans SQLite
- **Abonnements** : Actifs, expirés, annulés
- **Méthodes** : Campay, Noupai, Stripe (carte)

### ✨ Fonctionnalités

#### 5.1 Plans d'Abonnement

**Plans disponibles** :
```
┌────────────────────────────────────────┐
│  💳 PLANS D'ABONNEMENT                │
├────────────────────────────────────────┤
│                                        │
│  🆓 GRATUIT                           │
│  0 FCFA / mois                        │
│  • Dictionnaire complet               │
│  • 3 leçons par langue                │
│  • Quiz de base                       │
│                                        │
│  ⭐ MENSUEL                           │
│  2,000 FCFA / mois                    │
│  • Tout le contenu gratuit            │
│  • Leçons avancées                    │
│  • Quiz illimités                     │
│  • Certificats                        │
│                                        │
│  💎 ANNUEL                            │
│  20,000 FCFA / an                     │
│  • Économie de 2 mois gratuits        │
│  • Tout le contenu mensuel            │
│  • Support prioritaire                │
│  • Contenu exclusif                   │
│                                        │
│  🏆 À VIE                             │
│  50,000 FCFA (paiement unique)        │
│  • Accès à vie                        │
│  • Toutes futures fonctionnalités     │
│  • Badge VIP                          │
└────────────────────────────────────────┘
```

#### 5.2 Méthodes de Paiement

**1. Campay (Mobile Money Cameroun)** 🇨🇲
- Orange Money
- MTN Mobile Money
- Payment sécurisé local

**2. Noupai (Alternative locale)** 🇨🇲
- Portefeuille électronique
- Transfert instantané

**3. Stripe (Cartes internationales)** 💳
- Visa, Mastercard, American Express
- 3D Secure
- PCI-DSS compliant

#### 5.3 Processus de Paiement

```
Utilisateur choisit plan
        ↓
Sélectionne méthode de paiement
        ↓
Génération transaction_id unique
        ↓
Création payment record (SQLite, status: pending)
        ↓
Redirection vers gateway paiement
        ↓
Utilisateur complète paiement
        ↓
Webhook reçu de gateway
        ↓
Mise à jour status (SQLite: completed)
        ↓
Activation abonnement
        ↓
Notification utilisateur
        ↓
Firebase Analytics enregistre conversion
```

### 🗄️ Stockage SQLite

```sql
-- Paiements
CREATE TABLE payments (
  payment_id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  amount REAL NOT NULL,
  currency TEXT DEFAULT 'XAF',
  status TEXT CHECK(status IN ('pending', 'completed', 'failed', 'refunded')),
  payment_method TEXT,
  transaction_id TEXT,
  reference TEXT,
  subscription_id TEXT,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  completed_at INTEGER
);

-- Abonnements
CREATE TABLE subscriptions (
  subscription_id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  plan_type TEXT NOT NULL,
  status TEXT CHECK(status IN ('active', 'expired', 'cancelled', 'pending')),
  start_date INTEGER NOT NULL,
  end_date INTEGER NOT NULL,
  payment_id TEXT,
  auto_renew INTEGER DEFAULT 1,
  created_at INTEGER,
  updated_at INTEGER
);
```

### 🔧 Services

```dart
// Créer paiement
createPayment(payment) → PaymentModel

// Obtenir paiement
getPaymentById(paymentId) → PaymentModel

// Historique paiements
getUserPayments(userId) → List<PaymentModel>

// Mettre à jour statut
updatePaymentStatus(paymentId, status)

// Créer abonnement
upsertSubscription(subscription) → String

// Abonnement actif
getUserActiveSubscription(userId) → SubscriptionModel?
```

---

## 6. 📊 MODULE STATISTIQUES (Analytics)

### 🎯 Objectif
Fournir des insights détaillés sur la progression et l'engagement.

### ✨ Fonctionnalités

#### 6.1 Dashboard Statistiques Utilisateur

```
┌────────────────────────────────────────────┐
│  📊 MES STATISTIQUES                      │
├────────────────────────────────────────────┤
│  🎯 PROGRESSION GLOBALE                   │
│  ▓▓▓▓▓▓▓▓▓▓▓░░░░ 75% (Niveau 3)          │
│                                            │
│  📚 ACTIVITÉ                              │
│  • Leçons complétées: 24                  │
│  • Quiz réussis: 18                       │
│  • Mots appris: 245                       │
│  • Temps d'étude: 15h 32m                 │
│                                            │
│  🔥 SÉRIE D'APPRENTISSAGE                 │
│  ┌────────────────────────────────────┐  │
│  │  🔥 7 jours consécutifs            │  │
│  │  Record: 12 jours                  │  │
│  │  [L][M][M][J][V][S][D]            │  │
│  │  ✅✅✅✅✅✅✅            │  │
│  └────────────────────────────────────┘  │
│                                            │
│  💎 EXPÉRIENCE                            │
│  2,450 XP / 3,000 XP pour Niveau 4        │
│  ▓▓▓▓▓▓▓▓▓▓▓▓▓░░░ 82%                   │
│                                            │
│  🏆 ACHIEVEMENTS                          │
│  🥇 Premier Pas (10 XP)                   │
│  🥈 Marathon (100 XP)                     │
│  🥉 Polyglotte (200 XP)                   │
│                                            │
│  📈 [Voir Détails] [Partager]            │
└────────────────────────────────────────────┘
```

#### 6.2 Graphiques de Progression

**Graphique temps d'étude** :
```
Minutes/Jour (30 derniers jours)
80│      ●
60│    ●   ●     ●
40│  ●   ●   ● ●   ●
20│●   ●       ●     ●  ●
0 └──────────────────────────→
  1   5   10  15  20  25  30
```

**Répartition par langue** :
```
Ewondo:   ▓▓▓▓▓▓▓▓▓▓ 45%
Duala:    ▓▓▓▓▓▓ 30%
Fulfulde: ▓▓▓▓ 20%
Autres:   ▓ 5%
```

### 🗄️ Stockage

**Table** : `user_statistics`
```sql
CREATE TABLE user_statistics (
  stat_id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id TEXT NOT NULL UNIQUE,
  total_lessons_completed INTEGER DEFAULT 0,
  total_quizzes_completed INTEGER DEFAULT 0,
  total_words_learned INTEGER DEFAULT 0,
  total_readings_completed INTEGER DEFAULT 0,
  total_study_time INTEGER DEFAULT 0,
  current_streak INTEGER DEFAULT 0,
  longest_streak INTEGER DEFAULT 0,
  last_activity_date TEXT,
  level INTEGER DEFAULT 1,
  experience_points INTEGER DEFAULT 0,
  updated_at INTEGER NOT NULL
);
```

---

## 7. 🌍 MODULE LANGUES (Languages)

### 🎯 Langues Supportées

**Les 7 langues camerounaises** :

#### 1. Ewondo (EWO)
- **Région** : Centre
- **Locuteurs** : 577,000
- **Famille** : Beti-Pahuin (Bantu)
- **Difficulté** : Intermédiaire
- **Particularité** : Langue principale de Yaoundé

#### 2. Duala (DUA)
- **Région** : Littoral
- **Locuteurs** : 300,000
- **Famille** : Bantu côtier
- **Difficulté** : Intermédiaire
- **Particularité** : Langue historique du commerce côtier

#### 3. Fe'efe'e (FEF)
- **Région** : Ouest (Bafang)
- **Locuteurs** : 200,000
- **Famille** : Grassfields (Bamiléké)
- **Difficulté** : Intermédiaire
- **Particularité** : Riche tradition orale

#### 4. Fulfulde (FUL)
- **Région** : Nord, Adamaoua
- **Locuteurs** : 1,500,000
- **Famille** : Niger-Congo (Atlantic)
- **Difficulté** : Avancé
- **Particularité** : Langue des Peuls, nomades et éleveurs

#### 5. Bassa (BAS)
- **Région** : Centre-Littoral
- **Locuteurs** : 230,000
- **Famille** : A40 Bantu
- **Difficulté** : Intermédiaire
- **Particularité** : Forte tradition musicale

#### 6. Bamum (BAM)
- **Région** : Ouest (Foumban)
- **Locuteurs** : 215,000
- **Famille** : Grassfields
- **Difficulté** : Avancé
- **Particularité** : Possède son propre système d'écriture (script du Roi Njoya)

#### 7. Yemba (YMB)
- **Région** : Ouest (Dschang)
- **Locuteurs** : 300,000
- **Famille** : Grassfields (Bamiléké-Dschang)
- **Difficulté** : Intermédiaire
- **Particularité** : Langue des chefferies traditionnelles

### 🗄️ Stockage

**Table** : `languages`
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
```sql
INSERT INTO languages VALUES
('EWO', 'Ewondo', 'Beti-Pahuin (Bantu)', 'Central Region', 577000, '...', 'ewo'),
('DUA', 'Duala', 'Coastal Bantu', 'Littoral Region', 300000, '...', 'dua'),
-- ... 5 autres langues
```

---

## 8. 👥 MODULE COMMUNAUTÉ (Community)

### 🎯 Objectif
Créer une communauté d'apprentissage interactive.

### ✨ Fonctionnalités (Futures)

- 💬 Forums de discussion par langue
- 👥 Groupes d'étude
- 🎤 Salons de conversation
- 📝 Partage de ressources
- ⭐ Classements et compétitions

**Note** : Module actuellement en stub, sera implémenté Phase 3.

---

## 9. 🎨 MODULE CULTURE (Culture)

### 🎯 Objectif
Préserver et partager la culture camerounaise.

### ✨ Contenu

- 📜 Proverbes traditionnels
- 📖 Contes et légendes
- 🎵 Chansons populaires
- 🎭 Traditions et coutumes
- 🍲 Recettes traditionnelles
- 🎨 Art et artisanat

---

## 10. 🎮 MODULE GAMIFICATION

### 🎯 Objectif
Motiver l'apprentissage par le jeu.

### ✨ Éléments

- 🏆 Achievements (badges)
- 🎖️ Niveaux et XP
- 🔥 Séries quotidiennes
- 🏅 Classements
- 🎁 Récompenses

---

## ✅ RÉSUMÉ DES MODULES

| Module | Fichiers | Tables SQLite | Services Firebase | Status |
|--------|----------|---------------|-------------------|--------|
| Dictionnaire | 42 | translations, categories, languages | Analytics | ✅ |
| Leçons | 54 | lessons, user_progress | Analytics | ✅ |
| Quiz | 15 | quizzes, quiz_questions | Analytics | ✅ |
| Auth | 27 | users | Auth, Analytics | ✅ |
| Paiement | 23 | payments, subscriptions | Functions | ✅ |
| Analytics | 8 | user_statistics | Analytics | ✅ |
| Guest | 11 | daily_limits | Analytics | ✅ |
| Teacher | 10 | user_created_content | Analytics | ✅ |
| Admin | 12 | admin_logs, all tables | Analytics | ✅ |
| Community | 17 | (stub) | Firestore | ⏳ |

**Total** : 219 fichiers, 15+ tables, Architecture Hybride complète ✅

---

**Document créé** : 7 Octobre 2025  
**Fichiers liés** :
- `02_TYPES_UTILISATEURS.md`
- `04_BASE_DE_DONNEES_SQLITE.md`
- `05_SERVICES_FIREBASE.md`
