# Résumé des APIs - Ma'a yegue v2.0

## APIs Internes (Firebase)

### 1. Authentication API
- **Provider**: Firebase Authentication
- **Méthodes supportées**:
  - Email/Password
  - Google OAuth
  - Facebook OAuth
  - Téléphone SMS
- **Endpoints principaux**:
  - `signInWithEmailAndPassword`
  - `createUserWithEmailAndPassword`
  - `signInWithCredential` (Google, Facebook)
  - `verifyPhoneNumber` (SMS)
  - `signOut`
  - `sendPasswordResetEmail`

### 2. Firestore Database API
- **Collections principales**:
  - `users/` - Profils utilisateurs (12 rôles)
  - `courses/` - Cours et contenus pédagogiques
  - `lessons/` - Leçons par cours
  - `lesson_progress/` - Progression utilisateur
  - `dictionary_entries/` - Entrées du dictionnaire
  - `quiz_attempts/` - Tentatives de quiz
  - `payments/` - Transactions de paiement
  - `subscriptions/` - Abonnements utilisateurs
  - `schools/` - 🆕 Établissements scolaires
  - `classrooms/` - 🆕 Classes
  - `report_cards/` - 🆕 Bulletins scolaires
  - `parent_messages/` - 🆕 Communication parents
  - `gamification/` - Points, badges, achievements

### 3. Firebase Storage API
- **Buckets**:
  - `profile_images/` - Photos de profil
  - `lesson_media/` - Médias pédagogiques
  - `dictionary_audio/` - Prononciations audio
  - `user_uploads/` - Fichiers utilisateurs
  - `certificates/` - Certificats générés

### 4. Cloud Functions API
- **Functions déployées**:
  - `onUserCreate` - Setup initial profil
  - `onPaymentComplete` - Traitement paiements
  - `generateCertificate` - Génération certificats
  - `sendNotification` - Notifications push
  - `processGrade` - Calcul moyennes et classements

## APIs Externes

### 1. Google Gemini AI API
- **Base URL**: `https://generativelanguage.googleapis.com/v1beta/`
- **Modèle**: `gemini-pro`
- **Fonctionnalités**:
  - Chat conversationnel
  - Traduction contextuelle
  - Génération de contenu
  - Évaluation de prononciation
  - Recommandations personnalisées
  - Analyse de progression

**Endpoints utilisés**:
```
POST /models/gemini-pro:generateContent
```

### 2. CamPay Payment API
- **Base URL**: `https://api.campay.net/api`
- **Méthodes supportées**:
  - MTN Mobile Money
  - Orange Money
- **Endpoints**:
  - `POST /collect/` - Initier paiement
  - `GET /transaction/{reference}` - Vérifier statut
  - `POST /withdraw/` - Retrait (payouts enseignants)

### 3. NouPai Payment API
- **Base URL**: `https://api.noupai.cm/v1`
- **Méthodes supportées**:
  - Mobile Money (MTN, Orange, Express Union)
- **Endpoints**:
  - `POST /payments/initialize` - Initier paiement
  - `GET /payments/{id}` - Statut paiement

### 4. Stripe Payment API
- **Base URL**: `https://api.stripe.com/v1`
- **Méthodes supportées**:
  - Cartes bancaires (Visa, MasterCard, Amex)
- **Endpoints**:
  - `POST /payment_intents` - Créer intention de paiement
  - `POST /customers` - Créer client
  - `POST /subscriptions` - Gérer abonnements

## Services Locaux (SQLite)

### Tables Principales
- `dictionary_entries` - 500+ mots, 22 langues
- `user_progress` - Progression offline
- `lesson_cache` - Leçons téléchargées
- `quiz_cache` - Quiz offline
- `sync_queue` - File de synchronisation

## Analytics & Monitoring

### Firebase Analytics
- **Événements trackés**:
  - `app_open`
  - `screen_view`
  - `lesson_started`, `lesson_completed`
  - `quiz_submitted`
  - `payment_initiated`, `payment_completed`
  - `achievement_unlocked`
  - `user_signup`, `user_login`

### Firebase Crashlytics
- Crash reporting automatique
- Stack traces détaillés
- Custom logs et métadonnées
- Priorités (fatal, error, warning, info)

### Firebase Performance
- Métriques de démarrage app
- Temps de réponse réseau
- Traces personnalisées pour opérations critiques

## Webhooks

### Payment Webhooks
- **CamPay**: `POST /api/webhooks/campay`
- **NouPai**: `POST /api/webhooks/noupai`
- **Stripe**: `POST /api/webhooks/stripe`

**Validation**:
- Signatures HMAC
- Vérification IP whitelist
- Idempotence avec IDs de transaction

## Limites et Quotas

### Firebase (Plan Blaze)
- **Firestore**: 50K reads/jour gratuits, puis $0.06/100K
- **Storage**: 5GB gratuit, puis $0.026/GB
- **Functions**: 2M invocations/mois gratuites

### Gemini AI
- **Free tier**: 60 requêtes/minute
- **Paid tier**: Personnalisable

### Paiements
- **CamPay**: Frais 2% transaction
- **NouPai**: Frais 1.5% transaction
- **Stripe**: 2.9% + $0.30 par transaction

---

*Document mis à jour: 7 octobre 2025*
*Version app: 2.0.0*

