# 📚 API Reference - Système Éducatif Ma'a Yegue

**Version:** 2.0.0  
**Date:** 7 octobre 2025

---

## 🎓 Educational Models API

### Grade Levels

#### `GradeLevel` Enum

```dart
enum GradeLevel {
  // Primaire (6-11 ans)
  cp, ce1, ce2, cm1, cm2,
  
  // Secondaire 1er Cycle (11-15 ans)
  sixieme, cinquieme, quatrieme, troisieme,
  
  // Secondaire 2nd Cycle (15-18 ans)
  seconde, premiere, terminale
}
```

**Propriétés:**
- `code: String` - Code court (ex: "CP", "6ème")
- `fullName: String` - Nom complet (ex: "Cours Préparatoire")
- `level: int` - Niveau numérique (1-12)
- `educationLevel: EducationLevel` - Cycle éducatif
- `typicalAge: int` - Âge typique (6-17)

**Méthodes:**
- `isPrimaire: bool` - Vrai si primaire
- `isSecondaire: bool` - Vrai si secondaire

**Exemple:**
```dart
final grade = GradeLevel.sixieme;
print(grade.code);        // "6ème"
print(grade.fullName);    // "Sixième"
print(grade.level);       // 6
print(grade.typicalAge);  // 11
print(grade.isPrimaire);  // false
```

---

### User Roles

#### `UserRole` Enum

```dart
enum UserRole {
  visitor,           // Niveau 0
  student,           // Niveau 1
  parent,            // Niveau 1
  teacher,           // Niveau 2
  substitute,        // Niveau 2
  schoolDirector,    // Niveau 5
  viceDirector,      // Niveau 4
  educationalCounselor, // Niveau 3
  inspector,         // Niveau 6
  minEducOfficial,   // Niveau 7
  admin,             // Niveau 8
  superAdmin         // Niveau 9
}
```

**Propriétés:**
- `displayName: String` - Nom affiché
- `description: String` - Description du rôle
- `hierarchyLevel: int` - Niveau hiérarchique (0-9)

**Exemple:**
```dart
final role = UserRole.teacher;
print(role.displayName);      // "Enseignant"
print(role.hierarchyLevel);   // 2
```

---

### School Management

#### `School` Class

```dart
class School {
  final String id;
  final String name;
  final String code;              // MINEDUC code
  final SchoolType type;
  final String address;
  final String city;
  final String region;
  final String phoneNumber;
  final String? email;
  final String directorId;
  final List<String> viceDirectorIds;
  final DateTime foundedDate;
  final int maxCapacity;
  final int currentEnrollment;
  final SchoolStatus status;
}
```

**SchoolType Enum:**
```dart
enum SchoolType {
  publique,           // École Publique
  privee,             // École Privée
  confessionnelle,    // École Confessionnelle
  internationale      // École Internationale
}
```

**SchoolStatus Enum:**
```dart
enum SchoolStatus {
  active,       // Active
  inactive,     // Inactive
  suspended,    // Suspendue
  underReview   // En Révision
}
```

**JSON Serialization:**
```dart
// To JSON
final json = school.toJson();

// From JSON
final school = School.fromJson(jsonData);
```

**Exemple:**
```dart
final school = School(
  id: 'school_001',
  name: 'École Primaire et Secondaire de Yaoundé',
  code: 'MINEDUC_YDE_001',
  type: SchoolType.publique,
  address: 'Avenue Kennedy',
  city: 'Yaoundé',
  region: 'Centre',
  phoneNumber: '+237 222 123 456',
  directorId: 'user_director_123',
  foundedDate: DateTime(1980, 9, 1),
  maxCapacity: 1200,
  currentEnrollment: 985,
  status: SchoolStatus.active,
);
```

---

### Classroom Management

#### `Classroom` Class

```dart
class Classroom {
  final String id;
  final String schoolId;
  final String name;              // ex: "6ème A"
  final GradeLevel gradeLevel;
  final String academicYear;      // ex: "2024-2025"
  final String teacherId;
  final List<String> studentIds;
  final int maxCapacity;          // default: 40
  final String? room;
  final Map<String, dynamic> schedule;
  final ClassroomStatus status;
}
```

