import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:the_legit_smoothie/features/auth/views/login_screen.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  runApp(const TheLegitSmoothieApp());
}

// Global accessor for Supabase client
final supabase = Supabase.instance.client;

class TheLegitSmoothieApp extends StatelessWidget {
  const TheLegitSmoothieApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Legit Smoothie',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      // Set LoginScreen as the entry point when the app first loads
      home: const LoginScreen(),
    );
  }
}