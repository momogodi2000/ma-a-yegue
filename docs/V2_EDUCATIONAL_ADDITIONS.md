# 🎓 Additions Éducatives v2.0 - Architecture

**Ma'a Yegue Educational Platform**  
**Date:** 7 octobre 2025

---

## 🏗️ Nouveaux Modèles de Données

### 1. Modèles Éducatifs Core

**Fichier:** `lib/core/models/educational_models.dart` (530 lignes)

#### Classes Principales

```dart
// Niveaux scolaires
enum GradeLevel { cp, ce1, ce2, cm1, cm2, sixieme, cinquieme, quatrieme, troisieme, seconde, premiere, terminale }
enum EducationLevel { primaire, secondaire1, secondaire2 }

// Rôles utilisateurs étendus
enum UserRole { visitor, student, parent, teacher, substitute, schoolDirector, viceDirector, educationalCounselor, inspector, minEducOfficial, admin, superAdmin }

// Établissement scolaire
class School {
  String id, name, code;        // MINEDUC code
  SchoolType type;               // publique, privee, confessionnelle
  String address, city, region;
  String directorId;
  int maxCapacity, currentEnrollment;
  SchoolStatus status;
}

// Classe/Salle
class Classroom {
  String id, schoolId, name;
  GradeLevel gradeLevel;
  String academicYear, teacherId;
  List<String> studentIds;
  int maxCapacity;              // default: 40
  Map<String, dynamic> schedule;
}

// Trimestre académique
class AcademicTerm {
  String id, name;              // "1er Trimestre"
  int termNumber;                // 1, 2, 3
  String academicYear;
  DateTime startDate, endDate;
  bool isActive;
}

// Note /20
class Grade {
  String id, studentId, classroomId;
  String subject, assessmentType;
  double score, maxScore;        // sur 20
  String termId;
  DateTime date;
  
  // Propriétés calculées
  double get percentage;         // 0-100
  String get letterGrade;        // A-F
  String get appreciation;       // Français
}

// Bulletin scolaire
class ReportCard {
  String id, studentId, classroomId, termId;
  List<SubjectGrade> subjectGrades;
  double overallAverage;
  int rank, totalStudents;
  String generalComment;
  String? teacherComment, directorComment;
  DateTime generatedDate;
}

// Note par matière
class SubjectGrade {
  String subject;
  double average;
  String coefficient, appreciation;
  String? teacherComment;
}

// Présence
class AttendanceRecord {
  String id, studentId, classroomId;
  DateTime date;
  AttendanceStatus status;       // present, absent, late, excused
  String? reason;
  bool isJustified;
}
```

---

### 2. Modèles Enseignants

**Fichier:** `lib/features/teacher/data/models/teacher_models.dart` (370 lignes)

#### Classes Principales

```dart
// Affectation enseignant
class TeacherAssignment {
  String teacherId, classroomId, subject;
  bool isFormTeacher;            // Professeur principal
  int weeklyHours;
  String academicYear;
}

// Emploi du temps
class ClassSchedule {
  String id, classroomId, teacherId;
  DayOfWeek day;                 // monday-saturday
  String startTime, endTime;     // HH:mm
  String subject;
  String? room;
}

// Devoir
class Homework {
  String id, classroomId, teacherId;
  String subject, title, description;
  DateTime assignedDate, dueDate;
  List<String>? attachments;
  double maxPoints;              // défaut: 20
  bool isGraded;
}

// Soumission devoir
class HomeworkSubmission {
  String id, homeworkId, studentId;
  DateTime submittedDate;
  String? content;
  List<String>? attachments;
  double? grade;
  String? feedback;
  SubmissionStatus status;       // draft, submitted, graded, late, missing
}

// Plan de leçon (cahier de textes)
class LessonPlan {
  String id, classroomId, teacherId;
  String subject;
  DateTime date;
  String topic, objectives, content, materials;
  String? homework;
  int duration;                  // minutes
}

// Note de conduite
class ConductNote {
  String id, studentId, classroomId, teacherId;
  DateTime date;
  ConductType type;              // positive, negative, warning
  String description;
  ConductSeverity severity;      // minor, moderate, major
  String? actionTaken;
  bool parentNotified;
}
```