**Méthodes:**
- `currentEnrollment: int` - Nombre d'élèves
- `isFull: bool` - Si classe pleine

**ClassroomStatus Enum:**
```dart
enum ClassroomStatus {
  active,      // Active
  archived,    // Archivée
  suspended    // Suspendue
}
```

**Exemple:**
```dart
final classroom = Classroom(
  id: 'class_001',
  schoolId: 'school_001',
  name: '6ème A',
  gradeLevel: GradeLevel.sixieme,
  academicYear: '2024-2025',
  teacherId: 'teacher_123',
  studentIds: ['student_1', 'student_2', ...],
  maxCapacity: 40,
  room: 'Salle 12',
  status: ClassroomStatus.active,
);

print(classroom.currentEnrollment);  // 38
print(classroom.isFull);             // false
```

---

### Academic Terms

#### `AcademicTerm` Class

```dart
class AcademicTerm {
  final String id;
  final String name;              // "1er Trimestre"
  final int termNumber;           // 1, 2, 3
  final String academicYear;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;
}
```

**Exemple:**
```dart
final term1 = AcademicTerm(
  id: '2024-2025_term1',
  name: '1er Trimestre',
  termNumber: 1,
  academicYear: '2024-2025',
  startDate: DateTime(2024, 9, 1),
  endDate: DateTime(2024, 12, 15),
  isActive: true,
);
```

---

### Grading System

#### `Grade` Class

```dart
class Grade {
  final String id;
  final String studentId;
  final String classroomId;
  final String subject;
  final String assessmentType;    // 'quiz', 'exam', 'homework', 'project'
  final double score;             // Out of 20
  final double maxScore;          // Usually 20
  final String termId;
  final DateTime date;
  final String? teacherId;
  final String? comment;
}
```

**Propriétés Calculées:**
- `percentage: double` - Pourcentage (0-100)
- `letterGrade: String` - Lettre A-F
- `appreciation: String` - Appréciation française

**Appréciations:**
- 90%+: "Excellent"
- 80-89%: "Très Bien"
- 70-79%: "Bien"
- 60-69%: "Assez Bien"
- 50-59%: "Passable"
- <50%: "Insuffisant"

**Exemple:**
```dart
final grade = Grade(
  id: 'grade_001',
  studentId: 'student_123',
  classroomId: 'class_001',
  subject: 'Ewondo',
  assessmentType: 'exam',
  score: 16.5,
  maxScore: 20.0,
  termId: '2024-2025_term1',
  date: DateTime.now(),
  teacherId: 'teacher_456',
  comment: 'Très bon travail!',
);

print(grade.percentage);     // 82.5
print(grade.letterGrade);    // "B"
print(grade.appreciation);   // "Très Bien"
```

---

### Report Cards

#### `ReportCard` Class

```dart
class ReportCard {
  final String id;
  final String studentId;
  final String classroomId;
  final String termId;
  final List<SubjectGrade> subjectGrades;
  final double overallAverage;
  final int rank;
  final int totalStudents;
  final String generalComment;
  final String? teacherComment;
  final String? directorComment;
  final DateTime generatedDate;
}
```

#### `SubjectGrade` Class

```dart
class SubjectGrade {
  final String subject;
  final double average;
  final String coefficient;
  final String appreciation;
  final String? teacherComment;
}
```

**Exemple:**
```dart
final reportCard = ReportCard(
  id: 'report_001',
  studentId: 'student_123',
  classroomId: 'class_001',
  termId: '2024-2025_term1',
  subjectGrades: [
    SubjectGrade(
      subject: 'Ewondo',
      average: 16.5,
      coefficient: '3',
      appreciation: 'Très Bien',
      teacherComment: 'Excellent progrès',
    ),
    SubjectGrade(
      subject: 'Français',
      average: 14.0,
      coefficient: '4',
      appreciation: 'Bien',
    ),
  ],
  overallAverage: 15.2,
  rank: 3,
  totalStudents: 38,
  generalComment: 'Élève sérieux et appliqué',
  teacherComment: 'Continuez ainsi!',
  directorComment: 'Félicitations',
  generatedDate: DateTime.now(),
);
```

