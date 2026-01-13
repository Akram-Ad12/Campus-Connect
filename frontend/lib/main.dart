import 'package:flutter/material.dart';
import 'package:frontend/screens/login_page.dart';
import 'package:frontend/screens/student_home.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Color(0xFFF5F3FF), 
    systemNavigationBarIconBrightness: Brightness.dark, 
    systemNavigationBarDividerColor: Colors.transparent,
  ));

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  runApp(const CampusConnect());
}

class CampusConnect extends StatelessWidget {
  const CampusConnect({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // The builder wraps every route in the app automatically
      builder: (context, child) {
        return Scaffold(
          // This SafeArea (bottom: true) pushes everything above the Android bar
          body: SafeArea(
            top: false, // Usually you want the status bar to be transparent/colored
            bottom: true, 
            child: child!,
          ),
        );
      },
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginPage(),
        '/student_home': (context) => const StudentHome(),
      },
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF673AB7)),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
    );
  }
}