---

### 3. Modèles Parents

**Fichier:** `lib/features/parent/data/models/parent_models.dart` (350 lignes)

#### Classes Principales

```dart
// Relation parent-élève
class ParentStudentRelation {
  String id, parentId, studentId;
  ParentRelationType relationType;  // mother, father, guardian
  bool isPrimary;                    // Tuteur principal
  bool canViewGrades, canViewAttendance;
  bool canReceiveNotifications;
  DateTime createdDate;
}

// Message parent-professeur
class ParentTeacherMessage {
  String id, senderId, recipientId, studentId;
  String subject, message;
  DateTime sentDate;
  bool isRead;
  String? threadId;
  List<String>? attachments;
  MessagePriority priority;       // low, normal, high, urgent
}

// Annonce scolaire
class SchoolAnnouncement {
  String id, schoolId;
  String title, content;
  AnnouncementType type;          // general, academic, event, holiday
  DateTime publishDate;
  DateTime? expiryDate;
  String authorId;                // Director or Admin
  bool sendNotification;
  List<String> targetGradeLevels; // Empty = all
}

// Rendez-vous
class ParentTeacherMeeting {
  String id, parentId, teacherId, studentId;
  DateTime scheduledDate;
  String duration;
  MeetingMode mode;               // inPerson, virtual, phone
  String? location;
  String purpose;
  MeetingStatus status;           // scheduled, confirmed, completed
  String? notes, outcome;
}

// Résumé progression
class StudentProgressSummary {
  String studentId, academicYear, termId;
  double overallAverage;
  int classRank, totalStudents;
  Map<String, double> subjectAverages;
  int totalAbsences, justifiedAbsences, tardyCount;
  List<String> strengths, areasForImprovement;
  String teacherComment;
  DateTime lastUpdated;
}
```

---

## 🛠️ Nouveaux Services

### 1. Content Filter Service

**Fichier:** `lib/core/services/content_filter_service.dart` (270 lignes)

```dart
// 5 niveaux de complexité
enum ContentComplexity {
  veryEasy,      // CP, CE1 (6-8 ans)
  easy,          // CE2, CM1 (8-11 ans)
  medium,        // CM2, 6ème, 5ème (11-14 ans)
  advanced,      // 4ème, 3ème, 2nde (14-16 ans)
  expert         // 1ère, Terminale (16-18 ans)
}

// Service de filtrage
class ContentFilterService {
  static bool isContentAppropriate({...});
  static ContentComplexity getRecommendedComplexity({...});
  static ContentComplexity forGradeLevel(GradeLevel grade);
  static int getEstimatedReadingTime({...});
  static ValidationResult validateLessonContent({...});
}
```

**Vitesses de Lecture:**
- CP-CE1: 50 mots/minute
- CE2-CM2: 100 mots/minute
- Collège: 150 mots/minute
- Lycée: 200 mots/minute

---

### 2. Academic Calendar Service

**Fichier:** `lib/core/services/academic_calendar_service.dart` (280 lignes)

```dart
class AcademicCalendarService {
  // Génération trimestres camerounais
  static List<AcademicTerm> generateCameroonTerms(String year);
  
  // Année académique actuelle
  static String getCurrentAcademicYear();
  
  // Trimestre actuel
  static AcademicTerm? getCurrentTerm();
  
  // Jours fériés Cameroun
  static List<AcademicHoliday> getCameroonHolidays(String year);
  
  // Vérification jour d'école
  static bool isSchoolDay(DateTime date);
  
  // Comptage jours
  static int getSchoolDaysInTerm(AcademicTerm term);
  
  // Événements académiques
  static List<AcademicEvent> getAcademicEvents(String year);
  
  // Progression trimestre
  static double getTermProgress(AcademicTerm term);
  
  // Prochain événement
  static AcademicEvent? getNextEvent();
}
```

**Calendrier Camerounais:**
- 1er Trimestre: 1 sept → 15 déc
- 2ème Trimestre: 5 jan → 5 avr
- 3ème Trimestre: 15 avr → 10 juil