---

### Attendance

#### `AttendanceRecord` Class

```dart
class AttendanceRecord {
  final String id;
  final String studentId;
  final String classroomId;
  final DateTime date;
  final AttendanceStatus status;
  final String? reason;
  final bool isJustified;
  final String? justificationDocument;
}
```

**AttendanceStatus Enum:**
```dart
enum AttendanceStatus {
  present,    // Présent
  absent,     // Absent
  late,       // Retard
  excused     // Excusé
}
```

**Exemple:**
```dart
final attendance = AttendanceRecord(
  id: 'att_001',
  studentId: 'student_123',
  classroomId: 'class_001',
  date: DateTime.now(),
  status: AttendanceStatus.present,
);
```

---

## 👨‍🏫 Teacher Models API

### Teacher Assignment

```dart
class TeacherAssignment {
  final String id;
  final String teacherId;
  final String classroomId;
  final String subject;
  final bool isFormTeacher;
  final int weeklyHours;
  final String academicYear;
}
```

### Homework

```dart
class Homework {
  final String id;
  final String classroomId;
  final String teacherId;
  final String subject;
  final String title;
  final String description;
  final DateTime assignedDate;
  final DateTime dueDate;
  final List<String>? attachments;
  final double maxPoints;
  final bool isGraded;
}
```

### Homework Submission

```dart
class HomeworkSubmission {
  final String id;
  final String homeworkId;
  final String studentId;
  final DateTime submittedDate;
  final String? content;
  final List<String>? attachments;
  final double? grade;
  final String? feedback;
  final SubmissionStatus status;
}
```

**SubmissionStatus:**
- `draft` - Brouillon
- `submitted` - Soumis
- `graded` - Corrigé
- `late` - En Retard
- `missing` - Non Remis

### Lesson Plan

```dart
class LessonPlan {
  final String id;
  final String classroomId;
  final String teacherId;
  final String subject;
  final DateTime date;
  final String topic;
  final String objectives;
  final String content;
  final String materials;
  final String? homework;
  final int duration;
}
```

### Conduct Note

```dart
class ConductNote {
  final String id;
  final String studentId;
  final String classroomId;
  final String teacherId;
  final DateTime date;
  final ConductType type;
  final String description;
  final ConductSeverity severity;
  final String? actionTaken;
  final bool parentNotified;
}
```

**ConductType:**
- `positive` - Comportement Positif
- `negative` - Comportement Négatif
- `warning` - Avertissement
- `achievement` - Réussite

**ConductSeverity:**
- `minor` - Mineur
- `moderate` - Modéré
- `major` - Majeur

---

## 👨‍👩‍👧 Parent Portal API

### Parent-Student Relation

```dart
class ParentStudentRelation {
  final String id;
  final String parentId;
  final String studentId;
  final ParentRelationType relationType;
  final bool isPrimary;
  final bool canViewGrades;
  final bool canViewAttendance;
  final bool canReceiveNotifications;
  final DateTime createdDate;
}
```

**ParentRelationType:**
- `mother` - Mère
- `father` - Père
- `guardian` - Tuteur Légal
- `grandparent` - Grand-parent
- `other` - Autre

### Parent-Teacher Message

```dart
class ParentTeacherMessage {
  final String id;
  final String senderId;
  final String recipientId;
  final String studentId;
  final String subject;
  final String message;
  final DateTime sentDate;
  final bool isRead;
  final String? threadId;
  final List<String>? attachments;
  final MessagePriority priority;
}
```

**MessagePriority:**
- `low` - Faible
- `normal` - Normal
- `high` - Élevé
- `urgent` - Urgent

### School Announcement

```dart
class SchoolAnnouncement {
  final String id;
  final String schoolId;
  final String title;
  final String content;
  final AnnouncementType type;
  final DateTime publishDate;
  final DateTime? expiryDate;
  final String authorId;
  final bool sendNotification;
  final List<String>? attachments;
  final List<String> targetGradeLevels;
}
```

