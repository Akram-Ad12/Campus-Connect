// ignore_for_file: unused_import, avoid_print, use_build_context_synchronously
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:frontend/globals.dart' as globals;
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> register() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showFeedback("Please fill in all fields", false);
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      _showFeedback("Passwords do not match!", false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('http://${globals.serverIP}:8000/api/register'),
        body: {
          'name': _nameController.text,
          'email': _emailController.text,
          'password': _passwordController.text, 
          'role': 'student',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 || response.statusCode == 200) {
        _showFeedback("Register completed, Pending admin approval", true);
      } else {
        String errorMsg = data['message'] ?? "Registration failed";
        _showFeedback(errorMsg, false);
      }
    } catch (e) {
      _showFeedback("Could not connect to server.", false);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showFeedback(String message, bool isSuccess) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isSuccess ? "Success" : "Error", 
          style: TextStyle(color: isSuccess ? Colors.green : Colors.redAccent)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (isSuccess) Navigator.pop(context); 
            },
            child: const Text("OK", style: TextStyle(color: Color(0xFF673AB7), fontWeight: FontWeight.bold)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        elevation: 0, 
        iconTheme: const IconThemeData(color: Color(0xFF311B92))
      ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 35),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/campus_connect_logo.png',
                        height: 150,
                        errorBuilder: (context, error, stackTrace) => 
                          const Icon(Icons.school, size: 60, color: Color(0xFF673AB7)),
                      ),
                      
                      Text(
                        "Create Account",
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF311B92),
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "Join our student community today",
                        style: TextStyle(color: Colors.black45, fontSize: 13),
                      ),
                      const SizedBox(height: 25),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(25),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.white.withOpacity(0.5)),
                            ),
                            child: Column(
                              children: [
                                _buildTextField(
                                  controller: _nameController,
                                  label: "Full Name",
                                  icon: Icons.person_outline,
                                ),
                                const SizedBox(height: 15),
                                _buildTextField(
                                  controller: _emailController,
                                  label: "University Email",
                                  icon: Icons.email_outlined,
                                ),
                                const SizedBox(height: 15),
                                _buildTextField(
                                  controller: _passwordController,
                                  label: "Password",
                                  icon: Icons.lock_outline,
                                  isPassword: true,
                                ),
                                const SizedBox(height: 15),
                                _buildTextField(
                                  controller: _confirmPasswordController,
                                  label: "Confirm Password",
                                  icon: Icons.lock_reset_outlined,
                                  isPassword: true,
                                ),
                                const SizedBox(height: 25),
                                
                                _isLoading 
                                  ? const CircularProgressIndicator(color: Color(0xFF673AB7))
                                  : ElevatedButton(
                                      onPressed: register,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF673AB7),
                                        foregroundColor: Colors.white,
                                        minimumSize: const Size(double.infinity, 55),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                        elevation: 5,
                                        shadowColor: const Color(0xFF673AB7).withOpacity(0.4),
                                      ),
                                      child: const Text("Register Now", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
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
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.black45),
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