---

## 🔄 Intégration Architecture Existante

### Communication avec Modules Existants

#### 1. Authentication Module
```dart
// Rôles étendus
enum UserRole {
  visitor, student, parent,      // Nouveaux
  teacher, substitute,           // Étendus
  schoolDirector, inspector,     // Nouveaux
  admin, superAdmin              // Étendus
}

// Propriétés utilisateur enrichies
class User {
  String role;                   // UserRole as string
  String? schoolId;              // École d'affectation
  String? classroomId;           // Classe (pour élèves)
  GradeLevel? gradeLevel;        // Niveau scolaire (élèves)
  List<String>? childrenIds;     // Enfants (parents)
}
```

#### 2. Lessons Module
```dart
// Leçons avec niveau
class Lesson {
  // Existant
  String id, title, content;
  
  // Nouveau v2.0
  ContentComplexity? complexity;  // Niveau difficulté
  List<GradeLevel>? targetGrades; // Niveaux cibles
  int? estimatedTime;            // Minutes par âge
}
```

#### 3. Assessment Module
```dart
// Quiz avec notation /20
class Quiz {
  // Existant
  String id, title;
  List<Question> questions;
  
  // Nouveau v2.0
  double maxScore = 20.0;        // Note sur 20
  GradeLevel? targetGrade;       // Niveau cible
  String? termId;                // Trimestre
}

// Résultat quiz
class QuizResult {
  double score;                  // Sur 20
  
  // Nouveau v2.0
  String get letterGrade;        // A-F
  String get appreciation;       // Français
}
```

#### 4. Dashboard Module
```dart
// Dashboards différenciés
switch (userRole) {
  case UserRole.student:
    return StudentDashboard(gradeLevel: user.gradeLevel);
  
  case UserRole.teacher:
    return TeacherDashboard(classrooms: teacherClassrooms);
  
  case UserRole.parent:
    return ParentDashboard(children: user.childrenIds);
  
  case UserRole.schoolDirector:
    return DirectorDashboard(school: user.schoolId);
  
  case UserRole.visitor:
    return GuestDashboard();
}
```

---

## 📊 Collections Firestore

### Structure Proposée

```
firestore/
├── schools/{schoolId}
│   ├── name, code, type
│   ├── directorId
│   ├── region, city
│   └── status
│
├── classrooms/{classroomId}
│   ├── schoolId
│   ├── gradeLevel
│   ├── teacherId
│   ├── studentIds[]
│   ├── academicYear
│   └── schedule{}
│
├── grades/{gradeId}
│   ├── studentId
│   ├── classroomId
│   ├── subject
│   ├── score (/20)
│   ├── termId
│   └── date
│
├── report_cards/{reportCardId}
│   ├── studentId
│   ├── termId
│   ├── subjectGrades[]
│   ├── overallAverage
│   ├── rank
│   └── comments
│
├── attendance/{attendanceId}
│   ├── studentId
│   ├── classroomId
│   ├── date
│   ├── status
│   └── reason
│
├── homework/{homeworkId}
│   ├── classroomId
│   ├── teacherId
│   ├── subject
│   ├── title, description
│   ├── assignedDate, dueDate
│   └── maxPoints
│
├── homework_submissions/{submissionId}
│   ├── homeworkId
│   ├── studentId
│   ├── submittedDate
│   ├── content
│   ├── grade
│   └── feedback
│
├── lesson_plans/{planId}
│   ├── classroomId
│   ├── teacherId
│   ├── subject, topic
│   ├── date
│   ├── objectives, content
│   └── materials
│
├── conduct_notes/{noteId}
│   ├── studentId
│   ├── classroomId
│   ├── teacherId
│   ├── type, severity
│   ├── description
│   └── parentNotified
│
├── parent_student_relations/{relationId}
│   ├── parentId
│   ├── studentId
│   ├── relationType
│   └── permissions{}
│
├── parent_teacher_messages/{messageId}
│   ├── senderId, recipientId
│   ├── studentId
│   ├── subject, message
│   ├── priority
│   └── threadId
│
├── school_announcements/{announcementId}
│   ├── schoolId
│   ├── title, content
│   ├── type
│   ├── publishDate
│   └── targetGradeLevels[]
│
└── parent_teacher_meetings/{meetingId}
    ├── parentId, teacherId, studentId
    ├── scheduledDate
    ├── mode, location
    ├── status
    └── outcome
```

