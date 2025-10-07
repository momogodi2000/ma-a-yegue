/// Teacher-specific models for classroom management

/// Teacher assignment to classroom/subject
class TeacherAssignment {
  final String id;
  final String teacherId;
  final String classroomId;
  final String subject; // Language or subject taught
  final bool isFormTeacher; // Main teacher for the class
  final int weeklyHours;
  final String academicYear;

  const TeacherAssignment({
    required this.id,
    required this.teacherId,
    required this.classroomId,
    required this.subject,
    this.isFormTeacher = false,
    required this.weeklyHours,
    required this.academicYear,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'teacherId': teacherId,
    'classroomId': classroomId,
    'subject': subject,
    'isFormTeacher': isFormTeacher,
    'weeklyHours': weeklyHours,
    'academicYear': academicYear,
  };

  factory TeacherAssignment.fromJson(Map<String, dynamic> json) =>
      TeacherAssignment(
        id: json['id'] as String,
        teacherId: json['teacherId'] as String,
        classroomId: json['classroomId'] as String,
        subject: json['subject'] as String,
        isFormTeacher: json['isFormTeacher'] as bool? ?? false,
        weeklyHours: json['weeklyHours'] as int,
        academicYear: json['academicYear'] as String,
      );
}

/// Class schedule/timetable
class ClassSchedule {
  final String id;
  final String classroomId;
  final DayOfWeek day;
  final String startTime; // HH:mm format
  final String endTime;
  final String subject;
  final String teacherId;
  final String? room;

  const ClassSchedule({
    required this.id,
    required this.classroomId,
    required this.day,
    required this.startTime,
    required this.endTime,
    required this.subject,
    required this.teacherId,
    this.room,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'classroomId': classroomId,
    'day': day.name,
    'startTime': startTime,
    'endTime': endTime,
    'subject': subject,
    'teacherId': teacherId,
    'room': room,
  };

  factory ClassSchedule.fromJson(Map<String, dynamic> json) => ClassSchedule(
    id: json['id'] as String,
    classroomId: json['classroomId'] as String,
    day: DayOfWeek.values.byName(json['day'] as String),
    startTime: json['startTime'] as String,
    endTime: json['endTime'] as String,
    subject: json['subject'] as String,
    teacherId: json['teacherId'] as String,
    room: json['room'] as String?,
  );
}

enum DayOfWeek {
  monday('Lundi'),
  tuesday('Mardi'),
  wednesday('Mercredi'),
  thursday('Jeudi'),
  friday('Vendredi'),
  saturday('Samedi');

  const DayOfWeek(this.displayName);
  final String displayName;
}

/// Homework/Devoirs assignment
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

