/// Educational system models for Ma'a Yegue E-Learning Platform
/// Addresses CRITICAL_ANALYSIS recommendations for school integration

/// Grade levels following Cameroon educational system
enum GradeLevel {
  // Primaire (6 ans - 11 ans)
  cp('CP', 'Cours Préparatoire', 1, EducationLevel.primaire, 6),
  ce1('CE1', 'Cours Élémentaire 1', 2, EducationLevel.primaire, 7),
  ce2('CE2', 'Cours Élémentaire 2', 3, EducationLevel.primaire, 8),
  cm1('CM1', 'Cours Moyen 1', 4, EducationLevel.primaire, 9),
  cm2('CM2', 'Cours Moyen 2', 5, EducationLevel.primaire, 10),

  // Secondaire 1er Cycle (12 ans - 15 ans)
  sixieme('6ème', 'Sixième', 6, EducationLevel.secondaire1, 11),
  cinquieme('5ème', 'Cinquième', 7, EducationLevel.secondaire1, 12),
  quatrieme('4ème', 'Quatrième', 8, EducationLevel.secondaire1, 13),
  troisieme('3ème', 'Troisième', 9, EducationLevel.secondaire1, 14),

  // Secondaire 2nd Cycle (16 ans - 18 ans)
  seconde('2nde', 'Seconde', 10, EducationLevel.secondaire2, 15),
  premiere('1ère', 'Première', 11, EducationLevel.secondaire2, 16),
  terminale('Tle', 'Terminale', 12, EducationLevel.secondaire2, 17);

  const GradeLevel(
    this.code,
    this.fullName,
    this.level,
    this.educationLevel,
    this.typicalAge,
  );

  final String code;
  final String fullName;
  final int level;
  final EducationLevel educationLevel;
  final int typicalAge;

  bool get isPrimaire => educationLevel == EducationLevel.primaire;
  bool get isSecondaire =>
      educationLevel == EducationLevel.secondaire1 ||
      educationLevel == EducationLevel.secondaire2;
}

/// Education level categories
enum EducationLevel {
  primaire('Primaire', 'Primary Education', 1),
  secondaire1('Secondaire 1er Cycle', 'Lower Secondary', 2),
  secondaire2('Secondaire 2nd Cycle', 'Upper Secondary', 3);

  const EducationLevel(this.nameFr, this.nameEn, this.order);

  final String nameFr;
  final String nameEn;
  final int order;
}

/// User profile extension for educational context
/// Works with existing 4 roles: visitor, learner, teacher, admin
class StudentProfile {
  final String userId;
  final GradeLevel gradeLevel;
  final String? schoolId;
  final String? classroomId;
  final String academicYear;

  const StudentProfile({
    required this.userId,
    required this.gradeLevel,
    this.schoolId,
    this.classroomId,
    required this.academicYear,
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'gradeLevel': gradeLevel.code,
    'schoolId': schoolId,
    'classroomId': classroomId,
    'academicYear': academicYear,
  };

  factory StudentProfile.fromJson(Map<String, dynamic> json) => StudentProfile(
    userId: json['userId'] as String,
    gradeLevel: GradeLevel.values.firstWhere(
      (e) => e.code == json['gradeLevel'],
      orElse: () => GradeLevel.cp,
    ),
    schoolId: json['schoolId'] as String?,
    classroomId: json['classroomId'] as String?,
    academicYear: json['academicYear'] as String,
  );
}

/// Teacher profile extension
/// Role: teacher (from existing UserRole)
class TeacherProfile {
  final String userId;
  final String? schoolId;
  final List<String> classroomIds;
  final List<String> subjects;

  const TeacherProfile({
    required this.userId,
    this.schoolId,
    this.classroomIds = const [],
    this.subjects = const [],
  });

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'schoolId': schoolId,
    'classroomIds': classroomIds,
    'subjects': subjects,
  };

