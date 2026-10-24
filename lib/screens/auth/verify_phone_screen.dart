import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../providers/auth_provider.dart';
import '../../shared/widgets/app_back_button.dart';
import '../../shared/widgets/auth_text_field.dart';
import '../../shared/widgets/decorative_background.dart';
import '../../shared/widgets/gosika_logo.dart';
import '../../shared/widgets/primary_auth_button.dart';

class VerifyPhoneScreen extends ConsumerStatefulWidget {
  final String? phone;
  const VerifyPhoneScreen({super.key, this.phone});

  @override
  ConsumerState<VerifyPhoneScreen> createState() => _VerifyPhoneScreenState();
}

class _VerifyPhoneScreenState extends ConsumerState<VerifyPhoneScreen> {
  final _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    FocusScope.of(context).unfocus();

    if (_codeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter the OTP code.'),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final authService = ref.read(authServiceProvider);
      final result = await authService.verifyPhoneOtp(_codeController.text.trim());

      if (result.user != null) {
        ref.read(authProvider.notifier).setUser(result.user);
      } else {
        await ref.read(authProvider.notifier).checkAuth();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Phone number verified! Welcome to GOSIKA.'),
            backgroundColor: AppColors.successGreen,
          ),
        );
        context.go('/');
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

  Future<void> _handleResend() async {
    setState(() => _isLoading = true);
    try {
      await ref.read(authServiceProvider).sendPhoneOtp();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('OTP code resent!'),
            backgroundColor: AppColors.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.creamBackground,
      body: DecorativeBackground(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  AppBackButton(onPressed: () => context.pop()),
                  const Spacer(),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    const GosikaLogo(logoSize: 52, showTagline: false),
                    const SizedBox(height: 24),
                    Text(
                      'Verify Your Phone',
                      style: AppTextStyles.heading1.copyWith(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter the OTP code sent to ${widget.phone ?? 'your phone number'}',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium.copyWith(height: 1.45),
                    ),
                    const SizedBox(height: 32),
                    AuthTextField(
                      label: 'OTP Code',
                      hintText: 'Enter 6-digit code',
                      prefixIcon: Icons.phone_android_outlined,
                      controller: _codeController,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _handleVerify(),
                    ),
                    const SizedBox(height: 28),
                    PrimaryAuthButton(
                      text: 'Verify & Continue',
                      isLoading: _isLoading,
                      onPressed: _handleVerify,
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: _isLoading ? null : _handleResend,
                      child: Text(
                        'Resend Code',
                        style: AppTextStyles.button.copyWith(
                          color: AppColors.primaryOrange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
