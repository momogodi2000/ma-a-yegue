import 'package:equatable/equatable.dart';

/// Teacher entity representing a teacher in the e-learning platform
class TeacherEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String? profileImageUrl;
  final String specialization;
  final String bio;
  final List<String> languages;
  final int yearsOfExperience;
  final double rating;
  final int totalStudents;
  final int totalCourses;
  final List<String> certifications;
  final TeacherStatus status;
  final DateTime joinedAt;
  final DateTime lastActiveAt;
  final Map<String, dynamic> preferences;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TeacherEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    this.profileImageUrl,
    required this.specialization,
    required this.bio,
    required this.languages,
    required this.yearsOfExperience,
    required this.rating,
    required this.totalStudents,
    required this.totalCourses,
    required this.certifications,
    required this.status,
    required this.joinedAt,
    required this.lastActiveAt,
    required this.preferences,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    email,
    profileImageUrl,
    specialization,
    bio,
    languages,
    yearsOfExperience,
    rating,
    totalStudents,
    totalCourses,
    certifications,
    status,
    joinedAt,
    lastActiveAt,
    preferences,
    createdAt,
    updatedAt,
  ];
}

/// Course entity for teacher's courses
class CourseEntity extends Equatable {
  final String id;
  final String teacherId;
  final String title;
  final String description;
  final String languageCode;
  final String languageName;
  final String level;
  final List<String> topics;
  final List<String> lessonIds;
  final String thumbnailUrl;
  final double price;
  final int estimatedDuration; // in minutes
  final int enrolledStudents;
  final double rating;
  final CourseStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  const CourseEntity({
    required this.id,
    required this.teacherId,
    required this.title,
    required this.description,
    required this.languageCode,
    required this.languageName,
    required this.level,
    required this.topics,
    required this.lessonIds,
    required this.thumbnailUrl,
    required this.price,
    required this.estimatedDuration,
    required this.enrolledStudents,
    required this.rating,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.metadata,
  });

  /// Get lesson count from lessonIds
  int get lessonCount => lessonIds.length;

  @override
  List<Object?> get props => [
    id,
    teacherId,
    title,
    description,
    languageCode,
    languageName,
    level,
    topics,
    lessonIds,
    thumbnailUrl,
    price,
    estimatedDuration,
    enrolledStudents,
    rating,
    status,
    createdAt,
    updatedAt,
    metadata,
  ];
}

/// Lesson entity for teacher's lessons
class LessonEntity extends Equatable {
  final String id;
  final String courseId;
  final String teacherId;
  final String title;
  final String description;
  final String content;
  final String type; // video, text, audio, interactive
  final String? mediaUrl;
  final int duration; // in minutes
  final int order;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  const LessonEntity({
    required this.id,
    required this.courseId,
    required this.teacherId,
    required this.title,
    required this.description,
    required this.content,
    required this.type,
    this.mediaUrl,
    required this.duration,
    required this.order,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
    required this.metadata,
  });

  @override
  List<Object?> get props => [
    id,
    courseId,
    teacherId,
    title,
    description,
    content,
    type,
    mediaUrl,
    duration,
    order,
    isPublished,
    createdAt,
    updatedAt,
    metadata,
  ];
}

/// Student entity for teacher's students
class StudentEntity extends Equatable {
  final String id;
  final String userId;
  final String name;
  final String email;
  final String? profileImageUrl;
  final String currentLevel;
  final int totalExperiencePoints;
  final DateTime joinedAt;
  final DateTime lastActiveAt;
  final Map<String, StudentProgress> languageProgress;
  final List<String> enrolledCourses;
  final List<String> completedCourses;
  final Map<String, dynamic> metadata;

  const StudentEntity({
    required this.id,
    required this.userId,
    required this.name,
    required this.email,
    this.profileImageUrl,
    required this.currentLevel,
    required this.totalExperiencePoints,
    required this.joinedAt,
    required this.lastActiveAt,
    required this.languageProgress,
    required this.enrolledCourses,
    required this.completedCourses,
    required this.metadata,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    email,
    profileImageUrl,
    currentLevel,
    totalExperiencePoints,
    joinedAt,
    lastActiveAt,
    languageProgress,
    enrolledCourses,
    completedCourses,
    metadata,
  ];
}

/// Student progress entity
class StudentProgress extends Equatable {
  final String languageCode;
  final String languageName;
  final String currentLevel;
  final int experiencePoints;
  final int lessonsCompleted;
  final int coursesCompleted;
  final double accuracy;
  final int studyTimeMinutes;
  final DateTime lastStudiedAt;
  final List<String> completedLessons;
  final List<String> completedCourses;
  final Map<String, double> skillScores;

