import 'package:flutter/foundation.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/culture_entities.dart';
import '../../domain/usecases/culture_usecases.dart';

/// ViewModel for Culture Content
class CultureViewModel extends ChangeNotifier {
  final GetCultureContentUseCase getCultureContentUseCase;
  final GetCultureContentByIdUseCase getCultureContentByIdUseCase;
  final SearchCultureContentUseCase searchCultureContentUseCase;
  final GetCultureStatisticsUseCase getCultureStatisticsUseCase;

  CultureViewModel({
    required this.getCultureContentUseCase,
    required this.getCultureContentByIdUseCase,
    required this.searchCultureContentUseCase,
    required this.getCultureStatisticsUseCase,
  });

  // State
  List<CultureContentEntity> _cultureContent = [];
  CultureContentEntity? _selectedCultureContent;
  Map<String, dynamic> _statistics = {};
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  // Getters
  List<CultureContentEntity> get cultureContent => _cultureContent;
  CultureContentEntity? get selectedCultureContent => _selectedCultureContent;
  Map<String, dynamic> get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  // Filtered content based on search
  List<CultureContentEntity> get filteredCultureContent {
    if (_searchQuery.isEmpty) return _cultureContent;
    return _cultureContent.where((content) =>
        content.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        content.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        content.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()))
    ).toList();
  }

  // Actions
  Future<void> loadCultureContent({
    String? language,
    CultureCategory? category,
    int? limit,
    int? offset,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getCultureContentUseCase(
      GetCultureContentParams(
        language: language ?? '',
        category: category,
      ),
    );

    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
        _cultureContent = [];
      },
      (content) {
        _cultureContent = content;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadCultureContentById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getCultureContentByIdUseCase(id);

    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
        _selectedCultureContent = null;
      },
      (content) {
        _selectedCultureContent = content;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchCultureContent(String query) async {
    _searchQuery = query;
    if (query.isEmpty) {
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await searchCultureContentUseCase(
      SearchCultureContentParams(query: query),
    );

    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
        _cultureContent = [];
      },
      (content) {
        _cultureContent = content;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadStatistics() async {
    final result = await getCultureStatisticsUseCase('');

    result.fold(
      (failure) => _error = _mapFailureToMessage(failure),
      (stats) => _statistics = stats,
    );

    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error occurred';
      case CacheFailure:
        return 'Cache error occurred';
      default:
        return 'An unexpected error occurred';
    }
  }
}

/// ViewModel for Historical Content
class HistoricalViewModel extends ChangeNotifier {
  final GetHistoricalContentUseCase getHistoricalContentUseCase;
  final GetHistoricalContentByIdUseCase getHistoricalContentByIdUseCase;
  final SearchHistoricalContentUseCase searchHistoricalContentUseCase;

  HistoricalViewModel({
    required this.getHistoricalContentUseCase,
    required this.getHistoricalContentByIdUseCase,
    required this.searchHistoricalContentUseCase,
  });

  // State
  List<HistoricalContentEntity> _historicalContent = [];
  HistoricalContentEntity? _selectedHistoricalContent;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  // Getters
  List<HistoricalContentEntity> get historicalContent => _historicalContent;
  HistoricalContentEntity? get selectedHistoricalContent => _selectedHistoricalContent;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  List<HistoricalContentEntity> get filteredHistoricalContent {
    if (_searchQuery.isEmpty) return _historicalContent;
    return _historicalContent.where((content) =>
        content.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        content.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        content.period.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        content.figures.any((figure) => figure.toLowerCase().contains(_searchQuery.toLowerCase()))
    ).toList();
  }

  // Actions
  Future<void> loadHistoricalContent({
    String? language,
    String? period,
    int? limit,
    int? offset,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getHistoricalContentUseCase(
      GetHistoricalContentParams(
        language: language ?? '',
        period: period,
      ),
    );

    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
        _historicalContent = [];
      },
      (content) {
        _historicalContent = content;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadHistoricalContentById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getHistoricalContentByIdUseCase(id);

    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
        _selectedHistoricalContent = null;
      },
      (content) {
        _selectedHistoricalContent = content;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchHistoricalContent(String query) async {
    _searchQuery = query;
    if (query.isEmpty) {
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await searchHistoricalContentUseCase(
      SearchHistoricalContentParams(query: query),
    );

    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
        _historicalContent = [];
      },
      (content) {
        _historicalContent = content;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error occurred';
      case CacheFailure:
        return 'Cache error occurred';
      default:
        return 'An unexpected error occurred';
    }
  }
}

/// ViewModel for Yemba Content
class YembaViewModel extends ChangeNotifier {
  final GetYembaContentUseCase getYembaContentUseCase;
  final GetYembaContentByIdUseCase getYembaContentByIdUseCase;
  final SearchYembaContentUseCase searchYembaContentUseCase;

  YembaViewModel({
    required this.getYembaContentUseCase,
    required this.getYembaContentByIdUseCase,
    required this.searchYembaContentUseCase,
  });

  // State
  List<YembaContentEntity> _yembaContent = [];
  YembaContentEntity? _selectedYembaContent;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';

  // Getters
  List<YembaContentEntity> get yembaContent => _yembaContent;
  YembaContentEntity? get selectedYembaContent => _selectedYembaContent;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  List<YembaContentEntity> get filteredYembaContent {
    if (_searchQuery.isEmpty) return _yembaContent;
    return _yembaContent.where((content) =>
        content.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        content.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        content.tags.any((tag) => tag.toLowerCase().contains(_searchQuery.toLowerCase()))
    ).toList();
  }

  // Group content by category
  Map<YembaCategory, List<YembaContentEntity>> get yembaContentByCategory {
    final Map<YembaCategory, List<YembaContentEntity>> grouped = {};
    for (final content in filteredYembaContent) {
      grouped.putIfAbsent(content.category, () => []).add(content);
    }
    return grouped;
  }

  // Group content by difficulty
  Map<String, List<YembaContentEntity>> get yembaContentByDifficulty {
    final Map<String, List<YembaContentEntity>> grouped = {};
    for (final content in filteredYembaContent) {
      grouped.putIfAbsent(content.difficulty, () => []).add(content);
    }
    return grouped;
  }

  // Actions
  Future<void> loadYembaContent({
    YembaCategory? category,
    String? difficulty,
    int? limit,
    int? offset,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getYembaContentUseCase(
      GetYembaContentParams(
        category: category,
        difficulty: difficulty,
      ),
    );

    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
        _yembaContent = [];
      },
      (content) {
        _yembaContent = content;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadYembaContentById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await getYembaContentByIdUseCase(id);

    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
        _selectedYembaContent = null;
      },
      (content) {
        _selectedYembaContent = content;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> searchYembaContent(String query) async {
    _searchQuery = query;
    if (query.isEmpty) {
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await searchYembaContentUseCase(
      SearchYembaContentParams(query: query),
    );

    result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
        _yembaContent = [];
      },
      (content) {
        _yembaContent = content;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return 'Server error occurred';
      case CacheFailure:
        return 'Cache error occurred';
      default:
        return 'An unexpected error occurred';
    }
  }
}