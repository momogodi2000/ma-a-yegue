import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/culture_entities.dart';
import '../repositories/culture_repository.dart';

/// Use case for getting culture content
class GetCultureContentUseCase implements UseCase<List<CultureContentEntity>, GetCultureContentParams> {
  final CultureRepository repository;

  GetCultureContentUseCase(this.repository);

  @override
  Future<Either<Failure, List<CultureContentEntity>>> call(GetCultureContentParams params) async {
    return await repository.getCultureContent(params.language, category: params.category);
  }
}

/// Parameters for GetCultureContentUseCase
class GetCultureContentParams {
  final String language;
  final CultureCategory? category;

  const GetCultureContentParams({
    required this.language,
    this.category,
  });
}

/// Use case for getting historical content
class GetHistoricalContentUseCase implements UseCase<List<HistoricalContentEntity>, GetHistoricalContentParams> {
  final CultureRepository repository;

  GetHistoricalContentUseCase(this.repository);

  @override
  Future<Either<Failure, List<HistoricalContentEntity>>> call(GetHistoricalContentParams params) async {
    return await repository.getHistoricalContent(params.language, period: params.period);
  }
}

/// Parameters for GetHistoricalContentUseCase
class GetHistoricalContentParams {
  final String language;
  final String? period;

  const GetHistoricalContentParams({
    required this.language,
    this.period,
  });
}

/// Use case for getting Yemba content
class GetYembaContentUseCase implements UseCase<List<YembaContentEntity>, GetYembaContentParams> {
  final CultureRepository repository;

  GetYembaContentUseCase(this.repository);

  @override
  Future<Either<Failure, List<YembaContentEntity>>> call(GetYembaContentParams params) async {
    return await repository.getYembaContent(category: params.category, difficulty: params.difficulty);
  }
}

/// Parameters for GetYembaContentUseCase
class GetYembaContentParams {
  final YembaCategory? category;
  final String? difficulty;

  const GetYembaContentParams({
    this.category,
    this.difficulty,
  });
}

/// Use case for searching culture content
class SearchCultureContentUseCase implements UseCase<List<CultureContentEntity>, SearchCultureContentParams> {
  final CultureRepository repository;

  SearchCultureContentUseCase(this.repository);

  @override
  Future<Either<Failure, List<CultureContentEntity>>> call(SearchCultureContentParams params) async {
    return await repository.searchCultureContent(params.query);
  }
}

/// Parameters for SearchCultureContentUseCase
class SearchCultureContentParams {
  final String query;

  const SearchCultureContentParams({
    required this.query,
  });
}

/// Use case for marking content as read/completed
class MarkContentAsReadUseCase implements UseCase<void, MarkContentAsReadParams> {
  final CultureRepository repository;

  MarkContentAsReadUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(MarkContentAsReadParams params) async {
    try {
      if (params.contentType == 'culture') {
        await repository.markCultureContentAsRead(params.userId, params.contentId);
      } else if (params.contentType == 'historical') {
        await repository.markHistoricalContentAsRead(params.userId, params.contentId);
      } else if (params.contentType == 'yemba') {
        await repository.markYembaContentAsCompleted(params.userId, params.contentId);
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Failed to mark content as read: $e'));
    }
  }
}

/// Parameters for MarkContentAsReadUseCase
class MarkContentAsReadParams {
  final String userId;
  final String contentId;
  final String contentType; // 'culture', 'historical', 'yemba'

  const MarkContentAsReadParams({
    required this.userId,
    required this.contentId,
    required this.contentType,
  });
}

/// Use case for getting culture content by ID
class GetCultureContentByIdUseCase implements UseCase<CultureContentEntity?, String> {
  final CultureRepository repository;

  GetCultureContentByIdUseCase(this.repository);

  @override
  Future<Either<Failure, CultureContentEntity?>> call(String id) async {
    return await repository.getCultureContentById(id);
  }
}

/// Use case for getting historical content by ID
class GetHistoricalContentByIdUseCase implements UseCase<HistoricalContentEntity?, String> {
  final CultureRepository repository;

  GetHistoricalContentByIdUseCase(this.repository);

  @override
  Future<Either<Failure, HistoricalContentEntity?>> call(String id) async {
    return await repository.getHistoricalContentById(id);
  }
}

/// Use case for getting Yemba content by ID
class GetYembaContentByIdUseCase implements UseCase<YembaContentEntity?, String> {
  final CultureRepository repository;

  GetYembaContentByIdUseCase(this.repository);

  @override
  Future<Either<Failure, YembaContentEntity?>> call(String id) async {
    return await repository.getYembaContentById(id);
  }
}

/// Use case for searching historical content
class SearchHistoricalContentUseCase implements UseCase<List<HistoricalContentEntity>, SearchHistoricalContentParams> {
  final CultureRepository repository;

  SearchHistoricalContentUseCase(this.repository);

  @override
  Future<Either<Failure, List<HistoricalContentEntity>>> call(SearchHistoricalContentParams params) async {
    return await repository.searchHistoricalContent(params.query);
  }
}

/// Parameters for SearchHistoricalContentUseCase
class SearchHistoricalContentParams {
  final String query;

  const SearchHistoricalContentParams({
    required this.query,
  });
}

/// Use case for searching Yemba content
class SearchYembaContentUseCase implements UseCase<List<YembaContentEntity>, SearchYembaContentParams> {
  final CultureRepository repository;

  SearchYembaContentUseCase(this.repository);

  @override
  Future<Either<Failure, List<YembaContentEntity>>> call(SearchYembaContentParams params) async {
    return await repository.searchYembaContent(params.query);
  }
}

/// Parameters for SearchYembaContentUseCase
class SearchYembaContentParams {
  final String query;

  const SearchYembaContentParams({
    required this.query,
  });
}

/// Use case for getting culture statistics
class GetCultureStatisticsUseCase implements UseCase<Map<String, dynamic>, String> {
  final CultureRepository repository;

  GetCultureStatisticsUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(String userId) async {
    return await repository.getCultureStatistics(userId);
  }
}