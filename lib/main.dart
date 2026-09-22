import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:the_legit_smoothie/widgets/internet_connection_wrapper.dart';

import 'core/constants/app_colors.dart';
import 'firebase_options.dart';
import 'splash_screen.dart';

// ============================================================
// GLOBAL NAVIGATOR KEY
// ============================================================

final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ============================================================
  // ENVIRONMENT VARIABLES
  // ============================================================

  await dotenv.load(
    fileName: '.env',
  );

  // ============================================================
  // FIREBASE
  // ============================================================

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ============================================================
  // SUPABASE
  // ============================================================

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    publishableKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  // ============================================================
  // START APP
  // ============================================================

  runApp(
    const TheLegitSmoothieApp(),
  );
}

// ============================================================
// GLOBAL SUPABASE CLIENT
// ============================================================

final supabase = Supabase.instance.client;

// ============================================================
// APP
// ============================================================

class TheLegitSmoothieApp extends StatelessWidget {
  const TheLegitSmoothieApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // ========================================================
      // GLOBAL NAVIGATOR
      // ========================================================

      navigatorKey: navigatorKey,

      title: 'The Legit',
      debugShowCheckedModeBanner: false,

      // ========================================================
      // INTERNET CONNECTION WRAPPER
      // ========================================================

      builder: (context, child) {
        return InternetConnectionWrapper(
          child: child ?? const SizedBox.shrink(),
        );
      },

      // ========================================================
      // THEME
      // ========================================================

      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor:
            AppColors.background,
        primaryColor: AppColors.primary,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.surface,
          error: AppColors.error,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor:
              AppColors.background,
          foregroundColor:
              AppColors.textPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevatedButtonTheme:
            ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                AppColors.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme:
            InputDecorationTheme(
          focusedBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 2,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: AppColors.border,
            ),
          ),
        ),
      ),

      // ========================================================
      // STARTING SCREEN
      // ========================================================

      home: const SplashScreen(),
    );
  }
}