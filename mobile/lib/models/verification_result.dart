/// SmartCrop AI — Verification Result Model
class VerificationResult {
  final bool valid;
  final bool resolutionOk;
  final bool blurOk;
  final bool brightnessOk;
  final bool formatOk;
  final String message;
  final List<String> issues;
  final Map<String, dynamic> details;

  const VerificationResult({
    required this.valid,
    required this.resolutionOk,
    required this.blurOk,
    required this.brightnessOk,
    required this.formatOk,
    required this.message,
    required this.issues,
    required this.details,
  });

  factory VerificationResult.fromJson(Map<String, dynamic> json) {
    return VerificationResult(
      valid: json['valid'] ?? false,
      resolutionOk: json['resolution_ok'] ?? true,
      blurOk: json['blur_ok'] ?? true,
      brightnessOk: json['brightness_ok'] ?? true,
      formatOk: json['format_ok'] ?? true,
      message: json['message'] ?? 'Unknown',
      issues: List<String>.from(json['issues'] ?? []),
      details: Map<String, dynamic>.from(json['details'] ?? {}),
    );
  }

  /// Number of checks that passed
  int get passedChecks {
    int count = 0;
    if (resolutionOk) count++;
    if (blurOk) count++;
    if (brightnessOk) count++;
    if (formatOk) count++;
    return count;
  }

  int get totalChecks => 4;
}
