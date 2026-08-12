import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

/// SmartCrop AI — Analysis Step Widget
/// Shows a single step in the AI analysis pipeline
class AnalysisStep extends StatelessWidget {
  final String label;
  final AnalysisStepState state;

  const AnalysisStep({
    super.key,
    required this.label,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.sm,
        horizontal: AppSpacing.base,
      ),
      child: Row(
        children: [
          _buildIcon(),
          const SizedBox(width: AppSpacing.md),
          Text(
            label,
            style: AppTextStyles.bodyLarge.copyWith(
              color: _textColor,
              fontWeight: state == AnalysisStepState.active
                  ? FontWeight.w600
                  : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon() {
    switch (state) {
      case AnalysisStepState.completed:
        return const Icon(Icons.check_circle_rounded,
            color: AppColors.success, size: 24);
      case AnalysisStepState.active:
        return SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: AppColors.primary,
          ),
        );
      case AnalysisStepState.error:
        return const Icon(Icons.error_rounded,
            color: AppColors.danger, size: 24);
      case AnalysisStepState.pending:
        return Icon(Icons.radio_button_unchecked_rounded,
            color: AppColors.textTertiary, size: 24);
    }
  }

  Color get _textColor {
    switch (state) {
      case AnalysisStepState.completed:
        return AppColors.textPrimary;
      case AnalysisStepState.active:
        return AppColors.primary;
      case AnalysisStepState.error:
        return AppColors.danger;
      case AnalysisStepState.pending:
        return AppColors.textTertiary;
    }
  }
}

enum AnalysisStepState { pending, active, completed, error }
