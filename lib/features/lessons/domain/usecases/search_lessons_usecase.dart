import 'package:dartz/dartz.dart';
import '../entities/lesson.dart';

/// Search lessons usecase
class SearchLessonsUsecase {
  SearchLessonsUsecase();

  Future<Either<String, List<Lesson>>> call(String query) async {
    // Placeholder implementation
    return const Right(<Lesson>[]);
  }
}