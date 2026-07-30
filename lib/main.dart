import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:the_legit_smoothie/core/constants/app_colors.dart';
import 'package:the_legit_smoothie/features/admin/views/admin_dashboard_screen.dart';
import 'package:the_legit_smoothie/features/auth/views/login_screen.dart';
import 'package:the_legit_smoothie/features/seller/views/seller_dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Load saved theme preference prior to app build
  final prefs = await SharedPreferences.getInstance();
  final savedThemeIndex = prefs.getInt('theme_mode') ?? ThemeMode.light.index;
  final initialThemeMode = ThemeMode.values[savedThemeIndex];

  runApp(TheLegitSmoothieApp(initialThemeMode: initialThemeMode));
}

final supabase = Supabase.instance.client;

class TheLegitSmoothieApp extends StatefulWidget {
  final ThemeMode initialThemeMode;

  const TheLegitSmoothieApp({super.key, required this.initialThemeMode});

  @override
  State<TheLegitSmoothieApp> createState() => _TheLegitSmoothieAppState();
}

class _TheLegitSmoothieAppState extends State<TheLegitSmoothieApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
  }

  // Update in-memory state AND persist to local storage
  Future<void> _updateThemeMode(ThemeMode newMode) async {
    setState(() {
      _themeMode = newMode;
    });

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_mode', newMode.index);
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
          primary: AppColors.bobaBrown,
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
          primary: AppColors.bobaBrown,
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
class AuthGate extends StatefulWidget {
  final ThemeMode currentThemeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;

  const AuthGate({
    super.key,
    required this.currentThemeMode,
    required this.onThemeModeChanged,
  });

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Future<String?>? _roleFuture;
  String? _lastUserId;

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
          _roleFuture = null;
          _lastUserId = null;
          return LoginScreen(
            currentThemeMode: widget.currentThemeMode,
            onThemeModeChanged: widget.onThemeModeChanged,
          );
        }

        // Only fetch the role if the user ID changed or hasn't been fetched yet
        if (_roleFuture == null || _lastUserId != session.user.id) {
          _lastUserId = session.user.id;
          _roleFuture = _getUserRole(session.user.id);
        }

        return FutureBuilder<String?>(
          future: _roleFuture,
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(color: AppColors.bobaBrown),
                ),
              );
            }

            final role = roleSnapshot.data;

            if (role == 'admin') {
              return AdminDashboardScreen(
                currentThemeMode: widget.currentThemeMode,
                onThemeModeChanged: widget.onThemeModeChanged,
              );
            } else if (role == 'seller') {
              return SellerDashboardScreen(
                currentThemeMode: widget.currentThemeMode,
                onThemeModeChanged: widget.onThemeModeChanged,
              );
            } else {
              return AdminDashboardScreen(
                currentThemeMode: widget.currentThemeMode,
                onThemeModeChanged: widget.onThemeModeChanged,
              );
            }
          },
        );
      },
    );
  }
}
