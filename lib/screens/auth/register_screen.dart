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
import '../../shared/widgets/social_login_button.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _acceptTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() ?? false) {
      if (!_acceptTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please accept the Terms of Service & Privacy Policy.'),
            backgroundColor: AppColors.errorRed,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        final rawName = _fullNameController.text.trim();
        final nameParts = rawName.split(RegExp(r'\s+'));
        final firstName =
            nameParts.isNotEmpty && nameParts.first.isNotEmpty ? nameParts.first : rawName;
        final lastName =
            nameParts.length > 1 && nameParts.sublist(1).join(' ').trim().isNotEmpty
                ? nameParts.sublist(1).join(' ').trim()
                : firstName; // Fallback to firstName if user enters a single name!

        final authService = ref.read(authServiceProvider);
        final result = await authService.register(
          firstName: firstName,
          lastName: lastName,
          email: _emailController.text.trim(),
          phone: '+977${_phoneController.text.trim()}',
          password: _passwordController.text,
          passwordConfirmation: _confirmPasswordController.text,
        );

        if (mounted) {
          if (result.user != null && result.token != null) {
            ref.read(authProvider.notifier).setUser(result.user);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Account created successfully! Welcome to GOSIKA.'),
                backgroundColor: AppColors.successGreen,
              ),
            );
            context.go('/');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registration successful! Please verify your code.'),
                backgroundColor: AppColors.successGreen,
              ),
            );
            context.push('/verify-email', extra: _emailController.text.trim());
          }
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
      resizeToAvoidBottomInset: false, // Prevents background image shifting up
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

            // Form Scrollable Container
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(24, 0, 24, bottomInset + 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 8),

                      // Logo (Larger 64 size)
                      const GosikaLogo(
                        logoSize: 64,
                        showTagline: false,
                      ),
                      const SizedBox(height: 18),

                      // Heading & Subtitle
                      Text(
                        'Create Your Account',
                        style: AppTextStyles.heading1.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Join GOSIKA and start shopping today.',
                        style: AppTextStyles.bodyMedium,
                      ),
                      const SizedBox(height: 24),

                      // 1. Full Name
                      AuthTextField(
                        label: 'Full Name',
                        hintText: 'Enter your full name',
                        prefixIcon: Icons.person_outline_rounded,
                        controller: _fullNameController,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // 2. Email Address
                      AuthTextField(
                        label: 'Email Address',
                        hintText: 'Enter your email address',
                        prefixIcon: Icons.email_outlined,
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
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
                      const SizedBox(height: 16),

                      // 3. Phone Number
                      AuthTextField(
                        label: 'Phone Number',
                        hintText: '98XXXXXXXX',
                        prefixIcon: Icons.phone_outlined,
                        prefixText: '+977 ',
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter your phone number';
                          }
                          if (value.trim().length < 10) {
                            return 'Please enter a valid 10-digit phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // 4. Password
                      AuthTextField(
                        label: 'Password',
                        hintText: 'Create a password (min. 8 chars)',
                        prefixIcon: Icons.lock_outline_rounded,
                        controller: _passwordController,
                        isPassword: true,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters long';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // 5. Confirm Password
                      AuthTextField(
                        label: 'Confirm Password',
                        hintText: 'Re-enter your password',
                        prefixIcon: Icons.lock_outline_rounded,
                        controller: _confirmPasswordController,
                        isPassword: true,
                        textInputAction: TextInputAction.done,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please confirm your password';
                          }
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),

                      // Terms & Conditions Checkbox
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 22,
                            height: 22,
                            child: Checkbox(
                              value: _acceptTerms,
                              onChanged: (v) {
                                setState(() => _acceptTerms = v ?? false);
                              },
                              activeColor: AppColors.primaryOrange,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.primaryText,
                                  height: 1.4,
                                ),
                                children: [
                                  const TextSpan(text: 'I agree to GOSIKA\'s '),
                                  TextSpan(
                                    text: 'Terms of Service',
                                    style: TextStyle(
                                      color: AppColors.primaryOrange,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const TextSpan(text: ' and '),
                                  TextSpan(
                                    text: 'Privacy Policy',
                                    style: TextStyle(
                                      color: AppColors.primaryOrange,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const TextSpan(text: '.'),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Primary Action: Create Account
                      PrimaryAuthButton(
                        text: 'Create Account',
                        isLoading: _isLoading,
                        onPressed: _handleRegister,
                      ),
                      const SizedBox(height: 20),

                      // Social Logins Divider
                      Row(
                        children: [
                          const Expanded(child: Divider(color: AppColors.border)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'OR',
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ),
                          const Expanded(child: Divider(color: AppColors.border)),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Social Buttons
                      const Row(
                        children: [
                          Expanded(
                            child: SocialLoginButton(
                              provider: SocialProvider.google,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: SocialLoginButton(
                              provider: SocialProvider.facebook,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Bottom Text: Already have an account? Log In
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: AppTextStyles.bodyMedium,
                          ),
                          GestureDetector(
                            onTap: () => context.pop(),
                            child: Text(
                              'Log In',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primaryOrange,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
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
