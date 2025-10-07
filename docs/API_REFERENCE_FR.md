# 📡 Référence API - Ma'a yegue

**Documentation complète des APIs et Services**

---

## 🔥 Firebase APIs

### Authentication API

#### Connexion Email/Password

```dart
// Endpoint: Firebase Authentication
POST /auth/signInWithEmailAndPassword

// Requête
{
  "email": "user@example.com",
  "password": "password123"
}

// Réponse
{
  "user": {
    "id": "abc123",
    "email": "user@example.com",
    "displayName": "John Doe",
    "role": "learner"
  },
  "token": "eyJhbGciOiJIUzI1NiIs..."
}

// Utilisation dans le code
final authService = FirebaseAuth.instance;
final credential = await authService.signInWithEmailAndPassword(
  email: email,
  password: password,
);
```

#### Inscription

```dart
POST /auth/createUserWithEmailAndPassword

{
  "email": "newuser@example.com",
  "password": "securepass123",
  "displayName": "Jane Doe"
}

// Code
final credential = await authService.createUserWithEmailAndPassword(
  email: email,
  password: password,
);

await credential.user?.updateDisplayName(displayName);
```

#### Connexion Google

```dart
// Processus OAuth
GET /auth/signInWithGoogle

// Code
final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

final credential = GoogleAuthProvider.credential(
  accessToken: googleAuth.accessToken,
  idToken: googleAuth.idToken,
);

final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

// Enregistrer l'utilisateur dans Firestore
await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
  'email': userCredential.user!.email,
  'displayName': userCredential.user!.displayName,
  'photoURL': userCredential.user!.photoURL,
  'provider': 'google',
  'role': 'student', // Rôle par défaut
  'createdAt': FieldValue.serverTimestamp(),
});
```

#### Connexion Facebook

```dart
// Processus OAuth Facebook
final LoginResult result = await FacebookAuth.instance.login();

if (result.status == LoginStatus.success) {
  final OAuthCredential facebookCredential = 
    FacebookAuthProvider.credential(result.accessToken!.token);
  
  final userCredential = await FirebaseAuth.instance
    .signInWithCredential(facebookCredential);
}
```

#### Authentification par Téléphone (SMS)

```dart
// Vérification du numéro de téléphone
await FirebaseAuth.instance.verifyPhoneNumber(
  phoneNumber: '+237XXXXXXXXX',
  verificationCompleted: (PhoneAuthCredential credential) async {
    await FirebaseAuth.instance.signInWithCredential(credential);
  },
  verificationFailed: (FirebaseAuthException e) {
    print('Verification failed: ${e.message}');
  },
  codeSent: (String verificationId, int? resendToken) {
    // Afficher l'écran de saisie du code
  },
  codeAutoRetrievalTimeout: (String verificationId) {},
);

// Vérification avec le code SMS
final credential = PhoneAuthProvider.credential(
  verificationId: verificationId,
  smsCode: smsCode,
);
await FirebaseAuth.instance.signInWithCredential(credential);
```

---

### Firestore API

#### Collection: Users

```dart
// Structure document utilisateur
users/{userId}
{
  "id": "string",
  "email": "string",
  "displayName": "string",
  "role": "learner|teacher|admin",
  "languages": ["ewo", "dua"],
  "subscription": {
    "plan": "free|premium|pro",
    "status": "active|expired|cancelled",
    "startDate": "timestamp",
    "endDate": "timestamp"
  },
  "preferences": {
    "theme": "light|dark",
    "language": "fr|en",
    "notifications": true|false
  },
  "createdAt": "timestamp",
  "lastLoginAt": "timestamp"
}

// Lecture
final userDoc = await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .get();

// Écriture
await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .set(userData);

// Mise à jour
await FirebaseFirestore.instance
    .collection('users')
    .doc(userId)
    .update({'lastLoginAt': FieldValue.serverTimestamp()});
```

#### Collection: Courses