**AnnouncementType:**
- `general` - Général
- `academic` - Académique
- `event` - Événement
- `holiday` - Vacances
- `urgent` - Urgent
- `meeting` - Réunion

### Parent-Teacher Meeting

```dart
class ParentTeacherMeeting {
  final String id;
  final String parentId;
  final String teacherId;
  final String studentId;
  final DateTime scheduledDate;
  final String duration;
  final MeetingMode mode;
  final String? location;
  final String purpose;
  final MeetingStatus status;
  final String? notes;
  final String? outcome;
}
```

**MeetingMode:**
- `inPerson` - En Personne
- `virtual` - Virtuel
- `phone` - Téléphone

**MeetingStatus:**
- `scheduled` - Planifié
- `confirmed` - Confirmé
- `completed` - Terminé
- `cancelled` - Annulé
- `rescheduled` - Reporté

### Student Progress Summary

```dart
class StudentProgressSummary {
  final String studentId;
  final String academicYear;
  final String termId;
  final double overallAverage;
  final int classRank;
  final int totalStudents;
  final Map<String, double> subjectAverages;
  final int totalAbsences;
  final int justifiedAbsences;
  final int tardyCount;
  final List<String> strengths;
  final List<String> areasForImprovement;
  final String teacherComment;
  final DateTime lastUpdated;
}
```

---

## 🎯 Content Filter Service API

### ContentComplexity Enum

```dart
enum ContentComplexity {
  veryEasy,    // CP, CE1 (6-8 ans)
  easy,        // CE2, CM1 (8-11 ans)
  medium,      // CM2, 6ème, 5ème (11-14 ans)
  advanced,    // 4ème, 3ème, 2nde (14-16 ans)
  expert       // 1ère, Terminale (16-18 ans)
}
```

**Propriétés:**
- `level: int` - Niveau 1-5
- `displayName: String` - Nom affiché
- `appropriateGrades: List<GradeLevel>` - Niveaux appropriés

**Méthodes:**
- `isAppropriateFor(GradeLevel): bool`
- `isAppropriateForAge(int): bool`
- `forGradeLevel(GradeLevel): ContentComplexity` - Statique

### ContentFilterService

#### Méthodes Statiques

**`isContentAppropriate()`**
```dart
static bool isContentAppropriate({
  required GradeLevel studentGrade,
  required ContentComplexity contentComplexity,
  bool allowHigherComplexity = false,
})
```

**`getRecommendedComplexity()`**
```dart
static ContentComplexity getRecommendedComplexity({
  required GradeLevel gradeLevel,
  required double performanceScore, // 0-100
})
```

**`validateLessonContent()`**
```dart
static ValidationResult validateLessonContent({
  required String lessonContent,
  required GradeLevel targetGrade,
})
```

**`getEstimatedReadingTime()`**
```dart
static int getEstimatedReadingTime({
  required String content,
  required GradeLevel gradeLevel,
})
```

**Exemple:**
```dart
// Vérifier si contenu approprié
final isOk = ContentFilterService.isContentAppropriate(
  studentGrade: GradeLevel.sixieme,
  contentComplexity: ContentComplexity.medium,
);

// Obtenir complexité recommandée
final recommended = ContentFilterService.getRecommendedComplexity(
  gradeLevel: GradeLevel.troisieme,
  performanceScore: 85.0,
);

// Temps de lecture
final minutes = ContentFilterService.getEstimatedReadingTime(
  content: lessonText,
  gradeLevel: GradeLevel.cm2,
);
```

---

## 📅 Academic Calendar Service API

### AcademicCalendarService

#### Méthodes Statiques

**`generateCameroonTerms()`**
```dart
static List<AcademicTerm> generateCameroonTerms(String academicYear)
```
Génère les 3 trimestres camerounais.

**`getCurrentAcademicYear()`**
```dart
static String getCurrentAcademicYear()
```
Retourne l'année académique actuelle (ex: "2024-2025").

**`getCurrentTerm()`**
```dart
static AcademicTerm? getCurrentTerm()
```
Retourne le trimestre en cours.

**`getCameroonHolidays()`**
```dart
static List<AcademicHoliday> getCameroonHolidays(String academicYear)
```
Liste des jours fériés et vacances.

