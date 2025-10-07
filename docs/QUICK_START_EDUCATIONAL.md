# 🚀 Guide de Démarrage Rapide - Système Éducatif

**Ma'a Yegue v2.0 - Educational Platform**

---

## 🎯 Pour qui est ce guide?

- **Développeurs** ajoutant des fonctionnalités éducatives
- **Designers** créant les interfaces enseignants/parents
- **Intégrateurs Backend** configurant Firebase
- **Testeurs** validant le système scolaire

---

## 📚 Concepts Clés

### 1. Hiérarchie Éducative

```
Cameroun (Nation)
    └── Régions (10)
        └── Écoles (School)
            └── Classes (Classroom)
                └── Élèves (Student)
```

### 2. Année Académique

```
2024-2025
├── 1er Trimestre: Sept 1 → Déc 15
├── 2ème Trimestre: Jan 5 → Avr 5
└── 3ème Trimestre: Avr 15 → Juil 10
```

### 3. Notation

```
Note /20 → Pourcentage → Lettre → Appréciation
17/20 → 85% → B → "Très Bien"
```

---

## 🛠️ Utilisation Rapide

### Importer les Modèles

```dart
// Modèles éducatifs
import 'package:mayegue/core/models/educational_models.dart';

// Modèles enseignants
import 'package:mayegue/features/teacher/data/models/teacher_models.dart';

// Modèles parents
import 'package:mayegue/features/parent/data/models/parent_models.dart';

// Services
import 'package:mayegue/core/services/content_filter_service.dart';
import 'package:mayegue/core/services/academic_calendar_service.dart';
```

---

### Créer une École

```dart
final school = School(
  id: 'school_001',
  name: 'École Primaire de Yaoundé',
  code: 'MINEDUC_YDE_001',
  type: SchoolType.publique,
  address: 'Quartier Bastos',
  city: 'Yaoundé',
  region: 'Centre',
  phoneNumber: '+237 222 123 456',
  email: 'contact@ecole-yaounde.cm',
  directorId: 'user_director_001',
  foundedDate: DateTime(1990, 9, 1),
  maxCapacity: 600,
  currentEnrollment: 485,
  status: SchoolStatus.active,
);

// Sauvegarder dans Firebase
await FirebaseFirestore.instance
    .collection('schools')
    .doc(school.id)
    .set(school.toJson());
```

---

### Créer une Classe

```dart
final classroom = Classroom(
  id: 'class_cm2_a',
  schoolId: 'school_001',
  name: 'CM2 A',
  gradeLevel: GradeLevel.cm2,
  academicYear: '2024-2025',
  teacherId: 'teacher_marie',
  studentIds: [],
  maxCapacity: 35,
  room: 'Salle 5',
  status: ClassroomStatus.active,
);

await FirebaseFirestore.instance
    .collection('classrooms')
    .doc(classroom.id)
    .set(classroom.toJson());
```

---

### Affecter des Élèves

```dart
// Ajouter un élève
final updatedStudentIds = [...classroom.studentIds, 'student_new_001'];

if (updatedStudentIds.length <= classroom.maxCapacity) {
  await FirebaseFirestore.instance
      .collection('classrooms')
      .doc(classroom.id)
      .update({'studentIds': updatedStudentIds});
} else {
  throw Exception('Classe pleine');
}
```

---

### Créer une Note

```dart
final grade = Grade(
  id: 'grade_${DateTime.now().millisecondsSinceEpoch}',
  studentId: 'student_paul_001',
  classroomId: 'class_cm2_a',
  subject: 'Ewondo',
  assessmentType: 'exam',
  score: 16.5,
  maxScore: 20.0,
  termId: '2024-2025_term1',
  date: DateTime.now(),
  teacherId: 'teacher_marie',
  comment: 'Excellent travail!',
);

// Afficher résultats
print('Note: ${grade.score}/${grade.maxScore}');
print('Pourcentage: ${grade.percentage}%');
print('Lettre: ${grade.letterGrade}');
print('Appréciation: ${grade.appreciation}');

// Sauvegarder
await FirebaseFirestore.instance
    .collection('grades')
    .doc(grade.id)
    .set(grade.toJson());
```

