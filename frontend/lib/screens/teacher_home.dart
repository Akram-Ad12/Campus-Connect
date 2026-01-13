// ignore_for_file: avoid_print, use_build_context_synchronously, library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:frontend/screens/attendance_page.dart';
import 'package:frontend/screens/course_details_page.dart';
import 'package:frontend/screens/group_details_page.dart';
import 'package:frontend/screens/login_page.dart';
import 'package:frontend/screens/mark_students_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../globals.dart' as globals;

class TeacherHome extends StatefulWidget {
  const TeacherHome({super.key});

  @override
  _TeacherHomeState createState() => _TeacherHomeState();
}

class _TeacherHomeState extends State<TeacherHome> {
  String teacherName = "Loading...";
  List<dynamic> assignedCourses = [];
  List<dynamic> assignedGroups = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTeacherDashboard();
  }

  Future<void> fetchTeacherDashboard() async {
    try {
      final response = await http.get(
        Uri.parse('http://${globals.serverIP}:8000/api/teacher/dashboard'),
        headers: {
          'Authorization': 'Bearer ${globals.userToken}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> rawCourses = data['courses'] ?? [];
        List<dynamic> rawGroups = data['groups'] ?? [];

        setState(() {
          teacherName = data['name'];
          assignedCourses = rawCourses;
          assignedGroups = rawGroups.map((g) {
            return {
              'group_name': g.toString(),
              'course_name': rawCourses.isNotEmpty ? rawCourses[0].toString() : "N/A",
            };
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          teacherName = "Error Loading Data";
          isLoading = false;
        });
      }
    } catch (e) {
      print("Connection Error: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    globals.userToken = "";
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF673AB7)))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTransitionHeader(),
                  const SizedBox(height: 25),
                  _buildSectionTitle("Quick Actions"),
                  const SizedBox(height: 15),
                  _buildQuickActionRow(),
                  const SizedBox(height: 35),
                  _buildSectionTitle("Your Assigned Courses"),
                  ...assignedCourses.map((c) => _buildInteractiveTile(
                        title: c.toString(),
                        subtitle: "Manage materials & content",
                        icon: Icons.auto_stories_outlined,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => CourseDetailsPage(courseName: c.toString(), isTeacher: true))),
                      )),
                  const SizedBox(height: 25),
                  _buildSectionTitle("Your Assigned Groups"),
                  ...assignedGroups.map((group) => _buildInteractiveTile(
                        title: group['group_name']!,
                        subtitle: "View student list & progress",
                        icon: Icons.groups_outlined,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => GroupDetailsPage(groupName: group['group_name']!, courseName: group['course_name']!))),
                      )),
                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildTransitionHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFEBE7FF), 
            Color(0xFFF8F9FD), 
          ],
        ),
      ),
      padding: const EdgeInsets.only(top: 60, bottom: 10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: Row(
          children: [
            Container(
              height: 80,
              width: 80,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF673AB7).withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 8))
                ],
              ),
              child: Image.asset(
                'assets/campus_connect_logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.school_outlined, color: Color(0xFF673AB7), size: 35),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Hello,", style: GoogleFonts.poppins(color: Colors.black45, fontSize: 15, fontWeight: FontWeight.w500)),
                  Text(teacherName, style: GoogleFonts.poppins(color: const Color(0xFF1A1A1A), fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.verified_outlined, color: Color(0xFF673AB7), size: 14),
                      const SizedBox(width: 4),
                      Text("Teacher's Account", style: GoogleFonts.poppins(color: const Color(0xFF673AB7), fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCompactAction(Icons.assignment_ind_outlined, "Attendance", const Color(0xFFFF9800), () => Navigator.push(context, MaterialPageRoute(builder: (context) => AttendancePage(courses: assignedCourses, groups: assignedGroups)))),
          _buildCompactAction(Icons.grade, "Grades", const Color(0xFF2196F3), () => Navigator.push(context, MaterialPageRoute(builder: (context) => MarkStudentsPage(courses: assignedCourses, groups: assignedGroups)))),
          _buildCompactAction(Icons.chat_bubble_outline_rounded, "Messages", const Color(0xFF9C27B0), () {}),
          _buildCompactAction(Icons.logout, "Logout", const Color(0xFFF44336),  ( ) {}, isLogout: true),
        ],
      ),
    );
  }

  Widget _buildCompactAction(IconData icon, String label, Color color, VoidCallback onTap, {bool isLogout = false}) {
    return GestureDetector(
      onTap: isLogout ? () => _handleLogout(context) : onTap,
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: color.withOpacity(0.06),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.12), width: 1.2),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.black54)),
        ],
      ),
    );
  }

  Widget _buildInteractiveTile({required String title, required String subtitle, required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF673AB7).withOpacity(0.05),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: const Color(0xFF673AB7), size: 22),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF2D3436))),
                  Text(subtitle, style: GoogleFonts.poppins(fontSize: 11, color: Colors.black38)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.black12, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Text(
        title,
        style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF1A1A1A)),
      ),
    );
  }
}