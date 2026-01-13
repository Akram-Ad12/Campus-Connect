// ignore_for_file: unused_import, avoid_print, use_build_context_synchronously
import 'dart:ui'; // Required for BackdropFilter (Glass effect)
import 'package:flutter/material.dart';
import '../globals.dart' as globals;
import 'package:frontend/screens/register_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend/screens/student_home.dart';
import 'package:frontend/screens/teacher_home.dart';
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

  Future<void> login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final response = await http.post(
        Uri.parse('http://${globals.serverIP}:8000/api/login'),
        body: {
          'email': _emailController.text,
          'password': _passwordController.text,
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        globals.userToken = data['token'] ?? data['plainTextToken'] ?? data['access_token'];
        String role = data['user']['role'];
        Widget nextScreen;
        
        if (role == 'admin') {
          nextScreen = const AdminHome();
        } else if (role == 'student') {
          nextScreen = const StudentHome();
        } else if (role == 'teacher') {
          nextScreen = const TeacherHome();
        } else {
          nextScreen = const LoginPage();
        }
        
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => nextScreen),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${data['message']}"),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not connect to server.")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF5F3FF), Color(0xFFEDE9FE), Color(0xFFDDD6FE)],
              ),
            ),
          ),
          
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/campus_connect_logo.png',
                        height: 180,
                        errorBuilder: (context, error, stackTrace) => 
                          const Icon(Icons.school, size: 80, color: Color(0xFF673AB7)),
                      ),
                      const SizedBox(height: 10),
                      
                      Text(
                        "Sign In",
                        style: GoogleFonts.poppins(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF311B92),
                          letterSpacing: 1.2,
                        ),
                      ),
                      Text(
                        "Welcome to Campus Connect",
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.black45,
                        ),
                      ),
                      const SizedBox(height: 30),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.white.withOpacity(0.5)),
                            ),
                            child: Column(
                              children: [
                                _buildTextField(
                                  controller: _emailController,
                                  label: "University Email",
                                  icon: Icons.email_outlined,
                                ),
                                const SizedBox(height: 20),
                                _buildTextField(
                                  controller: _passwordController,
                                  label: "Password",
                                  icon: Icons.lock_outline,
                                  isPassword: true,
                                ),
                                const SizedBox(height: 30),
                                
                                _isLoading 
                                  ? const CircularProgressIndicator(color: Color(0xFF673AB7))
                                  : Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        boxShadow: [
                                          BoxShadow(
                                            color: const Color(0xFF673AB7).withOpacity(0.3),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                          )
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        onPressed: login,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF673AB7),
                                          foregroundColor: Colors.white,
                                          minimumSize: const Size(double.infinity, 55),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                          elevation: 0,
                                        ),
                                        child: const Text("Continue", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                      ),
                                    ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      GestureDetector(
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterPage())),
                        child: RichText(
                          text: TextSpan(
                            text: "Don't have an account? ",
                            style: GoogleFonts.poppins(color: Colors.black54, fontSize: 13),
                            children: const [
                              TextSpan(
                                text: "Sign Up",
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
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black45, fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF673AB7), size: 20),
        filled: true,
        fillColor: Colors.white.withOpacity(0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
    );
  }
}