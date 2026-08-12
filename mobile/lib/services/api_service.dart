import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/prediction.dart';
import '../models/verification_result.dart';

/// SmartCrop AI — API Service
/// Handles all communication with the FastAPI backend.
class ApiService {
  // Change this to your backend URL
  static const String _baseUrl = 'http://10.0.2.2:8000'; // Android emulator
  static const String _webBaseUrl = 'http://localhost:8000'; // Web
  static const Duration _timeout = Duration(seconds: 30);

  String get baseUrl {
    // Use localhost for web, 10.0.2.2 for Android emulator
    try {
      if (Platform.isAndroid) return _baseUrl;
    } catch (_) {}
    return _webBaseUrl;
  }

  /// Health check
  Future<bool> checkHealth() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(_timeout);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'ok';
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Verify image quality
  Future<VerificationResult> verifyImage(File imageFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/verify-image'),
      );

      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      ));

      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return VerificationResult.fromJson(jsonDecode(response.body));
      } else {
        return VerificationResult(
          valid: false,
          resolutionOk: true,
          blurOk: true,
          brightnessOk: true,
          formatOk: true,
          message: 'We could not check your photo. Please try again.',
          issues: ['server_error'],
          details: {},
        );
      }
    } catch (e) {
      return VerificationResult(
        valid: false,
        resolutionOk: true,
        blurOk: true,
        brightnessOk: true,
        formatOk: true,
        message: 'Unable to connect. Please check your internet connection.',
        issues: ['connection_error'],
        details: {},
      );
    }
  }

  /// Predict crop disease
  Future<PredictionResult> predict(File imageFile, {String? cropName}) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/predict'),
      );

      request.files.add(await http.MultipartFile.fromPath(
        'image',
        imageFile.path,
        contentType: MediaType('image', 'jpeg'),
      ));

      if (cropName != null) {
        request.fields['crop'] = cropName;
      }

      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return PredictionResult.fromJson(jsonDecode(response.body));
      } else if (response.statusCode == 503) {
        return PredictionResult(
          success: false,
          crop: cropName ?? 'Unknown',
          predictedDisease: '',
          confidence: 0,
          confidencePercent: 0,
          confidenceLabel: 'None',
          message: 'Crop analysis is temporarily unavailable. Please try again later.',
          topPredictions: [],
        );
      } else {
        return PredictionResult(
          success: false,
          crop: cropName ?? 'Unknown',
          predictedDisease: '',
          confidence: 0,
          confidencePercent: 0,
          confidenceLabel: 'None',
          message: 'We could not analyze your crop. Please try again.',
          topPredictions: [],
        );
      }
    } catch (e) {
      return PredictionResult(
        success: false,
        crop: cropName ?? 'Unknown',
        predictedDisease: '',
        confidence: 0,
        confidencePercent: 0,
        confidenceLabel: 'None',
        message: 'Unable to connect. Please check your internet connection.',
        topPredictions: [],
      );
    }
  }
}
