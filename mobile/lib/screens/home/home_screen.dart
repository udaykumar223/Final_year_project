import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../models/crop.dart';
import '../../services/api_service.dart';

/// SmartCrop AI — Ultra-Premium Crop Health Dashboard
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final ApiService _api = ApiService();
  final ImagePicker _picker = ImagePicker();

  Crop _selectedCrop = Crop.defaults[0]; // Default Banana
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 90,
      );
      if (photo != null && mounted) {
        Navigator.of(context).pushNamed(
          '/image-preview',
          arguments: {
            'imagePath': photo.path,
            'crop': _selectedCrop,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not access ${source == ImageSource.camera ? "camera" : "gallery"}.'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _api.currentUser;
    final userName = user != null && user['name'] != null ? user['name'] : 'Farmer';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment(0, -0.7),
            radius: 1.1,
            colors: [
              Color(0xFF0D251C),
              Color(0xFF0A1612),
              Color(0xFF050B09),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.screenPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Profile & Live AI Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Hello, $userName',
                              style: AppTextStyles.headlineMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Text('👋', style: TextStyle(fontSize: 20)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Ready to inspect your crops today',
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                    // Live AI Indicator Chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceGlass,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.accent,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'AI READY',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                // Hero Futuristic Scanner Card
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final pulseVal = _pulseController.value;
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      decoration: BoxDecoration(
                        gradient: AppColors.heroGradient,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                        border: Border.all(
                          color: AppColors.accent.withValues(alpha: 0.3 + (pulseVal * 0.3)),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2 + (pulseVal * 0.15)),
                            blurRadius: 24,
                            spreadRadius: 2,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                    ),
                                    child: Text(
                                      'VISION TRANSFORMER',
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.accent,
                                        letterSpacing: 1,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Instant Leaf Diagnosis',
                                    style: AppTextStyles.headlineLarge.copyWith(
                                      color: Colors.white,
                                      fontSize: 22,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withValues(alpha: 0.1),
                                ),
                                child: const Icon(
                                  Icons.psychology_rounded,
                                  color: AppColors.accent,
                                  size: 28,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Point your camera at any affected leaf to detect disease and estimate severity in seconds.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // Two Main Action Buttons: Camera & Gallery
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _pickImage(ImageSource.camera),
                                  icon: const Icon(Icons.camera_alt_rounded, size: 20),
                                  label: const Text('Take Photo'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primaryLight,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _pickImage(ImageSource.gallery),
                                  icon: const Icon(Icons.photo_library_rounded, size: 20),
                                  label: const Text('From Gallery'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.white,
                                    side: const BorderSide(color: Colors.white70, width: 1.2),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: AppSpacing.xxl),

                // Active Crops Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Target Crop Type',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Select to scan',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Crop Cards Selector
                Row(
                  children: Crop.defaults.map((crop) {
                    final isSelected = _selectedCrop.id == crop.id;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedCrop = crop);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.surfaceVariant : AppColors.surfaceCard,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                            border: Border.all(
                              color: isSelected ? AppColors.accent : AppColors.border,
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(alpha: 0.3),
                                      blurRadius: 12,
                                    ),
                                  ]
                                : [],
                          ),
                          child: Column(
                            children: [
                              Text(crop.emoji, style: const TextStyle(fontSize: 32)),
                              const SizedBox(height: 6),
                              Text(
                                crop.displayName,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.titleSmall.copyWith(
                                  color: isSelected ? Colors.white : AppColors.textSecondary,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${crop.diseaseCount} Diseases',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: isSelected ? AppColors.accent : AppColors.textTertiary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: AppSpacing.xxl),

                // System Performance & Reliability Banner
                Container(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetricItem('88.3%', 'Model Accuracy', Icons.verified_rounded, AppColors.accent),
                      Container(width: 1, height: 36, color: AppColors.border),
                      _buildMetricItem('20 Classes', 'Disease Coverage', Icons.category_rounded, AppColors.info),
                      Container(width: 1, height: 36, color: AppColors.border),
                      _buildMetricItem('< 1.2s', 'Inference Speed', Icons.speed_rounded, AppColors.warning),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetricItem(String value, String label, IconData icon, Color iconColor) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 4),
            Text(
              value,
              style: AppTextStyles.titleMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}
