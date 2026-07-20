import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Supabase
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text('Welcome to The Legit Smoothie! 🥤'),
        ),
      ),
    );
  }
}