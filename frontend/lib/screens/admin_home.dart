// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; 
import 'package:frontend/screens/assign_groups_page.dart';
import 'package:frontend/screens/login_page.dart';
import 'package:frontend/screens/upload_schedule_page.dart';
import 'package:frontend/screens/manage_courses.dart';
import 'manage_students_page.dart';
import 'pending_registrations.dart';

class AdminHome extends StatelessWidget {
  const AdminHome({super.key});

  Future<void> _handleLogout(BuildContext context) async {
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
      appBar: AppBar(
        title: Text(
          "Control Center", 
          style: GoogleFonts.poppins(color: const Color(0xFF311B92), fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 15),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () => _handleLogout(context),
              icon: const Icon(Icons.power_settings_new, color: Colors.redAccent),
            ),
          )
        ],
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(25, 10, 25, 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome back,",
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.black45),
                  ),
                  Text(
                    "Administrator",
                    style: GoogleFonts.poppins(
                      fontSize: 28, 
                      fontWeight: FontWeight.bold, 
                      color: const Color(0xFF311B92)
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 4,
                    width: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF673AB7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 18,
                mainAxisSpacing: 18,
                childAspectRatio: 0.95, 
              ),
              delegate: SliverChildListDelegate([
                _buildMenuCard(
                  context, 
                  "Validate\nStudents", 
                  Icons.verified_user_outlined, 
                  const Color(0xFFE8EAF6), 
                  const Color(0xFF3F51B5),
                  const PendingRegistrations(),
                ),
                _buildMenuCard(
                  context, 
                  "Assign\nGroups", 
                  Icons.group_work_outlined, 
                  const Color(0xFFFFF3E0), 
                  const Color(0xFFFF9800),
                  const AssignGroupsPage(),
                ),
                _buildMenuCard(
                  context, 
                  "Manage\nStudents", 
                  Icons.badge_outlined, 
                  const Color(0xFFF3E5F5), 
                  const Color(0xFF9C27B0),
                  const ManageStudentsPage(),
                ),
                _buildMenuCard(
                  context, 
                  "Schedules", 
                  Icons.calendar_today_outlined, 
                  const Color(0xFFE1F5FE), 
                  const Color(0xFF03A9F4),
                  const UploadSchedulePage(),
                ),
                _buildMenuCard(
                  context, 
                  "Courses", 
                  Icons.library_books_outlined, 
                  const Color(0xFFE8F5E9), 
                  const Color(0xFF4CAF50),
                  const ManageCoursesPage(),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, 
    String title, 
    IconData icon, 
    Color bgColor, 
    Color iconColor,
    Widget destination
  ) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => destination)),
      borderRadius: BorderRadius.circular(25),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: iconColor, size: 28),
            ),
            const Spacer(),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.black87,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 5),
            Icon(Icons.arrow_forward, color: Colors.black12, size: 18),
          ],
        ),
      ),
    );
  }
}