```dart
courses/{courseId}
{
  "id": "string",
  "teacherId": "string",
  "title": "string",
  "description": "string",
  "languageCode": "ewo|dua|...",
  "languageName": "string",
  "level": "beginner|intermediate|advanced",
  "topics": ["array", "of", "topics"],
  "lessonIds": ["lesson1", "lesson2"],
  "thumbnailUrl": "string",
  "price": number,
  "estimatedDuration": number,  // minutes
  "enrolledStudents": number,
  "rating": number,
  "status": "draft|published|archived",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}

// Requêtes
// Tous les cours publiés
final courses = await FirebaseFirestore.instance
    .collection('courses')
    .where('status', isEqualTo: 'published')
    .orderBy('rating', descending: true)
    .limit(10)
    .get();

// Cours d'un enseignant
final teacherCourses = await FirebaseFirestore.instance
    .collection('courses')
    .where('teacherId', isEqualTo: teacherId)
    .get();

// Cours par langue
final ewondoCourses = await FirebaseFirestore.instance
    .collection('courses')
    .where('languageCode', isEqualTo: 'ewo')
    .where('level', isEqualTo: 'beginner')
    .get();
```

#### Collection: Lessons

```dart
lessons/{lessonId}
{
  "id": "string",
  "courseId": "string",
  "title": "string",
  "description": "string",
  "content": "string",  // HTML ou Markdown
  "type": "video|audio|text|interactive",
  "mediaUrl": "string?",
  "duration": number,  // minutes
  "order": number,
  "isPublished": boolean,
  "prerequisites": ["lessonId1", "lessonId2"],
  "learningObjectives": ["array", "of", "objectives"],
  "vocabulary": [
    {
      "word": "string",
      "translation": "string",
      "audioUrl": "string"
    }
  ],
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

#### Collection: Lesson Progress

```dart
lesson_progress/{progressId}
{
  "id": "string",
  "userId": "string",
  "lessonId": "string",
  "courseId": "string",
  "languageCode": "string",
  "status": "not_started|in_progress|completed",
  "progressPercentage": number,
  "timeSpentSeconds": number,
  "lastScore": number,
  "bestScore": number,
  "attemptsCount": number,
  "lastAccessedAt": "timestamp",
  "completedAt": "timestamp?",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}

// Progression utilisateur
final progress = await FirebaseFirestore.instance
    .collection('lesson_progress')
    .where('userId', isEqualTo: userId)
    .where('status', isEqualTo: 'completed')
    .get();

final completedCount = progress.docs.length;
```

#### Collection: Dictionary Entries

```dart
dictionary_entries/{entryId}
{
  "id": "string",
  "languageCode": "string",
  "canonicalForm": "string",
  "orthographyVariants": ["variant1", "variant2"],
  "ipa": "string?",  // Phonétique internationale
  "audioFileReferences": ["url1", "url2"],
  "partOfSpeech": "noun|verb|adjective|...",
  "translations": {
    "fr": "traduction française",
    "en": "english translation",
    "dua": "traduction duala"
  },
  "exampleSentences": [
    {
      "sentence": "string",
      "translation": "string",
      "audioUrl": "string?"
    }
  ],
  "tags": ["greetings", "basic"],
  "difficultyLevel": "beginner|intermediate|advanced",
  "contributorId": "string?",
  "reviewStatus": "pending|approved|rejected",
  "qualityScore": number,
  "usageCount": number,
  "lastUpdated": "timestamp"
}

// Recherche
final results = await FirebaseFirestore.instance
    .collection('dictionary_entries')
    .where('languageCode', isEqualTo: 'ewo')
    .where('canonicalForm', isGreaterThanOrEqualTo: searchQuery)
    .where('canonicalForm', isLessThan: searchQuery + 'z')
    .limit(20)
    .get();
