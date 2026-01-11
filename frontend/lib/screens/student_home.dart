// ignore_for_file: unused_import, use_build_context_synchronously, deprecated_member_use
import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import '../globals.dart' as globals;

class StudentHome extends StatefulWidget {
  const StudentHome({super.key});

  @override
  State<StudentHome> createState() => _StudentHomeState();
}

class _StudentHomeState extends State<StudentHome> {
  int _selectedIndex = 0;

  // The pages corresponding to the bottom navigation tabs
  late final List<Widget> _pages = [
    _buildHomeTab(),
    const Center(child: Text("Student Card Content")), // Placeholder for Tab 2
    const Center(child: Text("Profile Settings Content")), // Placeholder for Tab 3
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF), // Light purple-tinted background
      body: SafeArea(
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)
          ],
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Row
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
                child: const CircleAvatar(
                  radius: 22,
                  backgroundImage: AssetImage('user.png'), // Placeholder
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),

          // 2. Glass Banner
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
                const Text(
                  "Campus\nConnect",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    height: 1.2,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                Image.asset('assets/campus_connect_logo.png', height: 60, color: Colors.white), // Use your logo
              ],
            ),
          ),
          const SizedBox(height: 40),

          // 3. Quick Actions Grid
          const Text(
            "Quick Actions",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
          ),
          const SizedBox(height: 15),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1.2,
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

  Widget _buildMenuCard(String title, IconData icon, Color color) {
    return InkWell(
      onTap: () {
        if (title == "Logout") {
           // Add logout logic here
        }
        // Add navigation for others
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))
          ],
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
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFF424242)),
            ),
          ],
        ),
      ),
    );
  }
}