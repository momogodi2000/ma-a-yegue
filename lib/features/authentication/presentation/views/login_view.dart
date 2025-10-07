import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/routes.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/services/two_factor_auth_service_hybrid.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../../../../shared/themes/colors.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 15)),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Fermer',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final authViewModel = context.read<AuthViewModel>();
    final success = await authViewModel.login(
      emailController.text.trim(),
      passwordController.text,
    );

    if (success && mounted) {
      final user = authViewModel.currentUser;
      if (user == null) return;

      // Check if 2FA is required
      try {
        final twoFactorService = context.read<TwoFactorAuthService>();
        final needs2FA = await twoFactorService.needs2FAVerification(user.id);

        if (mounted) {
          if (needs2FA) {
            // Redirect to 2FA verification
            context.go(
              Routes.twoFactorAuth,
              extra: {'userId': user.id, 'email': user.email},
            );
          } else {
            // Navigation will be handled by the router based on auth state and role
            authViewModel.navigateToRoleBasedDashboard(context);
          }
        }
      } catch (e) {
        // If 2FA check fails, proceed to dashboard
        if (mounted) {
          authViewModel.navigateToRoleBasedDashboard(context);
        }
      }
    } else if (authViewModel.errorMessage != null && mounted) {
      _showErrorSnackBar(authViewModel.errorMessage!);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final authViewModel = context.read<AuthViewModel>();
    final success = await authViewModel.signInWithGoogle();

    if (success && mounted) {
      // Navigation will be handled by the router based on auth state and role
      authViewModel.navigateToRoleBasedDashboard(context);
    } else if (authViewModel.errorMessage != null && mounted) {
      _showErrorSnackBar(authViewModel.errorMessage!);
    }
  }

  Future<void> _handleFacebookSignIn() async {
    final authViewModel = context.read<AuthViewModel>();
    final success = await authViewModel.signInWithFacebook();

    if (success && mounted) {
      // Navigation will be handled by the router based on auth state and role
      authViewModel.navigateToRoleBasedDashboard(context);
    } else if (authViewModel.errorMessage != null && mounted) {
      _showErrorSnackBar(authViewModel.errorMessage!);
    }
  }

  Future<void> _handleAppleSignIn() async {
    final authViewModel = context.read<AuthViewModel>();
    final success = await authViewModel.signInWithApple();

    if (success && mounted) {
      // Navigation will be handled by the router based on auth state and role
      authViewModel.navigateToRoleBasedDashboard(context);
    } else if (authViewModel.errorMessage != null && mounted) {
      _showErrorSnackBar(authViewModel.errorMessage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Connexion"),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Icon(Icons.lock, size: 100, color: AppColors.onPrimary),
              const SizedBox(height: 20),

              // Error message display
              if (authViewModel.errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Text(
                    authViewModel.errorMessage!,
                    style: const TextStyle(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                ),

              if (authViewModel.errorMessage != null)
                const SizedBox(height: 15),

              // Email field
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email),
                  labelText: "Email",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                validator: (value) => Validators.getEmailError(value ?? ''),
              ),
              const SizedBox(height: 15),

              // Password field
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock),
                  labelText: "Mot de passe",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Entrez votre mot de passe";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 25),

              // Login button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.onPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                    vertical: 15,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: authViewModel.isLoading ? null : _handleLogin,
                child: authViewModel.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const Text(
                        "Se connecter",
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.onPrimary,
                        ),
                      ),
              ),
              const SizedBox(height: 15),

              // Social Sign In Buttons
              const Text(
                'Ou continuer avec',
                style: TextStyle(color: AppColors.onPrimary, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // Google Sign In Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: authViewModel.isLoading ? null : _handleGoogleSignIn,
                icon: Image.asset(
                  'assets/icons/google.png', // You'll need to add this asset
                  height: 24,
                  width: 24,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.g_mobiledata),
                ),
                label: const Text('Continuer avec Google'),
              ),
              const SizedBox(height: 10),

              // Facebook Sign In Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1877F2),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: authViewModel.isLoading
                    ? null
                    : _handleFacebookSignIn,
                icon: const Icon(Icons.facebook),
                label: const Text('Continuer avec Facebook'),
              ),
              const SizedBox(height: 10),

              // Apple Sign In Button
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: authViewModel.isLoading ? null : _handleAppleSignIn,
                icon: const Icon(Icons.apple),
                label: const Text('Continuer avec Apple'),
              ),
              const SizedBox(height: 10),

              // Phone Auth Button
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.secondary, width: 2),
                  foregroundColor: AppColors.secondary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(double.infinity, 48),
                ),
                onPressed: authViewModel.isLoading
                    ? null
                    : () => context.go(Routes.phoneAuth),
                icon: const Icon(Icons.phone),
                label: const Text('Connexion par SMS'),
              ),
              const SizedBox(height: 15),

              // Forgot password - More prominent
              Container(
                alignment: Alignment.center,
                child: TextButton(
                  onPressed: () {
                    context.go(Routes.forgotPassword);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    "Mot de passe oublié ?",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Register navigation - More prominent
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Pas encore de compte ?",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        context.go(Routes.register);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        "S'inscrire",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