```

#### Collection: Quiz Attempts

```dart
quiz_attempts/{attemptId}
{
  "id": "string",
  "userId": "string",
  "quizId": "string",
  "answers": [
    {
      "questionId": "string",
      "answer": "string",
      "isCorrect": boolean,
      "timeSpentSeconds": number,
      "pointsEarned": number
    }
  ],
  "totalScore": number,
  "maxScore": number,
  "percentage": number,
  "passed": boolean,
  "timeSpentSeconds": number,
  "startedAt": "timestamp",
  "completedAt": "timestamp"
}
```

#### Collection: Payments

```dart
payments/{paymentId}
{
  "id": "string",
  "userId": "string",
  "plan": "free|premium|pro",
  "amount": number,
  "currency": "XAF",
  "paymentMethod": "campay|noupay|stripe",
  "status": "pending|completed|failed|refunded",
  "transactionId": "string",
  "startDate": "timestamp",
  "endDate": "timestamp",
  "autoRenew": boolean,
  "metadata": {
    "phoneNumber": "string?",
    "email": "string?",
    "gateway": "string"
  },
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}

// Vérifier abonnement actif
final subscription = await FirebaseFirestore.instance
    .collection('payments')
    .where('userId', isEqualTo: userId)
    .where('status', isEqualTo: 'completed')
    .where('endDate', isGreaterThan: Timestamp.now())
    .orderBy('endDate', descending: true)
    .limit(1)
    .get();

final hasActiveSubscription = subscription.docs.isNotEmpty;
```

---

## 🤖 Google Gemini AI API

### Configuration

```dart
import 'package:google_generative_ai/google_generative_ai.dart';

final model = GenerativeModel(
  model: 'gemini-pro',
  apiKey: GEMINI_API_KEY,
);
```

### Chat Conversationnel

```dart
// Endpoint: Gemini API
POST https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent

// Requête
{
  "contents": [{
    "parts": [{
      "text": "Comment dit-on 'bonjour' en Ewondo?"
    }]
  }],
  "generationConfig": {
    "temperature": 0.7,
    "maxOutputTokens": 1024
  }
}

// Code
final chat = model.startChat();
final response = await chat.sendMessage(
  Content.text("Comment dit-on 'bonjour' en Ewondo?"),
);
print(response.text);  // "En Ewondo, on dit 'Mbolo'..."
```

### Traduction

```dart
final prompt = '''
Traduisez le texte suivant du français vers l'Ewondo.
Texte: "$text"
Contexte: $context
Fournissez une traduction naturelle et culturellement appropriée.
''';

final response = await model.generateContent([Content.text(prompt)]);
final translation = response.text;
```

### Évaluation Prononciation

```dart
final prompt = '''
Évaluez la prononciation de l'audio fourni.
Mot attendu: "$expectedWord"
Langue: $languageCode
Fournissez un score de 0 à 100 et des suggestions d'amélioration.
''';

// Note: Nécessite Gemini-Pro-Vision pour audio
final response = await visionModel.generateContent([
  Content.multi([
    TextPart(prompt),
    DataPart('audio/wav', audioBytes),
  ]),
]);
```

---

## 💳 APIs de Paiement

### CamPay API

#### Configuration

```dart
const String CAMPAY_BASE_URL = 'https://api.campay.net/v1';
const String CAMPAY_API_KEY = 'your_api_key';
```

#### Initier un Paiement

```dart
// Endpoint
POST /collect

// Headers
{
  "Authorization": "Token $CAMPAY_API_KEY",
  "Content-Type": "application/json"
}

// Body
{
  "amount": 2000,
  "currency": "XAF",
  "from": "237670000000",  // Numéro mobile money
  "description": "Abonnement Premium Ma'a yegue",
  "external_reference": "payment_123"
}

// Réponse
{
  "reference": "campay_ref_xyz",
  "status": "PENDING",
  "operator": "MTN"
}

// Code
final response = await dio.post(
  '$CAMPAY_BASE_URL/collect',
  options: Options(headers: {
    'Authorization': 'Token $CAMPAY_API_KEY',
  }),
  data: {
    'amount': amount,
    'currency': 'XAF',
    'from': phoneNumber,
    'description': description,
    'external_reference': reference,
  },
);
```

#### Vérifier Statut Paiement

```dart
GET /transaction/{reference}

