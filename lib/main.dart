import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'core/router.dart';
import 'core/config/environment_config.dart';
import 'core/database/database_initialization_service.dart';
import 'core/database/data_seeding_service.dart';
import 'core/database/database_helper.dart';
import 'shared/providers/app_providers.dart';
import 'shared/themes/app_theme.dart';
import 'shared/providers/theme_provider.dart';
import 'shared/providers/locale_provider.dart';
import 'l10n/app_localizations.dart';
import 'core/services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize only critical services before showing UI
  bool firebaseInitialized = false;

  // Initialize environment configuration (fast)
  try {
    await EnvironmentConfig.init();
  } catch (e) {
    debugPrint('Error initializing environment config: $e');
  }

  // Initialize Firebase (important for auth, can't skip)
  try {
    await Future.wait([
      Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
      FirebaseService().initialize(),
    ]);

    // Initialize Crashlytics
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    firebaseInitialized = true;
    debugPrint('✅ Firebase initialized');
  } catch (e) {
    debugPrint('⚠️ Firebase initialization failed: $e');
  }

  // Run app immediately - don't wait for database initialization
  runApp(MyApp(firebaseInitialized: firebaseInitialized));

  // Initialize databases in background AFTER app is running
  _initializeDatabasesInBackground();
}

/// Initialize heavy database operations in the background
/// This allows the UI to show immediately while data loads
Future<void> _initializeDatabasesInBackground() async {
  debugPrint('🔄 Starting background database initialization...');

  try {
    // Initialize databases (heavy operation - copying from assets)
    final dbFuture = DatabaseInitializationService.database;
    final helperFuture = DatabaseHelper.database;

    await Future.wait([dbFuture, helperFuture], eagerError: false);
    debugPrint('✅ Databases initialized');

    // Seed database (only on first run)
    await DataSeedingService.seedDatabase();
    debugPrint('✅ Database seeding completed');
  } catch (e) {
    debugPrint('⚠️ Background database initialization failed: $e');
    // App continues to work - databases will be initialized on demand
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key, this.firebaseInitialized = false});

  final bool firebaseInitialized;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: appProviders,
      child: Consumer2<ThemeProvider, LocaleProvider>(
        builder: (context, themeProvider, localeProvider, child) {
          // Initialize providers asynchronously (don't block UI)
          if (!themeProvider.isInitialized) {
            themeProvider.initialize().catchError((e) {
              debugPrint('⚠️ Theme provider initialization failed: $e');
            });
          }
          if (!localeProvider.isInitialized) {
            localeProvider.initialize().catchError((e) {
              debugPrint('⚠️ Locale provider initialization failed: $e');
            });
          }

          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Ma\'a yegue',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routerConfig: AppRouter.createRouter(),
            locale: localeProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en'), Locale('fr')],
            // Show loading indicator while initializing
            builder: (context, child) {
              return _AppInitializationWrapper(
                firebaseInitialized: widget.firebaseInitialized,
                child: child ?? const SizedBox(),
              );
            },
          );
        },
      ),
    );
  }
}

/// Wrapper to show loading state during initialization
class _AppInitializationWrapper extends StatelessWidget {
  const _AppInitializationWrapper({
    required this.firebaseInitialized,
    required this.child,
  });

  final bool firebaseInitialized;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // If Firebase is not initialized, show a simple loading screen
    if (!firebaseInitialized) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Text(
                'Initializing...',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      );
    }

    // Otherwise, show the app normally
    return child;
  }
}
