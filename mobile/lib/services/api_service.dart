import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import '../models/prediction.dart';
import '../models/verification_result.dart';

/// SmartCrop AI — API Service
/// Handles all communication with the FastAPI backend across Web and Mobile.
class ApiService {
  // Backend URLs
  static const String _androidEmulatorUrl = 'http://10.0.2.2:8000';
  static const String _localUrl = 'http://localhost:8000';
  static const Duration _timeout = Duration(seconds: 30);

  String get baseUrl {
    if (kIsWeb) {
      return _localUrl;
    }
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        return _androidEmulatorUrl;
      }
    } catch (_) {}
    return _localUrl;
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

  /// Verify image quality (supports Web and Mobile paths)
  Future<VerificationResult> verifyImage(String imagePath) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/verify-image'),
      );

      final bytes = await XFile(imagePath).readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: 'leaf_verify.jpg',
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
        message: 'Unable to connect. Please make sure the backend server is running.',
        issues: ['connection_error'],
        details: {},
      );
    }
  }

  /// Predict crop disease (supports Web and Mobile paths)
  Future<PredictionResult> predict(String imagePath, {String? cropName}) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/predict'),
      );

      final bytes = await XFile(imagePath).readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'image',
        bytes,
        filename: 'leaf_predict.jpg',
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
        message: 'Unable to connect. Please make sure the backend server is running.',
        topPredictions: [],
      );
    }
  }
}