// Réponse
{
  "reference": "campay_ref_xyz",
  "status": "SUCCESSFUL|FAILED|PENDING",
  "amount": 2000,
  "operator": "MTN",
  "external_reference": "payment_123"
}

// Code
final status = await dio.get(
  '$CAMPAY_BASE_URL/transaction/$reference',
  options: Options(headers: {
    'Authorization': 'Token $CAMPAY_API_KEY',
  }),
);
```

### NouPay API

#### Initier Paiement

```dart
POST https://api.noupay.com/v1/payments

{
  "merchant_id": "your_merchant_id",
  "amount": 2000,
  "currency": "XAF",
  "customer_email": "customer@example.com",
  "customer_phone": "237670000000",
  "return_url": "https://yourapp.com/payment/callback",
  "description": "Abonnement Premium"
}

// Réponse
{
  "payment_id": "noupay_123",
  "payment_url": "https://checkout.noupay.com/pay/noupay_123",
  "status": "pending"
}
```

### Stripe API

#### Créer Session Checkout

```dart
POST https://api.stripe.com/v1/checkout/sessions

// Headers
{
  "Authorization": "Bearer $STRIPE_SECRET_KEY",
  "Content-Type": "application/x-www-form-urlencoded"
}

// Body
{
  "payment_method_types": ["card"],
  "line_items": [{
    "price_data": {
      "currency": "xaf",
      "product_data": {
        "name": "Ma'a yegue Premium"
      },
      "unit_amount": 2000
    },
    "quantity": 1
  }],
  "mode": "subscription",
  "success_url": "https://yourapp.com/success",
  "cancel_url": "https://yourapp.com/cancel"
}

// Code (via Cloud Function)
final session = await functions.httpsCallable('createStripeSession').call({
  'plan': 'premium',
  'userId': userId,
});
```

---

## 🗄️ SQLite Local Database API

### Tables Principales

#### Table: dictionary_entries

```sql
CREATE TABLE dictionary_entries (
  id TEXT PRIMARY KEY,
  language_code TEXT NOT NULL,
  canonical_form TEXT NOT NULL,
  orthography_variants TEXT,  -- JSON array
  ipa TEXT,
  audio_file_references TEXT,  -- JSON array
  part_of_speech TEXT NOT NULL,
  translations TEXT,  -- JSON object
  example_sentences TEXT,  -- JSON array
  tags TEXT,  -- JSON array
  difficulty_level TEXT NOT NULL,
  contributor_id TEXT,
  review_status TEXT,
  quality_score REAL,
  usage_count INTEGER DEFAULT 0,
  last_updated INTEGER,
  is_deleted INTEGER DEFAULT 0,
  needs_sync INTEGER DEFAULT 0,
  has_conflict INTEGER DEFAULT 0
);

-- Indexes
CREATE INDEX idx_dictionary_language_code ON dictionary_entries(language_code);
CREATE INDEX idx_dictionary_canonical_form ON dictionary_entries(canonical_form);
CREATE INDEX idx_dictionary_review_status ON dictionary_entries(review_status);
```

**Utilisation :**

```dart
// Insertion
await db.insert('dictionary_entries', {
  'id': entryId,
  'language_code': 'ewo',
  'canonical_form': 'mbolo',
  'translations': jsonEncode({'fr': 'bonjour', 'en': 'hello'}),
  'part_of_speech': 'interjection',
  'difficulty_level': 'beginner',
  'last_updated': DateTime.now().millisecondsSinceEpoch,
});

// Recherche
final results = await db.query(
  'dictionary_entries',
  where: 'language_code = ? AND canonical_form LIKE ?',
  whereArgs: ['ewo', '%$searchQuery%'],
  limit: 20,
);

