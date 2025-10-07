import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../core/services/firebase_service.dart';
import '../../core/services/admin_setup_service.dart';
import '../../core/services/two_factor_auth_service_hybrid.dart';
import '../../core/services/user_role_service_hybrid.dart';
import '../../core/services/ai_service.dart';
import '../../core/config/environment_config.dart';
import '../../core/sync/general_sync_manager.dart';
import '../../core/network/network_info.dart';
import '../../features/authentication/data/datasources/auth_remote_datasource.dart';
import '../../features/authentication/data/datasources/auth_local_datasource.dart';
import '../../features/authentication/data/repositories/auth_repository_impl.dart';
import '../../features/authentication/domain/repositories/auth_repository.dart';
import '../../features/authentication/domain/usecases/login_usecase.dart';
import '../../features/authentication/domain/usecases/register_usecase.dart';
import '../../features/authentication/domain/usecases/logout_usecase.dart';
import '../../features/authentication/domain/usecases/get_current_user_usecase.dart';
import '../../features/authentication/domain/usecases/reset_password_usecase.dart';
import '../../features/authentication/domain/usecases/google_sign_in_usecase.dart';
import '../../features/authentication/domain/usecases/facebook_sign_in_usecase.dart';
import '../../features/authentication/domain/usecases/forgot_password_usecase.dart';
import '../../features/authentication/domain/usecases/sign_in_with_phone_number_usecase.dart';
import '../../features/authentication/domain/usecases/verify_phone_number_usecase.dart';
import '../../features/authentication/domain/usecases/apple_sign_in_usecase.dart';
import '../../features/authentication/presentation/viewmodels/auth_viewmodel.dart';
import '../../features/onboarding/data/datasources/onboarding_local_datasource.dart';
import '../../features/onboarding/data/repositories/onboarding_repository_impl.dart';
import '../../features/onboarding/domain/repositories/onboarding_repository.dart';
import '../../features/onboarding/domain/usecases/complete_onboarding_usecase.dart';
import '../../features/onboarding/domain/usecases/get_onboarding_status_usecase.dart';
import '../../features/dashboard/presentation/viewmodels/student_dashboard_viewmodel.dart';
import '../../features/dashboard/presentation/viewmodels/admin_dashboard_viewmodel.dart';
import '../../features/dashboard/presentation/viewmodels/teacher_dashboard_viewmodel.dart';
import '../../features/guest/presentation/viewmodels/guest_dashboard_viewmodel.dart';
import '../../features/ai/data/datasources/ai_remote_datasource.dart';
import '../../features/ai/data/repositories/ai_repository_impl.dart';
import '../../features/ai/domain/repositories/ai_repository.dart';
import '../../features/ai/domain/usecases/ai_usecases.dart';
import '../../features/ai/presentation/viewmodels/ai_viewmodels.dart';
import '../../features/community/data/datasources/community_remote_datasource.dart';
import '../../features/community/data/repositories/community_repository_impl.dart';
import '../../features/community/data/repositories/social_repository_impl.dart';
import '../../features/community/domain/repositories/community_repository.dart';
import '../../features/community/domain/repositories/social_repository.dart';
import '../../features/community/domain/usecases/social_usecases.dart';
import '../../features/community/domain/usecases/user_profile_usecases.dart';
import '../../features/community/presentation/viewmodels/social_viewmodel.dart';
import '../../features/culture/culture_providers.dart';
import 'theme_provider.dart';
import 'locale_provider.dart';

