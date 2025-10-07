import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'data/datasources/culture_datasources.dart';
import 'data/repositories/culture_repository_impl.dart';
import 'domain/repositories/culture_repository.dart';
import 'domain/usecases/culture_usecases.dart';
import 'presentation/viewmodels/culture_viewmodels.dart';

/// List of providers for the Culture feature
List<SingleChildWidget> get cultureProviders => [
  // Data sources
  Provider<CultureLocalDataSource>(
    create: (context) => CultureLocalDataSource(),
  ),

  Provider<CultureRemoteDataSource>(
    create: (_) => CultureRemoteDataSource(FirebaseFirestore.instance),
  ),

  // Repository
  Provider<CultureRepository>(
    create: (context) => CultureRepositoryImpl(
      localDataSource: context.read<CultureLocalDataSource>(),
      remoteDataSource: context.read<CultureRemoteDataSource>(),
    ),
  ),

  // Usecases
  ProxyProvider<CultureRepository, GetCultureContentUseCase>(
    update: (_, repository, __) => GetCultureContentUseCase(repository),
  ),

  ProxyProvider<CultureRepository, GetCultureContentByIdUseCase>(
    update: (_, repository, __) => GetCultureContentByIdUseCase(repository),
  ),

  ProxyProvider<CultureRepository, SearchCultureContentUseCase>(
    update: (_, repository, __) => SearchCultureContentUseCase(repository),
  ),

  ProxyProvider<CultureRepository, GetCultureStatisticsUseCase>(
    update: (_, repository, __) => GetCultureStatisticsUseCase(repository),
  ),

  // Historical content use cases
  ProxyProvider<CultureRepository, GetHistoricalContentUseCase>(
    update: (_, repository, __) => GetHistoricalContentUseCase(repository),
  ),

  ProxyProvider<CultureRepository, GetHistoricalContentByIdUseCase>(
    update: (_, repository, __) => GetHistoricalContentByIdUseCase(repository),
  ),

  ProxyProvider<CultureRepository, SearchHistoricalContentUseCase>(
    update: (_, repository, __) => SearchHistoricalContentUseCase(repository),
  ),

  // Yemba content use cases
  ProxyProvider<CultureRepository, GetYembaContentUseCase>(
    update: (_, repository, __) => GetYembaContentUseCase(repository),
  ),

  ProxyProvider<CultureRepository, GetYembaContentByIdUseCase>(
    update: (_, repository, __) => GetYembaContentByIdUseCase(repository),
  ),

  ProxyProvider<CultureRepository, SearchYembaContentUseCase>(
    update: (_, repository, __) => SearchYembaContentUseCase(repository),
  ),

  // ViewModels
  ChangeNotifierProvider<CultureViewModel>(
    create: (context) => CultureViewModel(
      getCultureContentUseCase: context.read<GetCultureContentUseCase>(),
      getCultureContentByIdUseCase: context
          .read<GetCultureContentByIdUseCase>(),
      searchCultureContentUseCase: context.read<SearchCultureContentUseCase>(),
      getCultureStatisticsUseCase: context.read<GetCultureStatisticsUseCase>(),
    ),
  ),

  ChangeNotifierProvider<HistoricalViewModel>(
    create: (context) => HistoricalViewModel(
      getHistoricalContentUseCase: context.read<GetHistoricalContentUseCase>(),
      getHistoricalContentByIdUseCase: context
          .read<GetHistoricalContentByIdUseCase>(),
      searchHistoricalContentUseCase: context
          .read<SearchHistoricalContentUseCase>(),
    ),
  ),

  ChangeNotifierProvider<YembaViewModel>(
    create: (context) => YembaViewModel(
      getYembaContentUseCase: context.read<GetYembaContentUseCase>(),
      getYembaContentByIdUseCase: context.read<GetYembaContentByIdUseCase>(),
      searchYembaContentUseCase: context.read<SearchYembaContentUseCase>(),
    ),
  ),
];
