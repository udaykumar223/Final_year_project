import 'package:flutter/material.dart';

import 'theme/app_theme.dart';
import 'models/crop.dart';
import 'models/prediction.dart';

// Screens
import 'screens/splash/splash_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/crop_selection/crop_selection_screen.dart';
import 'screens/scan/scan_screen.dart';
import 'screens/image_preview/image_preview_screen.dart';
import 'screens/verification/verification_screen.dart';
import 'screens/analysis/analysis_screen.dart';
import 'screens/result/result_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SmartCropApp());
}

class SmartCropApp extends StatelessWidget {
  const SmartCropApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartCrop AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/home',
      onGenerateRoute: _onGenerateRoute,
    );
  }

  Route<dynamic>? _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
      case '/home':
        return _fadeRoute(const HomeScreen(), settings);

      case '/splash':
        return _fadeRoute(const SplashScreen(), settings);

      case '/login':
        return _fadeRoute(const LoginScreen(), settings);

      case '/crop-selection':
        return _slideRoute(const CropSelectionScreen(), settings);

      case '/scan':
        final crop = (settings.arguments is Crop) ? (settings.arguments as Crop) : Crop.defaults[0];
        return _slideRoute(ScanScreen(crop: crop), settings);

      case '/image-preview':
        final args = settings.arguments is Map<String, dynamic> ? (settings.arguments as Map<String, dynamic>) : null;
        if (args == null) return _fadeRoute(const HomeScreen(), settings);
        return _slideRoute(
          ImagePreviewScreen(
            imagePath: args['imagePath'] as String,
            crop: args['crop'] is Crop ? args['crop'] as Crop : Crop.defaults[0],
          ),
          settings,
        );

      case '/verification':
        final args = settings.arguments is Map<String, dynamic> ? (settings.arguments as Map<String, dynamic>) : null;
        if (args == null) return _fadeRoute(const HomeScreen(), settings);
        return _slideRoute(
          VerificationScreen(
            imagePath: args['imagePath'] as String,
            crop: args['crop'] is Crop ? args['crop'] as Crop : Crop.defaults[0],
          ),
          settings,
        );

      case '/analysis':
        final args = settings.arguments is Map<String, dynamic> ? (settings.arguments as Map<String, dynamic>) : null;
        if (args == null) return _fadeRoute(const HomeScreen(), settings);
        return _fadeRoute(
          AnalysisScreen(
            imagePath: args['imagePath'] as String,
            crop: args['crop'] is Crop ? args['crop'] as Crop : Crop.defaults[0],
          ),
          settings,
        );

      case '/result':
        final args = settings.arguments is Map<String, dynamic> ? (settings.arguments as Map<String, dynamic>) : null;
        if (args == null || args['prediction'] == null) return _fadeRoute(const HomeScreen(), settings);
        return _slideRoute(
          ResultScreen(
            prediction: args['prediction'] as PredictionResult,
            imagePath: args['imagePath'] as String,
            crop: args['crop'] is Crop ? args['crop'] as Crop : Crop.defaults[0],
          ),
          settings,
        );

      default:
        return _fadeRoute(const HomeScreen(), settings);
    }
  }

  /// Fade transition for major screen changes
  static Route _fadeRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, a1, a2) => page,
      transitionsBuilder: (context, animation, a2, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  /// Slide transition for navigation within flows
  static Route _slideRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, a1, a2) => page,
      transitionsBuilder: (context, animation, a2, child) {
        final tween = Tween(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
    );
  }
}
