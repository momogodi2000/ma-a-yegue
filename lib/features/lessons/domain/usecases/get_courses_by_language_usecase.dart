import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/course.dart';
import '../repositories/course_repository.dart';

/// Get courses by language usecase
class GetCoursesByLanguageUsecase {
  final CourseRepository repository;

  GetCoursesByLanguageUsecase(this.repository);

  Future<Either<Failure, List<Course>>> call(String language) async {
    return await repository.getCoursesByLanguage(language);
  }
}