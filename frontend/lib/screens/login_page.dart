// ignore_for_file: unused_import, avoid_print, use_build_context_synchronously
import 'package:flutter/material.dart';
import '../globals.dart' as globals;
import 'package:frontend/screens/register_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/screens/student_home.dart';
import 'package:frontend/screens/admin_home.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? userToken;

  // Logic to connect to your Laravel Backend [cite: 34]
  Future<void> login() async {
  if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please fill in all fields")),
    );
    return;
  }

  setState(() => _isLoading = true);
  
  try {
    // Note: 'localhost' works for Chrome. 
    // If using a physical phone, use your IP address (e.g., 192.168.1.xx)
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/api/login'),
      body: {
        'email': _emailController.text,
        'password': _passwordController.text,
      },
    );

    print("Response Status: ${response.statusCode}");
    print("Response Body: ${response.body}");

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      print("FULL API RESPONSE: $data");
      globals.userToken = data['token'] ?? data['plainTextToken'] ?? data['access_token'];
      print("SUCCESS: ${data['user']['role']}");
      print("Login Success. Token: ${globals.userToken}");
      String role = data['user']['role'];
      Widget nextScreen;
      
      // Navigate based on actor role [cite: 9, 28]
      if (role == 'admin') {
        nextScreen = const AdminHome();
      } else if (role == 'student') {
        nextScreen = StudentHome(userData: data['user']);
      } else if (role == 'teacher') {
         // Placeholder until TeacherHome is created [cite: 11]
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Teacher Dashboard coming soon!")),
        );
        return;
      } else {
        nextScreen = const AdminHome();
      }
      Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => nextScreen),
    );
    }
     else {
      // Show error message from Laravel (e.g., "Invalid Credentials" or "Pending Validation") [cite: 13]
      print("LARAVEL ERROR: ${response.body}"); 
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Error: ${data['message']}"),
        backgroundColor: Colors.redAccent,
      ),
    );
    }
    
  } catch (e) {
    // If this runs, Flutter can't talk to Laravel at all
    print("Connection Error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Could not connect to server. Is Laravel running?")),
    );
  } finally {
    setState(() => _isLoading = false);
  }
}

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF5F5F7), // Light Gray background
    body: Center(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Requirement 2: Logo Placeholder
              Image.asset(
                'assets/campus_connect_logo.png',
                height: 250,
                errorBuilder: (context, error, stackTrace) => 
                  const Icon(Icons.school, size: 100, color: Color(0xFF673AB7)),
              ),
              const SizedBox(height: 40),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(25),
                  child: Column(
                    children: [
                      TextField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: "University Email",
                          prefixIcon: Icon(Icons.email_outlined, color: Color(0xFF673AB7)),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: "Password",
                          prefixIcon: Icon(Icons.lock_outline, color: Color(0xFF673AB7)),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 30),
                      _isLoading 
                        ? const CircularProgressIndicator()
                        : ElevatedButton(
                            onPressed: login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF673AB7),
                              minimumSize: const Size(double.infinity, 55),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text("Sign In", style: TextStyle(color: Colors.white, fontSize: 18)),
                          ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),
              // Requirement 3: Sign Up Link
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage())),
                child: RichText(
                  text: const TextSpan(
                    text: "Don't have a Campus Connect account? ",
                    style: TextStyle(color: Colors.black54),
                    children: [
                      TextSpan(
                        text: "Sign Up.",
                        style: TextStyle(color: Color(0xFF673AB7), fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}