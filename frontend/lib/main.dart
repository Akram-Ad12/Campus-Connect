import 'package:flutter/material.dart';
import 'package:frontend/screens/login_page.dart';
import 'package:frontend/screens/student_home.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const CampusConnect());
}

class CampusConnect extends StatelessWidget {
  const CampusConnect({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
      '/login': (context) => const LoginPage(), // Make sure your LoginPage class is named correctly
      '/student_home': (context) => const StudentHome(),
    },
      title: 'Campus Connect',
      theme: ThemeData(
        useMaterial3: true,
        // Using a professional Deep Purple shade
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF673AB7), 
          brightness: Brightness.light,
          primary: const Color(0xFF673AB7),
          secondary: const Color(0xFF512DA8),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(), // Clean, modern font
      ),
      home: const LoginPage(),
    );
  }
}
