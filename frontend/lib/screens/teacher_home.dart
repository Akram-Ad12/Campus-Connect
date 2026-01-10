// ignore_for_file: deprecated_member_use, unused_import, library_private_types_in_public_api
import 'package:flutter/material.dart';
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
      Uri.parse('http://127.0.0.1:8000/api/teacher/dashboard'),
      headers: {
        'Authorization': 'Bearer ${globals.userToken}',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
  final data = jsonDecode(response.body);
  
  // 1. Get the lists from the response
  List<dynamic> rawCourses = data['courses'] ?? [];
  List<dynamic> rawGroups = data['groups'] ?? [];

  setState(() {
    teacherName = data['name'];
    assignedCourses = rawCourses;

    // 2. TRANSFORM the strings into Maps so group['group_name'] works!
    assignedGroups = rawGroups.map((g) {
      return {
        'group_name': g.toString(), // Turns "L3 Group 1" into the 'group_name' key
        'course_name': rawCourses.isNotEmpty ? rawCourses[0].toString() : "N/A",
      };
    }).toList();
    
    isLoading = false;
  });
} else {
      // Print the actual error from Laravel
      print("Server Error Detail: ${response.body}"); 
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
  // Clear the global token
  globals.userToken = "";
  
  // Navigate back to Login and clear history
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
                  // 1. Header with Name and Logo
                  _buildHeader(),
                  
                  // 2. Quick Actions Bar (Includes Logout)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: SizedBox(
                      height: 110,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        children: [
                          _buildQuickAction(Icons.how_to_reg, "Attendance", Colors.orange, () => Navigator.push(context, MaterialPageRoute(builder: (context) => AttendancePage(courses: assignedCourses, groups: assignedGroups))) ),
                          _buildQuickAction(Icons.grade, "Mark Students", Colors.blue, () => Navigator.push(context, MaterialPageRoute(builder: (context) => MarkStudentsPage(courses: assignedCourses, groups: assignedGroups)))),
                          _buildQuickAction(Icons.message, "Messages", Colors.purple, () {}),
                          _buildQuickAction(Icons.logout, "Logout", Colors.red, () => _handleLogout(context)),
                        ],
                      ),
                    ),
                  ),

// 3. Your Assigned Courses Section
                  _buildSectionTitle("Your Assigned Courses"),
                  assignedCourses.isEmpty 
                    ? _buildEmptyState("No courses assigned yet")
                    : Column(
                        children: assignedCourses.map((c) {
                          String courseName = c.toString();
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CourseDetailsPage(
                                    courseName: courseName,
                                    isTeacher: true, // We will set this to false for the Student dashboard later
                                  ),
                                ),
                              );
                            },
                            child: _buildSimpleTile(courseName, Icons.book),
                          );
                        }).toList(),
                      ),

                  const SizedBox(height: 10),

                 // 4. Your Assigned Groups Section
_buildSectionTitle("Your Assigned Groups"),
assignedGroups.isEmpty 
    ? _buildEmptyState("No groups assigned yet")
    : Column(
        children: assignedGroups.map((group) {
          final String gName = group['group_name']?.toString() ?? "Unknown Group";
          final String cName = group['course_name']?.toString() ?? "No Course";
          
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupDetailsPage(
                    groupName: gName,
                    courseName: cName,
                  ),
                ),
              );
            },
            // CHANGE THIS LINE BELOW:
            child: _buildSimpleTile(gName, Icons.group), // Removed ($cName)
          );
        }).toList(),
      ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.only(top: 60, left: 25, right: 25, bottom: 30),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF673AB7), Color(0xFF9575CD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Welcome back,", style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16)),
              const SizedBox(height: 5),
              Text(teacherName, 
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          // App Logo replacement
          Image.asset('assets/campus_connect_logo.png', height: 125, errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.school, color: Colors.white, size: 40); 
          }),
        ],
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 90,
        margin: const EdgeInsets.only(right: 15),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Text(title, 
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
    );
  }

  Widget _buildSimpleTile(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF673AB7).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF673AB7), size: 22),
          ),
          const SizedBox(width: 15),
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
          const Spacer(),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      child: Text(message, style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),
    );
  }
}