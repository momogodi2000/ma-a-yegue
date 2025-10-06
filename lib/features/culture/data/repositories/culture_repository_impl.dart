import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/culture_entities.dart';
import '../../domain/repositories/culture_repository.dart';
import '../datasources/culture_datasources.dart';

/// Implementation of CultureRepository
class CultureRepositoryImpl implements CultureRepository {
  final CultureLocalDataSource localDataSource;
  final CultureRemoteDataSource remoteDataSource;

  CultureRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<Either<Failure, List<CultureContentEntity>>> getCultureContent(String language, {CultureCategory? category, int? limit, int? offset}) async {
    try {
      // Try to get from remote first, fallback to local
      final remoteContent = await remoteDataSource.getCultureContent(
        language: language,
        category: category,
        limit: limit,
        offset: offset,
      );

      if (remoteContent.isNotEmpty) {
        return Right(remoteContent);
      }

      // Fallback to local data
      final localContent = await localDataSource.getCultureContent(
        language: language,
        category: category,
        limit: limit,
        offset: offset,
      );

      return Right(localContent);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<HistoricalContentEntity>>> getHistoricalContent(String language, {String? period, int? limit, int? offset}) async {
    try {
      final remoteContent = await remoteDataSource.getHistoricalContent(
        language: language,
        period: period,
        limit: limit,
        offset: offset,
      );

      if (remoteContent.isNotEmpty) {
        return Right(remoteContent);
      }

      final localContent = await localDataSource.getHistoricalContent(
        language: language,
        period: period,
        limit: limit,
        offset: offset,
      );

      return Right(localContent);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<YembaContentEntity>>> getYembaContent({
    YembaCategory? category,
    String? difficulty,
    int? limit,
    int? offset,
  }) async {
    try {
      final remoteContent = await remoteDataSource.getYembaContent(
        category: category,
        difficulty: difficulty,
        limit: limit,
        offset: offset,
      );

      if (remoteContent.isNotEmpty) {
        return Right(remoteContent);
      }

      final localContent = await localDataSource.getYembaContent(
        category: category,
        difficulty: difficulty,
        limit: limit,
        offset: offset,
      );

      return Right(localContent);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, CultureContentEntity?>> getCultureContentById(String id) async {
    try {
      final remoteContent = await remoteDataSource.getCultureContentById(id);
      if (remoteContent != null) {
        return Right(remoteContent);
      }

      final localContent = await localDataSource.getCultureContentById(id);
      return Right(localContent);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, HistoricalContentEntity?>> getHistoricalContentById(String id) async {
    try {
      final remoteContent = await remoteDataSource.getHistoricalContentById(id);
      if (remoteContent != null) {
        return Right(remoteContent);
      }

      final localContent = await localDataSource.getHistoricalContentById(id);
      return Right(localContent);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, YembaContentEntity?>> getYembaContentById(String id) async {
    try {
      final remoteContent = await remoteDataSource.getYembaContentById(id);
      if (remoteContent != null) {
        return Right(remoteContent);
      }

      final localContent = await localDataSource.getYembaContentById(id);
      return Right(localContent);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CultureContentEntity>>> searchCultureContent(String query) async {
    try {
      final remoteResults = await remoteDataSource.searchCultureContent(query);
      if (remoteResults.isNotEmpty) {
        return Right(remoteResults);
      }

      final localResults = await localDataSource.searchCultureContent(query);
      return Right(localResults);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<HistoricalContentEntity>>> searchHistoricalContent(String query) async {
    try {
      final remoteResults = await remoteDataSource.searchHistoricalContent(query);
      if (remoteResults.isNotEmpty) {
        return Right(remoteResults);
      }

      final localResults = await localDataSource.searchHistoricalContent(query);
      return Right(localResults);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<YembaContentEntity>>> searchYembaContent(String query) async {
    try {
      final remoteResults = await remoteDataSource.searchYembaContent(query);
      if (remoteResults.isNotEmpty) {
        return Right(remoteResults);
      }

      final localResults = await localDataSource.searchYembaContent(query);
      return Right(localResults);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<String, int>>> getCultureStatistics(String userId) async {
    try {
      // Get counts from both sources
      final remoteCulture = await remoteDataSource.getCultureContent();
      final remoteHistorical = await remoteDataSource.getHistoricalContent();
      final remoteYemba = await remoteDataSource.getYembaContent();

      final localCulture = await localDataSource.getCultureContent();
      final localHistorical = await localDataSource.getHistoricalContent();
      final localYemba = await localDataSource.getYembaContent();

      return Right({
        'culture_content': remoteCulture.length + localCulture.length,
        'historical_content': remoteHistorical.length + localHistorical.length,
        'yemba_content': remoteYemba.length + localYemba.length,
      });
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markCultureContentAsRead(String userId, String contentId) async {
    try {
      // This would typically update user progress in a user progress table
      // For now, we'll just return success
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markHistoricalContentAsRead(String userId, String contentId) async {
    try {
      // This would typically update user progress in a user progress table
      // For now, we'll just return success
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markYembaContentAsCompleted(String userId, String contentId) async {
    try {
      // This would typically update user progress in a user progress table
      // For now, we'll just return success
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}