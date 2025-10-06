import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/services/two_factor_auth_service.dart';
import '../../../../core/constants/routes.dart';
import '../../../../shared/themes/colors.dart';
import '../viewmodels/auth_viewmodel.dart';

/// Two-Factor Authentication View
class TwoFactorAuthView extends StatefulWidget {
  final String userId;
  final String email;

  const TwoFactorAuthView({
    super.key,
    required this.userId,
    required this.email,
  });

  @override
  State<TwoFactorAuthView> createState() => _TwoFactorAuthViewState();
}

class _TwoFactorAuthViewState extends State<TwoFactorAuthView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _otpController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  bool _otpSent = false;
  bool _useBackupCode = false;

  @override
  void initState() {
    super.initState();
    _sendOTP();
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _sendOTP() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final twoFactorService = context.read<TwoFactorAuthService>();
      final success = await twoFactorService.sendOTPViaEmail(
        widget.userId,
        widget.email,
      );

      if (success) {
        setState(() {
          _otpSent = true;
          _isLoading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Code de vérification envoyé à ${widget.email}'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Échec de l\'envoi du code de vérification';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyOTP() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final twoFactorService = context.read<TwoFactorAuthService>();
      final authViewModel = context.read<AuthViewModel>();

      bool verified = false;

      if (_useBackupCode) {
        verified = await twoFactorService.verifyBackupCode(
          widget.userId,
          _otpController.text.trim(),
        );
      } else {
        verified = await twoFactorService.verifyOTP(
          widget.userId,
          _otpController.text.trim(),
        );
      }

      if (verified && mounted) {
        // 2FA verification successful, navigate to dashboard
        authViewModel.navigateToRoleBasedDashboard(context);
      } else {
        setState(() {
          _errorMessage = 'Code de vérification invalide';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vérification en deux étapes'),
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
              const Icon(
                Icons.security,
                size: 100,
                color: AppColors.onPrimary,
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                _useBackupCode
                    ? 'Entrez un code de récupération'
                    : 'Vérification en deux étapes',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),

              // Instructions
              Text(
                _useBackupCode
                    ? 'Entrez l\'un de vos codes de récupération'
                    : 'Un code de vérification a été envoyé à ${widget.email}',
                style: const TextStyle(
                  fontSize: 16,
                  color: AppColors.onPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // Error message
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                ),

              if (_errorMessage != null) const SizedBox(height: 15),

              // OTP Input
              TextFormField(
                controller: _otpController,
                keyboardType: _useBackupCode
                    ? TextInputType.text
                    : TextInputType.number,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.pin),
                  labelText: _useBackupCode
                      ? 'Code de récupération'
                      : 'Code de vérification',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  filled: true,
                  fillColor: AppColors.surface,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Entrez le code';
                  }
                  if (!_useBackupCode && value.length != 6) {
                    return 'Le code doit contenir 6 chiffres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 25),

              // Verify button
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
                onPressed: _isLoading ? null : _verifyOTP,
                child: _isLoading
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
                        'Vérifier',
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.onPrimary,
                        ),
                      ),
              ),
              const SizedBox(height: 15),

              // Resend code button
              if (!_useBackupCode && _otpSent)
                TextButton(
                  onPressed: _isLoading ? null : _sendOTP,
                  child: const Text(
                    'Renvoyer le code',
                    style: TextStyle(
                      color: AppColors.secondary,
                      fontSize: 16,
                    ),
                  ),
                ),

              // Use backup code toggle
              TextButton(
                onPressed: () {
                  setState(() {
                    _useBackupCode = !_useBackupCode;
                    _otpController.clear();
                    _errorMessage = null;
                  });
                },
                child: Text(
                  _useBackupCode
                      ? 'Utiliser le code de vérification'
                      : 'Utiliser un code de récupération',
                  style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 14,
                  ),
                ),
              ),

              // Cancel button
              TextButton(
                onPressed: () {
                  context.go(Routes.login);
                },
                child: const Text(
                  'Annuler',
                  style: TextStyle(
                    color: AppColors.secondary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
