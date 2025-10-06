# Ma'a yegue Test Suite

This directory contains comprehensive tests for the Ma'a yegue application, covering all features, layers, and functionality.

## Test Structure

```
test/
├── features/                    # Feature-specific tests
│   ├── authentication/         # Authentication feature tests
│   │   ├── data/
│   │   │   ├── models/        # Model tests
│   │   │   ├── datasources/   # Data source tests
│   │   │   └── repositories/  # Repository tests
│   │   ├── domain/
│   │   │   └── usecases/      # Use case tests
│   │   └── presentation/
│   │       └── viewmodels/    # ViewModel tests
│   ├── lessons/               # Lessons feature tests
│   ├── ai/                    # AI feature tests
│   ├── games/                 # Games feature tests
│   ├── payment/               # Payment feature tests
│   ├── community/             # Community feature tests
│   ├── dashboard/             # Dashboard feature tests
│   └── ...
├── integration/               # Integration tests
│   ├── firebase_connectivity_test.dart
│   ├── authentication_flow_test.dart
│   └── payment_flow_test.dart
├── widget/                    # Widget tests
│   ├── authentication/
│   ├── lessons/
│   ├── dashboard/
│   └── ...
├── unit/                      # Unit tests for core services
├── test_config.dart          # Test configuration and utilities
├── test_runner.dart          # Main test runner
└── README.md                 # This file
```

## Test Types

### 1. Unit Tests
- **Purpose**: Test individual components in isolation
- **Location**: `features/*/data/`, `features/*/domain/`, `features/*/presentation/`
- **Coverage**: Models, repositories, use cases, view models

### 2. Integration Tests
- **Purpose**: Test interaction between multiple components
- **Location**: `integration/`
- **Coverage**: Firebase connectivity, authentication flows, payment flows

### 3. Widget Tests
- **Purpose**: Test UI components and user interactions
- **Location**: `widget/`
- **Coverage**: Views, forms, navigation, user interactions

## Running Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test Categories
```bash
# Run unit tests only
flutter test test/features/

# Run integration tests only
flutter test test/integration/

# Run widget tests only
flutter test test/widget/

# Run specific feature tests
flutter test test/features/authentication/
```

### Run Tests with Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Run Integration Tests
```bash
flutter test integration_test/
```

## Test Configuration

### Test Environment Setup
The test environment is configured in `test_config.dart`:

```dart
// Initialize test environment
await TestConfig.initialize();

// Clean up after tests
await TestConfig.cleanup();
```

### Test Data Factory
Use `TestDataFactory` to create test data:

```dart
// Create test user
final user = TestDataFactory.createTestUser();

// Create test lesson
final lesson = TestDataFactory.createTestLesson();

// Create test course
final course = TestDataFactory.createTestCourse();
```

## Test Coverage

### Authentication Feature
- ✅ User Model Tests
- ✅ Auth Response Model Tests
- ✅ Local Data Source Tests
- ✅ Remote Data Source Tests
- ✅ Repository Implementation Tests
- ✅ Login Use Case Tests
- ✅ Register Use Case Tests
- ✅ Auth ViewModel Tests
- ✅ Login View Widget Tests

### Lessons Feature
- ✅ Lesson Model Tests
- ✅ Course Model Tests
- ✅ Repository Implementation Tests
- ✅ Lesson ViewModel Tests
- ✅ Lesson View Widget Tests

### AI Feature
- ✅ AI Models Tests
- ✅ Conversation Model Tests
- ✅ Translation Model Tests
- ✅ Pronunciation Assessment Tests
- ✅ Content Generation Tests
- ✅ AI Recommendation Tests

### Core Services
- ✅ Firebase Connectivity Tests
- ✅ Database Service Tests
- ✅ Network Service Tests
- ✅ Payment Service Tests

### Integration Tests
- ✅ Firebase Authentication Integration
- ✅ Firestore Integration
- ✅ Storage Integration
- ✅ Payment Gateway Integration

## Test Best Practices

### 1. Test Naming
- Use descriptive test names that explain what is being tested
- Follow the pattern: `should [expected behavior] when [condition]`

```dart
test('should return user data when login is successful', () async {
  // test implementation
});
```

### 2. Test Structure
- Use the AAA pattern: Arrange, Act, Assert
- Keep tests focused on a single behavior
- Use meaningful variable names with `t` prefix for test data

```dart
test('should return user when found by ID', () async {
  // arrange
  const tUserId = 'test-user-id';
  when(mockRepository.getUserById(tUserId)).thenAnswer((_) async => tUser);

  // act
  final result = await repository.getUserById(tUserId);

  // assert
  expect(result, tUser);
});
```

