// ignore_for_file: unused_import, use_build_context_synchronously, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; 
import 'package:frontend/screens/login_page.dart';
import 'package:frontend/screens/student_attendance_page.dart';
import 'package:frontend/screens/student_courses_page.dart';
import 'package:frontend/screens/student_grades_page.dart';
import 'package:frontend/screens/student_schedule_page.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../globals.dart' as globals;
import 'student_profile_tab.dart';
import 'student_card_tab.dart';

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  int _selectedIndex = 0;
  Map<String, dynamic>? studentProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchStudentData();
  }

  Future<void> fetchStudentData() async {
    try {
      final response = await http.get(
        Uri.parse('http://${globals.serverIP}:8000/api/student/profile'),
        headers: {
          'Authorization': 'Bearer ${globals.userToken}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          studentProfile = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching student data: $e");
      setState(() { isLoading = false; });
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

  List<Widget> _getPages() {
    return [
      _buildHomeTab(),
      StudentCardTab(userData: studentProfile),
      StudentProfileTab(
        userData: studentProfile, 
        onRefresh: fetchStudentData
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF673AB7))));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      body: SafeArea( 
        child: _getPages()[_selectedIndex],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
          ),
          child: SalomonBottomBar(
            currentIndex: _selectedIndex,
            selectedItemColor: const Color(0xFF673AB7),
            unselectedItemColor: const Color(0xFF757575),
            onTap: (index) => setState(() => _selectedIndex = index),
            items: [
              SalomonBottomBarItem(
                icon: const Icon(Icons.grid_view_rounded),
                title: Text("Home", style: GoogleFonts.poppins()),
                selectedColor: Colors.purple,
              ),
              SalomonBottomBarItem(
                icon: const Icon(Icons.badge_rounded),
                title: Text("Card", style: GoogleFonts.poppins()),
                selectedColor: Colors.deepPurple,
              ),
              SalomonBottomBarItem(
                icon: const Icon(Icons.person_rounded),
                title: Text("Profile", style: GoogleFonts.poppins()),
                selectedColor: Colors.indigo,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    String studentName = studentProfile?['name'] ?? "Student";
    String? profilePic = studentProfile?['profile_picture'];

    return RefreshIndicator(
      onRefresh: fetchStudentData,
      color: const Color(0xFF673AB7),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("CampusConnect", 
                      style: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.bold, color: const Color(0xFF673AB7), letterSpacing: 1.2)),
                    Text("Student Dashboard", 
                      style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A1A))),
                  ],
                ),
                Hero(
                  tag: 'profile_pic',
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: const Color(0xFF673AB7),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundImage: profilePic != null 
                        ? NetworkImage('http://${globals.serverIP}:8000/storage/$profilePic') as ImageProvider
                        : const AssetImage('assets/user.png'), 
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 30),
            
            // Welcome Card with Faded Logo Background
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF673AB7), Color(0xFF8E24AA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF673AB7).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))
                  ],
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Opacity(
                        opacity: 0.8,
                        child: Image.asset(
                          'assets/campus_connect_logo2.png', 
                          height: 100, 
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Welcome back,", style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 5),
                        Text(studentName, 
                          style: GoogleFonts.poppins(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                          child: Text("Active Student", style: GoogleFonts.poppins(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 35),
            Text("Quick Actions", style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black45, letterSpacing: 0.5)),
            const SizedBox(height: 15),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2, 
              crossAxisSpacing: 15, 
              mainAxisSpacing: 15, 
              childAspectRatio: 1.1,
              children: [
                _buildMenuCard("Schedule", Icons.calendar_today_rounded, const Color(0xFF5C6BC0)),
                _buildMenuCard("Grades", Icons.analytics_outlined, const Color(0xFFFF9800)),
                _buildMenuCard("Attendance", Icons.assignment_turned_in_rounded, const Color(0xFF4CAF50)),
                _buildMenuCard("Courses", Icons.library_books_rounded, const Color(0xFFEC407A)),
                _buildMenuCard("Messages", Icons.forum_rounded, const Color(0xFF26A69A)),
                _buildMenuCard("Logout", Icons.logout, const Color(0xFF78909C)),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(String title, IconData icon, Color color) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          if (title == "Logout") {
            _showLogoutDialog();
          } else {
            if (title == "Schedule") {
              Navigator.push(context, MaterialPageRoute(builder: (context) => StudentSchedulePage(schedulePath: studentProfile?['schedule_image'])));
            } else if (title == "Grades") {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const StudentGradesPage()));
            } else if (title == "Attendance") {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const StudentAttendancePage()));
            } else if (title == "Courses") {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const StudentCoursesPage()));
            }
          }
        },
        borderRadius: BorderRadius.circular(22),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.black.withOpacity(0.03)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: const Color(0xFF455A64))),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("Logout", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to sign out?", style: GoogleFonts.poppins()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text("Stay", style: GoogleFonts.poppins(color: Colors.grey))),
          TextButton(onPressed: () => _handleLogout(context), child: Text("Logout", style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}