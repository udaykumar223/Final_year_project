/// SmartCrop AI — Prediction & Severity Model
class PredictionResult {
  final bool success;
  final String plantName;
  final String crop;
  final String diseaseName;
  final String predictedDisease;
  final double confidence;
  final double confidencePercent;
  final String confidenceLabel;
  final SeverityInfo severity;
  final String message;
  final List<PredictionItem> topPredictions;
  final String? requestedCrop;

  const PredictionResult({
    required this.success,
    required this.plantName,
    required this.crop,
    required this.diseaseName,
    required this.predictedDisease,
    required this.confidence,
    required this.confidencePercent,
    required this.confidenceLabel,
    required this.severity,
    required this.message,
    required this.topPredictions,
    this.requestedCrop,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    final detectedCrop = json['crop'] ?? json['plant_name'] ?? 'Unknown';
    final detectedDisease = json['predicted_disease'] ?? json['disease_name'] ?? 'Unknown';

    return PredictionResult(
      success: json['success'] ?? true,
      plantName: json['plant_name'] ?? '$detectedCrop Plant',
      crop: detectedCrop,
      diseaseName: json['disease_name'] ?? detectedDisease,
      predictedDisease: detectedDisease,
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      confidencePercent: (json['confidence_percent'] ?? 0.0).toDouble(),
      confidenceLabel: json['confidence_label'] ?? 'Unknown',
      severity: json['severity'] != null
          ? SeverityInfo.fromJson(json['severity'])
          : SeverityInfo.defaultFor(detectedDisease),
      message: json['message'] ?? '',
      topPredictions: (json['top_predictions'] as List<dynamic>?)
              ?.map((e) => PredictionItem.fromJson(e))
              .toList() ??
          [],
      requestedCrop: json['requested_crop'],
    );
  }
}

class SeverityInfo {
  final String level;
  final double score;
  final String color;
  final String advisory;

  const SeverityInfo({
    required this.level,
    required this.score,
    required this.color,
    required this.advisory,
  });

  factory SeverityInfo.fromJson(Map<String, dynamic> json) {
    return SeverityInfo(
      level: json['level'] ?? 'Mild',
      score: (json['score'] ?? 30.0).toDouble(),
      color: json['color'] ?? '#F59E0B',
      advisory: json['advisory'] ?? 'Monitor plant daily for changes in leaf symptoms.',
    );
  }

  factory SeverityInfo.defaultFor(String disease) {
    if (disease.toLowerCase().contains('healthy')) {
      return const SeverityInfo(
        level: 'Healthy',
        score: 0.0,
        color: '#10B981',
        advisory: 'The plant is in great health! Maintain regular irrigation and care.',
      );
    }
    return const SeverityInfo(
      level: 'Moderate',
      score: 55.0,
      color: '#F97316',
      advisory: 'Active symptoms detected. Treat with recommended agricultural solutions.',
    );
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
