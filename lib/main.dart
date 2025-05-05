import 'package:flutter/material.dart';
import 'package:flutter_practical_25/ui/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const VocabVaultApp());
}

class VocabVaultApp extends StatelessWidget {
  const VocabVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VocabVault',
      theme: ThemeData(
        primaryColor: Colors.teal,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          secondary: Colors.amber,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.grey[100],
        textTheme: GoogleFonts.poppinsTextTheme(),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
