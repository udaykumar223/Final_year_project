import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../services/api_service.dart';

/// SmartCrop AI — Ultra-Premium Authentication Screen
/// Real Sign In and Account Creation with MongoDB Backend
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  final _formKey = GlobalKey<FormState>();

  bool _isSignUp = false;
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      Map<String, dynamic> response;
      if (_isSignUp) {
        response = await _api.register(
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
        );
      } else {
        response = await _api.login(
          email: _emailController.text,
          password: _passwordController.text,
        );
      }

      if (!mounted) return;

      if (response['success'] == true) {
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Authentication failed.';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An error occurred. Please try again.';
          _isLoading = false;
        });
      }
    }
  }

  void _toggleAuthMode(bool isSignUp) {
    setState(() {
      _isSignUp = isSignUp;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.6),
            radius: 1.2,
            colors: [
              Color(0xFF0F2B20),
              Color(0xFF0A1612),
              Color(0xFF050B09),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
                vertical: AppSpacing.lg,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: FadeTransition(
                  opacity: _fadeController,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Brand Logo & Glowing Icon
                      Container(
                        width: 76,
                        height: 76,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.primaryGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.45),
                              blurRadius: 30,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.eco_rounded,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),

                      Text(
                        'SMARTCROP AI',
                        style: AppTextStyles.headlineLarge.copyWith(
                          color: Colors.white,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'Intelligent Crop Disease Diagnosis & Health Advisory',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: AppSpacing.xl),

                      // Glassmorphic Auth Card
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceGlass,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                          border: Border.all(
                            color: AppColors.borderGlow.withValues(alpha: 0.2),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.4),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Segmented Switcher (Sign In vs Create Account)
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => _toggleAuthMode(false),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          decoration: BoxDecoration(
                                            color: !_isSignUp ? AppColors.primary : Colors.transparent,
                                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                            boxShadow: !_isSignUp
                                                ? [
                                                    BoxShadow(
                                                      color: AppColors.primary.withValues(alpha: 0.3),
                                                      blurRadius: 8,
                                                    ),
                                                  ]
                                                : [],
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Sign In',
                                            style: AppTextStyles.titleSmall.copyWith(
                                              color: !_isSignUp ? Colors.white : AppColors.textSecondary,
                                              fontWeight: !_isSignUp ? FontWeight.w700 : FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () => _toggleAuthMode(true),
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                          decoration: BoxDecoration(
                                            color: _isSignUp ? AppColors.primary : Colors.transparent,
                                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                            boxShadow: _isSignUp
                                                ? [
                                                    BoxShadow(
                                                      color: AppColors.primary.withValues(alpha: 0.3),
                                                      blurRadius: 8,
                                                    ),
                                                  ]
                                                : [],
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            'Create Account',
                                            style: AppTextStyles.titleSmall.copyWith(
                                              color: _isSignUp ? Colors.white : AppColors.textSecondary,
                                              fontWeight: _isSignUp ? FontWeight.w700 : FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: AppSpacing.lg),

                              // Error Banner
                              if (_errorMessage != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: AppColors.dangerLight,
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                    border: Border.all(color: AppColors.danger.withValues(alpha: 0.4)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 20),
                                      const SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        child: Text(
                                          _errorMessage!,
                                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.danger),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.md),
                              ],

                              // Full Name Field (Sign Up Only)
                              if (_isSignUp) ...[
                                TextFormField(
                                  controller: _nameController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    labelText: 'Full Name',
                                    hintText: 'Enter your name',
                                    prefixIcon: Icon(Icons.person_rounded, color: AppColors.accent),
                                  ),
                                  validator: (val) {
                                    if (_isSignUp && (val == null || val.trim().length < 2)) {
                                      return 'Please enter your full name';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: AppSpacing.md),
                              ],

                              // Email Field
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  labelText: 'Email Address',
                                  hintText: 'farmer@example.com',
                                  prefixIcon: Icon(Icons.email_rounded, color: AppColors.accent),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Email is required';
                                  }
                                  if (!val.contains('@') || !val.contains('.')) {
                                    return 'Please enter a valid email address';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: AppSpacing.md),

                              // Password Field with Eye Toggle
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  hintText: _isSignUp ? 'At least 6 characters' : 'Enter password',
                                  prefixIcon: const Icon(Icons.lock_rounded, color: AppColors.accent),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                                      color: AppColors.textSecondary,
                                    ),
                                    onPressed: () {
                                      setState(() => _obscurePassword = !_obscurePassword);
                                    },
                                  ),
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Password is required';
                                  }
                                  if (_isSignUp && val.length < 6) {
                                    return 'Password must be at least 6 characters';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: AppSpacing.xl),

                              // Submit Action Button
                              ElevatedButton(
                                onPressed: _isLoading ? null : _submitAuth,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shadowColor: AppColors.primary.withValues(alpha: 0.5),
                                  elevation: 6,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(
                                        _isSignUp ? 'Create Farmer Account' : 'Sign In to Dashboard',
                                        style: AppTextStyles.buttonLarge.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: AppSpacing.lg),

                      // Explore as Guest / Skip Button
                      TextButton.icon(
                        onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
                        icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                        label: Text(
                          'Continue as Guest (Demo Mode)',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