  const Homework({
    required this.id,
    required this.classroomId,
    required this.teacherId,
    required this.subject,
    required this.title,
    required this.description,
    required this.assignedDate,
    required this.dueDate,
    this.attachments,
    this.maxPoints = 20.0,
    this.isGraded = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'classroomId': classroomId,
    'teacherId': teacherId,
    'subject': subject,
    'title': title,
    'description': description,
    'assignedDate': assignedDate.toIso8601String(),
    'dueDate': dueDate.toIso8601String(),
    'attachments': attachments,
    'maxPoints': maxPoints,
    'isGraded': isGraded,
  };

  factory Homework.fromJson(Map<String, dynamic> json) => Homework(
    id: json['id'] as String,
    classroomId: json['classroomId'] as String,
    teacherId: json['teacherId'] as String,
    subject: json['subject'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    assignedDate: DateTime.parse(json['assignedDate'] as String),
    dueDate: DateTime.parse(json['dueDate'] as String),
    attachments: (json['attachments'] as List<dynamic>?)
        ?.map((e) => e as String)
        .toList(),
    maxPoints: (json['maxPoints'] as num?)?.toDouble() ?? 20.0,
    isGraded: json['isGraded'] as bool? ?? true,
  );
}

/// Homework submission
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

  const HomeworkSubmission({
    required this.id,
    required this.homeworkId,
    required this.studentId,
    required this.submittedDate,
    this.content,
    this.attachments,
    this.grade,
    this.feedback,
    this.status = SubmissionStatus.submitted,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'homeworkId': homeworkId,
    'studentId': studentId,
    'submittedDate': submittedDate.toIso8601String(),
    'content': content,
    'attachments': attachments,
    'grade': grade,
    'feedback': feedback,
    'status': status.name,
  };

  factory HomeworkSubmission.fromJson(Map<String, dynamic> json) =>
      HomeworkSubmission(
        id: json['id'] as String,
        homeworkId: json['homeworkId'] as String,
        studentId: json['studentId'] as String,
        submittedDate: DateTime.parse(json['submittedDate'] as String),
        content: json['content'] as String?,
        attachments: (json['attachments'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        grade: (json['grade'] as num?)?.toDouble(),
        feedback: json['feedback'] as String?,
        status: SubmissionStatus.values.byName(
          json['status'] as String? ?? 'submitted',
        ),
      );
}

enum SubmissionStatus {
  draft,
  submitted,
  graded,
  late,
  missing;

  String get displayName {
    switch (this) {
      case SubmissionStatus.draft:
        return 'Brouillon';
      case SubmissionStatus.submitted:
        return 'Soumis';
      case SubmissionStatus.graded:
        return 'Corrigé';
      case SubmissionStatus.late:
        return 'En Retard';
      case SubmissionStatus.missing:
        return 'Non Remis';
    }
  }
}

/// Lesson plan/cahier de textes
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
  final int duration; // in minutes

  const LessonPlan({
    required this.id,
    required this.classroomId,
    required this.teacherId,
    required this.subject,
    required this.date,
    required this.topic,
    required this.objectives,
    required this.content,
    required this.materials,
    this.homework,
    this.duration = 60,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'classroomId': classroomId,
    'teacherId': teacherId,
    'subject': subject,
    'date': date.toIso8601String(),
    'topic': topic,
    'objectives': objectives,
    'content': content,
    'materials': materials,
    'homework': homework,
    'duration': duration,
  };

  factory LessonPlan.fromJson(Map<String, dynamic> json) => LessonPlan(
    id: json['id'] as String,
    classroomId: json['classroomId'] as String,
    teacherId: json['teacherId'] as String,
    subject: json['subject'] as String,
    date: DateTime.parse(json['date'] as String),
    topic: json['topic'] as String,
    objectives: json['objectives'] as String,
    content: json['content'] as String,
    materials: json['materials'] as String,
    homework: json['homework'] as String?,
    duration: json['duration'] as int? ?? 60,
  );
}

/// Student behavior/conduct note
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

  const ConductNote({
    required this.id,
    required this.studentId,
    required this.classroomId,
    required this.teacherId,
    required this.date,
    required this.type,
    required this.description,
    required this.severity,
    this.actionTaken,
    this.parentNotified = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'studentId': studentId,
    'classroomId': classroomId,
    'teacherId': teacherId,
    'date': date.toIso8601String(),
    'type': type.name,
    'description': description,
    'severity': severity.name,
    'actionTaken': actionTaken,
    'parentNotified': parentNotified,
  };

  factory ConductNote.fromJson(Map<String, dynamic> json) => ConductNote(
    id: json['id'] as String,
    studentId: json['studentId'] as String,
    classroomId: json['classroomId'] as String,
    teacherId: json['teacherId'] as String,
    date: DateTime.parse(json['date'] as String),
    type: ConductType.values.byName(json['type'] as String),
    description: json['description'] as String,
    severity: ConductSeverity.values.byName(json['severity'] as String),
    actionTaken: json['actionTaken'] as String?,
    parentNotified: json['parentNotified'] as bool? ?? false,
  );
}

enum ConductType {
  positive('Comportement Positif'),
  negative('Comportement Négatif'),
  warning('Avertissement'),
  achievement('Réussite');

  const ConductType(this.displayName);
  final String displayName;
}

enum ConductSeverity {
  minor('Mineur'),
  moderate('Modéré'),
  major('Majeur');

  const ConductSeverity(this.displayName);
  final String displayName;
}
