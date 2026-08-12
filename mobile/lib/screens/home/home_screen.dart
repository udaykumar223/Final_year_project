import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../models/crop.dart';
import '../../widgets/crop_card.dart';

/// SmartCrop AI — Home Screen
/// Premium farmer dashboard with SCAN hero card
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppSpacing.xl),

              // Greeting header
              _buildHeader(),

              const SizedBox(height: AppSpacing.xxl),

              // Hero SCAN card
              _buildHeroScanCard(context),

              const SizedBox(height: AppSpacing.xxl),

              // Your Crops section
              Text('Your Crops', style: AppTextStyles.headlineSmall),
              const SizedBox(height: AppSpacing.md),

              ...Crop.availableCrops.map((crop) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: CropCard(
                  crop: crop,
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      '/scan',
                      arguments: crop,
                    );
                  },
                ),
              )),

              // Coming soon crops
              const SizedBox(height: AppSpacing.base),
              Text(
                'Coming Soon',
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              ...Crop.futureCrops.map((crop) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: CropCard(crop: crop),
              )),

              const SizedBox(height: AppSpacing.xxl),

              // Quick stats
              _buildQuickStats(),

              const SizedBox(height: AppSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$greeting \u{1F44B}',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text('Farmer', style: AppTextStyles.headlineLarge),
          ],
        ),
        // Profile avatar
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Center(
            child: Text(
              'F',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroScanCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('/crop-selection');
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          gradient: AppColors.heroGradient,
          borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.base),

            // Camera icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                ),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            Text(
              'SCAN YOUR CROP',
              style: AppTextStyles.headlineMedium.copyWith(
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),

            const SizedBox(height: AppSpacing.sm),

            Text(
              'Check your crop health in seconds',
              style: AppTextStyles.bodyMedium.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Scan button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: Center(
                child: Text(
                  'SCAN NOW',
                  style: AppTextStyles.buttonLarge.copyWith(
                    color: AppColors.primary,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.base),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          _buildStatItem(
            icon: Icons.eco_rounded,
            label: 'Crops',
            value: '${Crop.availableCrops.length}',
            color: AppColors.success,
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.divider,
          ),
          _buildStatItem(
            icon: Icons.bug_report_rounded,
            label: 'Diseases',
            value: '20',
            color: AppColors.warning,
          ),
          Container(
            width: 1,
            height: 40,
            color: AppColors.divider,
          ),
          _buildStatItem(
            icon: Icons.psychology_rounded,
            label: 'AI Model',
            value: 'Ready',
            color: AppColors.info,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(value, style: AppTextStyles.titleSmall),
          Text(label, style: AppTextStyles.labelSmall),
        ],
      ),
    );
  }
}