---

### Générer un Bulletin

```dart
// 1. Récupérer toutes les notes de l'élève pour le trimestre
final gradesSnapshot = await FirebaseFirestore.instance
    .collection('grades')
    .where('studentId', isEqualTo: 'student_paul_001')
    .where('termId', isEqualTo: '2024-2025_term1')
    .get();

// 2. Grouper par matière et calculer moyennes
final Map<String, List<double>> scoresBySubject = {};
for (final doc in gradesSnapshot.docs) {
  final grade = Grade.fromJson(doc.data());
  scoresBySubject.putIfAbsent(grade.subject, () => []);
  scoresBySubject[grade.subject]!.add(grade.score);
}

final subjectGrades = scoresBySubject.entries.map((entry) {
  final avg = entry.value.reduce((a, b) => a + b) / entry.value.length;
  return SubjectGrade(
    subject: entry.key,
    average: avg,
    coefficient: '2',
    appreciation: _getAppreciation(avg),
  );
}).toList();

// 3. Calculer moyenne générale
final overallAvg = subjectGrades
    .map((sg) => sg.average)
    .reduce((a, b) => a + b) / subjectGrades.length;

// 4. Calculer rang (simulé)
final rank = 3;
final totalStudents = 35;

// 5. Générer bulletin
final reportCard = ReportCard(
  id: 'report_paul_t1_2024',
  studentId: 'student_paul_001',
  classroomId: 'class_cm2_a',
  termId: '2024-2025_term1',
  subjectGrades: subjectGrades,
  overallAverage: overallAvg,
  rank: rank,
  totalStudents: totalStudents,
  generalComment: 'Élève sérieux et appliqué',
  teacherComment: 'Continuez ainsi!',
  directorComment: 'Félicitations',
  generatedDate: DateTime.now(),
);

await FirebaseFirestore.instance
    .collection('report_cards')
    .doc(reportCard.id)
    .set(reportCard.toJson());
```

---

### Filtrer Contenu par Âge

```dart
// Obtenir niveau de l'élève
final studentGrade = GradeLevel.sixieme;

// Complexité recommandée basée sur performance
final recommended = ContentFilterService.getRecommendedComplexity(
  gradeLevel: studentGrade,
  performanceScore: 85.0, // Élève performant
);
print(recommended); // ContentComplexity.advanced

// Filtrer leçons
final lessons = await getLessons();
final appropriateLessons = lessons.where((lesson) {
  return ContentFilterService.isContentAppropriate(
    studentGrade: studentGrade,
    contentComplexity: lesson.complexity,
    allowHigherComplexity: true, // Permettre +1 niveau
  );
}).toList();

// Temps de lecture estimé
final readingTime = ContentFilterService.getEstimatedReadingTime(
  content: lessonContent,
  gradeLevel: studentGrade,
);
print('Temps de lecture: $readingTime minutes');
```

---

### Gérer Présences

```dart
// Marquer présent
final attendance = AttendanceRecord(
  id: 'att_${DateTime.now().millisecondsSinceEpoch}',
  studentId: 'student_paul_001',
  classroomId: 'class_cm2_a',
  date: DateTime.now(),
  status: AttendanceStatus.present,
);

await FirebaseFirestore.instance
    .collection('attendance')
    .doc(attendance.id)
    .set(attendance.toJson());

// Marquer absent avec justification
final excused = AttendanceRecord(
  id: 'att_${DateTime.now().millisecondsSinceEpoch}',
  studentId: 'student_marie_002',
  classroomId: 'class_cm2_a',
  date: DateTime.now(),
  status: AttendanceStatus.excused,
  reason: 'Rendez-vous médical',
  isJustified: true,
  justificationDocument: 'url_to_medical_certificate',
);
```

---

### Créer un Devoir