// Full-text search
final searchResults = await db.rawQuery('''
  SELECT * FROM dictionary_entries
  WHERE language_code = ?
    AND (canonical_form LIKE ? OR translations LIKE ?)
    AND is_deleted = 0
  ORDER BY usage_count DESC
  LIMIT 50
''', ['ewo', '%$query%', '%$query%']);
```

#### Table: lesson_progress

```sql
CREATE TABLE lesson_progress (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  lesson_id TEXT NOT NULL,
  course_id TEXT NOT NULL,
  language_code TEXT NOT NULL,
  status TEXT NOT NULL,  -- not_started, in_progress, completed
  progress_percentage REAL DEFAULT 0,
  time_spent_seconds INTEGER DEFAULT 0,
  last_score INTEGER DEFAULT 0,
  best_score INTEGER DEFAULT 0,
  attempts_count INTEGER DEFAULT 0,
  last_accessed INTEGER,
  completed_at INTEGER,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,
  needs_sync INTEGER DEFAULT 0,
  
  UNIQUE(user_id, lesson_id)
);

CREATE INDEX idx_lesson_progress_user ON lesson_progress(user_id);
CREATE INDEX idx_lesson_progress_lesson ON lesson_progress(lesson_id);
CREATE INDEX idx_lesson_progress_status ON lesson_progress(status);
```

**Utilisation :**

```dart
// Enregistrer progression
await db.insert(
  'lesson_progress',
  {
    'id': progressId,
    'user_id': userId,
    'lesson_id': lessonId,
    'course_id': courseId,
    'language_code': languageCode,
    'status': 'in_progress',
    'progress_percentage': 50.0,
    'time_spent_seconds': 300,
    'last_accessed': DateTime.now().millisecondsSinceEpoch,
    'created_at': DateTime.now().millisecondsSinceEpoch,
    'updated_at': DateTime.now().millisecondsSinceEpoch,
    'needs_sync': 1,
  },
  conflictAlgorithm: ConflictAlgorithm.replace,
);

// Récupérer statistiques
final stats = await db.rawQuery('''
  SELECT 
    COUNT(*) as total,
    SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as completed,
    SUM(time_spent_seconds) as total_time,
    AVG(best_score) as avg_score
  FROM lesson_progress
  WHERE user_id = ? AND language_code = ?
''', [userId, languageCode]);
```

#### Table: quiz_attempts

```sql
CREATE TABLE quiz_attempts (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  quiz_id TEXT NOT NULL,
  answers TEXT,  -- JSON array
  total_score INTEGER,
  max_score INTEGER,
  percentage REAL,
  passed INTEGER,  -- boolean
  time_spent_seconds INTEGER,
  started_at INTEGER,
  completed_at INTEGER,
  
  INDEX idx_quiz_attempts_user (user_id),
  INDEX idx_quiz_attempts_quiz (quiz_id)
);
```

#### Table: user_levels

```sql
CREATE TABLE user_levels (
  id TEXT PRIMARY KEY,
  user_id TEXT NOT NULL,
  language_code TEXT NOT NULL,
  current_level TEXT NOT NULL,  -- beginner, intermediate, advanced
  current_points INTEGER DEFAULT 0,
  points_to_next_level INTEGER,
  completion_percentage REAL DEFAULT 0,
  level_achieved_at INTEGER,
  last_assessment_date INTEGER,
  completed_lessons TEXT,  -- JSON array
  unlocked_courses TEXT,  -- JSON array
  skill_scores TEXT,  -- JSON object
  created_at INTEGER,
  updated_at INTEGER,
  
  UNIQUE(user_id, language_code)
);
```

---

## 🔊 Audio Service API

### Lecture Audio

```dart
class AudioService {
  // Jouer prononciation
  Future<void> playPronunciation(String audioUrl) async {
    final player = AudioPlayer();
    await player.setUrl(audioUrl);
    await player.play();
  }
  
