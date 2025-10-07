/// Parent portal models for student tracking and communication

/// Parent-Student relationship
class ParentStudentRelation {
  final String id;
  final String parentId;
  final String studentId;
  final ParentRelationType relationType;
  final bool isPrimary; // Primary guardian
  final bool canViewGrades;
  final bool canViewAttendance;
  final bool canReceiveNotifications;
  final DateTime createdDate;

  const ParentStudentRelation({
    required this.id,
    required this.parentId,
    required this.studentId,
    required this.relationType,
    this.isPrimary = true,
    this.canViewGrades = true,
    this.canViewAttendance = true,
    this.canReceiveNotifications = true,
    required this.createdDate,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'parentId': parentId,
    'studentId': studentId,
    'relationType': relationType.name,
    'isPrimary': isPrimary,
    'canViewGrades': canViewGrades,
    'canViewAttendance': canViewAttendance,
    'canReceiveNotifications': canReceiveNotifications,
    'createdDate': createdDate.toIso8601String(),
  };

  factory ParentStudentRelation.fromJson(Map<String, dynamic> json) =>
      ParentStudentRelation(
        id: json['id'] as String,
        parentId: json['parentId'] as String,
        studentId: json['studentId'] as String,
        relationType: ParentRelationType.values.byName(
          json['relationType'] as String,
        ),
        isPrimary: json['isPrimary'] as bool? ?? true,
        canViewGrades: json['canViewGrades'] as bool? ?? true,
        canViewAttendance: json['canViewAttendance'] as bool? ?? true,
        canReceiveNotifications:
            json['canReceiveNotifications'] as bool? ?? true,
        createdDate: DateTime.parse(json['createdDate'] as String),
      );
}

enum ParentRelationType {
  mother('Mère'),
  father('Père'),
  guardian('Tuteur Légal'),
  grandparent('Grand-parent'),
  other('Autre');

  const ParentRelationType(this.displayName);
  final String displayName;
}

/// Parent-Teacher communication message
class ParentTeacherMessage {
  final String id;
  final String senderId; // Parent or Teacher ID
  final String recipientId;
  final String studentId;
  final String subject;
  final String message;
  final DateTime sentDate;
  final bool isRead;
  final String? threadId; // For message threads
  final List<String>? attachments;
  final MessagePriority priority;

