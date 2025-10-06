import 'package:dartz/dartz.dart';

/// Enroll in course usecase
class EnrollInCourseUsecase {
  EnrollInCourseUsecase();

  Future<Either<String, bool>> call(String courseId, String userId) async {
    // Placeholder implementation
    return const Right(true);
  }
}