```dart
final homework = Homework(
  id: 'hw_${DateTime.now().millisecondsSinceEpoch}',
  classroomId: 'class_cm2_a',
  teacherId: 'teacher_marie',
  subject: 'Ewondo',
  title: 'Les Salutations en Ewondo',
  description: '''
    Apprenez et pratiquez les salutations de base:
    1. Mbolo (Bonjour)
    2. Meh (Au revoir)
    3. Merci beaucoup (Akiba mingi)
    
    Exercice: Créez 5 phrases de dialogue.
  ''',
  assignedDate: DateTime.now(),
  dueDate: DateTime.now().add(Duration(days: 7)),
  maxPoints: 20.0,
  isGraded: true,
);

await FirebaseFirestore.instance
    .collection('homework')
    .doc(homework.id)
    .set(homework.toJson());
```

---

### Communication Parent-Enseignant

```dart
// Envoyer message
final message = ParentTeacherMessage(
  id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
  senderId: 'parent_jean_001',
  recipientId: 'teacher_marie',
  studentId: 'student_paul_001',
  subject: 'Question sur les devoirs d\'Ewondo',
  message: 'Bonjour, pourriez-vous m\'expliquer...',
  sentDate: DateTime.now(),
  priority: MessagePriority.normal,
);

await FirebaseFirestore.instance
    .collection('parent_teacher_messages')
    .doc(message.id)
    .set(message.toJson());

// Planifier rendez-vous
final meeting = ParentTeacherMeeting(
  id: 'meet_${DateTime.now().millisecondsSinceEpoch}',
  parentId: 'parent_jean_001',
  teacherId: 'teacher_marie',
  studentId: 'student_paul_001',
  scheduledDate: DateTime.now().add(Duration(days: 3)),
  duration: '30 minutes',
  mode: MeetingMode.inPerson,
  location: 'Salle des professeurs',
  purpose: 'Discussion progression Ewondo',
  status: MeetingStatus.scheduled,
);

await FirebaseFirestore.instance
    .collection('parent_teacher_meetings')
    .doc(meeting.id)
    .set(meeting.toJson());
```

---

### Calendrier Académique

```dart
// Année actuelle
final academicYear = AcademicCalendarService.getCurrentAcademicYear();
print(academicYear); // "2024-2025"

// Trimestre actuel
final currentTerm = AcademicCalendarService.getCurrentTerm();
print(currentTerm?.name); // "1er Trimestre"

// Générer tous les trimestres
final terms = AcademicCalendarService.generateCameroonTerms(academicYear);

// Vérifier jour d'école
final today = DateTime.now();
if (AcademicCalendarService.isSchoolDay(today)) {
  print('Jour d\'école');
} else {
  print('Week-end ou vacances');
}

// Prochain événement
final nextEvent = AcademicCalendarService.getNextEvent();
print('Prochain: ${nextEvent?.name} - ${nextEvent?.date}');

// Progression du trimestre
final progress = AcademicCalendarService.getTermProgress(currentTerm!);
print('Trimestre complété à ${progress.toStringAsFixed(1)}%');
```

---

## 🎨 Exemples UI (À Implémenter)

### Dashboard Enseignant

```dart
class TeacherDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dashboard Enseignant')),
      body: Column(
        children: [
          // Classes
          ClassroomsList(),
          
          // Présences du jour
          TodayAttendanceCard(),
          
          // Devoirs à corriger
          PendingHomeworkCard(),
          
          // Prochain événement
          NextEventCard(),
        ],
      ),
    );
  }
}
```

### Portail Parent

```dart
class ParentPortal extends StatelessWidget {
  final String studentId;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Suivi de mon enfant')),
      body: ListView(
        children: [
          // Résumé progression
          StudentProgressCard(studentId: studentId),
          
          // Notes récentes
          RecentGradesCard(studentId: studentId),
          
          // Présences
          AttendanceSummaryCard(studentId: studentId),
          
          // Messages
          MessagesCard(studentId: studentId),
          
          // Rendez-vous
          UpcomingMeetingsCard(studentId: studentId),
        ],
      ),
    );
  }
}
```

---

## 🔥 Fonctionnalités Avancées

### Calcul Automatique de Rang

