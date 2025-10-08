# ☁️ SERVICES FIREBASE - MA'A YEGUE

## 📋 Vue d'Ensemble

Firebase est utilisé **UNIQUEMENT pour les services**, **AUCUN stockage de données principales**.

---

## 🔥 SERVICES FIREBASE UTILISÉS

### 1. 🔐 Firebase Authentication

**Rôle** : Gestion de l'authentification utilisateur

#### Fonctionnalités Actives

**Méthodes d'authentification** :
- ✅ **Email/Password** - Méthode principale
- ✅ **Google Sign-In** - OAuth Google
- ✅ **Facebook Login** - OAuth Facebook
- ⚠️ **Apple Sign-In** - iOS uniquement
- ⏳ **Téléphone/SMS** - À implémenter

**Opérations supportées** :
```dart
// Inscription
await FirebaseAuth.instance.createUserWithEmailAndPassword(
  email: email,
  password: password,
);

// Connexion
await FirebaseAuth.instance.signInWithEmailAndPassword(
  email: email,
  password: password,
);

// Déconnexion
await FirebaseAuth.instance.signOut();

// Réinitialisation mot de passe
await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

// Utilisateur actuel
final user = FirebaseAuth.instance.currentUser;

// Token ID (pour API backend)
final token = await user?.getIdToken();
```

#### Configuration

**Fichier** : `firebase_options.dart` (auto-généré)

**Console Firebase** :
- Projet : `maa-yegue-prod`
- Méthodes activées : Email, Google, Facebook
- Domaines autorisés : `maayegue.com`, `localhost`

#### Flux Hybride Authentication

```
1. Firebase Auth vérifie identifiants ☁️
        ↓
2. Retourne Firebase UID
        ↓
3. Recherche/Crée utilisateur dans SQLite 📱
        ↓
4. Charge rôle et permissions depuis SQLite
        ↓
5. Session maintenue par Firebase
        ↓
6. Données utilisateur = 100% SQLite
```

**Sécurité** :
- 🔒 Mots de passe hashés (bcrypt)
- 🔒 Tokens JWT sécurisés
- 🔒 Expiration automatique des sessions
- 🔒 Rate limiting anti-brute-force

---

### 2. 📊 Firebase Analytics

**Rôle** : Analyser le comportement utilisateurs et l'engagement

#### Événements Trackés

**Authentification** :
```dart
// Inscription
await FirebaseAnalytics.instance.logSignUp(
  signUpMethod: 'email',
);

// Connexion
await FirebaseAnalytics.instance.logLogin(
  loginMethod: 'google',
);
```

**Engagement** :
```dart
// Début de leçon
await FirebaseAnalytics.instance.logEvent(
  name: 'lesson_start',
  parameters: {
    'lesson_id': '1',
    'language': 'ewondo',
    'level': 'beginner',
  },
);

// Complétion de leçon
await FirebaseAnalytics.instance.logEvent(
  name: 'lesson_complete',
  parameters: {
    'lesson_id': '1',
    'score': 85,
    'time_spent': 1800,  // 30 min
    'language': 'ewondo',
  },
);

// Quiz terminé
await FirebaseAnalytics.instance.logEvent(
  name: 'quiz_complete',
  parameters: {
    'quiz_id': '3',
    'score': 90,
    'language': 'duala',
  },
);
```

**Commerce** :
```dart
// Souscription
await FirebaseAnalytics.instance.logEvent(
  name: 'purchase',
  parameters: {
    'transaction_id': 'txn_123',
    'value': 2000,
    'currency': 'XAF',
    'items': ['monthly_subscription'],
  },
);
```

**Recherche** :
```dart
// Recherche dictionnaire
await FirebaseAnalytics.instance.logSearch(
  searchTerm: 'bonjour',
  parameters: {
    'language_filter': 'ewondo',
    'results_count': 5,
  },
);
```

#### Propriétés Utilisateur

```dart
// Définir propriétés utilisateur
await FirebaseAnalytics.instance.setUserProperty(
  name: 'user_role',
  value: 'student',
);

await FirebaseAnalytics.instance.setUserProperty(
  name: 'subscription_status',
  value: 'premium',
);

await FirebaseAnalytics.instance.setUserProperty(
  name: 'preferred_language',
  value: 'ewondo',
);
```

#### Dashboard Analytics (Console Firebase)