/// Centralized list of all app providers
List<SingleChildWidget> get appProviders => [
  // Core Services
  Provider<FirebaseService>(create: (_) => FirebaseService()),

  // Admin & Security Services
  ProxyProvider<FirebaseService, AdminSetupService>(
    update: (_, firebaseService, __) => AdminSetupService(firebaseService),
  ),
  ProxyProvider<FirebaseService, TwoFactorAuthService>(
    update: (_, firebaseService, __) => TwoFactorAuthService(firebaseService),
  ),
  ProxyProvider<FirebaseService, UserRoleServiceHybrid>(
    update: (_, firebaseService, __) => UserRoleServiceHybrid(),
  ),

  // Theme & Locale
  ChangeNotifierProvider<ThemeProvider>(create: (_) => ThemeProvider()),
  ChangeNotifierProvider<LocaleProvider>(create: (_) => LocaleProvider()),

  // Authentication Data Sources
  ProxyProvider<FirebaseService, AuthRemoteDataSource>(
    update: (_, firebaseService, __) => AuthRemoteDataSourceImpl(
      firebaseService: firebaseService,
      googleSignIn: GoogleSignIn(),
    ),
  ),
  Provider<AuthLocalDataSource>(create: (_) => AuthLocalDataSourceImpl()),

  // Connectivity
  Provider<Connectivity>(create: (_) => Connectivity()),

  // Network Info
  ProxyProvider<Connectivity, NetworkInfo>(
    update: (_, connectivity, __) => NetworkInfo(connectivity),
  ),

  // Sync Manager
  ProxyProvider<NetworkInfo, GeneralSyncManager>(
    update: (_, networkInfo, __) =>
        GeneralSyncManager(networkInfo: networkInfo),
  ),

  // Authentication Repository
  ProxyProvider4<
    AuthRemoteDataSource,
    AuthLocalDataSource,
    Connectivity,
    GeneralSyncManager,
    AuthRepository
  >(
    update:
        (_, remoteDataSource, localDataSource, connectivity, syncManager, __) =>
            AuthRepositoryImpl(
              remoteDataSource: remoteDataSource,
              localDataSource: localDataSource,
              connectivity: connectivity,
              syncManager: syncManager,
            ),
  ),

  // Authentication Use Cases
  ProxyProvider<AuthRepository, LoginUsecase>(
    update: (_, repository, __) => LoginUsecase(repository),
  ),
  ProxyProvider<AuthRepository, RegisterUsecase>(
    update: (_, repository, __) => RegisterUsecase(repository),
  ),
  ProxyProvider<AuthRepository, LogoutUsecase>(
    update: (_, repository, __) => LogoutUsecase(repository),
  ),
  ProxyProvider<AuthRepository, GetCurrentUserUsecase>(
    update: (_, repository, __) => GetCurrentUserUsecase(repository),
  ),
  ProxyProvider<AuthRepository, ResetPasswordUsecase>(
    update: (_, repository, __) => ResetPasswordUsecase(repository),
  ),
  ProxyProvider<AuthRepository, GoogleSignInUsecase>(
    update: (_, repository, __) => GoogleSignInUsecase(repository),
  ),
  ProxyProvider<AuthRepository, FacebookSignInUsecase>(
    update: (_, repository, __) => FacebookSignInUsecase(repository),
  ),
  ProxyProvider<AuthRepository, AppleSignInUsecase>(
    update: (_, repository, __) => AppleSignInUsecase(repository),
  ),
  ProxyProvider<AuthRepository, ForgotPasswordUsecase>(
    update: (_, repository, __) => ForgotPasswordUsecase(repository),
  ),
  ProxyProvider<AuthRepository, SignInWithPhoneNumberUsecase>(
    update: (_, repository, __) => SignInWithPhoneNumberUsecase(repository),
  ),
  ProxyProvider<AuthRepository, VerifyPhoneNumberUsecase>(
    update: (_, repository, __) => VerifyPhoneNumberUsecase(repository),
  ),

  // Onboarding Data Source
  Provider<OnboardingLocalDataSource>(
    create: (_) => OnboardingLocalDataSourceImpl(),
  ),

  // Onboarding Repository
  ProxyProvider<OnboardingLocalDataSource, OnboardingRepository>(
    update: (_, dataSource, __) => OnboardingRepositoryImpl(dataSource),
  ),

  // Onboarding Use Cases
  ProxyProvider<OnboardingRepository, CompleteOnboardingUsecase>(
    update: (_, repository, __) => CompleteOnboardingUsecase(repository),
  ),
  ProxyProvider<OnboardingRepository, GetOnboardingStatusUsecase>(
    update: (_, repository, __) => GetOnboardingStatusUsecase(repository),
  ),

  // Authentication ViewModel
  ChangeNotifierProxyProvider<LoginUsecase, AuthViewModel>(
    create: (context) => AuthViewModel(
      loginUsecase: context.read<LoginUsecase>(),
      registerUsecase: context.read<RegisterUsecase>(),
      logoutUsecase: context.read<LogoutUsecase>(),
      resetPasswordUsecase: context.read<ResetPasswordUsecase>(),
      getCurrentUserUsecase: context.read<GetCurrentUserUsecase>(),
      googleSignInUsecase: context.read<GoogleSignInUsecase>(),
      facebookSignInUsecase: context.read<FacebookSignInUsecase>(),
      appleSignInUsecase: context.read<AppleSignInUsecase>(),
      forgotPasswordUsecase: context.read<ForgotPasswordUsecase>(),
      getOnboardingStatusUsecase: context.read<GetOnboardingStatusUsecase>(),
      signInWithPhoneNumberUsecase: context
          .read<SignInWithPhoneNumberUsecase>(),
      verifyPhoneNumberUsecase: context.read<VerifyPhoneNumberUsecase>(),
    ),
    update: (_, __, authViewModel) => authViewModel!,
  ),

  // Dashboard ViewModels
  ChangeNotifierProvider<StudentDashboardViewModel>(
    create: (_) => StudentDashboardViewModel(),
  ),
  ChangeNotifierProvider<AdminDashboardViewModel>(
    create: (_) => AdminDashboardViewModel(),
  ),
  ChangeNotifierProvider<TeacherDashboardViewModel>(
    create: (_) => TeacherDashboardViewModel(),
  ),
  ChangeNotifierProvider<GuestDashboardViewModel>(
    create: (_) => GuestDashboardViewModel(),
  ),

  // AI Service
  Provider<GeminiAIService>(
    create: (_) => GeminiAIService(apiKey: EnvironmentConfig.geminiApiKey),
  ),

  // AI Data Source
  ProxyProvider<GeminiAIService, AiRemoteDataSource>(
    update: (_, geminiService, __) =>
        AiRemoteDataSourceImpl(geminiService: geminiService),
  ),

  // AI Repository
  ProxyProvider3<
    AiRemoteDataSource,
    FirebaseService,
    GeminiAIService,
    AiRepository
  >(
    update: (_, remoteDataSource, firebaseService, geminiService, __) =>
        AiRepositoryImpl(
          remoteDataSource: remoteDataSource,
          firestore: firebaseService.firestore,
          aiService: geminiService,
        ),
  ),

  // AI Use Cases
  ProxyProvider<AiRepository, SendMessageToAI>(
    update: (_, repository, __) => SendMessageToAI(repository),
  ),
  ProxyProvider<AiRepository, StartConversation>(
    update: (_, repository, __) => StartConversation(repository),
  ),
  ProxyProvider<AiRepository, GetUserConversations>(
    update: (_, repository, __) => GetUserConversations(repository),
  ),
  ProxyProvider<AiRepository, TranslateText>(
    update: (_, repository, __) => TranslateText(repository),
  ),
  ProxyProvider<AiRepository, GetTranslationHistory>(
    update: (_, repository, __) => GetTranslationHistory(repository),
  ),
  ProxyProvider<AiRepository, AssessPronunciation>(
    update: (_, repository, __) => AssessPronunciation(repository),
  ),
  ProxyProvider<AiRepository, GetPronunciationHistory>(
    update: (_, repository, __) => GetPronunciationHistory(repository),
  ),
  ProxyProvider<AiRepository, GenerateContent>(
    update: (_, repository, __) => GenerateContent(repository),
  ),
  ProxyProvider<AiRepository, GetPersonalizedRecommendations>(
    update: (_, repository, __) => GetPersonalizedRecommendations(repository),
  ),

  // AI ViewModels
  ChangeNotifierProxyProvider<SendMessageToAI, AiChatViewModel>(
    create: (context) => AiChatViewModel(
      sendMessageToAI: context.read<SendMessageToAI>(),
      startConversation: context.read<StartConversation>(),
      getUserConversations: context.read<GetUserConversations>(),
    ),
    update: (_, __, viewModel) => viewModel!,
  ),
  ChangeNotifierProxyProvider<TranslateText, TranslationViewModel>(
    create: (context) => TranslationViewModel(
      translateText: context.read<TranslateText>(),
      getTranslationHistory: context.read<GetTranslationHistory>(),
    ),
    update: (_, __, viewModel) => viewModel!,
  ),
  ChangeNotifierProxyProvider<AssessPronunciation, PronunciationViewModel>(
    create: (context) => PronunciationViewModel(
      assessPronunciation: context.read<AssessPronunciation>(),
      getPronunciationHistory: context.read<GetPronunciationHistory>(),
    ),
    update: (_, __, viewModel) => viewModel!,
  ),
  ChangeNotifierProxyProvider<GenerateContent, ContentGenerationViewModel>(
    create: (context) => ContentGenerationViewModel(
      generateContent: context.read<GenerateContent>(),
    ),
    update: (_, __, viewModel) => viewModel!,
  ),
  ChangeNotifierProxyProvider<
    GetPersonalizedRecommendations,
    AiRecommendationsViewModel
  >(
    create: (context) => AiRecommendationsViewModel(
      getPersonalizedRecommendations: context
          .read<GetPersonalizedRecommendations>(),
    ),
    update: (_, __, viewModel) => viewModel!,
  ),

  // Community Data Source
  ProxyProvider<FirebaseService, CommunityRemoteDataSource>(
    update: (_, firebaseService, __) =>
        CommunityRemoteDataSourceImpl(firebaseService),
  ),

  // Community Repositories
  ProxyProvider<CommunityRemoteDataSource, CommunityRepository>(
    update: (_, remoteDataSource, __) =>
        CommunityRepositoryImpl(remoteDataSource),
  ),
  ProxyProvider<CommunityRemoteDataSource, SocialRepository>(
    update: (_, remoteDataSource, __) => SocialRepositoryImpl(remoteDataSource),
  ),

  // Community Use Cases
  ProxyProvider<SocialRepository, FollowUserUseCase>(
    update: (_, repository, __) => FollowUserUseCase(repository),
  ),
  ProxyProvider<SocialRepository, UnfollowUserUseCase>(
    update: (_, repository, __) => UnfollowUserUseCase(repository),
  ),
  ProxyProvider<SocialRepository, GetFollowersUseCase>(
    update: (_, repository, __) => GetFollowersUseCase(repository),
  ),
  ProxyProvider<SocialRepository, GetFollowingUseCase>(
    update: (_, repository, __) => GetFollowingUseCase(repository),
  ),
  ProxyProvider<SocialRepository, IsFollowingUseCase>(
    update: (_, repository, __) => IsFollowingUseCase(repository),
  ),
  ProxyProvider<SocialRepository, ShareProgressUseCase>(
    update: (_, repository, __) => ShareProgressUseCase(repository),
  ),
  ProxyProvider<SocialRepository, GetProgressFeedUseCase>(
    update: (_, repository, __) => GetProgressFeedUseCase(repository),
  ),
  ProxyProvider<CommunityRepository, GetUserProfileUseCase>(
    update: (_, repository, __) => GetUserProfileUseCase(repository),
  ),
  ProxyProvider<CommunityRepository, UpdateUserProfileUseCase>(
    update: (_, repository, __) => UpdateUserProfileUseCase(repository),
  ),
  ProxyProvider<CommunityRepository, SearchUsersUseCase>(
    update: (_, repository, __) => SearchUsersUseCase(repository),
  ),
  ProxyProvider<CommunityRepository, GetOnlineUsersUseCase>(
    update: (_, repository, __) => GetOnlineUsersUseCase(repository),
  ),

  // Community ViewModels
  ChangeNotifierProvider<SocialViewModel>(
    create: (context) => SocialViewModel(
      context.read<GetUserProfileUseCase>(),
      context.read<UpdateUserProfileUseCase>(),
      context.read<FollowUserUseCase>(),
      context.read<UnfollowUserUseCase>(),
      context.read<GetFollowersUseCase>(),
      context.read<GetFollowingUseCase>(),
      context.read<IsFollowingUseCase>(),
      context.read<ShareProgressUseCase>(),
      context.read<GetProgressFeedUseCase>(),
    ),
  ),

  // Culture Providers
  ...cultureProviders,
];
