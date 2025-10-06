import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/lesson.dart';
import '../repositories/lesson_repository.dart';

/// Get lesson by ID usecase
class GetLessonByIdUsecase {
  final LessonRepository repository;

  GetLessonByIdUsecase(this.repository);

  Future<Either<Failure, Lesson>> call(String lessonId) async {
    return await repository.getLessonById(lessonId);
  }
}