import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../models/crop.dart';
import '../../services/api_service.dart';

/// SmartCrop AI — Ultra-Premium Crop Health & Field Advisory Dashboard
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

  // Recent diagnostic records
  final List<Map<String, dynamic>> _recentScans = [
    {
      'crop': 'Banana',
      'emoji': '🍌',
      'disease': 'Cordana Leaf Spot',
      'severity': 'Moderate',
      'score': '65%',
      'color': AppColors.moderate,
      'time': '10 mins ago',
    },
    {
      'crop': 'Radish',
      'emoji': '🥬',
      'disease': 'Healthy Leaf',
      'severity': 'Healthy',
      'score': '0%',
      'color': AppColors.healthy,
      'time': '2 hours ago',
    },
    {
      'crop': 'Groundnut',
      'emoji': '🥜',
      'disease': 'Early Leaf Spot',
      'severity': 'Mild',
      'score': '30%',
      'color': AppColors.mild,
      'time': 'Yesterday',
    },
  ];

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

  Future<void> _pickFromGallery() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
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
          const SnackBar(
            content: Text('Could not access gallery. Please check permissions.'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _openCameraScanner() {
    Navigator.of(context).pushNamed(
      '/scan',
      arguments: _selectedCrop,
    );
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
                // Header: Profile & Live Status
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
                            const Text('🌾', style: TextStyle(fontSize: 20)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Crop Health & Field Advisory',
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
                            'ONLINE',
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

                const SizedBox(height: AppSpacing.lg),

                // Live Agricultural Field & Spraying Advisory Widget
                Container(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceGlass,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.infoLight,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                        child: const Icon(Icons.wb_sunny_rounded, color: AppColors.info, size: 24),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Field Conditions: 28°C • Low Wind',
                                  style: AppTextStyles.labelMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.successLight,
                                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                  ),
                                  child: Text(
                                    'GOOD TO SPRAY',
                                    style: AppTextStyles.labelSmall.copyWith(color: AppColors.success, fontSize: 9),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Optimal morning conditions for bio-fungicide or neem oil application.',
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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
                                      'SELECTED: ${_selectedCrop.displayName.toUpperCase()}',
                                      style: AppTextStyles.labelSmall.copyWith(
                                        color: AppColors.accent,
                                        letterSpacing: 1,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Scan & Diagnose Leaf',
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
                                child: Text(_selectedCrop.emoji, style: const TextStyle(fontSize: 26)),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            'Take a clear photo of an affected leaf to identify plant disease and severity in seconds.',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // Two Main Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: _openCameraScanner,
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
                                  onPressed: _pickFromGallery,
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

                const SizedBox(height: AppSpacing.xl),

                // Target Crop Type Header
                Text(
                  'Target Crop Type',
                  style: AppTextStyles.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // Crop Cards (Only Crops displayed cleanly)
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
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: 8),
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
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(crop.emoji, style: const TextStyle(fontSize: 32)),
                              const SizedBox(height: 8),
                              Text(
                                crop.displayName,
                                textAlign: TextAlign.center,
                                style: AppTextStyles.titleSmall.copyWith(
                                  color: isSelected ? Colors.white : AppColors.textSecondary,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Recent Field Diagnoses
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Recent Field Diagnoses',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Synced to Cloud',
                      style: AppTextStyles.bodySmall.copyWith(color: AppColors.textTertiary),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Recent Diagnostics Feed
                Column(
                  children: _recentScans.map((scan) {
                    final color = scan['color'] as Color;
                    return Container(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                            child: Text(scan['emoji'], style: const TextStyle(fontSize: 22)),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      scan['disease'],
                                      style: AppTextStyles.titleSmall.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: color.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                                        border: Border.all(color: color.withValues(alpha: 0.4)),
                                      ),
                                      child: Text(
                                        '${scan['severity'].toUpperCase()} (${scan['score']})',
                                        style: AppTextStyles.labelSmall.copyWith(
                                          color: color,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${scan['crop']} Plant • ${scan['time']}',
                                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: AppSpacing.xl),

                // Practical Agronomic Tip Card
                Container(
                  padding: const EdgeInsets.all(AppSpacing.base),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        ),
                        child: const Icon(Icons.shield_rounded, color: AppColors.accent, size: 24),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Preventive Field Tip: ${_selectedCrop.displayName}',
                              style: AppTextStyles.titleSmall.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedCrop.id == 'banana'
                                  ? 'Deleaf old or spotted leaves at the base to improve sunlight and restrict Sigatoka spore circulation.'
                                  : _selectedCrop.id == 'groundnut'
                                      ? 'Apply bio-fertilizer Trichoderma to the root zone to strengthen resistance against soil-borne root rot.'
                                      : 'Ensure proper row spacing to avoid moisture stagnation and prevent Downy Mildew.',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
