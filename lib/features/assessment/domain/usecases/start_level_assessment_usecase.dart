import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/level_assessment_repository.dart';
import '../entities/level_assessment_entity.dart';

class StartLevelAssessmentUsecase implements UseCase<LevelAssessmentEntity, StartLevelAssessmentParams> {
  final LevelAssessmentRepository repository;

  StartLevelAssessmentUsecase(this.repository);

  @override
  Future<Either<Failure, LevelAssessmentEntity>> call(StartLevelAssessmentParams params) async {
    try {
      final assessment = await repository.startLevelAssessment(
        userId: params.userId,
        languageCode: params.languageCode,
        currentLevel: params.currentLevel,
        targetLevel: params.targetLevel,
      );
      return Right(assessment);
    } catch (e) {
      return Left(ServerFailure('Failed to start assessment: $e'));
    }
  }
}

class StartLevelAssessmentParams {
  final String userId;
  final String languageCode;
  final String currentLevel;
  final String targetLevel;

  StartLevelAssessmentParams({
    required this.userId,
    required this.languageCode,
    required this.currentLevel,
    required this.targetLevel,
  });
}