  factory TeacherProfile.fromJson(Map<String, dynamic> json) => TeacherProfile(
    userId: json['userId'] as String,
    schoolId: json['schoolId'] as String?,
    classroomIds:
        (json['classroomIds'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        const [],
    subjects:
        (json['subjects'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        const [],
  );
}

/// Parent info as metadata on learner profile
class ParentInfo {
  final String parentName;
  final String parentEmail;
  final String parentPhone;
  final String relationType; // mother, father, guardian

  const ParentInfo({
    required this.parentName,
    required this.parentEmail,
    required this.parentPhone,
    required this.relationType,
  });

  Map<String, dynamic> toJson() => {
    'parentName': parentName,
    'parentEmail': parentEmail,
    'parentPhone': parentPhone,
    'relationType': relationType,
  };

  factory ParentInfo.fromJson(Map<String, dynamic> json) => ParentInfo(
    parentName: json['parentName'] as String,
    parentEmail: json['parentEmail'] as String,
    parentPhone: json['parentPhone'] as String,
    relationType: json['relationType'] as String,
  );
}

/// School/Establishment entity
/// Managed by admin role
class School {
  final String id;
  final String name;
  final String code; // Unique identifier from MINEDUC
  final SchoolType type;
  final String address;
  final String city;
  final String region;
  final String phoneNumber;
  final String? email;
  final String? website;
  final String directorId; // Admin user ID managing this school
  final List<String> teacherIds; // List of teacher IDs in this school
  final DateTime foundedDate;
  final int maxCapacity;
  final int currentEnrollment;
  final SchoolStatus status;
  final Map<String, dynamic> metadata;

  const School({
    required this.id,
    required this.name,
    required this.code,
    required this.type,
    required this.address,
    required this.city,
    required this.region,
    required this.phoneNumber,
    this.email,
    this.website,
    required this.directorId,
    this.teacherIds = const [],
    required this.foundedDate,
    required this.maxCapacity,
    this.currentEnrollment = 0,
    this.status = SchoolStatus.active,
    this.metadata = const {},
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'code': code,
    'type': type.name,
    'address': address,
    'city': city,
    'region': region,
    'phoneNumber': phoneNumber,
    'email': email,
    'website': website,
    'directorId': directorId,
    'teacherIds': teacherIds,
    'foundedDate': foundedDate.toIso8601String(),
    'maxCapacity': maxCapacity,
    'currentEnrollment': currentEnrollment,
    'status': status.name,
    'metadata': metadata,
  };

  factory School.fromJson(Map<String, dynamic> json) => School(
    id: json['id'] as String,
    name: json['name'] as String,
    code: json['code'] as String,
    type: SchoolType.values.byName(json['type'] as String),
    address: json['address'] as String,
    city: json['city'] as String,
    region: json['region'] as String,
    phoneNumber: json['phoneNumber'] as String,
    email: json['email'] as String?,
    website: json['website'] as String?,
    directorId: json['directorId'] as String,
    teacherIds:
        (json['teacherIds'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        const [],
    foundedDate: DateTime.parse(json['foundedDate'] as String),
    maxCapacity: json['maxCapacity'] as int,
    currentEnrollment: json['currentEnrollment'] as int? ?? 0,
    status: SchoolStatus.values.byName(json['status'] as String? ?? 'active'),
    metadata: json['metadata'] as Map<String, dynamic>? ?? const {},
  );
}

enum SchoolType {
  publique('École Publique'),
  privee('École Privée'),
  confessionnelle('École Confessionnelle'),
  internationale('École Internationale');

  const SchoolType(this.displayName);
  final String displayName;
}

enum SchoolStatus {
  active,
  inactive,
  suspended,
  underReview;

  String get displayName {
    switch (this) {
      case SchoolStatus.active:
        return 'Active';
      case SchoolStatus.inactive:
        return 'Inactive';
      case SchoolStatus.suspended:
        return 'Suspendue';
      case SchoolStatus.underReview:
        return 'En Révision';
    }
  }
}

/// Classroom entity
class Classroom {
  final String id;
  final String schoolId;
  final String name; // e.g., "6ème A", "CM2 B"
  final GradeLevel gradeLevel;
  final String academicYear; // e.g., "2024-2025"
  final String teacherId; // Main teacher/form teacher
  final List<String> studentIds;
  final int maxCapacity;
  final String? room; // Physical room number
  final Map<String, dynamic> schedule; // Weekly schedule
  final ClassroomStatus status;

  const Classroom({
    required this.id,
    required this.schoolId,
    required this.name,
    required this.gradeLevel,
    required this.academicYear,
    required this.teacherId,
    this.studentIds = const [],
    this.maxCapacity = 40,
    this.room,
    this.schedule = const {},
    this.status = ClassroomStatus.active,
  });

  int get currentEnrollment => studentIds.length;
  bool get isFull => currentEnrollment >= maxCapacity;

  Map<String, dynamic> toJson() => {
    'id': id,
    'schoolId': schoolId,
    'name': name,
    'gradeLevel': gradeLevel.code,
    'academicYear': academicYear,
    'teacherId': teacherId,
    'studentIds': studentIds,
    'maxCapacity': maxCapacity,
    'room': room,
    'schedule': schedule,
    'status': status.name,
  };

  factory Classroom.fromJson(Map<String, dynamic> json) => Classroom(
    id: json['id'] as String,
    schoolId: json['schoolId'] as String,
    name: json['name'] as String,
    gradeLevel: GradeLevel.values.firstWhere(
      (e) => e.code == json['gradeLevel'],
      orElse: () => GradeLevel.cp,
    ),
    academicYear: json['academicYear'] as String,
    teacherId: json['teacherId'] as String,
    studentIds:
        (json['studentIds'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        const [],
    maxCapacity: json['maxCapacity'] as int? ?? 40,
    room: json['room'] as String?,
    schedule: json['schedule'] as Map<String, dynamic>? ?? const {},
    status: ClassroomStatus.values.byName(
      json['status'] as String? ?? 'active',
    ),
  );
}

enum ClassroomStatus {
  active,
  archived,
  suspended;

  String get displayName {
    switch (this) {
      case ClassroomStatus.active:
        return 'Active';
      case ClassroomStatus.archived:
        return 'Archivée';
      case ClassroomStatus.suspended:
        return 'Suspendue';
    }
  }
}

/// Academic term/trimester
class AcademicTerm {
  final String id;
  final String name; // "1er Trimestre", "2ème Trimestre", "3ème Trimestre"
  final int termNumber; // 1, 2, 3
  final String academicYear;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  const AcademicTerm({
    required this.id,
    required this.name,
    required this.termNumber,
    required this.academicYear,
    required this.startDate,
    required this.endDate,
    this.isActive = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'termNumber': termNumber,
    'academicYear': academicYear,
    'startDate': startDate.toIso8601String(),
    'endDate': endDate.toIso8601String(),
    'isActive': isActive,
  };

  factory AcademicTerm.fromJson(Map<String, dynamic> json) => AcademicTerm(
    id: json['id'] as String,
    name: json['name'] as String,
    termNumber: json['termNumber'] as int,
    academicYear: json['academicYear'] as String,
    startDate: DateTime.parse(json['startDate'] as String),
    endDate: DateTime.parse(json['endDate'] as String),
    isActive: json['isActive'] as bool? ?? false,
  );
}

/// Student grade/note (score /20 Cameroon system)
class Grade {
  final String id;
  final String studentId;
  final String classroomId;
  final String subject; // Language code or subject
  final String assessmentType; // 'quiz', 'exam', 'homework', 'project'
  final double score; // Out of 20
  final double maxScore; // Usually 20
  final String termId;
  final DateTime date;
  final String? teacherId;
  final String? comment;

  const Grade({
    required this.id,
    required this.studentId,
    required this.classroomId,
    required this.subject,
    required this.assessmentType,
    required this.score,
    this.maxScore = 20.0,
    required this.termId,
    required this.date,
    this.teacherId,
    this.comment,
  });

  double get percentage => (score / maxScore) * 100;

  String get letterGrade {
    final percent = percentage;
    if (percent >= 90) return 'A';
    if (percent >= 80) return 'B';
    if (percent >= 70) return 'C';
    if (percent >= 60) return 'D';
    if (percent >= 50) return 'E';
    return 'F';
  }

  String get appreciation {
    final percent = percentage;
    if (percent >= 90) return 'Excellent';
    if (percent >= 80) return 'Très Bien';
    if (percent >= 70) return 'Bien';
    if (percent >= 60) return 'Assez Bien';
    if (percent >= 50) return 'Passable';
    return 'Insuffisant';
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'studentId': studentId,
    'classroomId': classroomId,
    'subject': subject,
    'assessmentType': assessmentType,
    'score': score,
    'maxScore': maxScore,
    'termId': termId,
    'date': date.toIso8601String(),
    'teacherId': teacherId,
    'comment': comment,
  };

  factory Grade.fromJson(Map<String, dynamic> json) => Grade(
    id: json['id'] as String,
    studentId: json['studentId'] as String,
    classroomId: json['classroomId'] as String,
    subject: json['subject'] as String,
    assessmentType: json['assessmentType'] as String,
    score: (json['score'] as num).toDouble(),
    maxScore: (json['maxScore'] as num?)?.toDouble() ?? 20.0,
    termId: json['termId'] as String,
    date: DateTime.parse(json['date'] as String),
    teacherId: json['teacherId'] as String?,
    comment: json['comment'] as String?,
  );
}

/// Report card/bulletin scolaire
class ReportCard {
  final String id;
  final String studentId;
  final String classroomId;
  final String termId;
  final List<SubjectGrade> subjectGrades;
  final double overallAverage;
  final int rank; // Class rank
  final int totalStudents;
  final String generalComment;
  final String? teacherComment;
  final String? directorComment;
  final DateTime generatedDate;

  const ReportCard({
    required this.id,
    required this.studentId,
    required this.classroomId,
    required this.termId,
    required this.subjectGrades,
    required this.overallAverage,
    required this.rank,
    required this.totalStudents,
    required this.generalComment,
    this.teacherComment,
    this.directorComment,
    required this.generatedDate,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'studentId': studentId,
    'classroomId': classroomId,
    'termId': termId,
    'subjectGrades': subjectGrades.map((e) => e.toJson()).toList(),
    'overallAverage': overallAverage,
    'rank': rank,
    'totalStudents': totalStudents,
    'generalComment': generalComment,
    'teacherComment': teacherComment,
    'directorComment': directorComment,
    'generatedDate': generatedDate.toIso8601String(),
  };

  factory ReportCard.fromJson(Map<String, dynamic> json) => ReportCard(
    id: json['id'] as String,
    studentId: json['studentId'] as String,
    classroomId: json['classroomId'] as String,
    termId: json['termId'] as String,
    subjectGrades: (json['subjectGrades'] as List<dynamic>)
        .map((e) => SubjectGrade.fromJson(e as Map<String, dynamic>))
        .toList(),
    overallAverage: (json['overallAverage'] as num).toDouble(),
    rank: json['rank'] as int,
    totalStudents: json['totalStudents'] as int,
    generalComment: json['generalComment'] as String,
    teacherComment: json['teacherComment'] as String?,
    directorComment: json['directorComment'] as String?,
    generatedDate: DateTime.parse(json['generatedDate'] as String),
  );
}

class SubjectGrade {
  final String subject;
  final double average;
  final String coefficient;
  final String appreciation;
  final String? teacherComment;

  const SubjectGrade({
    required this.subject,
    required this.average,
    required this.coefficient,
    required this.appreciation,
    this.teacherComment,
  });

  Map<String, dynamic> toJson() => {
    'subject': subject,
    'average': average,
    'coefficient': coefficient,
    'appreciation': appreciation,
    'teacherComment': teacherComment,
  };

  factory SubjectGrade.fromJson(Map<String, dynamic> json) => SubjectGrade(
    subject: json['subject'] as String,
    average: (json['average'] as num).toDouble(),
    coefficient: json['coefficient'] as String,
    appreciation: json['appreciation'] as String,
    teacherComment: json['teacherComment'] as String?,
  );
}

/// Attendance record
class AttendanceRecord {
  final String id;
  final String studentId;
  final String classroomId;
  final DateTime date;
  final AttendanceStatus status;
  final String? reason;
  final bool isJustified;
  final String? justificationDocument;

  const AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.classroomId,
    required this.date,
    required this.status,
    this.reason,
    this.isJustified = false,
    this.justificationDocument,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'studentId': studentId,
    'classroomId': classroomId,
    'date': date.toIso8601String(),
    'status': status.name,
    'reason': reason,
    'isJustified': isJustified,
    'justificationDocument': justificationDocument,
  };

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      AttendanceRecord(
        id: json['id'] as String,
        studentId: json['studentId'] as String,
        classroomId: json['classroomId'] as String,
        date: DateTime.parse(json['date'] as String),
        status: AttendanceStatus.values.byName(json['status'] as String),
        reason: json['reason'] as String?,
        isJustified: json['isJustified'] as bool? ?? false,
        justificationDocument: json['justificationDocument'] as String?,
      );
}

enum AttendanceStatus {
  present('Présent'),
  absent('Absent'),
  late('Retard'),
  excused('Excusé');

  const AttendanceStatus(this.displayName);
  final String displayName;
}
