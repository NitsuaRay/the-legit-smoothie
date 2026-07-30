import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';
import 'package:the_legit_smoothie/features/admin/views/admin_dashboard_screen.dart';
import 'package:the_legit_smoothie/features/auth/views/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const TheLegitSmoothieApp());
}

final supabase = Supabase.instance.client;

class TheLegitSmoothieApp extends StatefulWidget {
  const TheLegitSmoothieApp({super.key});

  @override
  State<TheLegitSmoothieApp> createState() => _TheLegitSmoothieAppState();
}

class _TheLegitSmoothieAppState extends State<TheLegitSmoothieApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _updateThemeMode(ThemeMode newMode) {
    setState(() {
      _themeMode = newMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Legit Smoothie',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,

      // --- LIGHT THEME ---
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.cardWhite,
        ),
      ),

      // --- DARK THEME ---
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.bobaBrown,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryDark,
          secondary: AppColors.cream,
          surface: AppColors.darkText,
        ),
      ),

      home: AuthGate(
        currentThemeMode: _themeMode,
        onThemeModeChanged: _updateThemeMode,
      ),
    );
  }
}

/// Automatically handles session persistence and role routing on app startup
/// Automatically handles session persistence and role routing on app startup
class AuthGate extends StatelessWidget {
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const AuthGate({
    super.key,
    required this.currentThemeMode,
    required this.onThemeModeChanged,
  });

  Future<String?> _getUserRole(String userId) async {
    try {
      final response = await supabase
          .from('profiles')
          .select('role')
          .eq('id', userId)
          .single();
      return response['role'] as String?;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: supabase.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = supabase.auth.currentSession;

        if (session == null) {
          return LoginScreen(
            currentThemeMode: currentThemeMode, // Removed 'widget.'
            onThemeModeChanged: onThemeModeChanged, // Removed 'widget.'
          );
        }

        // 2. If session exists, fetch user role from profile
        return FutureBuilder<String?>(
          future: _getUserRole(session.user.id),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primaryDark,
                  ),
                ),
              );
            }

            final role = roleSnapshot.data;

            if (role == 'admin') {
              return AdminDashboardScreen(
                currentThemeMode: currentThemeMode,
                onThemeModeChanged: onThemeModeChanged,
              );
            } else if (role == 'seller') {
              // TODO: Return SellerDashboardScreen()
              return AdminDashboardScreen(
                currentThemeMode: currentThemeMode,
                onThemeModeChanged: onThemeModeChanged,
              );
            } else {
              // TODO: Return CustomerHomeScreen()
              return AdminDashboardScreen(
                currentThemeMode: currentThemeMode,
                onThemeModeChanged: onThemeModeChanged,
              );
            }
          },
        );
      },
    );
  }
}