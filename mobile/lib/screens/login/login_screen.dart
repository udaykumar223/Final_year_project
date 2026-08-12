import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';

/// SmartCrop AI — Login Screen
/// Clean, modular authentication with premium styling
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    // For 30% milestone — simplified auth
    setState(() => _isLoading = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        setState(() => _isLoading = false);
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.screenPaddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.massive),

              // Logo
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('\u{1F33F}', style: TextStyle(fontSize: 36)),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Title
              Center(
                child: Text(
                  'Welcome Back',
                  style: AppTextStyles.displaySmall,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              Center(
                child: Text(
                  'Sign in to check your crop health',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // Email field
              Text('Email or Phone', style: AppTextStyles.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Enter your email or phone',
                  prefixIcon: Icon(Icons.person_outline, color: AppColors.textTertiary),
                ),
                style: AppTextStyles.bodyLarge,
              ),

              const SizedBox(height: AppSpacing.lg),

              // Password field
              Text('Password', style: AppTextStyles.labelLarge),
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textTertiary),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      color: AppColors.textTertiary,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                style: AppTextStyles.bodyLarge,
              ),

              const SizedBox(height: AppSpacing.md),

              // Forgot password
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child: Text(
                    'Forgot Password?',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Login button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text('Sign In', style: AppTextStyles.buttonLarge),
              ),

              const SizedBox(height: AppSpacing.base),

              // Divider
              Row(
                children: [
                  const Expanded(child: Divider(color: AppColors.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
                    child: Text(
                      'or',
                      style: AppTextStyles.bodySmall,
                    ),
                  ),
                  const Expanded(child: Divider(color: AppColors.border)),
                ],
              ),

              const SizedBox(height: AppSpacing.base),

              // Create account button
              OutlinedButton(
                onPressed: () {
                  // For 30% — just navigate to home
                  Navigator.of(context).pushReplacementNamed('/home');
                },
                child: Text('Create Account', style: AppTextStyles.buttonLarge.copyWith(
                  color: AppColors.primary,
                )),
              ),

              const SizedBox(height: AppSpacing.xxl),

              // Skip for now (demo purposes)
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/home');
                  },
                  child: Text(
                    'Skip for now',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textTertiary,
                      decoration: TextDecoration.underline,
                    ),
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