### 3. Mocking
- Use Mockito for creating mocks
- Mock external dependencies only
- Verify mock interactions

```dart
@GenerateMocks([AuthRepository])
void main() {
  late MockAuthRepository mockAuthRepository;
  
  setUp(() {
    mockAuthRepository = MockAuthRepository();
  });
}
```

### 4. Test Data
- Use consistent test data across tests
- Create test data factories for complex objects
- Use meaningful test values

```dart
const tUser = UserEntity(
  id: 'test-user-id',
  email: 'test@example.com',
  displayName: 'Test User',
  // ... other properties
);
```

### 5. Error Testing
- Test both success and failure scenarios
- Test different types of errors
- Verify error messages and handling

```dart
test('should return error when network fails', () async {
  // arrange
  when(mockDataSource.getData()).thenThrow(NetworkException());

  // act
  final result = await repository.getData();

  // assert
  expect(result.isLeft(), true);
  expect(result.fold((l) => l, (r) => null), isA<NetworkFailure>());
});
```

## Firebase Testing

### Test Environment Setup
```dart
// Initialize Firebase for testing
await Firebase.initializeApp(
  options: const FirebaseOptions(
    apiKey: 'test-api-key',
    appId: 'test-app-id',
    projectId: 'test-project-id',
    // ... other options
  ),
);
```

### Test Data Management
- Use test-specific collections in Firestore
- Clean up test data after each test
- Use mock data when possible

### Authentication Testing
```dart
test('should sign in user successfully', () async {
  // arrange
  await FirebaseAuth.instance.signInAnonymously();
  
  // act
  final user = FirebaseAuth.instance.currentUser;
  
  // assert
  expect(user, isNotNull);
  expect(user!.isAnonymous, true);
  
  // cleanup
  await FirebaseAuth.instance.signOut();
});
```

## Performance Testing

### Test Timeouts
- Unit tests: 30 seconds
- Integration tests: 5 minutes
- Widget tests: 30 seconds

### Memory Testing
- Monitor memory usage in integration tests
- Clean up resources after tests
- Use weak references where appropriate

## Continuous Integration

### GitHub Actions
Tests are automatically run on:
- Pull requests
- Pushes to main branch
- Scheduled runs

### Test Reports
- Coverage reports generated automatically
- Test results published as artifacts
- Performance metrics tracked

## Debugging Tests

### Running Individual Tests
```bash
# Run specific test file
flutter test test/features/authentication/data/models/user_model_test.dart

# Run specific test
flutter test --name "should return user data when login is successful"
```

### Debug Mode
```bash
# Run tests in debug mode
flutter test --debug

# Run with verbose output
flutter test --verbose
```

### Test Logs
- Use `print()` statements for debugging
- Check test output for error messages
- Use `debugPrint()` for conditional logging

## Common Issues and Solutions

### 1. Firebase Initialization Errors
- Ensure Firebase is properly configured for testing
- Use test-specific Firebase project
- Handle initialization errors gracefully

### 2. Mock Generation Issues
- Run `flutter packages pub run build_runner build` to generate mocks
- Ensure all dependencies are properly imported
- Check mock annotations

### 3. Test Timeout Issues
- Increase timeout for slow tests
- Use `await Future.delayed()` for async operations
- Check for infinite loops in tests

### 4. Widget Test Issues
- Ensure proper widget binding initialization
- Use `tester.pump()` for widget updates
- Check for missing providers or dependencies

## Contributing to Tests

### Adding New Tests
1. Create test file in appropriate directory
2. Follow existing naming conventions
3. Include comprehensive test cases
4. Update this README with new test coverage

### Test Review Checklist
- [ ] Tests cover both success and failure scenarios
- [ ] Test names are descriptive
- [ ] Mocks are used appropriately
- [ ] Test data is consistent
- [ ] Tests are isolated and independent
- [ ] Cleanup is performed after tests

### Test Maintenance
- Update tests when features change
- Remove obsolete tests
- Keep test data up to date
- Monitor test performance

## Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Mockito Documentation](https://pub.dev/packages/mockito)
- [Firebase Testing Guide](https://firebase.google.com/docs/emulator-suite)
- [Integration Testing Guide](https://docs.flutter.dev/testing/integration-tests)

## Support

For questions about testing:
- Check existing test examples
- Review test documentation
- Ask in team channels
- Create issue for test-related problems