**`isSchoolDay()`**
```dart
static bool isSchoolDay(DateTime date)
```
Vérifie si une date est un jour d'école.

**`getSchoolDaysInTerm()`**
```dart
static int getSchoolDaysInTerm(AcademicTerm term)
```
Compte les jours d'école dans un trimestre.

**`getAcademicEvents()`**
```dart
static List<AcademicEvent> getAcademicEvents(String academicYear)
```
Événements académiques (rentrée, conseils, examens).

**`getTermProgress()`**
```dart
static double getTermProgress(AcademicTerm term)
```
Pourcentage de progression du trimestre (0-100).

**`getNextEvent()`**
```dart
static AcademicEvent? getNextEvent()
```
Prochain événement académique.

**Exemple:**
```dart
// Année académique actuelle
final year = AcademicCalendarService.getCurrentAcademicYear();
// "2024-2025"

// Trimestre en cours
final term = AcademicCalendarService.getCurrentTerm();
print(term?.name); // "1er Trimestre"

// Vérifier jour d'école
final isSchool = AcademicCalendarService.isSchoolDay(DateTime.now());

// Prochain événement
final nextEvent = AcademicCalendarService.getNextEvent();
print(nextEvent?.name); // "Conseil de Classe 1er Trimestre"
```

---

## 📊 Firebase Collections Structure

### Schools Collection
```
schools/{schoolId}
  - name: string
  - code: string (MINEDUC)
  - type: string
  - directorId: string
  - region: string
  - currentEnrollment: number
  - status: string
```

### Classrooms Collection
```
classrooms/{classroomId}
  - schoolId: string
  - name: string
  - gradeLevel: string
  - teacherId: string
  - studentIds: array
  - maxCapacity: number
  - academicYear: string
```

### Grades Collection
```
grades/{gradeId}
  - studentId: string
  - classroomId: string
  - subject: string
  - score: number (0-20)
  - termId: string
  - date: timestamp
```

### Report Cards Collection
```
report_cards/{reportCardId}
  - studentId: string
  - termId: string
  - overallAverage: number
  - rank: number
  - subjectGrades: array
  - teacherComment: string
  - directorComment: string
```

### Attendance Collection
```
attendance/{attendanceId}
  - studentId: string
  - classroomId: string
  - date: timestamp
  - status: string
  - isJustified: boolean
```

---

## 🔐 Permissions

### Culture Permissions (New)
- `viewCulture` - Voir contenu culturel
- `createCultureContent` - Créer contenu
- `editCultureContent` - Modifier contenu
- `deleteCultureContent` - Supprimer contenu

### Educational Permissions (Suggested)
- `viewGrades` - Voir notes
- `createGrades` - Saisir notes
- `viewAttendance` - Voir présences
- `manageAttendance` - Gérer présences
- `viewReportCards` - Voir bulletins
- `generateReportCards` - Générer bulletins
- `manageClassrooms` - Gérer classes
- `manageSchools` - Gérer établissements

---

## 📖 Usage Examples

### Complete Classroom Scenario

