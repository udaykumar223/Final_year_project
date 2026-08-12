/// SmartCrop AI — Prediction Model
class PredictionResult {
  final bool success;
  final String crop;
  final String predictedDisease;
  final double confidence;
  final double confidencePercent;
  final String confidenceLabel;
  final String message;
  final List<PredictionItem> topPredictions;
  final String? requestedCrop;

  const PredictionResult({
    required this.success,
    required this.crop,
    required this.predictedDisease,
    required this.confidence,
    required this.confidencePercent,
    required this.confidenceLabel,
    required this.message,
    required this.topPredictions,
    this.requestedCrop,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      success: json['success'] ?? true,
      crop: json['crop'] ?? 'Unknown',
      predictedDisease: json['predicted_disease'] ?? 'Unknown',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      confidencePercent: (json['confidence_percent'] ?? 0.0).toDouble(),
      confidenceLabel: json['confidence_label'] ?? 'Unknown',
      message: json['message'] ?? '',
      topPredictions: (json['top_predictions'] as List<dynamic>?)
              ?.map((e) => PredictionItem.fromJson(e))
              .toList() ??
          [],
      requestedCrop: json['requested_crop'],
    );
  }

  /// Farmer-friendly confidence color
  String get confidenceEmoji {
    if (confidencePercent >= 75) return '\u2705';
    if (confidencePercent >= 50) return '\u26A0\uFE0F';
    return '\u274C';
  }
}

class PredictionItem {
  final String className;
  final String crop;
  final String disease;
  final double confidence;

  const PredictionItem({
    required this.className,
    required this.crop,
    required this.disease,
    required this.confidence,
  });

  factory PredictionItem.fromJson(Map<String, dynamic> json) {
    return PredictionItem(
      className: json['class_name'] ?? '',
      crop: json['crop'] ?? '',
      disease: json['disease'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
    );
  }
}
