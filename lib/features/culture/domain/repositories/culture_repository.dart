import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/culture_entities.dart';

/// Repository interface for culture operations
abstract class CultureRepository {
  // Culture content operations
  Future<Either<Failure, List<CultureContentEntity>>> getCultureContent(String language, {CultureCategory? category, int? limit, int? offset});
  Future<Either<Failure, CultureContentEntity?>> getCultureContentById(String id);
  Future<Either<Failure, List<CultureContentEntity>>> searchCultureContent(String query);

  // Historical content operations
  Future<Either<Failure, List<HistoricalContentEntity>>> getHistoricalContent(String language, {String? period, int? limit, int? offset});
  Future<Either<Failure, HistoricalContentEntity?>> getHistoricalContentById(String id);
  Future<Either<Failure, List<HistoricalContentEntity>>> searchHistoricalContent(String query);

  // Yemba content operations
  Future<Either<Failure, List<YembaContentEntity>>> getYembaContent({YembaCategory? category, String? difficulty, int? limit, int? offset});
  Future<Either<Failure, YembaContentEntity?>> getYembaContentById(String id);
  Future<Either<Failure, List<YembaContentEntity>>> searchYembaContent(String query);

  // Statistics
  Future<Either<Failure, Map<String, int>>> getCultureStatistics(String userId);

  // Progress tracking
  Future<Either<Failure, void>> markCultureContentAsRead(String userId, String contentId);
  Future<Either<Failure, void>> markHistoricalContentAsRead(String userId, String contentId);
  Future<Either<Failure, void>> markYembaContentAsCompleted(String userId, String contentId);
}