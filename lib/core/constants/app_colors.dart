import 'package:flutter/material.dart';

/// App Color Palette extracted from "The Legit Smoothie" logo.
abstract class AppColors {
  // --- Brand Primary Colors ---
  
  /// Soft Taro Pink/Lavender from the Panda's head
  static const Color primary = Color(0xFFD3B0CF);
  
  
  /// Deeper variant of primary for active states or focused borders
  static const Color primaryDark = Color(0xFFA2789E);

  // --- Brand Secondary Colors ---
  
  /// Rich Boba Brown / Milk Tea color from the cup
  static const Color secondary = Color(0xFFC38E5A);
  
  /// Dark Boba Pearl Brown for accents or cup shadows
  static const Color bobaBrown = Color(0xFF533118);
  
  /// Creamy Cream / Milk Foam tone from the cup highlights and panda ears inner accent
  static const Color cream = Color(0xFFEBD8B8);

  // --- Neutral Colors ---
  
  /// Deep Charcoal / Black from the logo outline and panda ears/eyes
  static const Color darkText = Color(0xFF1E1C1A);
  
  /// Soft Grey for subtle borders or inactive icons
  static const Color greyBorder = Color(0xFFE0E0E0);
  
  /// Muted Secondary Text Grey
  static const Color greyText = Color(0xFF757575);
  
  /// Light Grey for screen backgrounds
  static const Color background = Color(0xFFF9F9FB);
  
  /// Pure White for card backgrounds
  static const Color cardWhite = Color(0xFFFFFFFF);

  // --- Status Colors ---
  static const Color error = Color(0xFFE57373);
  static const Color success = Color(0xFF81C784);
  static const Color warning = Color(0xFFFFB74D);
}