  const ParentTeacherMessage({
    required this.id,
    required this.senderId,
    required this.recipientId,
    required this.studentId,
    required this.subject,
    required this.message,
    required this.sentDate,
    this.isRead = false,
    this.threadId,
    this.attachments,
    this.priority = MessagePriority.normal,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'senderId': senderId,
    'recipientId': recipientId,
    'studentId': studentId,
    'subject': subject,
    'message': message,
    'sentDate': sentDate.toIso8601String(),
    'isRead': isRead,
    'threadId': threadId,
    'attachments': attachments,
    'priority': priority.name,
  };

  factory ParentTeacherMessage.fromJson(Map<String, dynamic> json) =>
      ParentTeacherMessage(
        id: json['id'] as String,
        senderId: json['senderId'] as String,
        recipientId: json['recipientId'] as String,
        studentId: json['studentId'] as String,
        subject: json['subject'] as String,
        message: json['message'] as String,
        sentDate: DateTime.parse(json['sentDate'] as String),
        isRead: json['isRead'] as bool? ?? false,
        threadId: json['threadId'] as String?,
        attachments: (json['attachments'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        priority: MessagePriority.values.byName(
          json['priority'] as String? ?? 'normal',
        ),
      );
}

enum MessagePriority {
  low('Faible'),
  normal('Normal'),
  high('Élevé'),
  urgent('Urgent');

  const MessagePriority(this.displayName);
  final String displayName;
}

/// School announcement/circular
class SchoolAnnouncement {
  final String id;
  final String schoolId;
  final String title;
  final String content;
  final AnnouncementType type;
  final DateTime publishDate;
  final DateTime? expiryDate;
  final String authorId; // Director or Admin
  final bool sendNotification;
  final List<String>? attachments;
  final List<String> targetGradeLevels; // Empty = all grades

  const SchoolAnnouncement({
    required this.id,
    required this.schoolId,
    required this.title,
    required this.content,
    required this.type,
    required this.publishDate,
    this.expiryDate,
    required this.authorId,
    this.sendNotification = true,
    this.attachments,
    this.targetGradeLevels = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'schoolId': schoolId,
    'title': title,
    'content': content,
    'type': type.name,
    'publishDate': publishDate.toIso8601String(),
    'expiryDate': expiryDate?.toIso8601String(),
    'authorId': authorId,
    'sendNotification': sendNotification,
    'attachments': attachments,
    'targetGradeLevels': targetGradeLevels,
  };

  factory SchoolAnnouncement.fromJson(Map<String, dynamic> json) =>
      SchoolAnnouncement(
        id: json['id'] as String,
        schoolId: json['schoolId'] as String,
        title: json['title'] as String,
        content: json['content'] as String,
        type: AnnouncementType.values.byName(json['type'] as String),
        publishDate: DateTime.parse(json['publishDate'] as String),
        expiryDate: json['expiryDate'] != null
            ? DateTime.parse(json['expiryDate'] as String)
            : null,
        authorId: json['authorId'] as String,
        sendNotification: json['sendNotification'] as bool? ?? true,
        attachments: (json['attachments'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        targetGradeLevels:
            (json['targetGradeLevels'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
      );
}

enum AnnouncementType {
  general('Général'),
  academic('Académique'),
  event('Événement'),
  holiday('Vacances'),
  urgent('Urgent'),
  meeting('Réunion');

  const AnnouncementType(this.displayName);
  final String displayName;
}

/// Parent-Teacher meeting appointment
class ParentTeacherMeeting {
  final String id;
  final String parentId;
  final String teacherId;
  final String studentId;
  final DateTime scheduledDate;
  final String duration; // e.g., "30 minutes"
  final MeetingMode mode; // In-person or virtual
  final String? location; // Room or video link
  final String purpose;
  final MeetingStatus status;
  final String? notes;
  final String? outcome;

  const ParentTeacherMeeting({
    required this.id,
    required this.parentId,
    required this.teacherId,
    required this.studentId,
    required this.scheduledDate,
    this.duration = '30 minutes',
    required this.mode,
    this.location,
    required this.purpose,
    this.status = MeetingStatus.scheduled,
    this.notes,
    this.outcome,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'parentId': parentId,
    'teacherId': teacherId,
    'studentId': studentId,
    'scheduledDate': scheduledDate.toIso8601String(),
    'duration': duration,
    'mode': mode.name,
    'location': location,
    'purpose': purpose,
    'status': status.name,
    'notes': notes,
    'outcome': outcome,
  };

  factory ParentTeacherMeeting.fromJson(Map<String, dynamic> json) =>
      ParentTeacherMeeting(
        id: json['id'] as String,
        parentId: json['parentId'] as String,
        teacherId: json['teacherId'] as String,
        studentId: json['studentId'] as String,
        scheduledDate: DateTime.parse(json['scheduledDate'] as String),
        duration: json['duration'] as String? ?? '30 minutes',
        mode: MeetingMode.values.byName(json['mode'] as String),
        location: json['location'] as String?,
        purpose: json['purpose'] as String,
        status: MeetingStatus.values.byName(
          json['status'] as String? ?? 'scheduled',
        ),
        notes: json['notes'] as String?,
        outcome: json['outcome'] as String?,
      );
}

enum MeetingMode {
  inPerson('En Personne'),
  virtual('Virtuel'),
  phone('Téléphone');

  const MeetingMode(this.displayName);
  final String displayName;
}

enum MeetingStatus {
  scheduled('Planifié'),
  confirmed('Confirmé'),
  completed('Terminé'),
  cancelled('Annulé'),
  rescheduled('Reporté');

  const MeetingStatus(this.displayName);
  final String displayName;
}

/// Student progress summary for parent view
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
  final List<String> strengths; // Strong subjects
  final List<String> areasForImprovement;
  final String teacherComment;
  final DateTime lastUpdated;

  const StudentProgressSummary({
    required this.studentId,
    required this.academicYear,
    required this.termId,
    required this.overallAverage,
    required this.classRank,
    required this.totalStudents,
    required this.subjectAverages,
    required this.totalAbsences,
    required this.justifiedAbsences,
    required this.tardyCount,
    required this.strengths,
    required this.areasForImprovement,
    required this.teacherComment,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() => {
    'studentId': studentId,
    'academicYear': academicYear,
    'termId': termId,
    'overallAverage': overallAverage,
    'classRank': classRank,
    'totalStudents': totalStudents,
    'subjectAverages': subjectAverages,
    'totalAbsences': totalAbsences,
    'justifiedAbsences': justifiedAbsences,
    'tardyCount': tardyCount,
    'strengths': strengths,
    'areasForImprovement': areasForImprovement,
    'teacherComment': teacherComment,
    'lastUpdated': lastUpdated.toIso8601String(),
  };

  factory StudentProgressSummary.fromJson(Map<String, dynamic> json) =>
      StudentProgressSummary(
        studentId: json['studentId'] as String,
        academicYear: json['academicYear'] as String,
        termId: json['termId'] as String,
        overallAverage: (json['overallAverage'] as num).toDouble(),
        classRank: json['classRank'] as int,
        totalStudents: json['totalStudents'] as int,
        subjectAverages: Map<String, double>.from(
          (json['subjectAverages'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(key, (value as num).toDouble()),
          ),
        ),
        totalAbsences: json['totalAbsences'] as int,
        justifiedAbsences: json['justifiedAbsences'] as int,
        tardyCount: json['tardyCount'] as int,
        strengths: (json['strengths'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        areasForImprovement: (json['areasForImprovement'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        teacherComment: json['teacherComment'] as String,
        lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      );
}
