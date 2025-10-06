import 'package:dartz/dartz.dart';

/// Download lesson usecase
class DownloadLessonUsecase {
  DownloadLessonUsecase();

  Future<Either<String, bool>> call(String lessonId) async {
    // Placeholder implementation
    return const Right(true);
  }
}