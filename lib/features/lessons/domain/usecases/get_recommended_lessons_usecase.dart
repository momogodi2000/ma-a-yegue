import 'package:dartz/dartz.dart';
import '../entities/lesson.dart';

/// Get recommended lessons usecase
class GetRecommendedLessonsUsecase {
  GetRecommendedLessonsUsecase();

  Future<Either<String, List<Lesson>>> call(String userId) async {
    // Placeholder implementation
    return const Right(<Lesson>[]);
  }
}