**Métriques disponibles** :
- 📈 Utilisateurs actifs (DAU/MAU/WAU)
- 📊 Rétention utilisateurs (jour 1, 7, 30)
- 🎯 Conversion funnel (guest → student → premium)
- ⏱️ Temps de session moyen
- 📱 Appareils utilisés (Android/iOS)
- 🌍 Localisation géographique
- 🔥 Événements populaires

**Audiences personnalisées** :
- Étudiants actifs (derniers 7 jours)
- Utilisateurs premium
- Utilisateurs Ewondo
- Abandons panier (paiement non complété)

#### Optimisation

**Fichier** : `lib/core/services/firebase_request_optimizer.dart`

**Batching d'événements** :
```dart
// Au lieu d'envoyer chaque événement immédiatement
FirebaseRequestOptimizer.queueAnalyticsEvent(
  name: 'word_viewed',
  parameters: {...},
);

// Flush toutes les 30 secondes ou après 50 événements
// Réduit les requêtes réseau de 90%
```

---

### 3. 🔔 Firebase Cloud Messaging (FCM)

**Rôle** : Notifications push

#### Types de Notifications

**1. Notifications Générales** :
- 📢 Nouvelles leçons disponibles
- 🎉 Nouveaux quiz ajoutés
- 📰 Actualités plateforme

**2. Notifications Personnalisées** :
- 🔥 Rappel série quotidienne ("Ne casse pas ta série de 5 jours!")
- 🎯 Encouragement ("Tu es à 90% du Niveau 3!")
- 🏆 Achievement débloqué
- 💎 Nouveaux contenus dans ta langue préférée

**3. Notifications Administratives** :
- ✉️ Changement de rôle
- 📝 Contenu approuvé
- 💳 Paiement confirmé
- ⚠️ Abonnement expirant

#### Implémentation

**Configuration** :
```dart
// Demander permission
await FirebaseMessaging.instance.requestPermission();

// Obtenir token FCM
final fcmToken = await FirebaseMessaging.instance.getToken();

// Sauvegarder dans SQLite
await db.upsertUser({
  'user_id': userId,
  'fcm_token': fcmToken,
  'fcm_token_updated_at': DateTime.now().toIso8601String(),
});
```

**Écouter notifications** :
```dart
FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  // Notification reçue en foreground
  showNotification(
    title: message.notification?.title,
    body: message.notification?.body,
  );
});

FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
  // Utilisateur a cliqué sur notification
  navigateToContent(message.data);
});
```

**Topics (sujets)** :
```dart
// S'abonner à un sujet
await FirebaseMessaging.instance.subscribeToTopic('ewondo_learners');
await FirebaseMessaging.instance.subscribeToTopic('premium_users');

// Se désabonner
await FirebaseMessaging.instance.unsubscribeFromTopic('ewondo_learners');
```

**Envoi depuis backend** :
```javascript
// Cloud Function pour envoyer notification
admin.messaging().sendToTopic('ewondo_learners', {
  notification: {
    title: 'Nouvelle leçon!',
    body: 'Une nouvelle leçon Ewondo est disponible',
  },
  data: {
    lessonId: '45',
    language: 'ewondo',
  },
});
```

---

### 4. 💥 Firebase Crashlytics

**Rôle** : Rapports de crash et erreurs

#### Configuration

```dart
void main() async {
  // Capturer erreurs Flutter
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };

  // Capturer erreurs natives
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(MyApp());
}
```

#### Logging Personnalisé

```dart
// Log événement personnalisé
await FirebaseCrashlytics.instance.log('User opened dictionary');

// Définir identité utilisateur
await FirebaseCrashlytics.instance.setUserIdentifier(userId);

// Ajouter clés personnalisées
await FirebaseCrashlytics.instance.setCustomKey('user_role', 'student');
await FirebaseCrashlytics.instance.setCustomKey('subscription', 'premium');

// Enregistrer erreur non-fatale
try {
  // Code risqué
} catch (error, stack) {
  await FirebaseCrashlytics.instance.recordError(
    error,
    stack,
    reason: 'Dictionary loading failed',
    fatal: false,
  );
}
```

#### Console Crashlytics

**Informations disponibles** :
- 📊 Taux de crash (crash-free users %)
- 🐛 Erreurs groupées par type
- 📱 Appareils affectés
- 🔢 Nombre d'occurrences
- 📍 Stack traces complets
- 👤 Utilisateurs affectés

