// ignore_for_file: unused_import, use_build_context_synchronously, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:frontend/screens/login_page.dart';
import 'package:frontend/screens/student_attendance_page.dart';
import 'package:frontend/screens/student_courses_page.dart';
import 'package:frontend/screens/student_grades_page.dart';
import 'package:frontend/screens/student_schedule_page.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:http/http.dart' as http; // ADD THIS
import 'dart:convert'; // ADD THIS
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
  
  // 1. ADD: State variables for student data
  Map<String, dynamic>? studentProfile;
  bool isLoading = true;

  // 2. ADD: initState to fetch data when the app starts
  @override
  void initState() {
    super.initState();
    fetchStudentData();
  }

  // 3. ADD: Fetch function
  Future<void> fetchStudentData() async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/student/profile'),
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
  // Clear the global token
  globals.userToken = "";
  
  // Navigate back to Login and clear history
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => const LoginPage()),
    (route) => false,
  );
}

  // 4. UPDATE: Modify _pages to pass data to the tabs
  List<Widget> _getPages() {
    return [
      _buildHomeTab(),
      StudentCardTab(userData: studentProfile), // Pass data here
      StudentProfileTab(
        userData: studentProfile, 
        onRefresh: fetchStudentData // Allows sub-tab to trigger a refresh
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    // Show a loader while waiting for the first fetch
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF673AB7))));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      body: SafeArea(
        child: _getPages()[_selectedIndex], // Use the function here
      ),
      bottomNavigationBar: Container(
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
              title: const Text("Home"),
              selectedColor: Colors.purple,
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.badge_outlined),
              title: const Text("Card"),
              selectedColor: Colors.deepPurple,
            ),
            SalomonBottomBarItem(
              icon: const Icon(Icons.person_outline_rounded),
              title: const Text("Profile"),
              selectedColor: Colors.indigo,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    // Use dynamic name from database
    String studentName = studentProfile?['name'] ?? "Student";
    String? profilePic = studentProfile?['profile_picture'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Student Dashboard",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF311B92)),
              ),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF673AB7), width: 2),
                ),
                child: CircleAvatar(
                  radius: 22,
                  // If there's an uploaded pic, show it; otherwise use default
                  backgroundImage: profilePic != null 
                    ? NetworkImage('http://127.0.0.1:8000/storage/$profilePic') as ImageProvider
                    : const AssetImage('assets/user.png'), 
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          
          // ... rest of your UI code (Glass Banner, GridView, etc.) ...
          // Ensure you keep the same _buildMenuCard and UI elements below
          
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [const Color(0xFF673AB7).withOpacity(0.8), const Color(0xFF9575CD).withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF673AB7).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Welcome back,\n$studentName", // Showing dynamic name
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    height: 1.2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Image.asset('assets/campus_connect_logo.png', height: 60, color: Colors.white),
              ],
            ),
          ),
          const SizedBox(height: 40),
          const Text("Quick Actions", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey)),
          const SizedBox(height: 15),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 1.2,
            children: [
              _buildMenuCard("Group Schedule", Icons.calendar_today_rounded, Colors.blue),
              _buildMenuCard("Grades", Icons.analytics_outlined, Colors.orange),
              _buildMenuCard("Attendance", Icons.fact_check_outlined, Colors.green),
              _buildMenuCard("Courses", Icons.book_online_rounded, Colors.red),
              _buildMenuCard("Messages", Icons.chat_bubble_outline_rounded, Colors.teal),
              _buildMenuCard("Logout", Icons.logout_rounded, Colors.blueGrey),
            ],
          ),
        ],
      ),
    );
  }

  // Keep your existing _buildMenuCard method here...
  Widget _buildMenuCard(String title, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        if (title == "Logout") {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text("Logout"),
              content: const Text("Are you sure you want to exit?"),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                TextButton(
                  onPressed: ()  => _handleLogout(context),
                  child: const Text("Logout", style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          );
        } else if (title == "Group Schedule") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StudentSchedulePage(
                schedulePath: studentProfile?['schedule_image'],
              ),
            ),
          );
        } else if (title == "Grades") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StudentGradesPage(),
            ),
          );
        } else if (title == "Attendance") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StudentAttendancePage(),
            ),
          );
        } else if (title == "Courses") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const StudentCoursesPage(),
            ),
          );
        } else if (title == "Messages") {
          // Navigate to Messages Page (to be implemented)
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))],
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
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF424242))),
          ],
        ),
      ),
    );
  }
}