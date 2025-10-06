import 'package:dartz/dartz.dart';
import '../repositories/lesson_repository.dart';

/// Complete lesson usecase
class CompleteLessonUsecase {
  final LessonRepository repository;

  CompleteLessonUsecase(this.repository);

  Future<Either<String, bool>> call(String lessonId) async {
    final result = await repository.completeLesson(lessonId);
    return result.fold(
      (failure) => Left(failure.toString()),
      (success) => Right(success),
    );
  }
}