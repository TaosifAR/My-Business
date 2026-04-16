import 'package:flutter/material.dart';
import 'package:get/get.dart'; // GetX import korun
import 'package:my_business/features/home/views/home_screen.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
  debugShowCheckedModeBanner: false,
  title: 'My Business',
  theme:ThemeData(
  useMaterial3: true,
  // Primary color hishebe Deep Navy r Accent hishebe Emerald Green
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF0F172A), 
    primary: const Color(0xFF0F172A),      // Buttons & AppBar text
    secondary: const Color(0xFF10B981),    // Green Accent (Green type color)
    surface: Colors.white,
    background: const Color(0xFFF8FAFC),   // App body background color
  ),
  
  // AppBar configuration
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      color: Color(0xFF0F172A),
      fontSize: 18,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(color: Color(0xFF0F172A)),
  ),

  // Default Button Style
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF0F172A), // Deep Navy button
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  ),
),
  home: const HomeScreen(),
);
  }
}