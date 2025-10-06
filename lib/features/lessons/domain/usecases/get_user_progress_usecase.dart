import 'package:dartz/dartz.dart';

/// User progress data
class UserProgress {
  final String userId;
  final String courseId;
  final int completedLessons;
  final int totalLessons;
  final double progressPercentage;

  const UserProgress({
    required this.userId,
    required this.courseId,
    required this.completedLessons,
    required this.totalLessons,
    required this.progressPercentage,
  });
}

/// Get user progress usecase
class GetUserProgressUsecase {
  GetUserProgressUsecase();

  Future<Either<String, UserProgress>> call(String userId, String courseId) async {
    // Placeholder implementation
    return const Right(UserProgress(
      userId: '',
      courseId: '',
      completedLessons: 0,
      totalLessons: 0,
      progressPercentage: 0.0,
    ));
  }
}