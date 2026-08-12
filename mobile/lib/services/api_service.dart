import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import '../models/prediction.dart';
import '../models/verification_result.dart';

/// SmartCrop AI — API Service
/// Handles real authentication (Register/Login) and AI Disease Diagnosis.
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Backend URLs
  static const String _androidEmulatorUrl = 'http://10.0.2.2:8000';
  static const String _localUrl = 'http://localhost:8000';
  static const Duration _timeout = Duration(seconds: 30);

  // In-memory auth session state
  String? _authToken;
  Map<String, dynamic>? _currentUser;

  String? get authToken => _authToken;
  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isAuthenticated => _authToken != null;

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

  /// Real User Registration
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name.trim(),
          'email': email.trim().toLowerCase(),
          'password': password,
        }),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        _authToken = data['token'];
        _currentUser = data['user'];
        return {'success': true, 'message': data['message'], 'user': data['user']};
      } else {
        return {
          'success': false,
          'message': data['detail'] ?? 'Registration failed. Please try again.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Unable to connect to server. Please ensure the backend is running.',
      };
    }
  }

  /// Real User Login (Strict Password Verification)
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email.trim().toLowerCase(),
          'password': password,
        }),
      ).timeout(_timeout);

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        _authToken = data['token'];
        _currentUser = data['user'];
        return {'success': true, 'message': data['message'], 'user': data['user']};
      } else {
        return {
          'success': false,
          'message': data['detail'] ?? 'Invalid credentials. Please check and try again.',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Unable to connect to server. Please ensure the backend is running.',
      };
    }
  }

  /// Logout
  void logout() {
    _authToken = null;
    _currentUser = null;
  }

  /// Verify image quality
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

  /// Predict crop disease and calculate severity
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
          plantName: cropName ?? 'Unknown Plant',
          crop: cropName ?? 'Unknown',
          diseaseName: 'Analysis Unavailable',
          predictedDisease: 'Analysis Unavailable',
          confidence: 0,
          confidencePercent: 0,
          confidenceLabel: 'None',
          severity: SeverityInfo.defaultFor('Unknown'),
          message: 'Crop analysis is temporarily unavailable. Please try again later.',
          topPredictions: [],
        );
      } else {
        return PredictionResult(
          success: false,
          plantName: cropName ?? 'Unknown Plant',
          crop: cropName ?? 'Unknown',
          diseaseName: 'Diagnosis Failed',
          predictedDisease: 'Diagnosis Failed',
          confidence: 0,
          confidencePercent: 0,
          confidenceLabel: 'None',
          severity: SeverityInfo.defaultFor('Unknown'),
          message: 'We could not analyze your crop. Please try again.',
          topPredictions: [],
        );
      }
    } catch (e) {
      return PredictionResult(
        success: false,
        plantName: cropName ?? 'Unknown Plant',
        crop: cropName ?? 'Unknown',
        diseaseName: 'Connection Error',
        predictedDisease: 'Connection Error',
        confidence: 0,
        confidencePercent: 0,
        confidenceLabel: 'None',
        severity: SeverityInfo.defaultFor('Unknown'),
        message: 'Unable to connect. Please make sure the backend server is running.',
        topPredictions: [],
      );
    }
  }
}
