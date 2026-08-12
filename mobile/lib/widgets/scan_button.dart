import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

/// SmartCrop AI — Premium Scan Button
/// Large, visually prominent call-to-action
class ScanButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;

  const ScanButton({
    super.key,
    required this.onPressed,
    this.label = 'SCAN NOW',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 22),
            const SizedBox(width: AppSpacing.sm),
            Text(
              label,
              style: AppTextStyles.buttonLarge.copyWith(
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