  const StudentProgress({
    required this.languageCode,
    required this.languageName,
    required this.currentLevel,
    required this.experiencePoints,
    required this.lessonsCompleted,
    required this.coursesCompleted,
    required this.accuracy,
    required this.studyTimeMinutes,
    required this.lastStudiedAt,
    required this.completedLessons,
    required this.completedCourses,
    required this.skillScores,
  });

  @override
  List<Object?> get props => [
    languageCode,
    languageName,
    currentLevel,
    experiencePoints,
    lessonsCompleted,
    coursesCompleted,
    accuracy,
    studyTimeMinutes,
    lastStudiedAt,
    completedLessons,
    completedCourses,
    skillScores,
  ];
}

/// Assignment entity
class AssignmentEntity extends Equatable {
  final String id;
  final String courseId;
  final String teacherId;
  final String title;
  final String description;
  final String instructions;
  final AssignmentType type;
  final List<QuestionEntity> questions;
  final int timeLimit; // in minutes
  final int totalPoints;
  final DateTime dueDate;
  final bool isPublished;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, dynamic> metadata;

  const AssignmentEntity({
    required this.id,
    required this.courseId,
    required this.teacherId,
    required this.title,
    required this.description,
    required this.instructions,
    required this.type,
    required this.questions,
    required this.timeLimit,
    required this.totalPoints,
    required this.dueDate,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
    required this.metadata,
  });

  /// Get submission count from metadata
  int get submissionCount => (metadata['submissionCount'] as int?) ?? 0;

  @override
  List<Object?> get props => [
    id,
    courseId,
    teacherId,
    title,
    description,
    instructions,
    type,
    questions,
    timeLimit,
    totalPoints,
    dueDate,
    isPublished,
    createdAt,
    updatedAt,
    metadata,
  ];
}

/// Question entity for assignments
class QuestionEntity extends Equatable {
  final String id;
  final String assignmentId;
  final String question;
  final QuestionType type;
  final List<String> options; // for multiple choice
  final List<String> correctAnswers;
  final int points;
  final String? explanation;
  final int order;
  final Map<String, dynamic> metadata;

  const QuestionEntity({
    required this.id,
    required this.assignmentId,
    required this.question,
    required this.type,
    required this.options,
    required this.correctAnswers,
    required this.points,
    this.explanation,
    required this.order,
    required this.metadata,
  });

  @override
  List<Object?> get props => [
    id,
    assignmentId,
    question,
    type,
    options,
    correctAnswers,
    points,
    explanation,
    order,
    metadata,
  ];
}

/// Submission entity for student submissions
class SubmissionEntity extends Equatable {
  final String id;
  final String assignmentId;
  final String studentId;
  final String studentName;
  final List<AnswerEntity> answers;
  final int score;
  final int totalPoints;
  final SubmissionStatus status;
  final DateTime submittedAt;
  final DateTime? gradedAt;
  final String? feedback;
  final Map<String, dynamic> metadata;

  const SubmissionEntity({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    required this.studentName,
    required this.answers,
    required this.score,
    required this.totalPoints,
    required this.status,
    required this.submittedAt,
    this.gradedAt,
    this.feedback,
    required this.metadata,
  });

  @override
  List<Object?> get props => [
    id,
    assignmentId,
    studentId,
    studentName,
    answers,
    score,
    totalPoints,
    status,
    submittedAt,
    gradedAt,
    feedback,
    metadata,
  ];
}

/// Answer entity for student answers
class AnswerEntity extends Equatable {
  final String id;
  final String questionId;
  final String submissionId;
  final List<String> selectedAnswers;
  final String? textAnswer;
  final bool isCorrect;
  final int pointsEarned;
  final Map<String, dynamic> metadata;