**Alertes** :
- Email si nouveau crash
- Notification si taux dépasse seuil
- Intégration Slack/Discord possible

---

### 5. ⚡ Firebase Performance Monitoring

**Rôle** : Mesurer performances de l'app

#### Traces Automatiques

Firebase mesure automatiquement :
- 🚀 Temps de démarrage app
- 📱 Temps de rendu écrans
- 🌐 Requêtes réseau (si HTTP)
- 🎨 Rendering frames per second

#### Traces Personnalisées

```dart
// Mesurer performance d'une opération
final trace = FirebasePerformance.instance.newTrace('database_query');

await trace.start();

// Opération à mesurer
final result = await db.searchTranslations(query);

await trace.stop();

// Ajouter métriques
trace.putMetric('results_count', result.length);
trace.putAttribute('query_type', 'full_text');
```

**Traces importantes pour Ma'a yegue** :
```dart
// Chargement dictionnaire
final dictTrace = FirebasePerformance.instance.newTrace('load_dictionary');

// Complétion leçon
final lessonTrace = FirebasePerformance.instance.newTrace('complete_lesson');

// Recherche
final searchTrace = FirebasePerformance.instance.newTrace('search_dictionary');
```

#### Console Performance

**Métriques affichées** :
- ⏱️ Temps de démarrage (cold start / warm start)
- 🎨 Frames per second (FPS)
- 🔄 Temps de réponse traces custom
- 📊 Percentiles (p50, p90, p99)
- 📱 Par version d'app
- 🌍 Par pays/région

---

### 6. 🔧 Firebase Cloud Functions

**Rôle** : Backend serverless pour webhooks et automatisations

#### Fonctions Déployées

**1. Webhook Paiement Campay**
```javascript
exports.campaypaymentWebhook = functions.https.onRequest(async (req, res) => {
  // Vérifie signature
  // Met à jour statut paiement dans SQLite (via API)
  // Active abonnement
  // Envoie notification
});
```

**2. Webhook Paiement Stripe**
```javascript
exports.stripeWebhook = functions.https.onRequest(async (req, res) => {
  const event = stripe.webhooks.constructEvent(req.rawBody, signature);
  
  if (event.type === 'payment_intent.succeeded') {
    // Mettre à jour paiement
    // Activer abonnement
  }
});
```

**3. Expiration Abonnements (Cron)**
```javascript
exports.checkExpiredSubscriptions = functions.pubsub
  .schedule('every 24 hours')
  .onRun(async (context) => {
    // Vérifier abonnements expirés
    // Mettre à jour statuts
    // Envoyer notifications
  });
```

**4. Génération Certificats**
```javascript
exports.generateCertificate = functions.https.onCall(async (data, context) => {
  // Vérifier complétion cours
  // Générer PDF certificat
  // Upload vers Storage
  // Retourner URL
});
```

#### Sécurité Functions

```javascript
// Vérifier authentification
if (!context.auth) {
  throw new functions.https.HttpsError(
    'unauthenticated',
    'Utilisateur non authentifié'
  );
}

// Vérifier rôle
const userId = context.auth.uid;
const userRole = await getUserRole(userId);

if (userRole !== 'admin') {
  throw new functions.https.HttpsError(
    'permission-denied',
    'Opération réservée aux administrateurs'
  );
}
```

---

### 7. 📱 Firebase Dynamic Links

**Rôle** : Liens profonds pour partage

#### Cas d'Usage

**Partage de leçon** :
```
https://maayegue.page.link/lesson?id=45&lang=ewondo
        ↓
Si app installée: Ouvre leçon directement
Si non installée: Redirige vers Play Store → Puis ouvre leçon
```

**Invitation parrainage** :
```
https://maayegue.page.link/ref?code=USER123
        ↓
Nouveau utilisateur s'inscrit
        ↓
Parrain reçoit bonus (ex: 1 mois gratuit)
```

**Réinitialisation mot de passe** :
```
Firebase Auth email contient Dynamic Link
        ↓
Click ouvre page web OU app directement
```

---

### 8. 🎨 Firebase Remote Config

**Rôle** : Configuration dynamique sans mise à jour app

#### Paramètres Configurables

```dart
// Récupérer config depuis Firebase
final remoteConfig = FirebaseRemoteConfig.instance;
await remoteConfig.fetchAndActivate();

// Lire valeurs
final maxGuestLessons = remoteConfig.getInt('max_guest_lessons_per_day');
final showPromotion = remoteConfig.getBool('show_summer_promotion');
final featureFlags = remoteConfig.getString('enabled_features');
```

