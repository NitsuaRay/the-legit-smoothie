import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Load saved theme preference prior to app build

  runApp(TheLegitSmoothieApp as Widget);
}

final supabase = Supabase.instance.client;

class TheLegitSmoothieApp extends StatefulWidget {
  final ThemeMode initialThemeMode;

  const TheLegitSmoothieApp({super.key, required this.initialThemeMode});

  @override
  State<TheLegitSmoothieApp> createState() => _TheLegitSmoothieAppState();
}

class _TheLegitSmoothieAppState extends State<TheLegitSmoothieApp> {

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Legit Smoothie',
      debugShowCheckedModeBanner: false,

    
      
    );
  }
}