---

## 🔐 Permissions Étendues

### Culture Module
```dart
Permission.viewCulture          // Voir contenu
Permission.createCultureContent // Créer
Permission.editCultureContent   // Modifier
Permission.deleteCultureContent // Supprimer
```

### Feature Flags
```dart
Feature.culture                 // Module culture
```

### Accès par Rôle

| Feature | Visitor | Student | Parent | Teacher | Director | Admin |
|---------|---------|---------|--------|---------|----------|-------|
| culture | ✅ View | ✅ View | ✅ View | ✅ Create | ✅ Full | ✅ Full |
| lessons | ✅ Limited | ✅ Full | ✅ View | ✅ Create | ✅ Full | ✅ Full |
| grades | ❌ | ✅ View Own | ✅ View Children | ✅ Create | ✅ View All | ✅ Full |

---

## 🎯 Flux de Données Éducatif

### Flux Notation

```
1. Enseignant crée évaluation (Homework/Quiz)
   ↓
2. Élèves soumettent travaux (HomeworkSubmission)
   ↓
3. Enseignant corrige et note (Grade sur /20)
   ↓
4. Notes stockées avec metadata
   ↓
5. Calcul automatique moyennes
   ↓
6. Génération bulletin (ReportCard)
   ↓
7. Parents notifiés
   ↓
8. Consultation portail parent
```

### Flux Présences

```
1. Enseignant marque présences du jour
   ↓
2. Enregistrement AttendanceRecord
   ↓
3. Si absent → Notification parent
   ↓
4. Parent peut justifier
   ↓
5. Statistiques calculées
   ↓
6. Affichage portail parent
```

### Flux Communication

```
Parent → Message → Teacher
   ↓
Teacher reçoit notification
   ↓
Teacher répond
   ↓
Parent reçoit notification
   ↓
Thread conversation continue
```

---

## 📱 State Management

### ViewModels Éducatifs (À Créer)

```dart
// ViewModel Enseignant
class TeacherViewModel extends ChangeNotifier {
  List<Classroom> _classrooms = [];
  List<Homework> _homework = [];
  List<AttendanceRecord> _todayAttendance = [];
  
  Future<void> loadClassrooms();
  Future<void> markAttendance(String studentId, AttendanceStatus);
  Future<void> createHomework(Homework);
  Future<void> gradeSubmission(String id, double grade);
}

// ViewModel Parent
class ParentViewModel extends ChangeNotifier {
  List<StudentProgressSummary> _childrenProgress = [];
  List<ParentTeacherMessage> _messages = [];
  List<ReportCard> _reportCards = [];
  
  Future<void> loadChildrenProgress();
  Future<void> sendMessage(ParentTeacherMessage);
  Future<void> scheduleMeeting(ParentTeacherMeeting);
}

// ViewModel Directeur
class DirectorViewModel extends ChangeNotifier {
  School? _school;
  List<Classroom> _classrooms = [];
  Map<String, dynamic> _statistics = {};
  
  Future<void> loadSchool();
  Future<void> createClassroom(Classroom);
  Future<void> publishAnnouncement(SchoolAnnouncement);
  Future<void> generateSchoolReport();
}
```

---

## 🔄 Intégration Routing

### Nouvelles Routes