```dart
Future<int> calculateClassRank(String studentId, String termId) async {
  // 1. Récupérer moyenne de l'élève
  final studentAvg = await getStudentAverage(studentId, termId);
  
  // 2. Récupérer moyennes de tous les élèves
  final classroom = await getStudentClassroom(studentId);
  final allAverages = await Future.wait(
    classroom.studentIds.map((id) => getStudentAverage(id, termId)),
  );
  
  // 3. Trier et trouver rang
  allAverages.sort((a, b) => b.compareTo(a)); // Décroissant
  return allAverages.indexOf(studentAvg) + 1;
}
```

### Recommandations Intelligentes

```dart
ContentComplexity getSmartRecommendation(Student student) {
  // Performance actuelle
  final perf = student.currentPerformance; // 0-100
  
  // Complexité recommandée
  return ContentFilterService.getRecommendedComplexity(
    gradeLevel: student.gradeLevel,
    performanceScore: perf,
  );
  
  // Si perf >= 90: +1 niveau
  // Si perf < 50: -1 niveau
  // Sinon: niveau standard pour la classe
}
```

### Validation Contenu

```dart
ValidationResult validateLesson(String content, GradeLevel grade) {
  return ContentFilterService.validateLessonContent(
    lessonContent: content,
    targetGrade: grade,
  );
}

// Utilisation
final result = validateLesson(myLessonText, GradeLevel.ce2);
if (!result.isValid) {
  print('Problème: ${result.message}');
  print('Suggestions:');
  result.suggestions.forEach(print);
}
```

---

## 📊 Queries Firestore Courantes

### Récupérer Classes d'une École

```dart
final classrooms = await FirebaseFirestore.instance
    .collection('classrooms')
    .where('schoolId', isEqualTo: 'school_001')
    .where('academicYear', isEqualTo: '2024-2025')
    .get();

final classroomList = classrooms.docs
    .map((doc) => Classroom.fromJson(doc.data()))
    .toList();
```

### Récupérer Notes d'un Élève

```dart
final grades = await FirebaseFirestore.instance
    .collection('grades')
    .where('studentId', isEqualTo: 'student_paul_001')
    .where('termId', isEqualTo: '2024-2025_term1')
    .orderBy('date', descending: true)
    .get();

final gradeList = grades.docs
    .map((doc) => Grade.fromJson(doc.data()))
    .toList();
```

### Récupérer Présences du Jour

```dart
final today = DateTime.now();
final startOfDay = DateTime(today.year, today.month, today.day);
final endOfDay = startOfDay.add(Duration(days: 1));

final attendance = await FirebaseFirestore.instance
    .collection('attendance')
    .where('classroomId', isEqualTo: 'class_cm2_a')
    .where('date', isGreaterThanOrEqualTo: startOfDay)
    .where('date', isLessThan: endOfDay)
    .get();

final records = attendance.docs
    .map((doc) => AttendanceRecord.fromJson(doc.data()))
    .toList();

// Statistiques
final present = records.where((r) => r.status == AttendanceStatus.present).length;
final absent = records.where((r) => r.status == AttendanceStatus.absent).length;
print('Présents: $present, Absents: $absent');
```

---

## 🎯 Prochaines Étapes

### Pour Développeurs
1. Lire [API Reference Éducation](API_REFERENCE_EDUCATIONAL.md)
2. Lire [Architecture Détaillée](ARCHITECTURE_DETAILLEE_FR.md)
3. Implémenter les UI manquantes
4. Intégrer Firebase backend

### Pour Designers
1. Créer maquettes dashboard enseignant
2. Créer maquettes portail parent
3. Adapter UI par âge (CP vs Terminale)
4. Design bulletins scolaires

### Pour Testeurs
1. Tester création école/classe
2. Tester saisie notes
3. Tester génération bulletins
4. Tester communication parent-prof
5. Tester filtrage par âge

---

## 🚀 Ressources Utiles

- [Système Éducatif Complet](EDUCATIONAL_SYSTEM_UPDATE.md)
- [Features Summary](FEATURES_SUMMARY.md)
- [Changelog](CHANGELOG.md)
- [Améliorations Futures](AMELIORATIONS_FUTURES_FR.md)

---

**Guide créé:** 7 octobre 2025  
**Version:** 2.0.0  
**Statut:** Fondation Complete - UI Pending