**Exemples de configs** :
```json
{
  "max_guest_lessons_per_day": 5,
  "show_summer_promotion": true,
  "premium_price_xaf": 2000,
  "referral_bonus_days": 7,
  "maintenance_mode": false,
  "min_app_version": "1.0.0",
  "force_update": false,
  "enabled_features": "dictionary,lessons,quiz,community"
}
```

**Avantages** :
- ✅ Changer limites sans update app
- ✅ A/B testing facile
- ✅ Feature flags dynamiques
- ✅ Mode maintenance instantané

---

## 🔧 SERVICE FIREBASE UNIFIÉ

**Fichier** : `lib/core/services/firebase_service.dart`

### Méthodes Principales

```dart
class FirebaseService {
  // Instance Firebase Auth
  FirebaseAuth get auth => FirebaseAuth.instance;
  
  // Instance Analytics
  FirebaseAnalytics get analytics => FirebaseAnalytics.instance;
  
  // Instance Crashlytics
  FirebaseCrashlytics get crashlytics => FirebaseCrashlytics.instance;
  
  // Instance Messaging
  FirebaseMessaging get messaging => FirebaseMessaging.instance;
  
  // Initialisation globale
  Future<void> initialize() async {
    await _initializeMessaging();
    await _initializeAnalytics();
    await _initializeCrashlytics();
    await _initializeRemoteConfig();
  }
  
  // Log événement personnalisé
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    await analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }
  
  // Définir propriété utilisateur
  Future<void> setUserProperties({
    required String userId,
    String? userRole,
    String? subscriptionStatus,
  }) async {
    await analytics.setUserId(id: userId);
    if (userRole != null) {
      await analytics.setUserProperty(name: 'role', value: userRole);
    }
    if (subscriptionStatus != null) {
      await analytics.setUserProperty(name: 'subscription', value: subscriptionStatus);
    }
  }
  
  // Utilisateur actuel
  User? get currentUser => auth.currentUser;
  
  // Vérifie si authentifié
  bool get isAuthenticated => currentUser != null;
  
  // Déconnexion
  Future<void> signOut() async {
    await auth.signOut();
  }
}
```

---

## 📊 OPTIMISATION DES REQUÊTES FIREBASE

### Fichier : `firebase_request_optimizer.dart`

### 1. Batching Analytics

**Problème** : Envoyer 100 événements = 100 requêtes réseau

**Solution** : Batching

```dart
// Queuer événement
FirebaseRequestOptimizer.queueAnalyticsEvent(
  name: 'word_viewed',
  parameters: {'word_id': '123'},
);

// Flush automatique toutes les 30s ou après 50 événements
// 100 événements = 2-3 requêtes au lieu de 100
```

**Économie** : 95% réduction requêtes

### 2. Throttling

**Problème** : Utilisateur spam bouton = spam Firebase

**Solution** : Throttling

```dart
// Limite à 1 requête par 500ms par type
final result = await FirebaseRequestOptimizer.throttledRequest(
  requestType: 'search_analytics',
  request: () => analytics.logSearch(searchTerm: query),
);
```

### 3. Connection Pooling

**Limite connexions simultanées** : Maximum 5

```dart
if (FirebaseRequestOptimizer.canMakeConnection()) {
  FirebaseRequestOptimizer.acquireConnection();
  
  try {
    await firebaseOperation();
  } finally {
    FirebaseRequestOptimizer.releaseConnection();
  }
}
```

---

## 🔐 RÈGLES DE SÉCURITÉ FIREBASE

### Firestore Rules (Si Utilisé)

