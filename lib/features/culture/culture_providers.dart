import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'data/datasources/culture_datasources.dart';
import 'data/repositories/culture_repository_impl.dart';
import 'domain/repositories/culture_repository.dart';

/// List of providers for the Culture feature
List<SingleChildWidget> get cultureProviders => [
      // Data sources
      Provider<CultureLocalDataSource>(
        create: (context) => CultureLocalDataSource(),
      ),

      Provider<CultureRemoteDataSource>(
        create: (_) => CultureRemoteDataSource(
          FirebaseFirestore.instance,
        ),
      ),

      // Repository
      Provider<CultureRepository>(
        create: (context) => CultureRepositoryImpl(
          localDataSource: context.read<CultureLocalDataSource>(),
          remoteDataSource: context.read<CultureRemoteDataSource>(),
        ),
      ),

      // TODO: Add more providers
    ];