```dart
// Teacher routes
GoRoute(path: '/teacher/classrooms', ...),
GoRoute(path: '/teacher/classroom/:id', ...),
GoRoute(path: '/teacher/attendance', ...),
GoRoute(path: '/teacher/homework', ...),
GoRoute(path: '/teacher/grades', ...),

// Parent routes
GoRoute(path: '/parent/dashboard', ...),
GoRoute(path: '/parent/student/:id', ...),
GoRoute(path: '/parent/messages', ...),
GoRoute(path: '/parent/meetings', ...),
GoRoute(path: '/parent/report-cards/:id', ...),

// Director routes
GoRoute(path: '/director/school', ...),
GoRoute(path: '/director/classrooms', ...),
GoRoute(path: '/director/teachers', ...),
GoRoute(path: '/director/announcements', ...),
GoRoute(path: '/director/analytics', ...),

// Admin routes
GoRoute(path: '/admin/schools', ...),
GoRoute(path: '/admin/users', ...),
GoRoute(path: '/admin/system', ...),
```

---

## 🧪 Tests Suggérés

### Tests Unitaires

```dart
// Test Grade calculation
test('should calculate correct letter grade', () {
  final grade = Grade(..., score: 17.0, maxScore: 20.0);
  expect(grade.percentage, 85.0);
  expect(grade.letterGrade, 'B');
  expect(grade.appreciation, 'Très Bien');
});

// Test ContentFilter
test('should recommend appropriate complexity', () {
  final complexity = ContentFilterService.getRecommendedComplexity(
    gradeLevel: GradeLevel.sixieme,
    performanceScore: 90.0,
  );
  expect(complexity, ContentComplexity.advanced); // +1 level
});

// Test Calendar
test('should generate correct Cameroon terms', () {
  final terms = AcademicCalendarService.generateCameroonTerms('2024-2025');
  expect(terms.length, 3);
  expect(terms[0].name, '1er Trimestre');
  expect(terms[0].termNumber, 1);
});
```

---

## 📈 Métriques et Analytics

### Indicateurs Enseignants
- Taux de présence classe
- Moyenne classe par matière
- Taux de soumission devoirs
- Distribution notes (histogramme)
- Élèves en difficulté

### Indicateurs Parents
- Moyenne enfant
- Rang dans classe
- Taux présence
- Devoirs à faire/terminés
- Messages non lus

### Indicateurs Directeur
- Effectifs par classe
- Moyennes par classe
- Taux présence école
- Performance enseignants
- Statistiques MINEDUC

---

## 🚀 Prochaines Implémentations

### Phase UI (Priorité 1)
1. [ ] Teacher dashboard UI
2. [ ] Parent portal UI
3. [ ] Student interface (adaptée par âge)
4. [ ] Director panel UI
5. [ ] Admin school management UI

### Phase Backend (Priorité 2)
1. [ ] Firebase collections setup
2. [ ] Cloud Functions pour calculs
3. [ ] Real-time listeners
4. [ ] Batch operations (bulletins)
5. [ ] Backup et exports

### Phase Tests (Priorité 3)
1. [ ] Unit tests modèles
2. [ ] Integration tests flux complets
3. [ ] Widget tests UI
4. [ ] E2E tests scenarios utilisateurs
5. [ ] Performance tests (1000+ élèves)

---

## ✅ Checklist Développeur

### Avant de Commencer
- [ ] Lire `EDUCATIONAL_SYSTEM_UPDATE.md`
- [ ] Lire `API_REFERENCE_EDUCATIONAL.md`
- [ ] Lire `QUICK_START_EDUCATIONAL.md`
- [ ] Comprendre hiérarchie éducative camerounaise
- [ ] Comprendre système notation /20

### Implémentation UI
- [ ] Créer écrans enseignants
- [ ] Créer écrans parents
- [ ] Créer écrans élèves (adaptés)
- [ ] Créer écrans directeur
- [ ] Tester sur plusieurs âges

### Intégration Backend
- [ ] Créer collections Firestore
- [ ] Implémenter security rules
- [ ] Créer Cloud Functions
- [ ] Tester CRUD operations
- [ ] Optimiser queries

### Testing
- [ ] Tests unitaires (100+ tests)
- [ ] Tests intégration
- [ ] Tests utilisateurs réels
- [ ] Validation par enseignants
- [ ] Validation par parents

---

**Document créé:** 7 octobre 2025  
**Version:** 2.0.0  
**Statut:** Spécification Architecture Complete  
**Usage:** Guide implémentation UI/Backend