**Fichier** : `firestore.rules`

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Fonction helper: vérifier auth
    function isAuthenticated() {
      return request.auth != null;
    }
    
    // Fonction helper: vérifier rôle
    function hasRole(role) {
      return isAuthenticated() && 
             get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == role;
    }
    
    // Métadonnées publiques (lecture seule)
    match /metadata/{document} {
      allow read: if true;
      allow write: if hasRole('admin');
    }
    
    // Données utilisateurs (privées)
    match /users/{userId} {
      allow read: if isAuthenticated() && 
                     (request.auth.uid == userId || hasRole('admin'));
      allow write: if isAuthenticated() && 
                      request.auth.uid == userId;
    }
    
    // Notifications (serveur seulement)
    match /notifications/{notificationId} {
      allow read: if isAuthenticated();
      allow write: if false;  // Serveur uniquement
    }
  }
}
```

### Storage Rules

**Fichier** : `storage.rules`

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    
    // Photos de profil
    match /profile_pictures/{userId}/{fileName} {
      allow read: if true;  // Public
      allow write: if request.auth != null && 
                      request.auth.uid == userId &&
                      request.resource.size < 5 * 1024 * 1024 &&  // 5MB max
                      request.resource.contentType.matches('image/.*');
    }
    
    // Audio leçons (enseignants)
    match /lesson_audio/{lessonId}/{fileName} {
      allow read: if true;
      allow write: if request.auth != null;  // Enseignants + Admin
    }
    
    // Certificats (serveur uniquement)
    match /certificates/{userId}/{fileName} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if false;  // Cloud Function uniquement
    }
  }
}
```

---

## 📈 MONITORING ET ALERTES

### Crashlytics Alerts

**Configuration console** :
```
Seuil d'alerte: 1% crash rate
Notification: Email + Slack
Destinataires: dev@maayegue.com

Alertes personnalisées:
- Nouveau crash affectant > 5 utilisateurs
- Augmentation soudaine crashes (> 50%)
- Crash sur version spécifique
```

### Performance Alerts

```
Seuil d'alerte: 95% des sessions > 3s startup
Notification: Email
Actions:
- Identifier cause (trace)
- Optimiser code
- Release hotfix si critique
```

### Analytics Anomalies

```
Détection automatique:
- Chute soudaine utilisateurs actifs (> 20%)
- Augmentation abandons (> 30%)
- Nouvelles erreurs fréquentes
```

---

## 💰 COÛTS FIREBASE (Estimés)

### Plan Gratuit (Spark)

**Inclus** :
- ✅ 50K MAU (Monthly Active Users)
- ✅ 20K writes Firestore/jour (non utilisé)
- ✅ 50K reads Firestore/jour (non utilisé)
- ✅ 1 GB storage (non utilisé)
- ✅ Analytics illimité
- ✅ Crashlytics illimité

**Usage Ma'a yegue (Hybride)** :
- Auth : < 1000 MAU = ✅ GRATUIT
- Analytics : Illimité = ✅ GRATUIT
- Crashlytics : Illimité = ✅ GRATUIT
- Firestore : Minimal (métadonnées) = ✅ GRATUIT
- **Total** : **0 €/mois** 🎉

### Plan Blaze (Pay-as-you-go)

**Seulement si dépassement limites** :

| Service | Prix | Usage Actuel | Coût Estimé |
|---------|------|--------------|-------------|
| Auth | Gratuit | 500 MAU | 0 € |
| Firestore (reads) | 0.036€/100K | 10K/jour | 0.10 €/mois |
| Firestore (writes) | 0.108€/100K | 5K/jour | 0.15 €/mois |
| Storage | 0.026€/GB | 1 GB | 0.03 €/mois |
| Functions | 0.40€/million | 10K/jour | 0.12 €/mois |
| **TOTAL** | | | **~0.40 €/mois** |

**Comparaison** :
- **Avant (100% Firebase)** : ~50-100 €/mois pour 1000 utilisateurs
- **Maintenant (Hybride)** : < 1 €/mois pour 1000 utilisateurs
- **Économie** : **99% de réduction** 🎉

---

## 🔄 SYNCHRONISATION (Optionnelle)

### Concept

Pour fonctionnalités avancées futures (synchronisation multi-appareils) :

```
SQLite (Appareil A)
        ↓
    Détecte changement
        ↓
    Upload métadonnées vers Firestore
        ↓
Firestore (Cloud)
        ↓
    Notification vers Appareil B
        ↓
SQLite (Appareil B) télécharge données
```

**Important** : 
- ✅ Optionnel (pas implémenté Phase 1)
- ✅ SQLite reste source de vérité
- ✅ Firestore = simple relais
- ✅ Pas de coûts supplémentaires significatifs

---

## 🎯 BEST PRACTICES FIREBASE

### 1. Minimiser les Requêtes

❌ **Mauvais** :
```dart
// 5 requêtes séparées
await analytics.logEvent(name: 'event1');
await analytics.logEvent(name: 'event2');
await analytics.logEvent(name: 'event3');
await analytics.logEvent(name: 'event4');
await analytics.logEvent(name: 'event5');
```