```dart
// 1. Créer une école
final school = School(
  id: 'school_yaounde_001',
  name: 'École Primaire et Secondaire de Yaoundé',
  code: 'MINEDUC_YDE_001',
  type: SchoolType.publique,
  address: 'Avenue Kennedy',
  city: 'Yaoundé',
  region: 'Centre',
  phoneNumber: '+237 222 123 456',
  directorId: 'director_john',
  foundedDate: DateTime(1980, 9, 1),
  maxCapacity: 1200,
  status: SchoolStatus.active,
);

// 2. Créer une classe
final classroom = Classroom(
  id: 'class_6eme_a',
  schoolId: school.id,
  name: '6ème A',
  gradeLevel: GradeLevel.sixieme,
  academicYear: '2024-2025',
  teacherId: 'teacher_marie',
  maxCapacity: 40,
  room: 'Salle 12',
  status: ClassroomStatus.active,
);

// 3. Créer un devoir
final homework = Homework(
  id: 'hw_001',
  classroomId: classroom.id,
  teacherId: 'teacher_marie',
  subject: 'Ewondo',
  title: 'Vocabulaire des Salutations',
  description: 'Apprendre et pratiquer les salutations en Ewondo',
  assignedDate: DateTime.now(),
  dueDate: DateTime.now().add(Duration(days: 7)),
  maxPoints: 20.0,
  isGraded: true,
);

// 4. Noter un élève
final grade = Grade(
  id: 'grade_001',
  studentId: 'student_paul',
  classroomId: classroom.id,
  subject: 'Ewondo',
  assessmentType: 'homework',
  score: 17.0,
  termId: '2024-2025_term1',
  date: DateTime.now(),
  teacherId: 'teacher_marie',
  comment: 'Excellent travail!',
);

print('Note: ${grade.score}/20');
print('Appréciation: ${grade.appreciation}'); // "Très Bien"

// 5. Générer bulletin
final reportCard = ReportCard(
  id: 'report_paul_t1',
  studentId: 'student_paul',
  classroomId: classroom.id,
  termId: '2024-2025_term1',
  subjectGrades: [
    SubjectGrade(
      subject: 'Ewondo',
      average: 17.0,
      coefficient: '3',
      appreciation: 'Très Bien',
    ),
  ],
  overallAverage: 16.5,
  rank: 2,
  totalStudents: 38,
  generalComment: 'Élève sérieux et travailleur',
  generatedDate: DateTime.now(),
);
```

---

## 🔄 State Management Integration

### Using with Provider

```dart
// Access from ViewModel
final gradeLevel = context.read<StudentProfileViewModel>().gradeLevel;
final complexity = ContentFilterService.getRecommendedComplexity(
  gradeLevel: gradeLevel,
  performanceScore: studentScore,
);

// Filter lessons
final filteredLessons = lessons.where((lesson) {
  return ContentFilterService.isContentAppropriate(
    studentGrade: gradeLevel,
    contentComplexity: lesson.complexity,
  );
}).toList();
```

---

## 📱 API Endpoints (Future Firebase Functions)

### Schools
- `POST /api/schools` - Créer école
- `GET /api/schools/{id}` - Récupérer école
- `PUT /api/schools/{id}` - Modifier école
- `DELETE /api/schools/{id}` - Supprimer école
- `GET /api/schools` - Liste écoles

### Classrooms
- `POST /api/classrooms` - Créer classe
- `GET /api/classrooms/{id}` - Récupérer classe
- `PUT /api/classrooms/{id}` - Modifier classe
- `GET /api/schools/{schoolId}/classrooms` - Classes d'une école

### Grades
- `POST /api/grades` - Créer note
- `GET /api/students/{studentId}/grades` - Notes élève
- `GET /api/classrooms/{classroomId}/grades` - Notes classe
- `PUT /api/grades/{id}` - Modifier note

### Report Cards
- `POST /api/report-cards/generate` - Générer bulletin
- `GET /api/students/{studentId}/report-cards` - Bulletins élève
- `GET /api/report-cards/{id}/pdf` - Télécharger PDF

### Attendance
- `POST /api/attendance` - Créer présence
- `GET /api/classrooms/{classroomId}/attendance/{date}` - Présences du jour
- `GET /api/students/{studentId}/attendance` - Présences élève

---

## ✅ Best Practices

### Data Validation
```dart
// Always validate before saving
if (classroom.isFull) {
  throw Exception('Classe pleine');
}

// Check grade validity
if (grade.score < 0 || grade.score > grade.maxScore) {
  throw Exception('Note invalide');
}

// Validate academic year format
final yearRegex = RegExp(r'^\d{4}-\d{4}$');
if (!yearRegex.hasMatch(academicYear)) {
  throw Exception('Format année invalide');
}
```

### Error Handling
```dart
try {
  final reportCard = await generateReportCard(studentId, termId);
  print('Bulletin généré: ${reportCard.id}');
} catch (e) {
  print('Erreur génération bulletin: $e');
  // Handle error appropriately
}
```

---

**Documentation mise à jour:** 7 octobre 2025  
**Version API:** 2.0.0  
**Statut:** Models Complete, Endpoints Pending

