import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/lesson.dart';
import '../repositories/lesson_repository.dart';

/// Get lessons by language usecase  
/// Note: This is a placeholder - actual implementation should filter by language
class GetLessonsByLanguageUsecase {
  final LessonRepository repository;

  GetLessonsByLanguageUsecase(this.repository);

  Future<Either<Failure, List<Lesson>>> call(String language) async {
    // For now, just return empty list as the repository doesn't have this method
    // In a real implementation, this would filter lessons by language
    return const Right(<Lesson>[]);
  }
}