✅ **Bon** :
```dart
// Batching: queue puis flush groupé
FirebaseRequestOptimizer.queueAnalyticsEvent(name: 'event1');
FirebaseRequestOptimizer.queueAnalyticsEvent(name: 'event2');
// ... automatiquement flushé en batch
```

### 2. Gérer Erreurs Réseau

```dart
try {
  await FirebaseService().logEvent(name: 'action');
} catch (e) {
  // Firebase inaccessible (offline) - ne pas crasher
  debugPrint('Firebase unavailable: $e');
  // App continue à fonctionner avec SQLite
}
```

### 3. Propriétés Utilisateur Utiles

```dart
await analytics.setUserProperty(name: 'user_role', value: 'student');
await analytics.setUserProperty(name: 'subscription', value: 'premium');
await analytics.setUserProperty(name: 'preferred_language', value: 'ewondo');
await analytics.setUserProperty(name: 'signup_date', value: '2025-10-07');
await analytics.setUserProperty(name: 'last_language_studied', value: 'duala');
```

**Permet segmentation** :
- Cibler utilisateurs Ewondo pour nouvelles leçons Ewondo
- Cibler premium users pour features avancées
- Cibler inactifs pour campagnes réengagement

---

## 🛠️ CONFIGURATION PROJET FIREBASE

### Console Firebase Setup

**1. Créer Projet** :
- Nom : `maa-yegue-prod`
- Région : `europe-west` (ou `us-central`)
- Plan : Spark (gratuit) → Blaze si nécessaire

**2. Ajouter Apps** :
- Android : Package `com.maa_yegue.app`
- iOS : Bundle ID `com.maayegue.app`

**3. Activer Services** :
- ✅ Authentication (Email, Google, Facebook)
- ✅ Cloud Messaging
- ✅ Analytics
- ✅ Crashlytics
- ✅ Performance Monitoring
- ⚠️ Firestore (minimal usage)
- ⚠️ Storage (si médias)
- ⚠️ Functions (webhooks)

**4. Télécharger Fichiers Config** :
- `google-services.json` → `android/app/`
- `GoogleService-Info.plist` → `ios/Runner/`
- `firebase_options.dart` → `lib/`

### Commandes FlutterFire CLI

```bash
# Installer FlutterFire CLI
npm install -g firebase-tools
dart pub global activate flutterfire_cli

# Configurer projet
flutterfire configure

# Générer firebase_options.dart
flutterfire configure --project=maa-yegue-prod
```

---

## 📊 DASHBOARD FIREBASE

### Analytics Dashboard

**Métriques clés à surveiller** :
- 📈 Utilisateurs actifs quotidiens (DAU)
- 📊 Rétention J1, J7, J30
- 🎯 Événements populaires (top 10)
- ⏱️ Durée session moyenne
- 🔄 Taux de retour
- 📱 Plateformes (Android vs iOS vs Web)

**Audiences utiles** :
- Étudiants actifs (7 derniers jours)
- Utilisateurs Ewondo
- Premium users
- Teachers actifs
- Abandons paiement (ciblage remarketing)

### Crashlytics Dashboard

**Vue d'ensemble** :
- 📊 Crash-free users % (objectif: > 99.5%)
- 🐛 Issues ouvertes par priorité
- 📉 Tendance crashes (graphique)
- 📱 Appareils affectés

**Par crash** :
- Stack trace complet
- Logs avant crash
- Nombre d'utilisateurs affectés
- Versions app affectées
- Fréquence d'occurrence

---

## ✅ RÉSUMÉ

**Services utilisés** : 8 (Auth, Analytics, Crashlytics, Performance, Messaging, Functions, Remote Config, Dynamic Links)  
**Coût mensuel** : < 1 € pour 1000 utilisateurs  
**Données stockées** : Métadonnées uniquement  
**Dépendance** : Légère (app fonctionne offline)  
**Optimisation** : Batching, throttling, caching  
**Monitoring** : Complet (crashes, performance, usage)  
**Sécurité** : Rules strictes, auth requise  

Firebase fournit des **services essentiels** sans stocker les **données sensibles** - parfait pour l'architecture hybride! ☁️

---

**Document créé** : 7 Octobre 2025  
**Fichiers liés** :
- `04_BASE_DE_DONNEES_SQLITE.md`
- `06_GUIDE_DEVELOPPEUR.md`
- `07_GUIDE_OPERATIONNEL.md`