  // Enregistrer audio
  Future<String> recordAudio(Duration maxDuration) async {
    final recorder = FlutterSoundRecorder();
    await recorder.startRecorder(
      toFile: 'audio_recording.wav',
      codec: Codec.pcm16WAV,
    );
    
    await Future.delayed(maxDuration);
    
    final path = await recorder.stopRecorder();
    return path!;
  }
  
  // Convertir Speech to Text
  Future<String> speechToText(String audioPath) async {
    final speech = SpeechToText();
    await speech.initialize();
    
    final result = await speech.listen();
    return result.recognizedWords;
  }
}
```

---

## 📊 Analytics API

### Firebase Analytics

```dart
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  
  // Événement personnalisé
  Future<void> logEvent(String name, Map<String, dynamic> parameters) async {
    await _analytics.logEvent(
      name: name,
      parameters: parameters,
    );
  }
  
  // Événements prédéfinis
  Future<void> logLessonComplete(String lessonId, int duration) async {
    await _analytics.logEvent(
      name: 'lesson_completed',
      parameters: {
        'lesson_id': lessonId,
        'duration_seconds': duration,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
  
  Future<void> logPurchase({
    required String transactionId,
    required double value,
    required String currency,
    required String plan,
  }) async {
    await _analytics.logPurchase(
      transactionId: transactionId,
      value: value,
      currency: currency,
      parameters: {'plan': plan},
    );
  }
  
  // User properties
  Future<void> setUserProperties(String userId, String role) async {
    await _analytics.setUserId(id: userId);
    await _analytics.setUserProperty(name: 'role', value: role);
  }
}
```

---

## 🔔 Notification API

### Firebase Cloud Messaging

```dart
class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  
  // Initialiser
  Future<void> initialize() async {
    // Demander permission
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    
    // Obtenir token
    final token = await _messaging.getToken();
    debugPrint('FCM Token: $token');
    
    // Sauvegarder token
    await _saveTokenToDatabase(token);
  }
  
  // Écouter notifications
  void listenToMessages() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Message reçu: ${message.notification?.title}');
      _showLocalNotification(message);
    });
    
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('App ouverte via notification');
      _handleNotificationClick(message);
    });
  }
  
  // Envoyer notification (via Cloud Function)
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    await functions.httpsCallable('sendNotification').call({
      'userId': userId,
      'notification': {
        'title': title,
        'body': body,
      },
      'data': data,
    });
  }
}

// Payload notification
{
  "notification": {
    "title": "Nouvelle leçon disponible !",
    "body": "Votre cours d'Ewondo a une nouvelle leçon."
  },
  "data": {
    "type": "new_lesson",
    "lessonId": "lesson_123",
    "courseId": "course_456",
    "action": "open_lesson"
  }
}
```

---

## 📥 Storage API

### Firebase Storage

```dart
class StorageService {
  final storage = FirebaseStorage.instance;
  
  // Upload fichier
  Future<String> uploadFile(File file, String path) async {
    final ref = storage.ref().child(path);
    final uploadTask = ref.putFile(file);
    
    final snapshot = await uploadTask.whenComplete(() {});
    final downloadUrl = await snapshot.ref.getDownloadURL();
    
    return downloadUrl;
  }
  
  // Upload avatar
  Future<String> uploadAvatar(String userId, File imageFile) async {
    final path = 'avatars/$userId/profile.jpg';
    return await uploadFile(imageFile, path);
  }
  
  // Upload audio prononciation
  Future<String> uploadAudio(String languageCode, String word, File audioFile) async {
    final path = 'audio/$languageCode/$word.wav';
    return await uploadFile(audioFile, path);
  }
  
  // Télécharger fichier
  Future<Uint8List?> downloadFile(String url) async {
    final ref = storage.refFromURL(url);
    return await ref.getData();
  }
  
