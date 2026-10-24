import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/app_back_button.dart';
import '../../shared/widgets/auth_text_field.dart';
import '../../shared/widgets/decorative_background.dart';
import '../../shared/widgets/gosika_logo.dart';
import '../../shared/widgets/primary_auth_button.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _isSubmitted = false;
  String _successMessage = '';

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendResetLink() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      try {
        final authService = ref.read(authServiceProvider);
        final message = await authService.forgotPassword(_emailController.text.trim());

        if (mounted) {
          setState(() {
            _isLoading = false;
            _isSubmitted = true;
            _successMessage = message;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppColors.successGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: AppColors.errorRed,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      resizeToAvoidBottomInset: false,
      body: DecorativeBackground(
        child: Column(
          children: [
            // Top App Bar Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  AppBackButton(
                    onPressed: () => context.pop(),
                  ),
                  const Spacer(),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24, 0, 24, bottomInset + 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      // Logo (Prominent 64 size)
                      const GosikaLogo(
                        logoSize: 64,
                        showTagline: false,
                      ),
                      const SizedBox(height: 16),

                      // Standalone Forgot Password Illustration (No white card)
                      SizedBox(
                        height: 170,
                        width: double.infinity,
                        child: Image.asset(
                          AppAssets.forgotPasswordIllustration,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) => Center(
                            child: Icon(
                              Icons.lock_reset_rounded,
                              size: 70,
                              color: AppColors.primaryOrange,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Heading & Description
                      Text(
                        'Forgot Password?',
                        style: AppTextStyles.heading1.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Enter your email address and we\'ll send you a link to reset your password.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          height: 1.45,
                          fontSize: 13.5,
                        ),
                      ),
                      const SizedBox(height: 28),

                      if (_isSubmitted) ...[
                        // Success Confirmation Card
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.successGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.successGreen.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppColors.successGreen,
                                size: 28,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _successMessage.isNotEmpty
                                      ? _successMessage
                                      : 'A reset link has been sent to ${_emailController.text}. Please check your inbox.',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.primaryText,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ] else ...[
                        // Email Field
                        AuthTextField(
                          label: 'Email Address',
                          hintText: 'Enter your email address',
                          prefixIcon: Icons.email_outlined,
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) => _handleSendResetLink(),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter your email address';
                            }
                            final emailRegExp = RegExp(
                                r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
                            if (!emailRegExp.hasMatch(value.trim())) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 28),

                        // Send Reset Link Button
                        PrimaryAuthButton(
                          text: 'Send Reset Link',
                          isLoading: _isLoading,
                          onPressed: _handleSendResetLink,
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Back to Login Link
                      TextButton(
                        onPressed: () => context.pop(),
                        child: Text(
                          'Back to Login',
                          style: AppTextStyles.button.copyWith(
                            color: AppColors.primaryOrange,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
