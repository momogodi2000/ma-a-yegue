import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

// Import all test files
import 'features/authentication/data/models/user_model_test.dart'
    as user_model_test;
import 'features/authentication/data/models/auth_response_model_test.dart'
    as auth_response_model_test;
import 'features/authentication/data/datasources/auth_local_datasource_test.dart'
    as auth_local_datasource_test;
import 'features/authentication/data/datasources/auth_remote_datasource_test.dart'
    as auth_remote_datasource_test;
import 'features/authentication/data/repositories/auth_repository_impl_test.dart'
    as auth_repository_impl_test;
import 'features/authentication/domain/usecases/login_usecase_test.dart'
    as login_usecase_test;
import 'features/authentication/domain/usecases/register_usecase_test.dart'
    as register_usecase_test;
import 'features/authentication/presentation/viewmodels/auth_viewmodel_test.dart'
    as auth_viewmodel_test;
import 'features/lessons/data/models/lesson_model_test.dart'
    as lesson_model_test;
import 'features/lessons/presentation/viewmodels/lesson_viewmodel_test.dart'
    as lesson_viewmodel_test;
import 'features/ai/data/models/ai_models_test.dart' as ai_models_test;
import 'integration/firebase_connectivity_test.dart'
    as firebase_connectivity_test;
import 'widget/authentication/login_view_test.dart' as login_view_test;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Ma\'a yegue Test Suite', () {
    group('Authentication Feature Tests', () {
      group('Data Layer Tests', () {
        test('User Model Tests', () {
          user_model_test.main();
        });

        test('Auth Response Model Tests', () {
          auth_response_model_test.main();
        });

        test('Auth Local DataSource Tests', () {
          auth_local_datasource_test.main();
        });

        test('Auth Remote DataSource Tests', () {
          auth_remote_datasource_test.main();
        });

        test('Auth Repository Implementation Tests', () {
          auth_repository_impl_test.main();
        });
      });

      group('Domain Layer Tests', () {
        test('Login UseCase Tests', () {
          login_usecase_test.main();
        });

        test('Register UseCase Tests', () {
          register_usecase_test.main();
        });
      });

      group('Presentation Layer Tests', () {
        test('Auth ViewModel Tests', () {
          auth_viewmodel_test.main();
        });
      });
    });

    group('Lessons Feature Tests', () {
      group('Data Layer Tests', () {
        test('Lesson Model Tests', () {
          lesson_model_test.main();
        });
      });

      group('Presentation Layer Tests', () {
        test('Lesson ViewModel Tests', () {
          lesson_viewmodel_test.main();
        });
      });
    });

    group('AI Feature Tests', () {
      group('Data Layer Tests', () {
        test('AI Models Tests', () {
          ai_models_test.main();
        });
      });
    });

    group('Integration Tests', () {
      test('Firebase Connectivity Tests', () {
        firebase_connectivity_test.main();
      });
    });

    group('Widget Tests', () {
      test('Login View Widget Tests', () {
        login_view_test.main();
      });
    });
  });
}