  // Supprimer fichier
  Future<void> deleteFile(String path) async {
    final ref = storage.ref().child(path);
    await ref.delete();
  }
}
```

---

## 🔄 Synchronisation API

### Sync Manager

```dart
class GeneralSyncManager {
  // Synchroniser tout
  Future<SyncResult> syncAll() async {
    final results = await Future.wait([
      syncLessonProgress(),
      syncDictionaryEntries(),
      syncQuizAttempts(),
      syncUserProfile(),
      syncGamificationData(),
    ]);
    
    return SyncResult.fromList(results);
  }
  
  // Sync spécifique
  Future<bool> syncLessonProgress() async {
    final db = await DatabaseHelper.database;
    
    // Upload local → Firebase
    final pending = await db.query(
      'lesson_progress',
      where: 'needs_sync = 1',
    );
    
    for (final record in pending) {
      await _firestore
          .collection('lesson_progress')
          .doc(record['id'])
          .set(record);
      
      await db.update(
        'lesson_progress',
        {'needs_sync': 0},
        where: 'id = ?',
        whereArgs: [record['id']],
      );
    }
    
    // Download Firebase → Local
    final remoteSnapshot = await _firestore
        .collection('lesson_progress')
        .where('userId', isEqualTo: userId)
        .where('updatedAt', isGreaterThan: lastSyncTimestamp)
        .get();
    
    for (final doc in remoteSnapshot.docs) {
      await db.insert(
        'lesson_progress',
        doc.data(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    
    return true;
  }
}
```

---

## 🎯 Endpoints Cloud Functions

### Structure

```
functions/
├── src/
│   ├── auth/
│   │   ├── onCreate.ts          # Trigger création utilisateur
│   │   └── onDelete.ts          # Trigger suppression utilisateur
│   ├── payments/
│   │   ├── createCheckout.ts   # Créer session paiement
│   │   ├── handleWebhook.ts    # Webhook paiements
│   │   └── verifyPayment.ts    # Vérifier paiement
│   ├── notifications/
│   │   ├── sendNotification.ts # Envoyer notification
│   │   └── scheduleReminder.ts # Planifier rappel
│   └── analytics/
│       ├── aggregateStats.ts   # Agréger statistiques
│       └── generateReport.ts   # Générer rapport
└── index.ts
```

### Exemples

#### Créer Session Paiement Stripe

```typescript
// functions/src/payments/createCheckout.ts
export const createStripeCheckout = functions.https.onCall(async (data, context) => {
  // Vérifier authentification
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User must be authenticated');
  }
  
  const { plan, userId } = data;
  
  // Créer session Stripe
  const session = await stripe.checkout.sessions.create({
    payment_method_types: ['card'],
    line_items: [{
      price: STRIPE_PRICE_IDS[plan],
      quantity: 1,
    }],
    mode: 'subscription',
    success_url: `${YOUR_DOMAIN}/success?session_id={CHECKOUT_SESSION_ID}`,
    cancel_url: `${YOUR_DOMAIN}/cancel`,
    client_reference_id: userId,
  });
  
  return { sessionId: session.id, url: session.url };
});
```

#### Envoyer Notification

```typescript
export const sendNotification = functions.https.onCall(async (data, context) => {
  const { userId, title, body, data: notificationData } = data;
  
  // Récupérer token FCM utilisateur
  const userDoc = await admin.firestore().collection('users').doc(userId).get();
  const fcmToken = userDoc.data()?.fcmToken;
  
  if (!fcmToken) {
    throw new functions.https.HttpsError('not-found', 'FCM token not found');
  }
  
  // Envoyer notification
  await admin.messaging().send({
    token: fcmToken,
    notification: { title, body },
    data: notificationData,
  });
  
  return { success: true };
});
```

---

## 🔍 Codes d'Erreur

### Erreurs d'Authentification

```dart
// Firebase Auth Error Codes
'user-not-found'          → 'Utilisateur non trouvé'
'wrong-password'          → 'Mot de passe incorrect'
'email-already-in-use'    → 'Email déjà utilisé'
'weak-password'           → 'Mot de passe trop faible'
'invalid-email'           → 'Email invalide'
'user-disabled'           → 'Compte désactivé'
'operation-not-allowed'   → 'Opération non autorisée'
'network-request-failed'  → 'Erreur réseau'
```

### Erreurs de Paiement

```dart
'payment-failed'          → 'Paiement échoué'
'insufficient-funds'      → 'Fonds insuffisants'
'invalid-card'            → 'Carte invalide'
'payment-cancelled'       → 'Paiement annulé'
'payment-timeout'         → 'Timeout paiement'
'gateway-error'           → 'Erreur passerelle'
```

### Erreurs de Synchronisation

```dart
'sync-failed'             → 'Synchronisation échouée'
'conflict-detected'       → 'Conflit détecté'
'offline'                 → 'Mode hors ligne'
'server-unreachable'      → 'Serveur injoignable'
```

---

## 📚 Exemples d'Intégration

### Flux Complet : Achat Premium

```dart
// 1. Utilisateur clique "Upgrade to Premium"
onPressed: () async {
  // 2. Navigation vers plans
  context.push('/subscription-plans');
  
  // 3. Sélection plan Premium
  final selectedPlan = SubscriptionPlan.premium;
  
  // 4. Choisir méthode paiement
  final paymentMethod = await showPaymentMethodDialog();
  
  // 5. Initier paiement
  final paymentViewModel = context.read<PaymentViewModel>();
  final paymentResult = await paymentViewModel.initiatePayment(
    plan: selectedPlan,
    method: paymentMethod,
    phoneNumber: userPhone,
  );
  
  // 6. Traiter selon résultat
  if (paymentResult.isSuccess) {
    // 7. Mettre à jour abonnement
    await profileViewModel.updateSubscription(selectedPlan);
    
    // 8. Débloquer contenu premium
    await lessonViewModel.unlockPremiumContent();
    
    // 9. Afficher confirmation
    showSuccessDialog('Abonnement activé !');
    
    // 10. Rediriger dashboard
    context.go('/dashboard');
    
    // 11. Envoyer notification confirmation
    await notificationService.sendConfirmation(
      userId: currentUserId,
      plan: selectedPlan,
    );
  } else {
    // Gérer erreur
    showErrorDialog(paymentResult.error);
  }
}
```

---

## 🔐 Variables d'Environnement

### Fichier .env

```env
# Firebase Configuration
FIREBASE_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
FIREBASE_AUTH_DOMAIN=maayegue.firebaseapp.com
FIREBASE_PROJECT_ID=maayegue
FIREBASE_STORAGE_BUCKET=maayegue.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789
FIREBASE_APP_ID=1:123456789:android:abcdefg
FIREBASE_MEASUREMENT_ID=G-XXXXXXXXXX

# Google Gemini AI
GEMINI_API_KEY=AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

# CamPay
CAMPAY_API_KEY=your_campay_api_key
CAMPAY_USERNAME=your_username
CAMPAY_PASSWORD=your_password
CAMPAY_BASE_URL=https://api.campay.net/v1

# NouPay
NOUPAY_API_KEY=your_noupay_api_key
NOUPAY_MERCHANT_ID=your_merchant_id
NOUPAY_BASE_URL=https://api.noupay.com/v1

# Stripe
STRIPE_PUBLISHABLE_KEY=pk_live_XXXXXXXXXXXXXXXXXXXX
STRIPE_SECRET_KEY=sk_live_XXXXXXXXXXXXXXXXXXXX
STRIPE_WEBHOOK_SECRET=whsec_XXXXXXXXXXXXXXXXXXXX

# App Configuration
APP_NAME=Ma'a yegue
APP_VERSION=1.0.0
ENVIRONMENT=production
DEBUG_MODE=false

# Features Flags
ENABLE_AI_FEATURES=true
ENABLE_PAYMENT=true
ENABLE_SOCIAL_FEATURES=true
ENABLE_OFFLINE_MODE=true
```

---

*Documentation API complète - Mise à jour le 7 octobre 2025*

