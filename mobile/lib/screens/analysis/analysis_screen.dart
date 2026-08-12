import 'dart:io';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../models/crop.dart';
import '../../services/api_service.dart';

/// SmartCrop AI — AI Analysis Screen
/// Premium animated analysis progress, then navigates to result
class AnalysisScreen extends StatefulWidget {
  final String imagePath;
  final Crop crop;

  const AnalysisScreen({
    super.key,
    required this.imagePath,
    required this.crop,
  });

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final ApiService _api = ApiService();
  final List<_AnalysisStep> _steps = [
    _AnalysisStep('Image received', StepStatus.pending),
    _AnalysisStep('Image verified', StepStatus.pending),
    _AnalysisStep('Image processed', StepStatus.pending),
    _AnalysisStep('Detecting disease', StepStatus.pending),
    _AnalysisStep('Preparing result', StepStatus.pending),
  ];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _runAnalysis();
  }

  Future<void> _updateStep(int index, StepStatus status,
      {int delayMs = 400}) async {
    await Future.delayed(Duration(milliseconds: delayMs));
    if (mounted) {
      setState(() {
        _steps[index].status = status;
      });
    }
  }

  Future<void> _runAnalysis() async {
    try {
      // Step 1: Image received
      await _updateStep(0, StepStatus.completed, delayMs: 300);

      // Step 2: Image verified
      await _updateStep(1, StepStatus.active, delayMs: 200);
      await _updateStep(1, StepStatus.completed, delayMs: 400);

      // Step 3: Image processed
      await _updateStep(2, StepStatus.active, delayMs: 200);
      await _updateStep(2, StepStatus.completed, delayMs: 500);

      // Step 4: Detecting disease (actual API call)
      await _updateStep(3, StepStatus.active, delayMs: 200);

      final result = await _api.predict(
        File(widget.imagePath),
        cropName: widget.crop.name,
      );

      if (!mounted) return;

      if (result.success) {
        await _updateStep(3, StepStatus.completed, delayMs: 300);
        await _updateStep(4, StepStatus.active, delayMs: 200);
        await _updateStep(4, StepStatus.completed, delayMs: 400);

        // Navigate to result
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(
            '/result',
            arguments: {
              'prediction': result,
              'imagePath': widget.imagePath,
              'crop': widget.crop,
            },
          );
        }
      } else {
        await _updateStep(3, StepStatus.error, delayMs: 0);
        setState(() {
          _errorMessage = result.message;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'We could not analyze your crop. Please try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.screenPaddingLarge),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // Title
              Text(
                'ANALYZING CROP',
                style: AppTextStyles.headlineLarge.copyWith(
                  letterSpacing: 2,
                  color: AppColors.primary,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              Text(
                'Checking ${widget.crop.displayName} health...',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),

              const SizedBox(height: AppSpacing.xxxl),

              // Steps
              ...List.generate(_steps.length, (index) {
                final step = _steps[index];
                return _buildStepRow(step);
              }),

              // Error message
              if (_errorMessage != null) ...[
                const SizedBox(height: AppSpacing.xl),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.base),
                  decoration: BoxDecoration(
                    color: AppColors.dangerLight,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(
                      color: AppColors.danger.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.danger,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.base),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.danger,
                        ),
                        child: Text('Go Back',
                            style: AppTextStyles.buttonMedium
                                .copyWith(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ],

              const Spacer(flex: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepRow(_AnalysisStep step) {
    IconData icon;
    Color iconColor;
    Color textColor;

    switch (step.status) {
      case StepStatus.completed:
        icon = Icons.check_circle_rounded;
        iconColor = AppColors.success;
        textColor = AppColors.textPrimary;
        break;
      case StepStatus.active:
        icon = Icons.radio_button_checked_rounded;
        iconColor = AppColors.primary;
        textColor = AppColors.primary;
        break;
      case StepStatus.error:
        icon = Icons.error_rounded;
        iconColor = AppColors.danger;
        textColor = AppColors.danger;
        break;
      case StepStatus.pending:
        icon = Icons.radio_button_unchecked_rounded;
        iconColor = AppColors.textTertiary;
        textColor = AppColors.textTertiary;
        break;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.base,
      ),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: step.status == StepStatus.active
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.primary,
                    ),
                  )
                : Icon(icon, color: iconColor, size: 24, key: ValueKey(step.status)),
          ),
          const SizedBox(width: AppSpacing.base),
          Text(
            step.label,
            style: AppTextStyles.bodyLarge.copyWith(
              color: textColor,
              fontWeight: step.status == StepStatus.active
                  ? FontWeight.w600
                  : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

enum StepStatus { pending, active, completed, error }

class _AnalysisStep {
  final String label;
  StepStatus status;

  _AnalysisStep(this.label, this.status);
}
