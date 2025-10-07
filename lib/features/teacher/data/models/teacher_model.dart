import '../../domain/entities/teacher_entity.dart';

/// Teacher data model for local storage and API communication
class TeacherModel extends TeacherEntity {
  const TeacherModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.email,
    super.profileImageUrl,
    required super.specialization,
    required super.bio,
    required super.languages,
    required super.yearsOfExperience,
    required super.rating,
    required super.totalStudents,
    required super.totalCourses,
    required super.certifications,
    required super.status,
    required super.joinedAt,
    required super.lastActiveAt,
    required super.preferences,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Convert from JSON
  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      specialization: json['specialization'] as String,
      bio: json['bio'] as String,
      languages: List<String>.from(json['languages'] as List),
      yearsOfExperience: json['yearsOfExperience'] as int,
      rating: (json['rating'] as num).toDouble(),
      totalStudents: json['totalStudents'] as int,
      totalCourses: json['totalCourses'] as int,
      certifications: List<String>.from(json['certifications'] as List),
      status: TeacherStatus.values.firstWhere((e) => e.name == json['status']),
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      lastActiveAt: DateTime.parse(json['lastActiveAt'] as String),
      preferences: json['preferences'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'specialization': specialization,
      'bio': bio,
      'languages': languages,
      'yearsOfExperience': yearsOfExperience,
      'rating': rating,
      'totalStudents': totalStudents,
      'totalCourses': totalCourses,
      'certifications': certifications,
      'status': status.name,
      'joinedAt': joinedAt.toIso8601String(),
      'lastActiveAt': lastActiveAt.toIso8601String(),
      'preferences': preferences,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create from entity
  factory TeacherModel.fromEntity(TeacherEntity entity) {
    return TeacherModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      email: entity.email,
      profileImageUrl: entity.profileImageUrl,
      specialization: entity.specialization,
      bio: entity.bio,
      languages: entity.languages,
      yearsOfExperience: entity.yearsOfExperience,
      rating: entity.rating,
      totalStudents: entity.totalStudents,
      totalCourses: entity.totalCourses,
      certifications: entity.certifications,
      status: entity.status,
      joinedAt: entity.joinedAt,
      lastActiveAt: entity.lastActiveAt,
      preferences: entity.preferences,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert to entity
  TeacherEntity toEntity() {
    return TeacherEntity(
      id: id,
      userId: userId,
      name: name,
      email: email,
      profileImageUrl: profileImageUrl,
      specialization: specialization,
      bio: bio,
      languages: languages,
      yearsOfExperience: yearsOfExperience,
      rating: rating,
      totalStudents: totalStudents,
      totalCourses: totalCourses,
      certifications: certifications,
      status: status,
      joinedAt: joinedAt,
      lastActiveAt: lastActiveAt,
      preferences: preferences,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

/// Course data model
class CourseModel extends CourseEntity {
  const CourseModel({
    required super.id,
    required super.teacherId,
    required super.title,
    required super.description,
    required super.languageCode,
    required super.languageName,
    required super.level,
    required super.topics,
    required super.lessonIds,
    required super.thumbnailUrl,
    required super.price,
    required super.estimatedDuration,
    required super.enrolledStudents,
    required super.rating,
    required super.status,
    required super.createdAt,
    required super.updatedAt,
    required super.metadata,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id'] as String,
      teacherId: json['teacherId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      languageCode: json['languageCode'] as String,
      languageName: json['languageName'] as String,
      level: json['level'] as String,
      topics: List<String>.from(json['topics'] as List),
      lessonIds: List<String>.from(json['lessonIds'] as List),
      thumbnailUrl: json['thumbnailUrl'] as String,
      price: (json['price'] as num).toDouble(),
      estimatedDuration: json['estimatedDuration'] as int,
      enrolledStudents: json['enrolledStudents'] as int,
      rating: (json['rating'] as num).toDouble(),
      status: CourseStatus.values.firstWhere((e) => e.name == json['status']),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'teacherId': teacherId,
      'title': title,
      'description': description,
      'languageCode': languageCode,
      'languageName': languageName,
      'level': level,
      'topics': topics,
      'lessonIds': lessonIds,
      'thumbnailUrl': thumbnailUrl,
      'price': price,
      'estimatedDuration': estimatedDuration,
      'enrolledStudents': enrolledStudents,
      'rating': rating,
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory CourseModel.fromEntity(CourseEntity entity) {
    return CourseModel(
      id: entity.id,
      teacherId: entity.teacherId,
      title: entity.title,
      description: entity.description,
      languageCode: entity.languageCode,
      languageName: entity.languageName,
      level: entity.level,
      topics: entity.topics,
      lessonIds: entity.lessonIds,
      thumbnailUrl: entity.thumbnailUrl,
      price: entity.price,
      estimatedDuration: entity.estimatedDuration,
      enrolledStudents: entity.enrolledStudents,
      rating: entity.rating,
      status: entity.status,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      metadata: entity.metadata,
    );
  }

  CourseEntity toEntity() {
    return CourseEntity(
      id: id,
      teacherId: teacherId,
      title: title,
      description: description,
      languageCode: languageCode,
      languageName: languageName,
      level: level,
      topics: topics,
      lessonIds: lessonIds,
      thumbnailUrl: thumbnailUrl,
      price: price,
      estimatedDuration: estimatedDuration,
      enrolledStudents: enrolledStudents,
      rating: rating,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      metadata: metadata,
    );
  }
}

/// Lesson data model
class LessonModel extends LessonEntity {
  const LessonModel({
    required super.id,
    required super.courseId,
    required super.teacherId,
    required super.title,
    required super.description,
    required super.content,
    required super.type,
    super.mediaUrl,
    required super.duration,
    required super.order,
    required super.isPublished,
    required super.createdAt,
    required super.updatedAt,
    required super.metadata,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] as String,
      courseId: json['courseId'] as String,
      teacherId: json['teacherId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      content: json['content'] as String,
      type: json['type'] as String,
      mediaUrl: json['mediaUrl'] as String?,
      duration: json['duration'] as int,
      order: json['order'] as int,
      isPublished: json['isPublished'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'teacherId': teacherId,
      'title': title,
      'description': description,
      'content': content,
      'type': type,
      'mediaUrl': mediaUrl,
      'duration': duration,
      'order': order,
      'isPublished': isPublished,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory LessonModel.fromEntity(LessonEntity entity) {
    return LessonModel(
      id: entity.id,
      courseId: entity.courseId,
      teacherId: entity.teacherId,
      title: entity.title,
      description: entity.description,
      content: entity.content,
      type: entity.type,
      mediaUrl: entity.mediaUrl,
      duration: entity.duration,
      order: entity.order,
      isPublished: entity.isPublished,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      metadata: entity.metadata,
    );
  }

  LessonEntity toEntity() {
    return LessonEntity(
      id: id,
      courseId: courseId,
      teacherId: teacherId,
      title: title,
      description: description,
      content: content,
      type: type,
      mediaUrl: mediaUrl,
      duration: duration,
      order: order,
      isPublished: isPublished,
      createdAt: createdAt,
      updatedAt: updatedAt,
      metadata: metadata,
    );
  }
}

/// Student data model
class StudentModel extends StudentEntity {
  const StudentModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.email,
    super.profileImageUrl,
    required super.currentLevel,
    required super.totalExperiencePoints,
    required super.joinedAt,
    required super.lastActiveAt,
    required super.languageProgress,
    required super.enrolledCourses,
    required super.completedCourses,
    required super.metadata,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      currentLevel: json['currentLevel'] as String,
      totalExperiencePoints: json['totalExperiencePoints'] as int,
      joinedAt: DateTime.parse(json['joinedAt'] as String),
      lastActiveAt: DateTime.parse(json['lastActiveAt'] as String),
      languageProgress: (json['languageProgress'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          StudentProgressModel.fromJson(value as Map<String, dynamic>),
        ),
      ),
      enrolledCourses: List<String>.from(json['enrolledCourses'] as List),
      completedCourses: List<String>.from(json['completedCourses'] as List),
      metadata: json['metadata'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'email': email,
      'profileImageUrl': profileImageUrl,
      'currentLevel': currentLevel,
      'totalExperiencePoints': totalExperiencePoints,
      'joinedAt': joinedAt.toIso8601String(),
      'lastActiveAt': lastActiveAt.toIso8601String(),
      'languageProgress': languageProgress.map(
        (key, value) => MapEntry(key, (value as StudentProgressModel).toJson()),
      ),
      'enrolledCourses': enrolledCourses,
      'completedCourses': completedCourses,
      'metadata': metadata,
    };
  }

  factory StudentModel.fromEntity(StudentEntity entity) {
    return StudentModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      email: entity.email,
      profileImageUrl: entity.profileImageUrl,
      currentLevel: entity.currentLevel,
      totalExperiencePoints: entity.totalExperiencePoints,
      joinedAt: entity.joinedAt,
      lastActiveAt: entity.lastActiveAt,
      languageProgress: entity.languageProgress.map(
        (key, value) => MapEntry(key, StudentProgressModel.fromEntity(value)),
      ),
      enrolledCourses: entity.enrolledCourses,
      completedCourses: entity.completedCourses,
      metadata: entity.metadata,
    );
  }

  StudentEntity toEntity() {
    return StudentEntity(
      id: id,
      userId: userId,
      name: name,
      email: email,
      profileImageUrl: profileImageUrl,
      currentLevel: currentLevel,
      totalExperiencePoints: totalExperiencePoints,
      joinedAt: joinedAt,
      lastActiveAt: lastActiveAt,
      languageProgress: languageProgress.map(
        (key, value) =>
            MapEntry(key, (value as StudentProgressModel).toEntity()),
      ),
      enrolledCourses: enrolledCourses,
      completedCourses: completedCourses,
      metadata: metadata,
    );
  }
}

/// Student progress data model
class StudentProgressModel extends StudentProgress {
  const StudentProgressModel({
    required super.languageCode,
    required super.languageName,
    required super.currentLevel,
    required super.experiencePoints,
    required super.lessonsCompleted,
    required super.coursesCompleted,
    required super.accuracy,
    required super.studyTimeMinutes,
    required super.lastStudiedAt,
    required super.completedLessons,
    required super.completedCourses,
    required super.skillScores,
  });

  factory StudentProgressModel.fromJson(Map<String, dynamic> json) {
    return StudentProgressModel(
      languageCode: json['languageCode'] as String,
      languageName: json['languageName'] as String,
      currentLevel: json['currentLevel'] as String,
      experiencePoints: json['experiencePoints'] as int,
      lessonsCompleted: json['lessonsCompleted'] as int,
      coursesCompleted: json['coursesCompleted'] as int,
      accuracy: (json['accuracy'] as num).toDouble(),
      studyTimeMinutes: json['studyTimeMinutes'] as int,
      lastStudiedAt: DateTime.parse(json['lastStudiedAt'] as String),
      completedLessons: List<String>.from(json['completedLessons'] as List),
      completedCourses: List<String>.from(json['completedCourses'] as List),
      skillScores: Map<String, double>.from(json['skillScores'] as Map),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'languageCode': languageCode,
      'languageName': languageName,
      'currentLevel': currentLevel,
      'experiencePoints': experiencePoints,
      'lessonsCompleted': lessonsCompleted,
      'coursesCompleted': coursesCompleted,
      'accuracy': accuracy,
      'studyTimeMinutes': studyTimeMinutes,
      'lastStudiedAt': lastStudiedAt.toIso8601String(),
      'completedLessons': completedLessons,
      'completedCourses': completedCourses,
      'skillScores': skillScores,
    };
  }

  factory StudentProgressModel.fromEntity(StudentProgress entity) {
    return StudentProgressModel(
      languageCode: entity.languageCode,
      languageName: entity.languageName,
      currentLevel: entity.currentLevel,
      experiencePoints: entity.experiencePoints,
      lessonsCompleted: entity.lessonsCompleted,
      coursesCompleted: entity.coursesCompleted,
      accuracy: entity.accuracy,
      studyTimeMinutes: entity.studyTimeMinutes,
      lastStudiedAt: entity.lastStudiedAt,
      completedLessons: entity.completedLessons,
      completedCourses: entity.completedCourses,
      skillScores: entity.skillScores,
    );
  }

  StudentProgress toEntity() {
    return StudentProgress(
      languageCode: languageCode,
      languageName: languageName,
      currentLevel: currentLevel,
      experiencePoints: experiencePoints,
      lessonsCompleted: lessonsCompleted,
      coursesCompleted: coursesCompleted,
      accuracy: accuracy,
      studyTimeMinutes: studyTimeMinutes,
      lastStudiedAt: lastStudiedAt,
      completedLessons: completedLessons,
      completedCourses: completedCourses,
      skillScores: skillScores,
    );
  }
}

/// Assignment data model
class AssignmentModel extends AssignmentEntity {
  const AssignmentModel({
    required super.id,
    required super.courseId,
    required super.teacherId,
    required super.title,
    required super.description,
    required super.instructions,
    required super.type,
    required super.questions,
    required super.timeLimit,
    required super.totalPoints,
    required super.dueDate,
    required super.isPublished,
    required super.createdAt,
    required super.updatedAt,
    required super.metadata,
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      id: json['id'] as String,
      courseId: json['courseId'] as String,
      teacherId: json['teacherId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      instructions: json['instructions'] as String,
      type: AssignmentType.values.firstWhere((e) => e.name == json['type']),
      questions: (json['questions'] as List)
          .map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
          .toList(),
      timeLimit: json['timeLimit'] as int,
      totalPoints: json['totalPoints'] as int,
      dueDate: DateTime.parse(json['dueDate'] as String),
      isPublished: json['isPublished'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'teacherId': teacherId,
      'title': title,
      'description': description,
      'instructions': instructions,
      'type': type.name,
      'questions': questions.map((q) => (q as QuestionModel).toJson()).toList(),
      'timeLimit': timeLimit,
      'totalPoints': totalPoints,
      'dueDate': dueDate.toIso8601String(),
      'isPublished': isPublished,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory AssignmentModel.fromEntity(AssignmentEntity entity) {
    return AssignmentModel(
      id: entity.id,
      courseId: entity.courseId,
      teacherId: entity.teacherId,
      title: entity.title,
      description: entity.description,
      instructions: entity.instructions,
      type: entity.type,
      questions: entity.questions
          .map((q) => QuestionModel.fromEntity(q))
          .toList(),
      timeLimit: entity.timeLimit,
      totalPoints: entity.totalPoints,
      dueDate: entity.dueDate,
      isPublished: entity.isPublished,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      metadata: entity.metadata,
    );
  }

  AssignmentEntity toEntity() {
    return AssignmentEntity(
      id: id,
      courseId: courseId,
      teacherId: teacherId,
      title: title,
      description: description,
      instructions: instructions,
      type: type,
      questions: questions.map((q) => (q as QuestionModel).toEntity()).toList(),
      timeLimit: timeLimit,
      totalPoints: totalPoints,
      dueDate: dueDate,
      isPublished: isPublished,
      createdAt: createdAt,
      updatedAt: updatedAt,
      metadata: metadata,
    );
  }
}

/// Question data model
class QuestionModel extends QuestionEntity {
  const QuestionModel({
    required super.id,
    required super.assignmentId,
    required super.question,
    required super.type,
    required super.options,
    required super.correctAnswers,
    required super.points,
    super.explanation,
    required super.order,
    required super.metadata,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String,
      assignmentId: json['assignmentId'] as String,
      question: json['question'] as String,
      type: QuestionType.values.firstWhere((e) => e.name == json['type']),
      options: List<String>.from(json['options'] as List),
      correctAnswers: List<String>.from(json['correctAnswers'] as List),
      points: json['points'] as int,
      explanation: json['explanation'] as String?,
      order: json['order'] as int,
      metadata: json['metadata'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assignmentId': assignmentId,
      'question': question,
      'type': type.name,
      'options': options,
      'correctAnswers': correctAnswers,
      'points': points,
      'explanation': explanation,
      'order': order,
      'metadata': metadata,
    };
  }

  factory QuestionModel.fromEntity(QuestionEntity entity) {
    return QuestionModel(
      id: entity.id,
      assignmentId: entity.assignmentId,
      question: entity.question,
      type: entity.type,
      options: entity.options,
      correctAnswers: entity.correctAnswers,
      points: entity.points,
      explanation: entity.explanation,
      order: entity.order,
      metadata: entity.metadata,
    );
  }

  QuestionEntity toEntity() {
    return QuestionEntity(
      id: id,
      assignmentId: assignmentId,
      question: question,
      type: type,
      options: options,
      correctAnswers: correctAnswers,
      points: points,
      explanation: explanation,
      order: order,
      metadata: metadata,
    );
  }
}

/// Submission data model
class SubmissionModel extends SubmissionEntity {
  const SubmissionModel({
    required super.id,
    required super.assignmentId,
    required super.studentId,
    required super.studentName,
    required super.answers,
    required super.score,
    required super.totalPoints,
    required super.status,
    required super.submittedAt,
    super.gradedAt,
    super.feedback,
    required super.metadata,
  });

  factory SubmissionModel.fromJson(Map<String, dynamic> json) {
    return SubmissionModel(
      id: json['id'] as String,
      assignmentId: json['assignmentId'] as String,
      studentId: json['studentId'] as String,
      studentName: json['studentName'] as String,
      answers: (json['answers'] as List)
          .map((a) => AnswerModel.fromJson(a as Map<String, dynamic>))
          .toList(),
      score: json['score'] as int,
      totalPoints: json['totalPoints'] as int,
      status: SubmissionStatus.values.firstWhere(
        (e) => e.name == json['status'],
      ),
      submittedAt: DateTime.parse(json['submittedAt'] as String),
      gradedAt: json['gradedAt'] != null
          ? DateTime.parse(json['gradedAt'] as String)
          : null,
      feedback: json['feedback'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assignmentId': assignmentId,
      'studentId': studentId,
      'studentName': studentName,
      'answers': answers.map((a) => (a as AnswerModel).toJson()).toList(),
      'score': score,
      'totalPoints': totalPoints,
      'status': status.name,
      'submittedAt': submittedAt.toIso8601String(),
      'gradedAt': gradedAt?.toIso8601String(),
      'feedback': feedback,
      'metadata': metadata,
    };
  }

  factory SubmissionModel.fromEntity(SubmissionEntity entity) {
    return SubmissionModel(
      id: entity.id,
      assignmentId: entity.assignmentId,
      studentId: entity.studentId,
      studentName: entity.studentName,
      answers: entity.answers.map((a) => AnswerModel.fromEntity(a)).toList(),
      score: entity.score,
      totalPoints: entity.totalPoints,
      status: entity.status,
      submittedAt: entity.submittedAt,
      gradedAt: entity.gradedAt,
      feedback: entity.feedback,
      metadata: entity.metadata,
    );
  }

  SubmissionEntity toEntity() {
    return SubmissionEntity(
      id: id,
      assignmentId: assignmentId,
      studentId: studentId,
      studentName: studentName,
      answers: answers.map((a) => (a as AnswerModel).toEntity()).toList(),
      score: score,
      totalPoints: totalPoints,
      status: status,
      submittedAt: submittedAt,
      gradedAt: gradedAt,
      feedback: feedback,
      metadata: metadata,
    );
  }
}

/// Answer data model
class AnswerModel extends AnswerEntity {
  const AnswerModel({
    required super.id,
    required super.questionId,
    required super.submissionId,
    required super.selectedAnswers,
    super.textAnswer,
    required super.isCorrect,
    required super.pointsEarned,
    required super.metadata,
  });

  factory AnswerModel.fromJson(Map<String, dynamic> json) {
    return AnswerModel(
      id: json['id'] as String,
      questionId: json['questionId'] as String,
      submissionId: json['submissionId'] as String,
      selectedAnswers: List<String>.from(json['selectedAnswers'] as List),
      textAnswer: json['textAnswer'] as String?,
      isCorrect: json['isCorrect'] as bool,
      pointsEarned: json['pointsEarned'] as int,
      metadata: json['metadata'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'questionId': questionId,
      'submissionId': submissionId,
      'selectedAnswers': selectedAnswers,
      'textAnswer': textAnswer,
      'isCorrect': isCorrect,
      'pointsEarned': pointsEarned,
      'metadata': metadata,
    };
  }

  factory AnswerModel.fromEntity(AnswerEntity entity) {
    return AnswerModel(
      id: entity.id,
      questionId: entity.questionId,
      submissionId: entity.submissionId,
      selectedAnswers: entity.selectedAnswers,
      textAnswer: entity.textAnswer,
      isCorrect: entity.isCorrect,
      pointsEarned: entity.pointsEarned,
      metadata: entity.metadata,
    );
  }

  AnswerEntity toEntity() {
    return AnswerEntity(
      id: id,
      questionId: questionId,
      submissionId: submissionId,
      selectedAnswers: selectedAnswers,
      textAnswer: textAnswer,
      isCorrect: isCorrect,
      pointsEarned: pointsEarned,
      metadata: metadata,
    );
  }
}

/// Grade data model
class GradeModel extends GradeEntity {
  const GradeModel({
    required super.id,
    required super.studentId,
    required super.courseId,
    required super.assignmentId,
    required super.assignmentTitle,
    required super.score,
    required super.totalPoints,
    required super.percentage,
    required super.grade,
    super.feedback,
    required super.gradedAt,
    required super.metadata,
  });

  factory GradeModel.fromJson(Map<String, dynamic> json) {
    return GradeModel(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      courseId: json['courseId'] as String,
      assignmentId: json['assignmentId'] as String,
      assignmentTitle: json['assignmentTitle'] as String,
      score: json['score'] as int,
      totalPoints: json['totalPoints'] as int,
      percentage: (json['percentage'] as num).toDouble(),
      grade: GradeLetter.values.firstWhere((e) => e.name == json['grade']),
      feedback: json['feedback'] as String?,
      gradedAt: DateTime.parse(json['gradedAt'] as String),
      metadata: json['metadata'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentId': studentId,
      'courseId': courseId,
      'assignmentId': assignmentId,
      'assignmentTitle': assignmentTitle,
      'score': score,
      'totalPoints': totalPoints,
      'percentage': percentage,
      'grade': grade.name,
      'feedback': feedback,
      'gradedAt': gradedAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory GradeModel.fromEntity(GradeEntity entity) {
    return GradeModel(
      id: entity.id,
      studentId: entity.studentId,
      courseId: entity.courseId,
      assignmentId: entity.assignmentId,
      assignmentTitle: entity.assignmentTitle,
      score: entity.score,
      totalPoints: entity.totalPoints,
      percentage: entity.percentage,
      grade: entity.grade,
      feedback: entity.feedback,
      gradedAt: entity.gradedAt,
      metadata: entity.metadata,
    );
  }

  GradeEntity toEntity() {
    return GradeEntity(
      id: id,
      studentId: studentId,
      courseId: courseId,
      assignmentId: assignmentId,
      assignmentTitle: assignmentTitle,
      score: score,
      totalPoints: totalPoints,
      percentage: percentage,
      grade: grade,
      feedback: feedback,
      gradedAt: gradedAt,
      metadata: metadata,
    );
  }
}

/// Teacher analytics data model
class TeacherAnalyticsModel extends TeacherAnalyticsEntity {
  const TeacherAnalyticsModel({
    required super.teacherId,
    required super.totalCourses,
    required super.totalStudents,
    required super.totalLessons,
    required super.totalAssignments,
    required super.averageRating,
    required super.studentEngagement,
    required super.coursePerformance,
    required super.assignmentSubmissions,
    required super.completionRate,
    required super.averageTimeSpent,
    required super.studentSatisfaction,
    required super.lastUpdated,
    required super.metadata,
  });

  factory TeacherAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return TeacherAnalyticsModel(
      teacherId: json['teacherId'] as String,
      totalCourses: json['totalCourses'] as int,
      totalStudents: json['totalStudents'] as int,
      totalLessons: json['totalLessons'] as int,
      totalAssignments: json['totalAssignments'] as int,
      averageRating: (json['averageRating'] as num).toDouble(),
      studentEngagement: Map<String, int>.from(
        json['studentEngagement'] as Map,
      ),
      coursePerformance: Map<String, double>.from(
        json['coursePerformance'] as Map,
      ),
      assignmentSubmissions: Map<String, int>.from(
        json['assignmentSubmissions'] as Map,
      ),
      completionRate: (json['completionRate'] as num?)?.toDouble() ?? 0.0,
      averageTimeSpent: json['averageTimeSpent'] as int? ?? 0,
      studentSatisfaction:
          (json['studentSatisfaction'] as num?)?.toDouble() ?? 0.0,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      metadata: json['metadata'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teacherId': teacherId,
      'totalCourses': totalCourses,
      'totalStudents': totalStudents,
      'totalLessons': totalLessons,
      'totalAssignments': totalAssignments,
      'averageRating': averageRating,
      'studentEngagement': studentEngagement,
      'coursePerformance': coursePerformance,
      'assignmentSubmissions': assignmentSubmissions,
      'completionRate': completionRate,
      'averageTimeSpent': averageTimeSpent,
      'studentSatisfaction': studentSatisfaction,
      'lastUpdated': lastUpdated.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory TeacherAnalyticsModel.fromEntity(TeacherAnalyticsEntity entity) {
    return TeacherAnalyticsModel(
      teacherId: entity.teacherId,
      totalCourses: entity.totalCourses,
      totalStudents: entity.totalStudents,
      totalLessons: entity.totalLessons,
      totalAssignments: entity.totalAssignments,
      averageRating: entity.averageRating,
      studentEngagement: entity.studentEngagement,
      coursePerformance: entity.coursePerformance,
      assignmentSubmissions: entity.assignmentSubmissions,
      completionRate: entity.completionRate,
      averageTimeSpent: entity.averageTimeSpent,
      studentSatisfaction: entity.studentSatisfaction,
      lastUpdated: entity.lastUpdated,
      metadata: entity.metadata,
    );
  }

  TeacherAnalyticsEntity toEntity() {
    return TeacherAnalyticsEntity(
      teacherId: teacherId,
      totalCourses: totalCourses,
      totalStudents: totalStudents,
      totalLessons: totalLessons,
      totalAssignments: totalAssignments,
      averageRating: averageRating,
      studentEngagement: studentEngagement,
      coursePerformance: coursePerformance,
      assignmentSubmissions: assignmentSubmissions,
      completionRate: completionRate,
      averageTimeSpent: averageTimeSpent,
      studentSatisfaction: studentSatisfaction,
      lastUpdated: lastUpdated,
      metadata: metadata,
    );
  }
}