  const AnswerEntity({
    required this.id,
    required this.questionId,
    required this.submissionId,
    required this.selectedAnswers,
    this.textAnswer,
    required this.isCorrect,
    required this.pointsEarned,
    required this.metadata,
  });

  @override
  List<Object?> get props => [
    id,
    questionId,
    submissionId,
    selectedAnswers,
    textAnswer,
    isCorrect,
    pointsEarned,
    metadata,
  ];
}

/// Grade entity for student grades
class GradeEntity extends Equatable {
  final String id;
  final String studentId;
  final String courseId;
  final String assignmentId;
  final String assignmentTitle;
  final int score;
  final int totalPoints;
  final double percentage;
  final GradeLetter grade;
  final String? feedback;
  final DateTime gradedAt;
  final Map<String, dynamic> metadata;

  const GradeEntity({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.assignmentId,
    required this.assignmentTitle,
    required this.score,
    required this.totalPoints,
    required this.percentage,
    required this.grade,
    this.feedback,
    required this.gradedAt,
    required this.metadata,
  });

  @override
  List<Object?> get props => [
    id,
    studentId,
    courseId,
    assignmentId,
    assignmentTitle,
    score,
    totalPoints,
    percentage,
    grade,
    feedback,
    gradedAt,
    metadata,
  ];
}

/// Analytics entity for teacher analytics
class TeacherAnalyticsEntity extends Equatable {
  final String teacherId;
  final int totalCourses;
  final int totalStudents;
  final int totalLessons;
  final int totalAssignments;
  final double averageRating;
  final Map<String, int> studentEngagement; // by language
  final Map<String, double> coursePerformance; // courseId -> completion rate
  final Map<String, int>
  assignmentSubmissions; // assignmentId -> submission count
  final double completionRate;
  final int averageTimeSpent; // in minutes
  final double studentSatisfaction; // 0-5 scale
  final DateTime lastUpdated;
  final Map<String, dynamic> metadata;

  const TeacherAnalyticsEntity({
    required this.teacherId,
    required this.totalCourses,
    required this.totalStudents,
    required this.totalLessons,
    required this.totalAssignments,
    required this.averageRating,
    required this.studentEngagement,
    required this.coursePerformance,
    required this.assignmentSubmissions,
    required this.completionRate,
    required this.averageTimeSpent,
    required this.studentSatisfaction,
    required this.lastUpdated,
    required this.metadata,
  });

  /// Get completed lessons count from metadata
  int get totalCompletedLessons =>
      (metadata['totalCompletedLessons'] as int?) ?? 0;

  /// Get in-progress lessons count from metadata
  int get totalInProgressLessons =>
      (metadata['totalInProgressLessons'] as int?) ?? 0;

  /// Get not started lessons count from metadata
  int get totalNotStartedLessons =>
      (metadata['totalNotStartedLessons'] as int?) ?? 0;

  /// Get active courses count from metadata
  int get totalActiveCourses => (metadata['totalActiveCourses'] as int?) ?? 0;

  /// Get pending courses count from metadata
  int get totalPendingCourses => (metadata['totalPendingCourses'] as int?) ?? 0;

  /// Get archived courses count from metadata
  int get totalArchivedCourses =>
      (metadata['totalArchivedCourses'] as int?) ?? 0;

  @override
  List<Object?> get props => [
    teacherId,
    totalCourses,
    totalStudents,
    totalLessons,
    totalAssignments,
    averageRating,
    studentEngagement,
    coursePerformance,
    assignmentSubmissions,
    completionRate,
    averageTimeSpent,
    studentSatisfaction,
    lastUpdated,
    metadata,
  ];
}

// Enums
enum TeacherStatus { active, inactive, suspended, pending }

enum CourseStatus { draft, published, archived, suspended }

enum AssignmentType { quiz, homework, exam, project, discussion }

enum QuestionType {
  multipleChoice,
  trueFalse,
  shortAnswer,
  essay,
  fillInTheBlank,
  matching,
}

enum SubmissionStatus { draft, submitted, graded, returned }

enum GradeLetter {
  aPlus,
  a,
  aMinus,
  bPlus,
  b,
  bMinus,
  cPlus,
  c,
  cMinus,
  dPlus,
  d,
  dMinus,
  f,
}
